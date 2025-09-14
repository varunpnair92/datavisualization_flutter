class Dataset {
  final int? id;
  final String heading;
  final String category;
  final String data;
  final String? sortBy;

  Dataset({
    this.id,
    required this.heading,
    required this.category,
    required this.data,
    this.sortBy,
  });

  factory Dataset.fromJson(Map<String, dynamic> json) => Dataset(
        id: json["id"],
        heading: json["heading"],
        category: json["category"],
        data: json["data"],
        sortBy: json["sort_by"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "heading": heading,
        "category": category,
        "data": data,
        "sort_by": sortBy,
      };
}

class Entity {
  final int? id;
  final int dataset;
  final String name;
  final String? volume;
  final String? imageUrl;

  Entity({
    this.id,
    required this.dataset,
    required this.name,
    this.volume,
    this.imageUrl,
  });

  factory Entity.fromJson(Map<String, dynamic> json) => Entity(
        id: json["id"],
        dataset: json["dataset"],
        name: json["name"],
        volume: json["volume"],
        imageUrl: json["image_url"], // comes from Django serializer
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "dataset": dataset,
        "name": name,
        "volume": volume,
        // don’t send image_url back in create/update (image is uploaded separately)
      };
}

class Detail {
  final int? id;
  final int entity;
  final String details;

  Detail({
    this.id,
    required this.entity,
    required this.details,
  });

  factory Detail.fromJson(Map<String, dynamic> json) => Detail(
        id: json["id"],
        entity: json["entity"],
        details: json["details"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "entity": entity,
        "details": details,
      };
}
