/// Health tip / article model stored in Firestore `healthTips` collection
class HealthTipModel {
  final String id;
  final String title;
  final String content;
  final String? imageUrl;
  final String? category;
  final DateTime createdAt;
  final String createdBy;

  const HealthTipModel({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    this.category,
    required this.createdAt,
    required this.createdBy,
  });

  factory HealthTipModel.fromJson(Map<String, dynamic> json) {
    return HealthTipModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String?,
      category: json['category'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'imageUrl': imageUrl,
        'category': category,
        'createdAt': createdAt.toIso8601String(),
        'createdBy': createdBy,
      };

  HealthTipModel copyWith({
    String? id,
    String? title,
    String? content,
    String? imageUrl,
    String? category,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return HealthTipModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
