import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:record/record.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart';
import 'package:med_parser/features/speech_to_text/data/speech_to_text_repository.dart';
import 'package:med_parser/features/speech_to_text/domain/speech_to_text_result.dart';
import '../../../test_util/mocks.dart';

void main() {
  late SpeechToTextRepository speechToTextRepository;
  late MockAudioRecorder mockAudioRecorder;
  late MockOnlineRecognizer mockOnlineRecognizer;
  late MockOnlineStream mockOnlineStream;

  Future<OnlineRecognizer> mockRecognizerFactory() async {
    return mockOnlineRecognizer;
  }

  setUpAll(() {
    registerFallbackValue(MockOnlineStream());
    registerFallbackValue(const RecordConfig());
    registerFallbackValue(AudioEncoder.pcm16bits);
    registerFallbackValue(
        OnlineRecognizerResult(text: '', tokens: [], timestamps: []));
    registerFallbackValue(Float32List(0));
  });

  setUp(() {
    mockAudioRecorder = MockAudioRecorder();
    mockOnlineRecognizer = MockOnlineRecognizer();
    mockOnlineStream = MockOnlineStream();

    speechToTextRepository = SpeechToTextRepository(
      audioRecorder: mockAudioRecorder,
      recognizerFactory: mockRecognizerFactory,
    );

    when(() => mockOnlineRecognizer.createStream())
        .thenReturn(mockOnlineStream);
    when(() => mockOnlineRecognizer.decode(any<OnlineStream>()))
        .thenAnswer((_) {});
    when(() => mockOnlineRecognizer.reset(any<OnlineStream>()))
        .thenAnswer((_) {});
    when(() => mockOnlineStream.free()).thenAnswer((_) {});
    when(() => mockOnlineRecognizer.free()).thenAnswer((_) {});
    when(() => mockOnlineRecognizer.getResult(any<OnlineStream>())).thenReturn(
        OnlineRecognizerResult(
            text: 'default test result', tokens: [], timestamps: []));
    when(() => mockOnlineRecognizer.isEndpoint(any<OnlineStream>()))
        .thenReturn(false);
    when(() => mockAudioRecorder.hasPermission()).thenAnswer((_) async => true);
    when(() => mockAudioRecorder.isEncoderSupported(any<AudioEncoder>()))
        .thenAnswer((_) async => true);
    when(() => mockAudioRecorder.startStream(any<RecordConfig>()))
        .thenAnswer((_) async {
      final controller = StreamController<Uint8List>();
      return controller.stream;
    });
    when(() => mockAudioRecorder.stop()).thenAnswer((_) async {
      return null;
    });
    when(() => mockAudioRecorder.dispose()).thenAnswer((_) async {});
  });

  tearDown(() {
    speechToTextRepository.dispose();
  });

  group('SpeechToTextRepository', () {
    test(
        '_initializeRecognizer calls factory and sets _isRecognizerInitialized',
        () async {
      when(() => mockOnlineRecognizer.getResult(any<OnlineStream>()))
          .thenReturn(OnlineRecognizerResult(
              text: 'init test', tokens: [], timestamps: []));

      final initStreamController = StreamController<Uint8List>();
      when(() => mockAudioRecorder.startStream(any()))
          .thenAnswer((_) async => initStreamController.stream);
      Future.microtask(initStreamController.close);

      final stream = speechToTextRepository.startRecognition();
      await stream.toList();

      verify(() => mockOnlineRecognizer.createStream()).called(1);
    });

    test(
        'startRecognition throws exception if microphone permission not granted',
        () async {
      when(() => mockAudioRecorder.hasPermission())
          .thenAnswer((_) async => false);
      expect(
        () => speechToTextRepository.startRecognition().toList(),
        throwsA(isA<Exception>().having(
            (e) => e.toString(), 'message', contains('Microphone permission'))),
      );
    });

    test('startRecognition throws exception if encoder is not supported',
        () async {
      when(() => mockAudioRecorder.isEncoderSupported(any()))
          .thenAnswer((_) async => false);
      when(() => mockAudioRecorder.hasPermission())
          .thenAnswer((_) async => true);
      expect(
        () => speechToTextRepository.startRecognition().toList(),
        throwsA(isA<Exception>().having(
            (e) => e.toString(), 'message', contains('is not supported'))),
      );
    });

    test(
        'startRecognition yields SpeectToTextResult when audio data is processed',
        () async {
      final mockAudioDataStreamController = StreamController<Uint8List>();
      when(() => mockAudioRecorder.startStream(any<RecordConfig>()))
          .thenAnswer((_) async => mockAudioDataStreamController.stream);

      final isReadyResponseQueue = <bool>[
        true, false, // For the first data chunk's while loop cycle
        true, false, // For the second data chunk's while loop cycle
      ];
      when(() => mockOnlineRecognizer.isReady(mockOnlineStream))
          .thenAnswer((_) {
        if (isReadyResponseQueue.isNotEmpty) {
          final response = isReadyResponseQueue.removeAt(0);
          return response;
        }
        return false;
      });

      // Stub for the first result
      when(() => mockOnlineRecognizer.getResult(mockOnlineStream)).thenReturn(
          OnlineRecognizerResult(text: 'hello', tokens: [], timestamps: []));
      when(() => mockOnlineRecognizer.isEndpoint(mockOnlineStream))
          .thenReturn(false);

      final results = <SpeectToTextResult>[];
      final recognitionStream = speechToTextRepository.startRecognition();
      final completer = Completer<void>();

      final subscription = recognitionStream.listen(
        (result) {
          results.add(result);
        },
        onDone: () {
          if (!completer.isCompleted) completer.complete();
        },
      );

      // --- First data chunk processing ---
      mockAudioDataStreamController.add(Uint8List.fromList([1, 2]));
      await Future.delayed(Duration.zero); // Allow event loop to process

      if (completer.isCompleted && results.isEmpty) {
        fail(
            "Stream completed prematurely with error before yielding results.");
      }

      expect(results.first.text, 'hello');
      expect(results.first.isFinal, isFalse);

      // --- Second data chunk processing ---
      // Re-stub for the second result
      when(() => mockOnlineRecognizer.getResult(mockOnlineStream)).thenReturn(
          OnlineRecognizerResult(text: 'world', tokens: [], timestamps: []));
      when(() => mockOnlineRecognizer.isEndpoint(mockOnlineStream))
          .thenReturn(true);

      // print("Test: Adding second data chunk [4, 5, 6, 8]");
      mockAudioDataStreamController.add(Uint8List.fromList([4, 5, 6, 8]));
      await Future.delayed(Duration.zero); // Allow event loop to process

      expect(results.length, 2,
          reason: "Should have two results after second data chunk");
      expect(results.last.text, 'world');
      expect(results.last.isFinal, isTrue);
      verify(() => mockOnlineRecognizer.reset(mockOnlineStream)).called(1);

      await mockAudioDataStreamController.close();

      await completer.future;
      await subscription.cancel();

      verify(() => mockAudioRecorder.startStream(any<RecordConfig>()))
          .called(1);
      verify(() => mockOnlineStream.acceptWaveform(
          samples: any(
            named: 'samples',
          ), // Explicitly type if needed, though often inferred
          sampleRate: 16000)).called(2);
      // decode should be called once for each 'true' from isReadyResponseQueue
      verify(() => mockOnlineRecognizer.decode(mockOnlineStream)).called(2);
    });

    test('stopRecognition calls audioRecorder.stop', () async {
      await speechToTextRepository.stopRecognition();
      verify(() => mockAudioRecorder.stop()).called(1);
    });

    test('dispose calls dispose on recorder and frees recognizer/stream',
        () async {
      final disposeStreamController = StreamController<Uint8List>();
      when(() => mockAudioRecorder.startStream(any()))
          .thenAnswer((_) async => disposeStreamController.stream);

      final isReadyDisposeQueue = <bool>[true, false];
      when(() => mockOnlineRecognizer.isReady(mockOnlineStream))
          .thenAnswer((_) {
        if (isReadyDisposeQueue.isNotEmpty) {
          return isReadyDisposeQueue.removeAt(0);
        }
        return false;
      });

      final stream = speechToTextRepository.startRecognition();
      final sub = stream.listen((event) {}, onDone: () {}, onError: (_, __) {});

      disposeStreamController.add(Uint8List.fromList([1, 2]));
      await Future.delayed(Duration.zero);

      await Future.microtask(disposeStreamController.close);

      await sub.cancel();

      speechToTextRepository.dispose();

      verify(() => mockAudioRecorder.dispose()).called(1);
      verify(() => mockOnlineRecognizer.free()).called(1);
      verify(() => mockOnlineStream.free()).called(1);
    });
  });
}
