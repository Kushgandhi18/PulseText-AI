import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import 'package:med_parser/features/speech_to_text/data/speech_to_text_repository.dart';
import 'package:med_parser/features/speech_to_text/domain/speech_to_text_result.dart';
import 'package:med_parser/features/speech_to_text/domain/speech_to_text_state.dart';

class SpeechToTextController extends StateNotifier<SpeechToTextState> {
  final SpeechToTextRepository _repository;
  StreamSubscription<SpeectToTextResult>? _speechSubscription;

  String _accumulatedFinalText = '';
  String _currentPartialText = '';
  int _segmentIndex = 0;

  SpeechToTextController(this._repository) : super(SpeechToTextState());
  Future<void> startListening() async {
    if (state.isListening) return;

    _accumulatedFinalText = '';
    _currentPartialText = '';
    _segmentIndex = 0;
    state = state.copyWith(
        isListening: true, displayedText: 'Listening...', clearError: true);

    _speechSubscription?.cancel();
    try {
      _speechSubscription = _repository.startRecognition().listen(
        (result) {
          if (!state.isListening) return;

          // Two possible cases:
          // 1. The result is final (the user has stopped speaking):
          //    - The app will accumulate the text and display it
          //    (e.g., User says "Hello", then "World" -> Text will be 'World' and _accumulatedFinalText will be 'Hello')
          // 2. The result is partial (the user is still speaking)
          //  - The app will display the current partial text (e.g.,
          //    User says "Hello world! I made it here" -> The app will display the text partially as the user speaks.
          if (result.isFinal) {
            final text = result.text;
            if (text.isNotEmpty) {
              _accumulatedFinalText = _accumulatedFinalText.isEmpty
                  ? '${_segmentIndex++}: $text'
                  : '${_segmentIndex++}: $text\n$_accumulatedFinalText';
            }
            _currentPartialText = '';
          } else {
            _currentPartialText = result.text;
          }

          final display = _currentPartialText.isEmpty
              ? _accumulatedFinalText
              : '$_segmentIndex: $_currentPartialText \n$_accumulatedFinalText';

          state = state.copyWith(displayedText: display);
        },
        onError: (e, stackTrace) {
          state = state.copyWith(
            error: 'Error: $e',
            isListening: false,
            displayedText: _accumulatedFinalText.isEmpty
                ? 'Error occurred'
                : '$_accumulatedFinalText\nError occurred',
          );
        },
        onDone: () {
          if (state.isListening) {
            state = state.copyWith(
                isListening: false, displayedText: "Tap 'Start' to speak");
          }
        },
      );
    } catch (e) {
      state = state.copyWith(
          error: 'Failed to start: $e',
          isListening: false,
          displayedText: 'Error starting');
    }
  }

  Future<void> stopListening() async {
    if (!state.isListening && _speechSubscription == null) return;

    await _speechSubscription?.cancel();
    _speechSubscription = null;
    await _repository.stopRecognition();
    state = state.copyWith(
        isListening: false, displayedText: "Tap 'Start' to speak");
  }

  @override
  void dispose() {
    _speechSubscription?.cancel();
    super.dispose();
  }
}

final speechToTextRepositoryProvider = Provider<SpeechToTextRepository>((ref) {
  final repo = SpeechToTextRepository(
    audioRecorder: AudioRecorder(),
    recognizerFactory: SpeechToTextRepository.defaultOnlineRecognizerFactory,
  );
  ref.onDispose(() => repo.dispose());
  return repo;
});

final speechToTextControllerProvider = StateNotifierProvider.autoDispose<
    SpeechToTextController, SpeechToTextState>((ref) {
  final repository = ref.watch(speechToTextRepositoryProvider);
  return SpeechToTextController(repository);
});
