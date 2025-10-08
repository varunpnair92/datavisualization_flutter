import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
              onPressed: () => Get.toNamed('/dataset-form'),
              child: const Text("Add Dataset"),
            ),
            ElevatedButton(
              onPressed: () => Get.toNamed('/entity-form'),
              child: const Text("Add Entity"),
            ),
            ElevatedButton(
              onPressed: () => Get.toNamed('/detail-form'),
              child: const Text("Add Detail"),
            ),
            ElevatedButton(
              onPressed: () => Get.toNamed('/timeline-view'),
              child: const Text("View Timeline"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Get.toNamed('/timeline-home'),
              child: const Text("Animated Timeline"),
            ),
          ],
        ),
      ),
    );
  }
}
