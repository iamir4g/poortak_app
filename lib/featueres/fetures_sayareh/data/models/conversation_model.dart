class Message {
  final int id;
  final String text;

  Message({required this.id, required this.text});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      text: json['text'],
    );
  }
}

class ConversationData {
  final List<Message> firstPerson;
  final List<Message> secondPerson;

  ConversationData({
    required this.firstPerson,
    required this.secondPerson,
  });

  factory ConversationData.fromJson(Map<String, dynamic> json) {
    return ConversationData(
      firstPerson: (json['firstPerson'] as List)
          .map((e) => Message.fromJson(e))
          .toList(),
      secondPerson: (json['secondPerson'] as List)
          .map((e) => Message.fromJson(e))
          .toList(),
    );
  }
}
