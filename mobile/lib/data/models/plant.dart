class Plant {
  final String id;
  final String nameEn;
  final String nameKh;
  final String scientificName;
  final String family;
  final String genus;
  final String species;
  final String rarity;
  final String descriptionEn;
  final String descriptionKh;
  final String originEn;
  final String originKh;
  final Map<String, String>? careEn;
  final Map<String, String>? careKh;
  final List<String> funFactsEn;
  final List<String> funFactsKh;
  final String imageUrl;
  final String thumbnailUrl;
  final bool verified;
  final int totalUnlocks;

  Plant({
    required this.id,
    required this.nameEn,
    required this.nameKh,
    required this.scientificName,
    required this.family,
    required this.genus,
    required this.species,
    required this.rarity,
    this.descriptionEn = '',
    this.descriptionKh = '',
    this.originEn = '',
    this.originKh = '',
    this.careEn,
    this.careKh,
    this.funFactsEn = const [],
    this.funFactsKh = const [],
    this.imageUrl = '',
    this.thumbnailUrl = '',
    this.verified = false,
    this.totalUnlocks = 0,
  });

  factory Plant.fromMap(String id, Map<String, dynamic> data) {
    return Plant(
      id: id,
      nameEn: data['name_en'] ?? '',
      nameKh: data['name_kh'] ?? '',
      scientificName: data['scientific_name'] ?? '',
      family: data['family'] ?? '',
      genus: data['genus'] ?? '',
      species: data['species'] ?? '',
      rarity: data['rarity'] ?? 'normal',
      descriptionEn: data['description_en'] ?? '',
      descriptionKh: data['description_kh'] ?? '',
      originEn: data['origin_en'] ?? '',
      originKh: data['origin_kh'] ?? '',
      careEn: data['care_en'] != null
          ? Map<String, String>.from(data['care_en'])
          : null,
      careKh: data['care_kh'] != null
          ? Map<String, String>.from(data['care_kh'])
          : null,
      funFactsEn: List<String>.from(data['fun_facts_en'] ?? []),
      funFactsKh: List<String>.from(data['fun_facts_kh'] ?? []),
      imageUrl: data['image_urls']?.isNotEmpty == true
          ? data['image_urls'][0]
          : (data['image_url'] ?? ''),
      thumbnailUrl: data['thumbnail_url'] ?? '',
      verified: data['verified'] ?? false,
      totalUnlocks: data['total_unlocks'] ?? 0,
    );
  }

  String localizedName(bool isKh) => isKh ? nameKh : nameEn;
  String localizedDescription(bool isKh) =>
      isKh && descriptionKh.isNotEmpty ? descriptionKh : descriptionEn;
  String localizedOrigin(bool isKh) =>
      isKh && originKh.isNotEmpty ? originKh : originEn;
  Map<String, String>? localizedCare(bool isKh) =>
      (isKh && careKh != null) ? careKh : careEn;
  List<String> localizedFunFacts(bool isKh) =>
      (isKh && funFactsKh.isNotEmpty) ? funFactsKh : funFactsEn;
}

class UserPlant {
  final String plantId;
  final String? rarity;
  final String photoUrl;
  final String thumbnailUrl;
  final DateTime unlockedAt;
  final int sightingCount;

  UserPlant({
    required this.plantId,
    this.rarity,
    required this.photoUrl,
    required this.thumbnailUrl,
    required this.unlockedAt,
    this.sightingCount = 1,
  });

  factory UserPlant.fromMap(Map<String, dynamic> data) {
    return UserPlant(
      plantId: data['plant_id'] ?? '',
      rarity: data['rarity'],
      photoUrl: data['photo_url'] ?? '',
      thumbnailUrl: data['thumbnail_url'] ?? '',
      unlockedAt: (data['unlocked_at'] as dynamic)?.toDate() ?? DateTime.now(),
      sightingCount: data['sighting_count'] ?? 1,
    );
  }
}