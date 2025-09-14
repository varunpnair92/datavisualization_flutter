import 'package:datavisual/models.dart';
import 'package:datavisual/sharedvariables.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class DatasetController extends GetxController {
  var datasets = <Dataset>[].obs;
  var isLoading = false.obs;

  Future<void> fetchDatasets() async {
    isLoading(true);
    final response = await http.get(Uri.parse("${AppConfig.baseUrl}/datasets/"));
    if (response.statusCode == 200) {
      datasets.value = (jsonDecode(response.body) as List)
          .map((e) => Dataset.fromJson(e))
          .toList();
    }
    isLoading(false);
  }

  Future<bool> createDataset(Dataset dataset) async {
    final response = await http.post(
      Uri.parse("${AppConfig.baseUrl}/datasets/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(dataset.toJson()),
    );
    if (response.statusCode == 201) {
      fetchDatasets();
      return true;
    }
    return false;
  }
}
