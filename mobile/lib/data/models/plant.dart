import 'dart:convert';

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
    imageUrl: data['image_url'] ?? '',
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

  UserPlant({
    required this.plantId,
    this.rarity = 'normal',
    this.thumbnailUrl = '',
    this.photoUrl = '',
    this.sightingCount = 0,
    required this.unlockedAt,
  });

  factory UserPlant.fromMap(Map<String, dynamic> data) => UserPlant(
    plantId: data['plant_id'] ?? '',
    rarity: data['rarity'] ?? 'normal',
    thumbnailUrl: data['thumbnail_url'] ?? '',
    photoUrl: data['photo_url'] ?? '',
    sightingCount: data['sighting_count'] ?? 0,
    unlockedAt: (data['unlocked_at'] as dynamic)?.toDate() ?? DateTime.now(),
  );
}