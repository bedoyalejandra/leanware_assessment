import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:leanware_assessment/models/call_history.dart';
import 'package:leanware_assessment/pages/call_page.dart';
import 'package:leanware_assessment/pages/login_page.dart';
import 'package:leanware_assessment/providers/call_history_provider.dart';
import 'package:leanware_assessment/utils/widgets/error_message.dart';
import 'package:leanware_assessment/widget/call_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? user;
  late String userId;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController textEditingController = TextEditingController();
  String message = '';
  CallHistoryProvider? callHistoryProvider;
  List<CallHistoryModel> callHistory = [];

  @override
  void initState() {
    super.initState();

    FirebaseAuth auth = FirebaseAuth.instance;
    user = auth.currentUser;
    if (user != null) {
      userId = user!.uid;
      callHistoryProvider = CallHistoryProvider(userId);
      _getCallHistory();
    }
  }

  @override
  void dispose() {
    super.dispose();
    textEditingController.clear();
  }

  Future<void> _logout() async {
    try {
      await _auth.signOut();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  void _getCallHistory() async {
    callHistory = await callHistoryProvider?.getCallHistory() ?? [];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Home Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _logout,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: textEditingController,
                decoration: InputDecoration(
                    hintText: "RoomId",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none),
                    fillColor: Colors.purple.withOpacity(0.1),
                    filled: true,
                    prefixIcon: const Icon(Icons.key)),
              ),
              if (message.isNotEmpty) errorMessageWidget(context, message),
              SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute<dynamic>(
                      builder: (BuildContext context) => CallPage(),
                    ),
                  ).then((_) {
                    _getCallHistory();
                  });
                },
                style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.purple,
                ),
                child: const Text(
                  "Create Room",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () async {
                  if (textEditingController.text.isEmpty) {
                    setState(() {
                      message = 'Please enter a room Id';
                    });
                    return;
                  }
                  await Navigator.push(
                    context,
                    MaterialPageRoute<dynamic>(
                      builder: (BuildContext context) => CallPage(
                        roomId: textEditingController.text,
                      ),
                    ),
                  ).then((_) {
                    _getCallHistory();
                  });
                },
                style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.purple,
                ),
                child: const Text(
                  "Join Room",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              // Mostrar el historial de llamadas
              Expanded(
                child: ListView.builder(
                  itemCount: callHistory.length,
                  itemBuilder: (context, index) {
                    final call = callHistory[index];
                    return CallTile(call: call);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
