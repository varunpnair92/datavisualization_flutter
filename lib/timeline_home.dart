import 'package:datavisual/timeline_animated.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:datavisual/data_controller.dart';

class TimelineHomePage extends StatelessWidget {
  TimelineHomePage({super.key});
  final datasetController = Get.put(DatasetController());

  @override
  Widget build(BuildContext context) {
    datasetController.fetchDatasets();

    return Scaffold(
      appBar: AppBar(title: const Text("Select Dataset")),
      body: Obx(() {
        if (datasetController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          itemCount: datasetController.datasets.length,
          itemBuilder: (_, i) {
            final dataset = datasetController.datasets[i];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              child: ListTile(
                title: Text(dataset.heading),
                subtitle: Text("Category: ${dataset.category}"),
                trailing: const Icon(Icons.play_arrow),
                onTap: () {
                  // Navigate to animation page with dataset ID
                  Get.to(() => TimelineAnimationPage(datasetId: dataset.id!));
                },
              ),
            );
          },
        );
      }),
    );
  }
}
