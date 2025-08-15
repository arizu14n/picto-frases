class Category {
  final int id;
  final String name;
  final String? userId;

  Category({
    required this.id,
    required this.name,
    this.userId,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      userId: json['user_id'] as String?,
    );
  }
}