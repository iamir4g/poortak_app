import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/locator.dart';
import 'package:poortak/common/services/tts_service.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/conversation_model.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/converstion_bloc.dart';
// import 'package:poortak/featueres/fetures_sayareh/data/models/conversation_model.dart';
// import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/converstion_bloc.dart';
// import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/converstion_event.dart';
// import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/converstion_state.dart';

class ConversationScreen extends StatelessWidget {
  static const routeName = "/conversation_screen";
  final String conversationId;

  const ConversationScreen({
    super.key,
    required this.conversationId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ConverstionBloc(
        sayarehRepository: locator(),
      )..add(GetConversationEvent(id: conversationId)),
      child: Scaffold(
        backgroundColor: MyColors.secondaryTint4,
        appBar: AppBar(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
            ),
          ),
          title: const Text(
            'مکالمه',
            style: MyTextStyle.textMatn16,
          ),
        ),
        body: BlocBuilder<ConverstionBloc, ConverstionState>(
          builder: (context, state) {
            if (state is ConverstionLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ConverstionError) {
              return Center(child: Text(state.message));
            }

            if (state is ConverstionSuccess) {
              return _buildConversationList(context, state.data);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildConversationList(BuildContext context, ConversationModel data) {
    final TTSService ttsService = locator<TTSService>();
    final ScrollController scrollController = ScrollController();

    Future<void> speakText(String text, String voice) async {
      // Set voice based on the message's voice field
      if (voice == 'male') {
        await ttsService.setPitch(0.3);
      } else if (voice == 'female') {
        await ttsService.setPitch(1.0);
      }
      await ttsService.speak(text);
    }

    Widget buildMessageBubble(Datum message) {
      final isFirstPerson = message.voice == 'male';

      return Align(
        alignment: isFirstPerson ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            color: isFirstPerson ? MyColors.primary : Colors.grey[300],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.text,
                style: TextStyle(
                  color: isFirstPerson ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                message.translation,
                style: TextStyle(
                  color: isFirstPerson ? Colors.white70 : Colors.black54,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.volume_up,
                      color: isFirstPerson ? Colors.white : Colors.black,
                      size: 20,
                    ),
                    onPressed: () => speakText(message.text, message.voice),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // Sort messages by order
    final sortedMessages = data.data
      ..sort((a, b) => a.order.compareTo(b.order));

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: sortedMessages.length,
      itemBuilder: (context, index) {
        final message = sortedMessages[index];
        return buildMessageBubble(message);
      },
    );
  }
}
