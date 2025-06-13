import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  // cria lista com mensagens
  final List<Map<String, dynamic>> _messages = [
    
  ];

  void _sendMessage() async {
    final userMessage = _controller.text.trim();
    String url = "https://pedroguerra8-chatbot-integrador.hf.space/api/v1/run/99463d46-5a42-4c52-9eaa-c2816ee95d89";
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        'text': userMessage,
        'isMe': true,
        // pega a data e hora da mensagem digitada
        'time': TimeOfDay.now().format(context),
      });
      _controller.clear();
    });
    try{
      final response = await http.post(Uri.parse(url),
      headers: {
        "Content-Type":"application/json"
      },
      body: jsonEncode({
        "input_value":userMessage,
        "output_type":"chat",
        "input_type":"chat"
      })
      );

      if(response.statusCode==200){
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        print("Resposta a API: $decoded");
        final botReply = decoded["outputs"]?[0]?["outputs"]?[0]?["results"]
                ?["message"]?["text"] ??
            "Não entendi sua mensagem";
            // adiciona a resposta do bot na lista de mensagens
            setState(() {
              _messages.add({
               'text':botReply,
               'isMe':false,
               'time':TimeOfDay.now().format(context),
              });
            });
      }else{
        setState(() {
          _messages.add({
            'text':'Erro ao obter resposta do assistente',
            'isMe':false,
            'time':TimeOfDay.now().format(context)
          });
        });
      }
    }catch(e){
      setState(() {
        _messages.add({
        'text':'Erro de conexão $e',
        'isMe':false,
        'time':TimeOfDay.now().format(context)
        });
      });
    }
  }

  // função para limpar as mensagens
  void _limparMessages() {
    setState(() {
      _messages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 105, 105, 105),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'AGROTECH Solutions',
              style: TextStyle(color: Colors.white),
            ),
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person_outline_sharp, color: Colors.black),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    return MessageBubble(
                        text: msg['text'],
                        isMe: msg['isMe'],
                        time: msg['time']);
                  })),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Digite sua mensagem',
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 4),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red[300],
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _limparMessages,
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  // cria variaveis e construtor
  final String text;
  final bool isMe;
  final String time;
  const MessageBubble(
      {super.key, required this.text, required this.isMe, required this.time});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 5),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: isMe ? Colors.green[100] : Colors.grey[300],
                borderRadius: BorderRadius.circular(12)),
            child: Text(text),
          ),
          Text(
            time,
            style: TextStyle(fontSize: 10, color: Colors.grey),
          )
        ],
      ),
    );
  }
}