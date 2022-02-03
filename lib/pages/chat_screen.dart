import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late TextEditingController _controller;

  List<String> items = [];

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, false);
        return Future.value(false);
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.indigo,
            titleSpacing: 0,
            title: const Text(
              'Chat Screen',
              style: TextStyle(color: Colors.white),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final String item = items[index];

                    return _buildListItem(item, index);
                  },
                ),
              ),
              Container(
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            hintText: 'Enter Text',
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.white),
                      ),
                      onPressed: () {},
                      child: IconButton(
                        icon: const Icon(
                          Icons.send,
                          color: Colors.indigo,
                        ),
                        onPressed: () {
                          if (_controller.text.replaceAll(' ', '').isNotEmpty) {
                            items.add(_controller.text);
                            _controller.text = '';
                          } else {
                            const snackBar = SnackBar(
                                content:
                                    Text('Please type a message to send.'));
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          }
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListItem(String data, int pos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Wrap(
            children: [Text(data)],
          ),
        ),
        (pos == items.length)
            ? Container()
            : const Divider(
                color: Colors.grey,
                height: 1,
              ),
      ],
    );
  }
}
