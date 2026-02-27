class MapPlaceModel {
  final String id;
  final String? ownerUserId;
  final String placeType;
  final String title;
  final String? description;
  final String? categoryId;
  final List<String> tags;
  final double lat;
  final double lng;
  final String? addressText;
  final String? country;
  final String? city;
  final Map<String, dynamic> contact;
  final List<String> images;
  final String visibility;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  MapPlaceModel({
    required this.id,
    this.ownerUserId,
    required this.placeType,
    required this.title,
    this.description,
    this.categoryId,
    required this.tags,
    required this.lat,
    required this.lng,
    this.addressText,
    this.country,
    this.city,
    required this.contact,
    required this.images,
    required this.visibility,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MapPlaceModel.fromJson(Map<String, dynamic> json) {
    return MapPlaceModel(
      id: json['id'] as String,
      ownerUserId: json['owner_user_id'] as String?,
      placeType: json['place_type'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      categoryId: json['category_id'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          [],
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      addressText: json['address_text'] as String?,
      country: json['country'] as String?,
      city: json['city'] as String?,
      contact: (json['contact'] as Map<String, dynamic>?) ?? {},
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      visibility: json['visibility'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_user_id': ownerUserId,
      'place_type': placeType,
      'title': title,
      'description': description,
      'category_id': categoryId,
      'tags': tags,
      'lat': lat,
      'lng': lng,
      'address_text': addressText,
      'country': country,
      'city': city,
      'contact': contact,
      'images': images,
      'visibility': visibility,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
