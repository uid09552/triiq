/// The label on text an AI model wrote that leaves the chat: session
/// descriptions sent to Intervals.icu, the weekly-review sentence. The EU
/// AI Act (Art. 50, applies from 2 Aug 2026) asks that AI-generated text be
/// recognisable as such; whether it binds a hobby open-source app is open,
/// but labelling costs nothing. The chat itself shows which model answered.
const aiWrittenNote = 'AI-written (TriIQ). Check it before you train.';

/// [text] with [aiWrittenNote] as its last line, once.
String withAiLabel(String text) {
  final t = text.trimRight();
  if (t.endsWith(aiWrittenNote)) return t;
  return t.isEmpty ? aiWrittenNote : '$t\n\n$aiWrittenNote';
}
