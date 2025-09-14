import 'dart:typed_data';
import 'package:datavisual/entity_controller.dart';
import 'package:datavisual/data_controller.dart';
import 'package:datavisual/models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';

class EntityFormPage extends StatelessWidget {
  final EntityController entityController = Get.put(EntityController());
  final DatasetController datasetController = Get.put(DatasetController());

  final nameCtrl = TextEditingController();
  final volumeCtrl = TextEditingController();

  final selectedDatasetId = 0.obs;
  final imageBytes = Rx<Uint8List?>(null);
  final imageName = RxString('');

  EntityFormPage({super.key}) {
    datasetController.fetchDatasets();
  }

  void submit() async {
    if (selectedDatasetId.value == 0) {
      Get.snackbar("Error", "Please select a dataset");
      return;
    }

    bool ok = await entityController.createEntity(
      datasetId: selectedDatasetId.value,
      name: nameCtrl.text,
      volume: volumeCtrl.text,
      imageBytes: imageBytes.value,
      fileName: imageName.value,
    );

    Get.snackbar("Entity", ok ? "Created Successfully" : "Failed to Create");

    if (ok) {
      nameCtrl.clear();
      volumeCtrl.clear();
      imageBytes.value = null;
      imageName.value = '';
      selectedDatasetId.value = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Entity")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Dropdown for dataset
            Obx(() => DropdownButton<int>(
                  hint: const Text("Select Dataset"),
                  value: selectedDatasetId.value == 0 ? null : selectedDatasetId.value,
                  items: datasetController.datasets.map((d) {
                    return DropdownMenuItem<int>(
                      value: d.id!,
                      child: Text(d.heading),
                    );
                  }).toList(),
                  onChanged: (val) => selectedDatasetId.value = val!,
                )),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: volumeCtrl, decoration: const InputDecoration(labelText: "Volume")),
            const SizedBox(height: 10),

            // Image picker
            Obx(() => Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles(type: FileType.image);
                        if (result != null && result.files.single.bytes != null) {
                          imageBytes.value = result.files.single.bytes;
                          imageName.value = result.files.single.name;
                        }
                      },
                      icon: const Icon(Icons.upload),
                      label: const Text("Pick Image"),
                    ),
                    const SizedBox(width: 10),
                    Text(imageName.value.isEmpty ? "No file chosen" : imageName.value),
                  ],
                )),

            const SizedBox(height: 20),
            ElevatedButton(onPressed: submit, child: const Text("Save")),
          ],
        ),
      ),
    );
  }
}
