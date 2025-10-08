import 'package:datavisual/details_controller.dart';
import 'package:datavisual/entity_controller.dart';
import 'package:datavisual/data_controller.dart';
import 'package:datavisual/models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DetailFormPage extends StatelessWidget {
  final DetailController detailController = Get.put(DetailController());
  final EntityController entityController = Get.put(EntityController());
  final DatasetController datasetController = Get.put(DatasetController());

  final detailsCtrl = TextEditingController();

  // reactive variables for dropdown selections
  final selectedDatasetId = 0.obs;
  final selectedEntityId = 0.obs;

  DetailFormPage({super.key}) {
    datasetController.fetchDatasets();
    entityController.fetchEntities();
  }

  void submit() async {
    if (selectedDatasetId.value == 0) {
      Get.snackbar("Error", "Please select a dataset");
      return;
    }
    if (selectedEntityId.value == 0) {
      Get.snackbar("Error", "Please select an entity");
      return;
    }

    final detail = Detail(
      entity: selectedEntityId.value,
      details: detailsCtrl.text,
    );

    bool ok = await detailController.createDetail(detail);
    Get.snackbar("Detail", ok ? "Created Successfully" : "Failed to Create");

    if (ok) {
      detailsCtrl.clear();
      selectedDatasetId.value = 0;
      selectedEntityId.value = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Detail")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Dataset Dropdown
            Obx(() {
              if (datasetController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return DropdownButton<int>(
                isExpanded: true,
                hint: const Text("Select Dataset"),
                value: selectedDatasetId.value == 0
                    ? null
                    : selectedDatasetId.value,
                items: datasetController.datasets.map((d) {
                  return DropdownMenuItem<int>(
                    value: d.id!,
                    child: Text(d.heading),
                  );
                }).toList(),
                onChanged: (val) {
                  selectedDatasetId.value = val!;
                  selectedEntityId.value = 0; // reset entity
                },
              );
            }),

            const SizedBox(height: 10),

            // Entity Dropdown (filtered by selected dataset)
            Obx(() {
              final filteredEntities = entityController.entities
                  .where((e) => e.dataset == selectedDatasetId.value)
                  .toList();

              if (filteredEntities.isEmpty &&
                  selectedDatasetId.value != 0) {
                return const Text("No entities found for this dataset");
              }

              return DropdownButton<int>(
                isExpanded: true,
                hint: const Text("Select Entity"),
                value: selectedEntityId.value == 0
                    ? null
                    : selectedEntityId.value,
                items: filteredEntities.map((e) {
                  return DropdownMenuItem<int>(
                    value: e.id!,
                    child: Text(e.name),
                  );
                }).toList(),
                onChanged: (val) => selectedEntityId.value = val!,
              );
            }),

            const SizedBox(height: 20),

            TextField(
              controller: detailsCtrl,
              decoration: const InputDecoration(
                labelText: "Details",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: submit,
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
