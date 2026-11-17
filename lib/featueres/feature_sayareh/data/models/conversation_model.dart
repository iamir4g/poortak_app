// To parse this JSON data, do
//
//     final conversationModel = conversationModelFromJson(jsonString);

import 'dart:convert';

ConversationModel conversationModelFromJson(String str) =>
    ConversationModel.fromJson(json.decode(str));

String conversationModelToJson(ConversationModel data) =>
    json.encode(data.toJson());

class ConversationModel {
  bool ok;
  Meta meta;
  List<Datum> data;

  ConversationModel({
    required this.ok,
    required this.meta,
    required this.data,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    final rawData = json["data"];
    final items = rawData is List ? rawData : const [];
    return ConversationModel(
      ok: json["ok"] == true,
      meta: Meta.fromJson(
        (json["meta"] as Map?)?.cast<String, dynamic>() ?? {},
      ),
      data: List<Datum>.from(
        items.whereType<Map>().map(
              (x) => Datum.fromJson(x.cast<String, dynamic>()),
            ),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        "ok": ok,
        "meta": meta.toJson(),
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Datum {
  String id;
  String text;
  String translation;
  String voice;
  String? voiceFileId;
  String? voiceChecksum;
  String? avatarId;
  int order;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic disabledAt;
  String courseId;

  Datum({
    required this.id,
    required this.text,
    required this.translation,
    required this.voice,
    this.voiceFileId,
    this.voiceChecksum,
    this.avatarId,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
    required this.disabledAt,
    required this.courseId,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        text: json["text"],
        translation: json["translation"],
        voice: json["voice"],
        voiceFileId: json["voiceFileId"]?.toString(),
        voiceChecksum: json["voiceChecksum"]?.toString(),
        avatarId: json["avatarId"],
        order: json["order"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        disabledAt: json["disabledAt"],
        courseId: json["courseId"]?.toString() ?? "",
      );

  bool get isDisabled => _hasDisabledAt(disabledAt);

  Map<String, dynamic> toJson() => {
        "id": id,
        "text": text,
        "translation": translation,
        "voice": voice,
        "voiceFileId": voiceFileId,
        "voiceChecksum": voiceChecksum,
        "avatarId": avatarId,
        "order": order,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "disabledAt": disabledAt,
        "courseId": courseId,
      };
}

extension ConversationSpeaker on Datum {
  /// صدای آقا
  bool get isMaleSpeaker {
    final v = voice.toLowerCase().trim();
    return v == 'male' || v == 'm' || v == 'man' || v.contains('robot');
  }

  /// صدای خانم (هر چیزی غیر از male)
  bool get isFemaleSpeaker => !isMaleSpeaker;

  String get playbackVoice => isMaleSpeaker ? 'male' : 'female';
}

bool _hasDisabledAt(dynamic value) {
  if (value == null) return false;
  if (value is String && value.trim().isEmpty) return false;
  return true;
}

class Meta {
  String? checksum;

  Meta({this.checksum});

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
        checksum: json["checksum"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "checksum": checksum,
      };
}
