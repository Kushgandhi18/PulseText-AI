import 'package:flutter/material.dart';
import 'package:med_parser/common_widgets/empty_placeholder_widget.dart';
import 'package:med_parser/l10n/generated/app_localizations.dart/app_localizations.dart';

/// Simple not found screen used for 404 errors (page not found on web)
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: EmptyPlaceholderWidget(
          message: AppLocalizations.of(context).notFoundMessage,
        ));
  }
}
