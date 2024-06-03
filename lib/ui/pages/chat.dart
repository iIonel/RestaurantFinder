import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:restaurant_finder/controllers/user_controller.dart';
import 'package:restaurant_finder/data/services/api_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatPage extends StatefulWidget {
  final String otherUserName;

  const ChatPage({super.key, required this.otherUserName});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  late Timer _timer;
  final UserController _userController = UserController();

  @override
  void initState() {
    super.initState();
    _getMessages();

    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _getMessages();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.otherUserName.split('@').first}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isSentByCurrentUser = message['sender'] == _userController.getEmail();

                return Align(
                  alignment: isSentByCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSentByCurrentUser ? Colors.blueAccent : Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        message['content']!,
                        style: TextStyle(color: isSentByCurrentUser ? Colors.white : Colors.black),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(hintText: 'Enter your message'),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    String message = _messageController.text.trim();
    if (message.isNotEmpty) {
      try {
        var response = await ApiService.postRequest(
          dotenv.env['SEND_MESSAGE_URL']!,
          queryParams: {
            'sender': _userController.getEmail(),
            'receiver': widget.otherUserName,
            'content': message,
          },
        );

        if (response.statusCode == 200) {
          _messageController.clear();
          _getMessages();
        } else {
          if (kDebugMode) {
            print('Failed to send message: ${response.statusCode}');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Network error: $e');
        }
      }
    }
  }

  void _getMessages() async {
    try {
      var response = await ApiService.getRequest(dotenv.env['GET_MESSAGES_URL']!);
      if (response.statusCode == 200) {
        List<dynamic> messages = jsonDecode(response.body);
        setState(() {
          _messages.clear();
          messages.sort((a, b) => a['time']['_seconds'].compareTo(b['time']['_seconds']));
          _messages.addAll(messages.map((message) => {
            'sender': message['sender'],
            'content': message['content']
          }));
        });
      } else {
        if (kDebugMode) {
          print('Failed to get messages: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Network error: $e');
      }
    }
  }
}
