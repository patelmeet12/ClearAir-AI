import 'package:equatable/equatable.dart';

enum LocationTag {
  home('Home', 'Personal residence where indoor air filtering is prioritized'),
  workplace('Workplace', 'Office / workspace commute destination'),
  school('School', 'Children’s educational facility requiring safe commute times'),
  other('Other', 'Custom saved point of interest');

  final String label;
  final String description;
  const LocationTag(this.label, this.description);
}

class LocationItem extends Equatable {
  final String id;
  final String name;
  final String country;
  final double latitude;
  final double longitude;
  final LocationTag tag;
  final bool isDefault;

  const LocationItem({
    required this.id,
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.tag = LocationTag.other,
    this.isDefault = false,
  });

  LocationItem copyWith({
    String? id,
    String? name,
    String? country,
    double? latitude,
    double? longitude,
    LocationTag? tag,
    bool? isDefault,
  }) {
    return LocationItem(
      id: id ?? this.id,
      name: name ?? this.name,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      tag: tag ?? this.tag,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'country': country,
    'latitude': latitude,
    'longitude': longitude,
    'tag': tag.name,
    'isDefault': isDefault,
  };

  factory LocationItem.fromJson(Map<String, dynamic> json) => LocationItem(
    id: json['id'] as String,
    name: json['name'] as String,
    country: json['country'] as String? ?? '',
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    tag: LocationTag.values.firstWhere(
      (t) => t.name == json['tag'],
      orElse: () => LocationTag.other,
    ),
    isDefault: json['isDefault'] as bool? ?? false,
  );

  @override
  List<Object?> get props => [id, name, country, latitude, longitude, tag, isDefault];
}
