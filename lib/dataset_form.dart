import 'package:datavisual/data_controller.dart';
import 'package:datavisual/models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DatasetFormPage extends StatelessWidget {
  final DatasetController controller = Get.put(DatasetController());

  final headingCtrl = TextEditingController();
  final categoryCtrl = TextEditingController();
  final dataCtrl = TextEditingController();
  final sortByCtrl = TextEditingController();

  DatasetFormPage({super.key});

  void submit() async {
    final dataset = Dataset(
      heading: headingCtrl.text,
      category: categoryCtrl.text,
      data: dataCtrl.text,
      sortBy: sortByCtrl.text,
    );
    bool ok = await controller.createDataset(dataset);
    Get.snackbar("Dataset", ok ? "Created Successfully" : "Failed to Create");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Dataset")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: headingCtrl, decoration: const InputDecoration(labelText: "Heading")),
          TextField(controller: categoryCtrl, decoration: const InputDecoration(labelText: "Category")),
          TextField(controller: dataCtrl, decoration: const InputDecoration(labelText: "Data")),
          TextField(controller: sortByCtrl, decoration: const InputDecoration(labelText: "Sort By")),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: submit, child: const Text("Save")),
        ]),
      ),
    );
  }
}
