import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../plan/proposal_safety.dart' show RedFlag;
import 'plan_proposals.dart';
import 'training_agent.dart' show AgentReplyBuffer;
import 'usage.dart';

/// One message of the chat: what the athlete asked or what the trainer
/// answered, with what the answer was made of. Saved with the chat
/// ([ChatStore]) so a restart does not lose the conversation.
class TranscriptMessage {
  TranscriptMessage({
    required this.fromUser,
    this.text = '',
    this.isError = false,
  });

  /// Grows as the model streams, so this is the one mutable field.
  String text;
  final bool fromUser;
  final bool isError;

  /// Changes the agent proposed during this reply, shown as cards under it.
  final proposals = <PlanProposal>[];

  /// App pages the agent offered to open (`open_app_page`), as buttons.
  final navigations = <String>[];

  /// The reply as streamed, minus any failed attempt's partial text. Not
  /// saved: a reply is only saved once it is finished.
  final buffer = AgentReplyBuffer();

  /// "Switched to … — … unreachable" notes, in order.
  final switchNotes = <String>[];

  /// The model entry that gave this reply (shown as a chip under it).
  String? answeredBy;

  /// The tools the agent ran for this reply, once each, in order: what the
  /// answer is *based on*.
  final toolsUsed = <String>[];

  /// What the reply cost in tokens, once the turn ended normally.
  TurnUsage? usage;

  /// When the local data the answer read was last synced.
  DateTime? dataAsOf;

  /// The athlete stopped the reply before it was finished.
  bool stopped = false;

  /// Set on a safety message (no text): the signs in the athlete's words
  /// that call for a doctor. Shown as a card under their message.
  final redFlags = <RedFlag>[];

  Map<String, dynamic> toJson() => {
    'fromUser': fromUser,
    'text': text,
    'isError': isError,
    'answeredBy': answeredBy,
    'switchNotes': switchNotes,
    'navigations': navigations,
    'tools': toolsUsed,
    'usage': usage?.toJson(),
    'dataAsOf': dataAsOf?.toIso8601String(),
    'stopped': stopped,
    'redFlags': [for (final f in redFlags) f.name],
    'proposals': [for (final p in proposals) ?proposalToJson(p)],
  };

  /// Reads a saved message; its proposals are registered with [proposals]
  /// (new ids, same state).
  static TranscriptMessage? fromJson(Object? json, PlanProposals proposals) {
    if (json is! Map) return null;
    final fromUser = json['fromUser'], text = json['text'];
    if (fromUser is! bool || text is! String) return null;
    final m = TranscriptMessage(
      fromUser: fromUser,
      text: text,
      isError: json['isError'] == true,
    );
    m.answeredBy = json['answeredBy'] as String?;
    m.switchNotes.addAll([
      for (final n in json['switchNotes'] as List? ?? const []) '$n',
    ]);
    m.navigations.addAll([
      for (final n in json['navigations'] as List? ?? const []) '$n',
    ]);
    m.toolsUsed.addAll([
      for (final n in json['tools'] as List? ?? const []) '$n',
    ]);
    m.usage = TurnUsage.fromJson(json['usage']);
    final asOf = json['dataAsOf'];
    m.dataAsOf = asOf is String ? DateTime.tryParse(asOf) : null;
    m.stopped = json['stopped'] == true;
    for (final n in json['redFlags'] as List? ?? const []) {
      final flag = RedFlag.values.asNameMap()['$n'];
      if (flag != null) m.redFlags.add(flag);
    }
    m.buffer.text = text;
    for (final raw in json['proposals'] as List? ?? const []) {
      final p = proposalFromJson(raw);
      if (p != null) m.proposals.add(proposals.restore(p));
    }
    return m;
  }
}

/// The chat, kept on the device (shared preferences; never part of a
/// backup or an export, and gone with "erase all data"), so the
/// conversation and any proposal not yet applied survive the app being
/// closed or killed.
class ChatStore {
  ChatStore();

  static const prefsKey = 'chat.transcript';

  /// Only the newest messages are kept: the model's own context is capped
  /// too (see `TrainingAgent.maxHistoryMessages`).
  static const maxMessages = 60;

  Future<List<TranscriptMessage>> load(PlanProposals proposals) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(prefsKey);
      if (raw == null) return [];
      final json = jsonDecode(raw);
      if (json is! Map || json['messages'] is! List) return [];
      return [
        for (final m in json['messages'] as List)
          ?TranscriptMessage.fromJson(m, proposals),
      ];
    } catch (error) {
      debugPrint('ChatStore: cannot read the saved chat: $error');
      return [];
    }
  }

  Future<void> save(List<TranscriptMessage> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (messages.isEmpty) {
        await prefs.remove(prefsKey);
        return;
      }
      final keep = messages.length > maxMessages
          ? messages.sublist(messages.length - maxMessages)
          : messages;
      await prefs.setString(
        prefsKey,
        jsonEncode({
          'v': 1,
          'messages': [for (final m in keep) m.toJson()],
        }),
      );
    } catch (error) {
      debugPrint('ChatStore: cannot save the chat: $error');
    }
  }

  Future<void> clear() => save(const []);
}
