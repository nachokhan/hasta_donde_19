import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<String> loadTextAsset(BuildContext context, String assetPath) async {
  return await DefaultAssetBundle.of(context).loadString(assetPath);
}

Future<String> loadTextAssets(String assetPath) async {
  return await rootBundle.loadString(assetPath);
}