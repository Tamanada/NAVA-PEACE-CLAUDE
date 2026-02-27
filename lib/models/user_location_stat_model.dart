class UserLocationStatModel {
  final String country;
  final int userCount;
  final double lat;
  final double lng;

  UserLocationStatModel({
    required this.country,
    required this.userCount,
    required this.lat,
    required this.lng,
  });

  factory UserLocationStatModel.fromJson(Map<String, dynamic> json) {
    return UserLocationStatModel(
      country: json['country'] as String,
      userCount: (json['user_count'] as num).toInt(),
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'country': country,
      'user_count': userCount,
      'lat': lat,
      'lng': lng,
    };
  }
}
