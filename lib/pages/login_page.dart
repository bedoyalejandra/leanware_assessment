import 'package:flutter/material.dart';
import 'package:leanware_assessment/pages/home_page.dart';
import 'package:leanware_assessment/pages/signup_page.dart';
import 'package:leanware_assessment/utils/widgets/error_message.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _email = TextEditingController();
  final _password = TextEditingController();
  String errorMessage = '';

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _headerComponent(),
            _inputFieldComponent(),
            _forgotPasswordComponent(),
            _signupComponent(),
          ],
        ),
      ),
    );
  }

  _headerComponent() {
    return const Column(
      children: [
        Text(
          "Welcome Back",
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        Text("Enter your credential to login"),
      ],
    );
  }

  _inputFieldComponent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _email,
          decoration: InputDecoration(
              hintText: "Email",
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none),
              fillColor: Colors.deepPurple.withOpacity(0.1),
              filled: true,
              prefixIcon: const Icon(Icons.email)),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _password,
          decoration: InputDecoration(
            hintText: "Password",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none),
            fillColor: Colors.deepPurple.withOpacity(0.1),
            filled: true,
            prefixIcon: const Icon(Icons.lock),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 10),
        if (errorMessage.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: errorMessageWidget(context, errorMessage),
          ),
        ElevatedButton(
          onPressed: _login,
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.deepPurple,
          ),
          child: const Text(
            "Login",
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        )
      ],
    );
  }

  _forgotPasswordComponent() {
    return TextButton(
      onPressed: _resetPassword,
      child: const Text(
        "Forgot password?",
        style: TextStyle(color: Colors.deepPurple),
      ),
    );
  }

  _signupComponent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account? "),
        TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => SignupPage()),
              );
            },
            child: const Text(
              "Sign Up",
              style: TextStyle(color: Colors.deepPurple),
            ))
      ],
    );
  }

  bool _validateFields() {
    if (_email.text.isEmpty || _password.text.isEmpty) {
      setState(() {
        errorMessage = 'All fields are required';
      });
      return false;
    }
    return true;
  }

  Future<void> _login() async {
    setState(() {
      errorMessage = '';
    });

    if (_validateFields()) {
      try {
        await _auth.signInWithEmailAndPassword(
          email: _email.text.trim(),
          password: _password.text.trim(),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } catch (e) {
        String errorMsg = 'An unknown error occurred';

        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'user-not-found':
              errorMsg = 'No user found for this email';
              break;
            case 'wrong-password':
              errorMsg = 'Incorrect password';
              break;
            case 'invalid-email':
              errorMsg = 'The email address is not valid';
              break;
            default:
              errorMsg = 'Error: ${e.message}';
          }
        }

        setState(() {
          errorMessage = errorMsg;
        });
      }
    }
  }

  Future<void> _resetPassword() async {
    if (_email.text.isEmpty) {
      setState(() {
        errorMessage = 'Please enter your email to reset password';
      });
      return;
    }
    try {
      await _auth.sendPasswordResetEmail(email: _email.text);
      setState(() {
        errorMessage = 'Password reset email sent! Check your inbox.';
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    }
  }
}
