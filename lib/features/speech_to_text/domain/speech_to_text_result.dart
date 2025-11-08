import 'package:equatable/equatable.dart';

class SpeectToTextResult extends Equatable {
  final String text;
  final bool isFinal;

  const SpeectToTextResult({required this.text, required this.isFinal});

  @override
  List<Object?> get props => [text, isFinal];
}
