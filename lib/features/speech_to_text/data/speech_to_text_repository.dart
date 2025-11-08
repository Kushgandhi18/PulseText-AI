import 'package:sherpa_onnx/sherpa_onnx.dart';
import 'package:med_parser/features/speech_to_text/domain/speech_to_text_result.dart';
import 'package:med_parser/utils/file_util.dart';
import 'package:med_parser/utils/float_util.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';

typedef OnlineRecognizerFactory = Future<OnlineRecognizer> Function();

class SpeechToTextRepository {
  final AudioRecorder _audioRecorder;
  final OnlineRecognizerFactory _recognizerFactory;
  late OnlineRecognizer _recognizer;
  OnlineStream? _stream;

  bool _isRecognizerInitialized = false;
  final int _sampleRate = 16000;
  final _numChannels = 1;

  SpeechToTextRepository({
    required AudioRecorder audioRecorder,
    required OnlineRecognizerFactory recognizerFactory,
  })  : _audioRecorder = audioRecorder,
        _recognizerFactory = recognizerFactory;

  Future<void> _initializeRecognizer() async {
    if (_isRecognizerInitialized) return;
    _recognizer = await _recognizerFactory();
    _isRecognizerInitialized = true;
    debugPrint('Speech recognizer initialized.');
  }

  Stream<SpeectToTextResult> startRecognition() async* {
    await _initializeRecognizer();

    if (!await _audioRecorder.hasPermission()) {
      throw Exception('Microphone permission not granted');
    }

    _stream?.free();
    _stream = _recognizer.createStream();
    debugPrint('Created new recognizer stream');

    final recordConfig = RecordConfig(
      encoder: AudioEncoder.pcm16bits,
      sampleRate: _sampleRate,
      numChannels: _numChannels,
    );

    if (!await _audioRecorder.isEncoderSupported(recordConfig.encoder)) {
      throw Exception(
          '${recordConfig.encoder.name} is not supported on this platform');
    }

    debugPrint('Starting audio recording...');
    final audioStream = await _audioRecorder.startStream(recordConfig);

    await for (final data in audioStream) {
      if (_stream == null || !_isRecognizerInitialized) {
        debugPrint(
            'Stream or recognizer became invalid during audio processing. Exiting.');
        break;
      }

      final samplesFloat32 = convertBytesToFloat32(Uint8List.fromList(data));
      _stream!.acceptWaveform(samples: samplesFloat32, sampleRate: _sampleRate);

      while (_recognizer.isReady(_stream!)) {
        _recognizer.decode(_stream!);
      }

      final result = _recognizer.getResult(_stream!);
      final isEndpoint = _recognizer.isEndpoint(_stream!);

      yield SpeectToTextResult(text: result.text, isFinal: isEndpoint);

      if (isEndpoint) {
        _recognizer.reset(_stream!);
        debugPrint('Endpoint detected, stream reset');
      }
    }
    debugPrint('Audio stream ended');
  }

  static Future<OnlineRecognizer> defaultOnlineRecognizerFactory() async {
    final modelDirectory = 'assets/model';
    final modelConfig = OnlineModelConfig(
        transducer: OnlineTransducerModelConfig(
          encoder: await copyAssetToAppDir(
              '$modelDirectory/encoder-epoch-99-avg-1.int8.onnx'),
          decoder: await copyAssetToAppDir(
              '$modelDirectory/decoder-epoch-99-avg-1.onnx'),
          joiner: await copyAssetToAppDir(
              '$modelDirectory/joiner-epoch-99-avg-1.int8.onnx'),
        ),
        tokens: await copyAssetToAppDir('$modelDirectory/tokens.txt'),
        modelType: 'zipformer');
    final onlineRecognizerConfig = OnlineRecognizerConfig(
      model: modelConfig,
    );
    return OnlineRecognizer(onlineRecognizerConfig);
  }

  Future<void> stopRecognition() async {
    await _audioRecorder.stop();

    debugPrint('Audio recording stopped');
  }

  void dispose() {
    _audioRecorder.dispose();
    _stream?.free();
    _stream = null;
    if (_isRecognizerInitialized) {
      _recognizer.free();
    }
    _isRecognizerInitialized = false;
    debugPrint('SpeechToTextRepository disposed');
  }
}
