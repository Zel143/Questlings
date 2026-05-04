import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rive/rive.dart';
import '../../core/widgets/pixel_filter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Questlings')),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text('Vector Egg (Clean)'),
              const SizedBox(height: 10),
              SvgPicture.asset(
                'assets/images/test_egg.svg',
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 40),
              const Text('Pixel Egg (Mimicry)'),
              const SizedBox(height: 10),
              PixelFilter(
                pixelSize: 6.0,
                child: SvgPicture.asset(
                  'assets/images/test_egg.svg',
                  width: 150,
                  height: 150,
                ),
              ),
              const SizedBox(height: 40),
              const Text('Pixel Animation (Rive)'),
              const SizedBox(height: 10),
              SizedBox(
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
