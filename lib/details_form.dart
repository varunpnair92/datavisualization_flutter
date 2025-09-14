import 'package:datavisual/details_controller.dart';
import 'package:datavisual/entity_controller.dart';
import 'package:datavisual/models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DetailFormPage extends StatelessWidget {
  final DetailController detailController = Get.put(DetailController());
  final EntityController entityController = Get.put(EntityController());

  final detailsCtrl = TextEditingController();
  final selectedEntityId = 0.obs;

  DetailFormPage({super.key}) {
    entityController.fetchEntities();
  }

  void submit() async {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Detail")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Obx(() => DropdownButton<int>(
                hint: const Text("Select Entity"),
                value: selectedEntityId.value == 0 ? null : selectedEntityId.value,
                items: entityController.entities.map((e) {
                  return DropdownMenuItem<int>(
                    value: e.id!,
                    child: Text(e.name),
                  );
                }).toList(),
                onChanged: (val) => selectedEntityId.value = val!,
              )),
          TextField(controller: detailsCtrl, decoration: const InputDecoration(labelText: "Details")),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: submit, child: const Text("Save")),
        ]),
      ),
    );
  }
}
