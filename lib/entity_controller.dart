import 'dart:convert';
import 'dart:typed_data';
import 'package:datavisual/sharedvariables.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models.dart';

class EntityController extends GetxController {
  var entities = <Entity>[].obs;
  var isLoading = false.obs;

  /// Fetch all entities
  Future<void> fetchEntities() async {
    try {
      isLoading(true);
      final response = await http.get(Uri.parse("${AppConfig.baseUrl}/entities/"));
      if (response.statusCode == 200) {
        entities.value = (jsonDecode(response.body) as List)
            .map((e) => Entity.fromJson(e))
            .toList();
      } else {
        print("Error fetching entities: ${response.body}");
      }
    } catch (e) {
      print("Exception fetching entities: $e");
    } finally {
      isLoading(false);
    }
  }

  /// Create a new entity with image upload
  Future<bool> createEntity({
    required int datasetId,
    required String name,
    String? volume,
    Uint8List? imageBytes,
    String? fileName,
  }) async {
    var uri = Uri.parse("${AppConfig.baseUrl}/entities/");
    var request = http.MultipartRequest("POST", uri);

    request.fields["dataset"] = datasetId.toString();
    request.fields["name"] = name;
    if (volume != null) request.fields["volume"] = volume;

    // ✅ Support image from Uint8List (works for Web too)
    if (imageBytes != null && fileName != null && fileName.isNotEmpty) {
      request.files.add(
        http.MultipartFile.fromBytes(
          "image", // must match Django field
          imageBytes,
          filename: fileName,
          contentType: MediaType("image", "jpeg"),
        ),
      );
    }

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        await fetchEntities(); // refresh after create
        return true;
      } else {
        print("Create entity failed: ${response.statusCode} -> ${response.body}");
      }
    } catch (e) {
      print("Exception creating entity: $e");
    }
    return false;
  }
}
