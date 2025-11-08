import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

Future<String> copyAssetToAppDir(String assetPath) async {
  final directory = await getApplicationDocumentsDirectory();
  final fileName = assetPath.split('/').last;
  final filePath = '${directory.path}/$fileName';
  final file = File(filePath);

  final byteData = await rootBundle.load(assetPath);
  await file.writeAsBytes(byteData.buffer.asUint8List(), flush: true);
  debugPrint('Copied $assetPath to $filePath');
  return filePath;
}
