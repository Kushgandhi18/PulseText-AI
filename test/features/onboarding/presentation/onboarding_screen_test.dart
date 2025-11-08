import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:med_parser/features/onboarding/presentation/onboarding_controller.dart';
import 'package:med_parser/features/onboarding/presentation/onboarding_screen.dart';
import 'package:med_parser/l10n/generated/app_localizations.dart/app_localizations.dart';
import 'package:med_parser/routing/app_router.dart';

import '../../../test_util/mocks.dart';

void main() {
  group('OnboardingScreen Widget Tests', () {
    late MockOnboardingController mockOnboardingController;
    late GoRouter testGoRouter;

    setUp(() {
      mockOnboardingController = MockOnboardingController();
      testGoRouter = GoRouter(
        initialLocation: AppRoute.onboarding.name,
        routes: [
          GoRoute(
            path: AppRoute.onboarding.name,
            builder: (context, state) => const OnboardingScreen(),
          ),
          GoRoute(
            path: AppRoute.speechToText.name,
            builder: (context, state) =>
                const Scaffold(body: Text('Mock SpeechToText Screen')),
          ),
        ],
      );
    });

    Future<void> pumpOnboardingScreen(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            onboardingControllerProvider.overrideWith(
              () => mockOnboardingController,
            ),
          ],
          child: MaterialApp.router(
            routerConfig: testGoRouter,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        ),
      );
    }

    testWidgets('renders initial content correctly when not loading',
        (WidgetTester tester) async {
      mockOnboardingController.mockInitialState = const AsyncData(null);
      when(() => mockOnboardingController.completeOnboarding())
          .thenAnswer((_) async {});

      await pumpOnboardingScreen(tester);
      await tester.pumpAndSettle();

      expect(find.text('Speech-to-Text in Real-Time'), findsOneWidget);
      expect(find.byType(SvgPicture), findsOneWidget);
      final buttonFinder = find.widgetWithText(ElevatedButton, 'Get Started');
      expect(buttonFinder, findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('calls completeOnboarding on button press and navigates',
        (WidgetTester tester) async {
      mockOnboardingController.mockInitialState = const AsyncData(null);
      when(() => mockOnboardingController.completeOnboarding())
          .thenAnswer((_) async {
        mockOnboardingController.setMockState(const AsyncData(null));
      });

      await pumpOnboardingScreen(tester);
      await tester.pumpAndSettle();

      final buttonFinder = find.widgetWithText(ElevatedButton, 'Get Started');

      await tester.ensureVisible(
          buttonFinder); // <-- This ensures the button is visible
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      verify(() => mockOnboardingController.completeOnboarding()).called(1);

      expect(find.text('Mock SpeechToText Screen'), findsOneWidget);
    });
  });
}
