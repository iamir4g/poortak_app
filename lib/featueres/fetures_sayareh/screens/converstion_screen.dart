import 'package:flutter/material.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/locator.dart';
import 'package:poortak/common/services/tts_service.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/conversation_model.dart';
import 'dart:convert';

class ConversationScreen extends StatefulWidget {
  static const routeName = "/conversation_screen";
  const ConversationScreen({super.key});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final TTSService _ttsService = locator<TTSService>();
  late ConversationData _conversationData;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadConversationData();
  }

  void _loadConversationData() {
    final jsonData = '''
    {
      "data": {
        "firstPerson": [
          {"id": 0, "text": "hello"},
          {"id": 2, "text": "how are you to day saba?"},
          {"id": 5, "text": "all good"}
        ],
        "secondPerson": [
          {"id": 1, "text": "hello amir"},
          {"id": 3, "text": "thank's. all good"},
          {"id": 4, "text": "how are you to day amir?"}
        ]
      }
    }
    ''';

    final Map<String, dynamic> jsonMap = json.decode(jsonData);
    _conversationData = ConversationData.fromJson(jsonMap['data']);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _ttsService.dispose();
    super.dispose();
  }

  Future<void> _speakText(String text) async {
    await _ttsService.speak(text);
  }

  Widget _buildMessageBubble(Message message, bool isFirstPerson) {
    return Align(
      alignment: isFirstPerson ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: isFirstPerson ? MyColors.primary : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: isFirstPerson ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                Icons.volume_up,
                color: isFirstPerson ? Colors.white : Colors.black,
                size: 20,
              ),
              onPressed: () => _speakText(message.text),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.secondaryTint4,
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
          ),
        ),
        title: const Text('مکالمه'),
      ),
      body: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _conversationData.firstPerson.length +
            _conversationData.secondPerson.length,
        itemBuilder: (context, index) {
          // Sort messages by ID
          final allMessages = [
            ..._conversationData.firstPerson.map((m) => (m, true)),
            ..._conversationData.secondPerson.map((m) => (m, false)),
          ]..sort((a, b) => a.$1.id.compareTo(b.$1.id));

          final (message, isFirstPerson) = allMessages[index];
          return _buildMessageBubble(message, isFirstPerson);
        },
      ),
    );
  }
}
