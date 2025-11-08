import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_parser/constants/app_sizes.dart';
import 'package:med_parser/features/speech_to_text/presentation/speech_to_text_controller.dart';
import 'package:med_parser/features/speech_to_text/domain/speech_to_text_state.dart';
import 'package:med_parser/l10n/generated/app_localizations.dart/app_localizations.dart';
import 'package:med_parser/utils/number_extension.dart';

class SpeechToTextScreen extends ConsumerWidget {
  const SpeechToTextScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speechToTextController =
        ref.read(speechToTextControllerProvider.notifier);
    final state = ref.watch(speechToTextControllerProvider);
    final l10n = AppLocalizations.of(context);

    final textEditingController =
        TextEditingController(text: state.displayedText);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.speechToTextAppBarTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(Sizes.spacingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (state.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: Sizes.spacingS),
                child: Text(
                  state.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            Expanded(
              child: TextField(
                controller: textEditingController,
                readOnly: true,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Sizes.spacingS),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  hintText: l10n.speechToTextHint,
                ),
              ),
            ),
            const SizedBox(height: Sizes.spacingL),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildRecordControl(context, state, speechToTextController),
                Sizes.spacingS.wSpace,
                Text(state.isListening ? l10n.listening : l10n.tapToStart,
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordControl(BuildContext context, SpeechToTextState state,
      SpeechToTextController controller) {
    late Icon icon;
    late Color color;
    final theme = Theme.of(context);

    if (state.isListening) {
      icon = const Icon(Icons.stop, color: Colors.red, size: 30);
      color = Colors.red.withValues(alpha: 0.1);
    } else {
      icon = Icon(Icons.mic, size: 30);
      color = theme.primaryColor.withValues(alpha: 0.1);
    }

    return ClipOval(
      child: Material(
        color: color,
        child: InkWell(
          child: SizedBox(width: 56, height: 56, child: icon),
          onTap: () {
            if (state.isListening) {
              controller.stopListening();
            } else {
              controller.startListening();
            }
          },
        ),
      ),
    );
  }
}
