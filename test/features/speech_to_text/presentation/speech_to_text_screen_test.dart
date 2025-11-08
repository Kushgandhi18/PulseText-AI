import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:med_parser/features/speech_to_text/domain/speech_to_text_state.dart';
import 'package:med_parser/features/speech_to_text/presentation/speech_to_text_controller.dart';
import 'package:med_parser/features/speech_to_text/presentation/speech_to_text_screen.dart';
import '../../../test_util/mocks.dart';
import '../../../test_util/test_utils.dart';

void main() {
  late MockSpeechToTextController mockController;

  setUp(() {
    final initialMockState = SpeechToTextState();
    mockController = MockSpeechToTextController(initialMockState);

    when(() => mockController.startListening()).thenAnswer((_) async {});
    when(() => mockController.stopListening()).thenAnswer((_) async {});
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          speechToTextControllerProvider.overrideWith((ref) => mockController),
        ],
        child: wrapWithMaterialAppWithLocalization(
          const SpeechToTextScreen(),
        ),
      ),
    );
  }

  testWidgets('renders initial UI correctly', (WidgetTester tester) async {
    mockController.state =
        SpeechToTextState(displayedText: 'Initial Text', isListening: false);
    await pumpScreen(tester);
    await tester.pump(); // Ensure UI rebuilds after state change

    expect(find.text('Real-time Speech Recognition'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Initial Text'), findsOneWidget);
    expect(find.byIcon(Icons.mic), findsOneWidget);
    expect(find.text('Tap to Start'), findsOneWidget);
    expect(find.textContaining('Error:'), findsNothing);
  });

  testWidgets('displays error message when error is present',
      (WidgetTester tester) async {
    mockController.state = SpeechToTextState(
        displayedText: 'Some text',
        isListening: false,
        error: 'Test Error Message');
    await pumpScreen(tester);
    await tester.pump();

    expect(find.text('Test Error Message'), findsOneWidget);
  });

  testWidgets('tapping mic button calls startListening when not listening',
      (WidgetTester tester) async {
    mockController.state = SpeechToTextState(isListening: false);
    await pumpScreen(tester);
    await tester.pump();

    await tester.tap(find.byIcon(Icons.mic));
    await tester.pump();

    verify(() => mockController.startListening()).called(1);
  });

  testWidgets('tapping stop button calls stopListening when listening',
      (WidgetTester tester) async {
    mockController.state = SpeechToTextState(isListening: true);
    await pumpScreen(tester);
    await tester.pump();

    await tester.tap(find.byIcon(Icons.stop));
    await tester.pump();

    verify(() => mockController.stopListening()).called(1);
  });

  testWidgets('TextField updates when displayedText changes in state',
      (WidgetTester tester) async {
    mockController.state = SpeechToTextState(displayedText: 'First message');
    await pumpScreen(tester);
    await tester.pump();
    expect(find.widgetWithText(TextField, 'First message'), findsOneWidget);

    mockController.state = SpeechToTextState(displayedText: 'Second message');
    await pumpScreen(tester);
    await tester.pump();

    expect(find.widgetWithText(TextField, 'Second message'), findsOneWidget);
  });
}
