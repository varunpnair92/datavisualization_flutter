import 'package:datavisual/sharedvariables.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models.dart';

class DetailController extends GetxController {
  var details = <Detail>[].obs;
  var isLoading = false.obs;

  Future<void> fetchDetails() async {
    isLoading(true);
    final response = await http.get(Uri.parse("${AppConfig.baseUrl}/details/"));
    if (response.statusCode == 200) {
      details.value = (jsonDecode(response.body) as List)
          .map((e) => Detail.fromJson(e))
          .toList();
    }
    isLoading(false);
  }

  Future<bool> createDetail(Detail detail) async {
    final response = await http.post(
      Uri.parse("${AppConfig.baseUrl}/details/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(detail.toJson()),
    );
    if (response.statusCode == 201) {
      fetchDetails();
      return true;
    }
    return false;
  }
}
