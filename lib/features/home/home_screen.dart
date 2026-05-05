import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/widgets/pixel_filter.dart';
import './widgets/habit_checklist.dart';
import '../../core/providers/questling_provider.dart';
import '../../models/questling.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questlingAsync = ref.watch(equippedQuestlingProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Questlings')),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text('Equipped Questling'),
              const SizedBox(height: 10),
              questlingAsync.when(
                data: (questling) {
                  if (questling == null) {
                    return const Text('No questling equipped');
                  }

                  final isSick = questling.status == QuestlingStatus.sick;

                  return Column(
                    children: [
                      if (isSick)
                        const Chip(
                          backgroundColor: Colors.redAccent,
                          label: Text('SICK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          avatar: Icon(Icons.warning, color: Colors.white, size: 16),
                        ),
                      const SizedBox(height: 10),
                      PixelFilter(
                        pixelSize: 6.0,
                        saturation: isSick ? 0.0 : 1.0,
                        child: SvgPicture.asset(
                          'assets/images/test_egg.svg', // In real app, use questling.speciesId
                          width: 150,
                          height: 150,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(questling.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (err, stack) => Text('Error: $err'),
              ),
              const SizedBox(height: 40),
              const Divider(),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text('Daily Checklist', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              const HabitChecklist(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
