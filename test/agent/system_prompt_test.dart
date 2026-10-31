import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/agent/system_prompt.dart';

void main() {
  test('the prompt says proposals need the athlete to tap Apply', () {
    expect(trainingAgentSystemPrompt, contains('Proposals are not changes'));
    expect(trainingAgentSystemPrompt, contains('taps Apply'));
    expect(trainingAgentSystemPrompt, contains('Never say a proposal is'));
    for (final tool in [
      'get_training_plan',
      'propose_load_curve',
      'propose_session_change',
      'generate_training_plan',
    ]) {
      expect(trainingAgentSystemPrompt, contains('`$tool`'), reason: tool);
    }
  });
}
