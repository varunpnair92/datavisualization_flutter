import 'package:datavisual/details_form.dart';
import 'package:datavisual/timeline.dart';
import 'package:datavisual/timeline_animated.dart';
import 'package:datavisual/timeline_home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dataset_form.dart';
import 'entity_form.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Visualization Home")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Get.to(() => DatasetFormPage()),
              child: const Text("Add Dataset"),
            ),
            ElevatedButton(
              onPressed: () => Get.to(() => EntityFormPage()),
              child: const Text("Add Entity"),
            ),
            ElevatedButton(
              onPressed: () => Get.to(() => DetailFormPage()),
              child: const Text("Add Detail"),
            ),
            ElevatedButton(
              onPressed: () => Get.to(() => const TimelineViewPage()),
              child: const Text("View Timeline"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Get.to(() =>  TimelineHomePage()), // <-- new
              child: const Text("Animated Timeline"),
            ),
          ],
        ),
      ),
    );
  }
}
