class SpeechToTextState {
  final String displayedText;
  final bool isListening;
  final String? error;

  SpeechToTextState({
    this.displayedText = 'Tap \'Start\' to speak',
    this.isListening = false,
    this.error,
  });

  SpeechToTextState copyWith({
    String? displayedText,
    bool? isListening,
    String? error,
    bool clearError = false,
  }) {
    return SpeechToTextState(
      displayedText: displayedText ?? this.displayedText,
      isListening: isListening ?? this.isListening,
      error: clearError ? null : error ?? this.error,
    );
  }
}
