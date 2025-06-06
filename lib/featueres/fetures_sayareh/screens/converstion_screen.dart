import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/locator.dart';
import 'package:poortak/common/services/tts_service.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/conversation_model.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/converstion_bloc/converstion_bloc.dart';
// import 'package:poortak/featueres/fetures_sayareh/data/models/conversation_model.dart';
// import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/converstion_bloc.dart';
// import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/converstion_event.dart';
// import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/converstion_state.dart';

class ConversationScreen extends StatefulWidget {
  static const routeName = "/conversation_screen";
  final String conversationId;

  const ConversationScreen({
    super.key,
    required this.conversationId,
  });

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final TTSService ttsService = locator<TTSService>();
  bool isPlaying = false;
  int currentPlayingIndex = 0;
  List<Datum>? sortedMessages;
  bool showTranslations = false;

  Future<void> playAllConversations(List<Datum> messages) async {
    if (isPlaying) {
      await ttsService.stop();
      setState(() {
        isPlaying = false;
        currentPlayingIndex = 0;
      });
      return;
    }

    setState(() {
      isPlaying = true;
      currentPlayingIndex = 0;
    });

    try {
      for (var i = 0; i < messages.length; i++) {
        if (!isPlaying) break;

        final message = messages[i];
        setState(() {
          currentPlayingIndex = i;
        });

        // Set voice based on the message's voice field
        if (message.voice == 'male') {
          await ttsService.setPitch(0.3);
        } else if (message.voice == 'female') {
          await ttsService.setPitch(1.0);
        }

        // Wait for the current message to finish playing
        await ttsService.speak(message.text);
        await Future.delayed(const Duration(
            milliseconds: 500)); // Add a small delay between messages
      }
    } finally {
      setState(() {
        isPlaying = false;
        currentPlayingIndex = 0;
      });
    }
  }

  Future<void> speakText(String text, String voice) async {
    // Set voice based on the message's voice field
    if (voice == 'male') {
      await ttsService.setPitch(0.3);
    } else if (voice == 'female') {
      await ttsService.setPitch(1.0);
    }
    await ttsService.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ConverstionBloc(
        sayarehRepository: locator(),
      )..add(GetConversationEvent(id: widget.conversationId)),
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
            style: MyTextStyle.textHeader16Bold,
          ),
        ),
        bottomNavigationBar: Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  if (sortedMessages != null) {
                    playAllConversations(sortedMessages!);
                  }
                },
                icon: Icon(
                  isPlaying ? Icons.stop_circle : Icons.play_circle,
                  size: 30,
                  color: isPlaying ? Colors.red : Colors.green,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    showTranslations = !showTranslations;
                  });
                },
                icon: Icon(
                  Icons.translate,
                  color: showTranslations ? Colors.blue : Colors.grey,
                ),
              ),
            ],
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
              sortedMessages = state.data.data
                ..sort((a, b) => a.order.compareTo(b.order));
              return _buildConversationList(context, state.data);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildConversationList(BuildContext context, ConversationModel data) {
    final ScrollController scrollController = ScrollController();

    Widget buildMessageBubble(Datum message) {
      final isFirstPerson = message.voice == 'male';
      final isCurrentPlaying = sortedMessages != null &&
          currentPlayingIndex < sortedMessages!.length &&
          sortedMessages![currentPlayingIndex].id == message.id;

      return Align(
        alignment: isFirstPerson ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            color: isFirstPerson ? MyColors.primary : Colors.grey[300],
            borderRadius: BorderRadius.circular(20),
            border: isCurrentPlaying
                ? Border.all(color: Colors.green, width: 2)
                : null,
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
              if (showTranslations) ...[
                const SizedBox(height: 4),
                Text(
                  message.translation,
                  style: TextStyle(
                    color: isFirstPerson ? Colors.white70 : Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: sortedMessages?.length ?? 0,
      itemBuilder: (context, index) {
        final message = sortedMessages![index];
        return buildMessageBubble(message);
      },
    );
  }
}
