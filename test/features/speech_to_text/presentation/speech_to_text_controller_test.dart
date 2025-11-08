import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:med_parser/features/speech_to_text/presentation/speech_to_text_controller.dart';
import 'package:med_parser/features/speech_to_text/domain/speech_to_text_result.dart';

import '../../../test_util/mocks.dart';

void main() {
  late MockSpeechToTextRepository mockRepository;
  late SpeechToTextController controller;
  late StreamController<SpeectToTextResult> recognitionStreamController;

  setUp(() {
    mockRepository = MockSpeechToTextRepository();
    controller = SpeechToTextController(mockRepository);
    recognitionStreamController = StreamController<SpeectToTextResult>();

    // Default stub for startRecognition
    when(() => mockRepository.startRecognition())
        .thenAnswer((_) => recognitionStreamController.stream);
    // Default stub for stopRecognition
    when(() => mockRepository.stopRecognition()).thenAnswer((_) async {});
  });

  tearDown(() {
    controller.dispose();
    recognitionStreamController.close();
  });

  group('SpeechToTextController', () {
    test('initial state is correct', () {
      expect(controller.state.displayedText, 'Tap \'Start\' to speak');
      expect(controller.state.isListening, isFalse);
      expect(controller.state.error, isNull);
    });

    group('startListening', () {
      test('sets isListening to true and updates displayedText', () async {
        await controller.startListening();

        expect(controller.state.isListening, isTrue);
        expect(controller.state.displayedText, 'Listening...');
        verify(() => mockRepository.startRecognition()).called(1);
      });

      test(
          'updates displayedText with partial results and accumulates final results',
          () async {
        await controller.startListening();

        recognitionStreamController
            .add(const SpeectToTextResult(text: 'Hello', isFinal: false));
        await Future.delayed(Duration.zero); // Allow stream to process
        expect(controller.state.displayedText, '0: Hello \n');

        // Simulate final result
        recognitionStreamController
            .add(const SpeectToTextResult(text: 'Hello world', isFinal: true));
        await Future.delayed(Duration.zero);
        expect(controller.state.displayedText, '0: Hello world');

        // Simulate another partial result
        recognitionStreamController
            .add(const SpeectToTextResult(text: 'How', isFinal: false));
        await Future.delayed(Duration.zero);
        expect(controller.state.displayedText, '1: How \n0: Hello world');
      });

      test('handles empty final results correctly', () async {
        await controller.startListening();

        recognitionStreamController
            .add(const SpeectToTextResult(text: 'Test', isFinal: true));
        await Future.delayed(Duration.zero);
        expect(controller.state.displayedText, '0: Test');

        // Empty final result should not add a new numbered line if text is empty
        recognitionStreamController
            .add(const SpeectToTextResult(text: '', isFinal: true));
        await Future.delayed(Duration.zero);
        expect(controller.state.displayedText, '0: Test'); // Remains the same
      });

      test('handles errors from repository stream', () async {
        await controller.startListening();
        final exception = Exception('Recognition failed');
        recognitionStreamController.addError(exception);
        await Future.delayed(Duration.zero);

        expect(controller.state.isListening, isFalse);
        expect(controller.state.error, 'Error: $exception');
        expect(controller.state.displayedText, 'Error occurred');
      });

      test('handles onDone from repository stream', () async {
        await controller.startListening();
        await recognitionStreamController.close(); // Triggers onDone
        await Future.delayed(Duration.zero);

        expect(controller.state.isListening, isFalse);
        expect(controller.state.displayedText, 'Tap \'Start\' to speak');
      });

      test('handles exception during repository.startRecognition() call',
          () async {
        final exception = Exception('Failed to start repo');
        when(() => mockRepository.startRecognition())
            .thenThrow(exception); // Simulate immediate throw

        await controller.startListening();
        await Future.delayed(Duration.zero);

        expect(controller.state.isListening, isFalse);
        expect(controller.state.error, 'Failed to start: $exception');
        expect(controller.state.displayedText, 'Error starting');
      });
    });

    group('stopListening', () {
      test(
          'sets isListening to false, updates displayedText, and calls repository.stopRecognition',
          () async {
        // Start listening first to have an active subscription
        await controller.startListening();
        expect(controller.state.isListening, isTrue);

        await controller.stopListening();

        expect(controller.state.isListening, isFalse);
        expect(controller.state.displayedText, 'Tap \'Start\' to speak');
        verify(() => mockRepository.stopRecognition()).called(1);
      });

      test('cancels stream subscription', () async {
        await controller.startListening();
        // Add some data to ensure subscription is active
        recognitionStreamController
            .add(const SpeectToTextResult(text: 'test', isFinal: false));
        await Future.delayed(Duration.zero);

        await controller.stopListening();
        // Try adding more data, it should not be processed
        recognitionStreamController
            .add(const SpeectToTextResult(text: 'ignored', isFinal: false));
        await Future.delayed(Duration.zero);

        // Displayed text should remain as "Tap 'Start' to speak"
        expect(controller.state.displayedText, 'Tap \'Start\' to speak');
      });

      test('does nothing if not listening', () async {
        expect(controller.state.isListening, isFalse);
        await controller.stopListening();
        verifyNever(() => mockRepository.stopRecognition());
      });
    });
  });
}
