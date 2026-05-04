import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final pixelArtShaderProvider = FutureProvider<FragmentProgram>((ref) async {
  return await FragmentProgram.fromAsset('shaders/pixel_art.frag');
});
