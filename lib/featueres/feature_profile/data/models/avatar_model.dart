class AvatarModel {
  final String id;
  final String fileKey;

  AvatarModel({
    required this.id,
    required this.fileKey,
  });

  factory AvatarModel.fromJson(Map<String, dynamic> json) {
    return AvatarModel(
      id: json['id'] as String,
      fileKey: json['fileKey'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileKey': fileKey,
    };
  }
}
