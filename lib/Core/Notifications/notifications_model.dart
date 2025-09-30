class NotificationModel {
  final String title;
  final String body;
  final String? image;
  final Map<String, dynamic>? data;

  NotificationModel({
    required this.title,
    required this.body,
    this.image,
    this.data,
  });

  Map<String, dynamic> toPayload() {
    return {
      'title': title,
      'body': body,
      if (image != null) 'image': image,
      if (data != null) 'data': data,
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      image: json['image'],
      data: json['data'] != null
          ? Map<String, dynamic>.from(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'body': body, 'image': image, 'data': data};
  }
}
