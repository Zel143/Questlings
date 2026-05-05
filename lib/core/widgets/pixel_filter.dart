import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import '../providers/shader_providers.dart';

class PixelFilter extends ConsumerWidget {
  final Widget child;
  final double pixelSize;
  final double saturation;

  const PixelFilter({
    super.key,
    required this.child,
    this.pixelSize = 4.0,
    this.saturation = 1.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shaderAsync = ref.watch(pixelArtShaderProvider);

    return shaderAsync.maybeWhen(
      data: (program) {
        return AnimatedSampler(
          (image, size, canvas) {
            final shader = program.fragmentShader();

            // uSize
            shader.setFloat(0, size.width);
            shader.setFloat(1, size.height);

            // uTexture
            shader.setImageSampler(0, image);

            // uTextureSize
            shader.setFloat(2, size.width / pixelSize);
            shader.setFloat(3, size.height / pixelSize);

            // uSaturation
            shader.setFloat(4, saturation);

            final paint = Paint()..shader = shader;
            canvas.drawRect(Offset.zero & size, paint);
          },
          child: child,
        );
      },
      orElse: () => child,
    );
  }
}
