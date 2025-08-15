
import 'package:uuid/uuid.dart';

class Pictogram {
  final int id;
  final String name;
  final String imageUrl;
  final String? audioUrl;
  final int? categoryId;
  final String? userId;
  final String uuid;

  static final _uuid = Uuid();

  Pictogram({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.audioUrl,
    this.categoryId,
    this.userId,
    String? uuid,
  }) : uuid = uuid ?? _uuid.v4();

  factory Pictogram.fromMap(Map<String, dynamic> map) {
    return Pictogram(
      id: map['id'] as int,
      name: map['name'] as String,
      imageUrl: map['image_url'] as String,
      audioUrl: map['audio_url'] as String?,
      categoryId: map['category_id'] as int?,
      userId: map['user_id'] as String?,
      uuid: map['uuid'] as String? ?? _uuid.v4(), // Generate if not present in map
    );
  }

  // Named constructor for text-only pictograms
  factory Pictogram.fromText(String text) {
    return Pictogram(
      id: -1, // A special ID for text-only items
      name: text,
      imageUrl: '', // Empty string to indicate no image
      audioUrl: null,
      categoryId: null,
      userId: null,
      uuid: _uuid.v4(), // Generate a new UUID for text items
    );
  }

  factory Pictogram.fromArasaacJson(Map<String, dynamic> json) {
    final String baseUrl = 'https://api.arasaac.org/v1/pictograms/';
    final int arasaacId = json['_id'] as int;
    final String name = (json['keywords'] as List).isNotEmpty
        ? (json['keywords'][0]['keyword'] as String)
        : 'Sin nombre'; // Fallback if no keyword

    return Pictogram(
      id: arasaacId, // Use ARASAAC's ID
      name: name,
      imageUrl: '$baseUrl$arasaacId/image',
      audioUrl: json['audio'] != null ? '$baseUrl$arasaacId/audio' : null,
      categoryId: null, // Categories are complex, handle separately
      userId: null, // ARASAAC pictograms are not user-specific
      uuid: _uuid.v4(), // Generate a new UUID for our internal use
    );
  }
}
