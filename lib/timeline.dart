import 'package:datavisual/data_controller.dart';
import 'package:datavisual/details_controller.dart';
import 'package:datavisual/entity_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TimelineViewPage extends StatelessWidget {
  const TimelineViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final datasetController = Get.put(DatasetController());
    final entityController = Get.put(EntityController());
    final detailController = Get.put(DetailController());

    datasetController.fetchDatasets();
    entityController.fetchEntities();
    detailController.fetchDetails();

    return Scaffold(
      appBar: AppBar(title: const Text("Timeline View")),
      body: Obx(() {
        if (datasetController.isLoading.value ||
            entityController.isLoading.value ||
            detailController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          itemCount: datasetController.datasets.length,
          itemBuilder: (context, i) {
            final dataset = datasetController.datasets[i];
            final datasetEntities = entityController.entities
                .where((e) => e.dataset == dataset.id)
                .toList();

            return ExpansionTile(
              title: Text("${dataset.heading} (${dataset.data})"),
              subtitle: Text("Category: ${dataset.category}"),
              children: datasetEntities.map((entity) {
                final entityDetails = detailController.details
                    .where((d) => d.entity == entity.id)
                    .toList();

                return ExpansionTile(
                  leading: entity.imageUrl != null
                      ? Image.network(
                          entity.imageUrl!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image),
                        )
                      : const Icon(Icons.image_not_supported),
                  title: Text(entity.name),
                  subtitle: Text(entity.volume ?? ""),
                  children: entityDetails
                      .map((d) => ListTile(title: Text(d.details)))
                      .toList(),
                );
              }).toList(),
            );
          },
        );
      }),
    );
  }
}
