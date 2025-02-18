import 'package:flutter/foundation.dart';
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
      backgroundColor: Colors.deepPurple.shade50,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('Home Page', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: kIsWeb
                  ? Row(
                      children: [
                        Expanded(child: _buildJoinForm()),
                        SizedBox(width: 20),
                        Expanded(child: _buildHistory()),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildJoinForm(),
                        SizedBox(height: 20),
                        Expanded(child: _buildHistory()),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  _buildJoinForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: textEditingController,
          decoration: InputDecoration(
              hintText: "Enter Room ID",
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none),
              fillColor: Colors.deepPurple.shade100,
              filled: true,
              prefixIcon: const Icon(Icons.vpn_key, color: Colors.deepPurple)),
        ),
        if (message.isNotEmpty) errorMessageWidget(context, message),
        const SizedBox(height: 15),
        _buildButton("Create Room", () async {
          await Navigator.push(
            context,
            MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => CallPage(),
            ),
          ).then((_) {
            _getCallHistory();
          });
        }),
        const SizedBox(height: 10),
        _buildButton("Join Room", () async {
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
        }),
      ],
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Colors.deepPurple,
      ),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildHistory() {
    if (callHistory.isEmpty) {
      return Center(
        child: Text(
          'No call history available',
          style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
        ),
      );
    }
    return ListView.builder(
      itemCount: callHistory.length,
      itemBuilder: (context, index) {
        final call = callHistory[index];
        return CallTile(call: call);
      },
    );
  }
}
