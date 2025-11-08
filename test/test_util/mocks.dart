import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart';
import 'package:med_parser/features/onboarding/data/onboarding_repository.dart';
import 'package:med_parser/features/onboarding/presentation/onboarding_controller.dart';
import 'package:med_parser/features/speech_to_text/presentation/speech_to_text_controller.dart';
import 'package:med_parser/features/speech_to_text/data/speech_to_text_repository.dart';
import 'package:med_parser/features/speech_to_text/domain/speech_to_text_state.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockOnboardingRepository extends Mock implements OnboardingRepository {}

class MockOnboardingController extends AutoDisposeAsyncNotifier<void>
    with Mock
    implements OnboardingController {
  AsyncValue<void> mockInitialState = const AsyncData(null);

  // This method will be mocked using Mocktail's `when`
  @override
  Future<void> completeOnboarding() {
    return super.noSuchMethod(
      Invocation.method(#completeOnboarding, null),
    );
  }

  void setMockState(AsyncValue<void> newState) {
    state = newState;
  }
}

class MockSpeechToTextRepository extends Mock
    implements SpeechToTextRepository {}

class MockAudioRecorder extends Mock implements AudioRecorder {}

class MockOnlineRecognizer extends Mock implements OnlineRecognizer {}

class MockOnlineStream extends Mock implements OnlineStream {}

class MockSpeechToTextController extends StateNotifier<SpeechToTextState>
    with Mock
    implements SpeechToTextController {
  MockSpeechToTextController(super.state);

  void setInitialState(SpeechToTextState newState) {
    state = newState;
  }

  @override
  Future<void> startListening() {
    return super.noSuchMethod(
      Invocation.method(#startListening, []),
    ) as Future<void>;
  }

  @override
  Future<void> stopListening() {
    return super.noSuchMethod(
      Invocation.method(#stopListening, []),
    ) as Future<void>;
  }

  SpeechToTextState get currentState => state;
}
