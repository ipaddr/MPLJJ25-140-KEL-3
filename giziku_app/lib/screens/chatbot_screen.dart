import 'package:flutter/material.dart';
import 'package:giziku_app/services/gemini_service.dart'; // Import service Gemini

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];

  void _handleSubmitted(String text) async {
    // Ubah menjadi async
    _textController.clear();
    if (text.isEmpty) return; // Jangan kirim pesan kosong

    ChatMessage message = ChatMessage(
      text: text,
      isUserMessage: true, // Tandai sebagai pesan pengguna
    );
    setState(() {
      _messages.insert(0, message); // Tambahkan pesan pengguna ke daftar
    });

    // Tampilkan indikator loading atau pesan "mengetik" dari bot (opsional)
    // Anda bisa menambahkan ChatMessage sementara dengan teks "Bot sedang mengetik..."

    // Kirim pesan ke Gemini API
    String botResponse = await getGeminiResponse(text);

    // Setelah mendapat respons dari bot, tambahkan ke _messages
    // Pastikan widget masih mounted sebelum memanggil setState
    if (mounted) {
      //   ChatMessage botMessage = ChatMessage(
      //     text: "Ini adalah respons dari bot untuk: $text",
      //     isUserMessage: false,
      //   );
      //   setState(() {
      //     _messages.insert(0, botMessage);
      //   });
      ChatMessage botMessage = ChatMessage(
        text: botResponse,
        isUserMessage: false, // Tandai sebagai pesan bot
      );
      setState(() {
        _messages.insert(0, botMessage); // Tambahkan respons bot ke daftar
      });
    }
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: _handleSubmitted,
                decoration:
                    const InputDecoration.collapsed(hintText: 'Kirim pesan'),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => _handleSubmitted(_textController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios), // Ikon kustom
          onPressed: () {
            Navigator.pop(context); // Perilaku default
          },
        ),
        title: const Text('Giziku Chatbot'),
      ),
      body: Column(
        children: [
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              reverse: true, // Pesan terbaru di bawah
              itemBuilder: (_, int index) => _messages[index],
              itemCount: _messages.length,
            ),
          ),
          const Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  const ChatMessage({
    required this.text,
    required this.isUserMessage,
    super.key,
  });

  final String text;
  final bool isUserMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUserMessage) // Avatar bot di kiri
            Container(
              margin: const EdgeInsets.only(right: 16.0),
              child: CircleAvatar(child: Text('B')), // Placeholder avatar bot
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: isUserMessage
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(isUserMessage ? 'Anda' : 'GizBot',
                    style: Theme.of(context).textTheme.titleMedium),
                Container(
                  margin: const EdgeInsets.only(top: 5.0),
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: isUserMessage
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: isUserMessage ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isUserMessage) // Avatar pengguna di kanan
            Container(
              margin: const EdgeInsets.only(left: 16.0),
              child: CircleAvatar(child: Text('U')), // Placeholder avatar user
            ),
        ],
      ),
    );
  }
}
