import 'package:flutter/material.dart';
import 'package:cousify_frontend/services/ai_service.dart';
import 'package:cousify_frontend/utils/colors.dart';

class AiChatScreen extends StatefulWidget {
  final String courseTitle;
  final int? courseId;

  const AiChatScreen({Key? key, required this.courseTitle, this.courseId}) : super(key: key);

  @override
  _AiChatScreenState createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addMessage(String text, String sender) {
    setState(() {
      _messages.add({'sender': sender, 'text': text});
    });
    // ensure the list scrolls to bottom
    Future.delayed(Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    _controller.clear();
    _addMessage(text, 'user');

    setState(() => _isSending = true);
    // show typing indicator
    _addMessage('...', 'ai');

    try {
      final answer = await AiService.ask(text, courseId: widget.courseId);

      // debug prints removed

      // replace the typing indicator with the real answer
      setState(() {
        final idx = _messages.indexWhere((m) => m['text'] == '...' && m['sender'] == 'ai');
        if (idx >= 0) {
          _messages[idx] = {'sender': 'ai', 'text': answer};
        } else {
          _messages.add({'sender': 'ai', 'text': answer});
        }
      });
    } catch (e) {
      setState(() {
        final idx = _messages.indexWhere((m) => m['text'] == '...' && m['sender'] == 'ai');
        if (idx >= 0) {
          _messages[idx] = {'sender': 'ai', 'text': 'Error contacting AI service.'};
        }
      });
    } finally {
      setState(() => _isSending = false);
    }
  }

  Widget _buildBubble(Map<String, String> msg) {
    final isAi = msg['sender'] == 'ai';
    final text = msg['text'] ?? '';
    if (isAi) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primaryColor,
            child: Icon(Icons.smart_toy_outlined, color: Colors.white),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Text(
                text,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          SizedBox(width: 40),
        ],
      );
    }

    // user bubble (right aligned)
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 40),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
            child: Text(
              text,
              style: TextStyle(color: Colors.black87),
            ),
          ),
        ),
        SizedBox(width: 8),
        CircleAvatar(
          backgroundColor: Colors.grey[400],
          child: Icon(Icons.person, color: Colors.white),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text('Course chat', style: TextStyle(color: Colors.black)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return _buildBubble(msg);
                },
              ),
            ),

            // Input area
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Type message here...',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    height: 48,
                    width: 48,
                    child: ElevatedButton(
                      onPressed: _sendMessage,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        backgroundColor: AppColors.primaryColor,
                      ),
                      child: Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
