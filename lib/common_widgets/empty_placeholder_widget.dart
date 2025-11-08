import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_parser/constants/app_sizes.dart';
import 'package:med_parser/common_widgets/primary_button.dart';
import 'package:med_parser/utils/number_extension.dart';
import 'package:med_parser/l10n/generated/app_localizations.dart/app_localizations.dart';

/// Placeholder widget showing a message and CTA to go back to the home screen.
class EmptyPlaceholderWidget extends ConsumerWidget {
  const EmptyPlaceholderWidget({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(Sizes.spacingXl),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              message,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            Sizes.spacingXl.hSpace,
            PrimaryButton(
              onPressed: () {},
              text: AppLocalizations.of(context).goHome,
            )
          ],
        ),
      ),
    );
  }
}
