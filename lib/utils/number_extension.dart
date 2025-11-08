import 'package:flutter/widgets.dart';

extension NumberExtension on num {
  SizedBox get hSpace => SizedBox(height: toDouble());
  SizedBox get wSpace => SizedBox(width: toDouble());
}
