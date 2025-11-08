import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:med_parser/constants/app_colors.dart';
import 'package:med_parser/constants/app_sizes.dart';
import 'package:med_parser/features/onboarding/presentation/onboarding_controller.dart';
import 'package:med_parser/l10n/generated/app_localizations.dart/app_localizations.dart';
import 'package:med_parser/routing/app_router.dart';
import 'package:med_parser/utils/number_extension.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryColor,
              AppColors.secondaryColor,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Sizes.spacingXxl.hSpace,
                  Text(
                    l10n.onboardingTitle,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: Sizes.spacingXl,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  Sizes.spacingXl.hSpace,
                  Text(
                    l10n.onboardingSubTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontSize: Sizes.spacingM,
                          fontWeight: FontWeight.normal,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Sizes.spacingXl),
                  SvgPicture.asset(
                    'assets/onboarding_graphic.svg',
                    width: 300,
                    height: 250,
                  ),
                  const SizedBox(height: Sizes.spacingXl),
                  SizedBox(
                    width: 320,
                    height: Sizes.spacingXxl,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Sizes.spacingXl),
                        ),
                        textStyle: const TextStyle(
                          fontSize: Sizes.fontSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: state.isLoading
                          ? null
                          : () async {
                              await ref
                                  .read(onboardingControllerProvider.notifier)
                                  .completeOnboarding();
                              if (context.mounted) {
                                context.go(AppRoute.speechToText.name);
                              }
                            },
                      child: state.isLoading
                          ? const CircularProgressIndicator()
                          : Text(
                              l10n.getStarted,
                              style: const TextStyle(
                                color: Color(0xff407FBD),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: Sizes.spacingXl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
