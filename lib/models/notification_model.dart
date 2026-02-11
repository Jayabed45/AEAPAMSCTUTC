class NotificationModel {
  final String id;
  final String title;
  final String description;
  final String time;
  final bool isUnread;
  final String iconName; // Store icon name as string for backend compatibility
  final String? iconColorHex;

  NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.isUnread,
    required this.iconName,
    this.iconColorHex,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      time: json['time'],
      isUnread: json['is_unread'] ?? false,
      iconName: json['icon_name'],
      iconColorHex: json['icon_color_hex'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'time': time,
      'is_unread': isUnread,
      'icon_name': iconName,
      'icon_color_hex': iconColorHex,
    };
  }
}
