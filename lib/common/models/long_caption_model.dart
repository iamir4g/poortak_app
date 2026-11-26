enum LongCaptionKey {
  aboutUs('AboutUs'),
  tos('Tos');

  final String value;

  const LongCaptionKey(this.value);
}

class LongCaptionResponse {
  final bool ok;
  final LongCaptionModel data;

  LongCaptionResponse({
    required this.ok,
    required this.data,
  });

  factory LongCaptionResponse.fromJson(Map<String, dynamic> json) {
    return LongCaptionResponse(
      ok: json['ok'] == true,
      data: LongCaptionModel.fromJson(
          (json['data'] as Map).cast<String, dynamic>()),
    );
  }
}

class LongCaptionModel {
  final String id;
  final String key;
  final String caption;

  LongCaptionModel({
    required this.id,
    required this.key,
    required this.caption,
  });

  factory LongCaptionModel.fromJson(Map<String, dynamic> json) {
    return LongCaptionModel(
      id: json['id']?.toString() ?? '',
      key: json['key']?.toString() ?? '',
      caption: json['caption']?.toString() ?? '',
    );
  }

  List<String> get paragraphs => caption
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();
}
