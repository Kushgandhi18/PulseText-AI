import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:med_parser/common_widgets/primary_button.dart';

void main() {
  testWidgets('PrimaryButton renders text and handles tap',
      (WidgetTester tester) async {
    bool tapped = false;
    const buttonText = 'Tap Me';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PrimaryButton(
            text: buttonText,
            onPressed: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    expect(find.text(buttonText), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    await tester.tap(find.text(buttonText));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('PrimaryButton shows loading indicator when isLoading is true',
      (WidgetTester tester) async {
    const buttonText = 'Loading...';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PrimaryButton(
            text: buttonText,
            isLoading: true,
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text(buttonText), findsNothing);
  });
}
