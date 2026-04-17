class AnnouncementModel {
  final int id;
  final String title;
  final String body;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isRead;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    required this.createdAt,
    this.updatedAt,
    this.isRead = false,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      body: json['content'] ?? json['body'] ?? '',
      imageUrl: json['imageUrl'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
      isRead: json['isRead'] ?? false,
    );
  }
}
