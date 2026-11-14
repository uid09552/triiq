import 'dart:math' as math;

/// What a destination can be found by. Each field is a list of phrases
/// (English and German both), weighted by how much a hit there says.
class SearchDocument {
  SearchDocument({
    required List<String> titles,
    List<String> keywords = const [],
    List<String> path = const [],
    List<String> descriptions = const [],
    String okfText = '',
  }) : _fields = [
         _Field(titles, 10, fuzzy: true),
         _Field(keywords, 7, fuzzy: true),
         _Field(path, 3, fuzzy: true),
         _Field(descriptions, 3, fuzzy: false),
         _Field([okfText], 1, fuzzy: false),
       ],
       _titlePhrases = [for (final t in titles) normalizeSearchText(t)];

  final List<_Field> _fields;
  final List<String> _titlePhrases;

  /// How well [query] matches, 0 for not at all. At least half of the
  /// query's meaningful words have to match something.
  double score(String query) {
    final terms = searchTerms(query);
    if (terms.isEmpty) return 0;
    var total = 0.0;
    var matched = 0;
    for (final term in terms) {
      var best = 0.0;
      for (final field in _fields) {
        best = math.max(best, field.score(term));
      }
      if (best > 0) matched++;
      total += best;
    }
    if (matched * 2 < terms.length) return 0;
    final phrase = normalizeSearchText(query);
    if (phrase.length > 2 && _titlePhrases.any((t) => t.contains(phrase))) {
      total += 5;
    }
    return total * matched / terms.length;
  }
}

class _Field {
  _Field(List<String> phrases, this.weight, {required this.fuzzy})
    : tokens = {for (final p in phrases) ..._tokens(normalizeSearchText(p))};

  final Set<String> tokens;
  final double weight;
  final bool fuzzy;

  double score(String term) {
    if (tokens.contains(term)) return weight;
    var best = 0.0;
    for (final token in tokens) {
      final s = _match(term, token);
      if (s > best) best = s;
      if (best >= 0.85) break;
    }
    return best * weight;
  }

  double _match(String term, String token) {
    if (term.length >= 2 && token.startsWith(term)) return 0.85;
    if (!fuzzy) return 0;
    // A plural or a compound part: "notification" ↔ "notifications",
    // "ziele" inside "wochenziele".
    if (token.length >= 4 && term.startsWith(token)) return 0.7;
    if (term.length >= 4 && token.contains(term)) return 0.6;
    final allowed = term.length >= 8 ? 2 : (term.length >= 5 ? 1 : 0);
    if (allowed == 0 || (term.length - token.length).abs() > allowed) {
      return 0;
    }
    return _distance(term, token, allowed) <= allowed ? 0.55 : 0;
  }
}

/// Lowercased, umlauts and accents folded (ä → a, ß → ss), anything that
/// isn't a letter or digit turned into a space — so "Müdigkeit",
/// "mudigkeit" and "MÜDIGKEIT" are one word.
String normalizeSearchText(String text) {
  final lower = text.toLowerCase();
  final out = StringBuffer();
  for (final rune in lower.runes) {
    final c = String.fromCharCode(rune);
    final folded = _fold[c];
    if (folded != null) {
      out.write(folded);
    } else if (RegExp(r'[a-z0-9]').hasMatch(c)) {
      out.write(c);
    } else {
      out.write(' ');
    }
  }
  return out.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
}

const _fold = {
  'ä': 'a',
  'ö': 'o',
  'ü': 'u',
  'ß': 'ss',
  'é': 'e',
  'è': 'e',
  'ê': 'e',
  'à': 'a',
  'á': 'a',
  'â': 'a',
  'ô': 'o',
  'ó': 'o',
  'í': 'i',
  'ú': 'u',
  'ñ': 'n',
  'ç': 'c',
  '′': '',
  "'": '',
};

Iterable<String> _tokens(String normalized) =>
    normalized.split(' ').where((t) => t.isNotEmpty);

/// The words of [query] worth matching: normalized, without the filler of
/// a "how do I … / where is …" question in either language. A query of
/// nothing but filler keeps its words.
List<String> searchTerms(String query) {
  final all = _tokens(normalizeSearchText(query)).toList();
  final meaningful = [
    for (final t in all)
      if (!_stopWords.contains(t)) t,
  ];
  return meaningful.isEmpty ? all : meaningful;
}

const _stopWords = {
  // English
  'a', 'an', 'the', 'i', 'me', 'my', 'how', 'do', 'does', 'can', 'where',
  'is', 'are', 'what', 'which', 'to', 'of', 'in', 'on', 'for', 'and', 'or',
  'find', 'open', 'show', 'see', 'get', 'go', 'set', 'change', 'turn',
  'app', 'page', 'screen', 'setting', 'settings', 'it', 'with', 'there',
  // German
  'wie', 'wo', 'ist', 'sind', 'ich', 'mein', 'meine', 'meinen', 'der',
  'die', 'das', 'den', 'dem', 'ein', 'eine', 'einen', 'kann', 'finde',
  'zu', 'im', 'am', 'auf', 'fur', 'und', 'oder', 'was', 'welche', 'offnen',
  'zeigen', 'andern', 'stelle', 'einstellen', 'seite', 'einstellungen',
  'es', 'mit', 'gibt',
};

/// Optimal string alignment distance, giving up past [limit].
int _distance(String a, String b, int limit) {
  final rows = a.length + 1, cols = b.length + 1;
  final d = List.generate(rows, (i) => List<int>.filled(cols, 0));
  for (var i = 0; i < rows; i++) {
    d[i][0] = i;
  }
  for (var j = 0; j < cols; j++) {
    d[0][j] = j;
  }
  for (var i = 1; i < rows; i++) {
    var rowMin = 1 << 30;
    for (var j = 1; j < cols; j++) {
      final cost = a[i - 1] == b[j - 1] ? 0 : 1;
      var v = math.min(
        math.min(d[i - 1][j] + 1, d[i][j - 1] + 1),
        d[i - 1][j - 1] + cost,
      );
      if (i > 1 && j > 1 && a[i - 1] == b[j - 2] && a[i - 2] == b[j - 1]) {
        v = math.min(v, d[i - 2][j - 2] + 1);
      }
      d[i][j] = v;
      if (v < rowMin) rowMin = v;
    }
    if (rowMin > limit) return rowMin;
  }
  return d[a.length][b.length];
}
