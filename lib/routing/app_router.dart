import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:go_router/go_router.dart';
import 'package:med_parser/features/onboarding/data/onboarding_repository.dart';
import 'package:med_parser/features/onboarding/presentation/onboarding_screen.dart';
import 'package:med_parser/features/speech_to_text/presentation/speech_to_text_screen.dart';
import 'package:med_parser/routing/not_found_screen.dart';

part 'app_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

enum AppRoute {
  onboarding('/onboarding'),
  speechToText('/speechToText');

  final String name;
  const AppRoute(this.name);
}

@riverpod
GoRouter goRouter(Ref ref) {
  return GoRouter(
    initialLocation: AppRoute.onboarding.name,
    navigatorKey: _rootNavigatorKey,
    redirect: (context, state) {
      final onboardingRepository =
          ref.read(onboardingRepositoryProvider).requireValue;
      final didCompleteOnboarding = onboardingRepository.isOnboardingComplete();
      final path = state.uri.path;
      if (!didCompleteOnboarding) {
        // Always check state.subloc before returning a non-null route
        // https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/redirection.dart#L78
        if (path != AppRoute.onboarding.name) {
          return AppRoute.onboarding.name;
        }
        return null;
      }
      return AppRoute.speechToText.name;
    },
    routes: [
      GoRoute(
        path: AppRoute.onboarding.name,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: AppRoute.speechToText.name,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          return const MaterialPage(
            fullscreenDialog: true,
            child: SpeechToTextScreen(),
          );
        },
      ),
    ],
    errorPageBuilder: (context, state) => const NoTransitionPage(
      child: NotFoundScreen(),
    ),
  );
}
