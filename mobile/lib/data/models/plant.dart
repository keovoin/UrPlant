
class Plant {
  final String id;
  final String nameEn;
  final String nameKh;
  final String scientificName;
  final String family;
  final String genus;
  final String species;
  final String rarity;
  final String description;
  final String origin;
  final String characteristics;
  final String habitat;
  final String uses;
  final Map<String, dynamic> care;
  final List<String> funFacts;
  final String imageUrl;
  final int totalUnlocks;
  final String thumbnailUrl;

  Plant({
    required this.id,
    this.nameEn = '',
    this.nameKh = '',
    this.scientificName = '',
    this.family = '',
    this.genus = '',
    this.species = '',
    this.rarity = 'normal',
    this.description = '',
    this.origin = '',
    this.characteristics = '',
    this.habitat = '',
    this.uses = '',
    this.care = const {},
    this.funFacts = const [],
    this.imageUrl = '',
    this.totalUnlocks = 0,
    this.thumbnailUrl = '',
  });

  factory Plant.fromMap(String id, Map<String, dynamic> data) => Plant(
    id: id,
    nameEn: data['name_en'] ?? '',
    nameKh: data['name_kh'] ?? '',
    scientificName: data['scientific_name'] ?? '',
    family: data['family'] ?? '',
    genus: data['genus'] ?? '',
    species: data['species'] ?? '',
    rarity: data['rarity'] ?? 'normal',
    description: data['description'] ?? data['description_en'] ?? '',
    origin: data['origin'] ?? data['origin_en'] ?? '',
    characteristics: data['characteristics'] ?? data['characteristics_en'] ?? '',
    habitat: data['habitat'] ?? data['habitat_en'] ?? '',
    uses: data['uses'] ?? data['uses_en'] ?? '',
    care: data['care'] is Map ? Map<String, dynamic>.from(data['care']) : {},
    funFacts: data['fun_facts'] is List
        ? List<String>.from(data['fun_facts'].map((e) => e.toString()))
        : [],
    imageUrl: data['image_url'] ?? (data['image_urls'] is List && (data['image_urls'] as List).isNotEmpty ? (data['image_urls'] as List).first.toString() : ''),
    totalUnlocks: (data['total_unlocks'] ?? 0) as int,
    thumbnailUrl: data['thumbnail_url'] ?? '',
  );

  String localizedName(bool isKh) => isKh && nameKh.isNotEmpty ? nameKh : nameEn;
  String localizedDescription(bool isKh) => description;
  String localizedOrigin(bool isKh) => origin;
  Map<String, dynamic>? localizedCare(bool isKh) => care.isNotEmpty ? care : null;
  List<String> localizedFunFacts(bool isKh) => funFacts;
}

class UserPlant {
  final String plantId;
  final String rarity;
  final String thumbnailUrl;
  final String photoUrl;
  final int sightingCount;
  final DateTime unlockedAt;
  final List<String> commonNames;

  UserPlant({
    required this.plantId,
    this.rarity = 'normal',
    this.thumbnailUrl = '',
    this.photoUrl = '',
    this.sightingCount = 0,
    this.commonNames = const [],
    required this.unlockedAt,
  });

  String get displayName => commonNames.isNotEmpty
      ? commonNames.first
      : plantId
          .split(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}'))
          .last
          .replaceAll(RegExp(r'^_+'), '')
          .replaceAll('_', ' ')
          .trim();

  factory UserPlant.fromMap(Map<String, dynamic> data) => UserPlant(
    plantId: data['plant_id'] ?? '',
    rarity: data['rarity'] ?? 'normal',
    thumbnailUrl: data['thumbnail_url'] ?? '',
    photoUrl: data['photo_url'] ?? '',
    sightingCount: data['sighting_count'] ?? 0,
    commonNames: (data['ai_data'] is Map && (data['ai_data'] as Map)['common_names'] is List)
        ? List<String>.from(((data['ai_data'] as Map)['common_names'] as List).map((e) => e.toString()))
        : const [],
    unlockedAt: (data['unlocked_at'] as dynamic)?.toDate() ?? DateTime.now(),
  );
}