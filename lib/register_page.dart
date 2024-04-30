import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'authentification.dart';  // Assurez-vous d'avoir AuthService dans ce fichier

class SignUpPage extends StatelessWidget {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                bool success = await authService.signUp(
                  _emailController.text,
                  _passwordController.text,
                );
                if (success) {
                  Fluttertoast.showToast(msg: "Registration Successful");
                  Navigator.pop(context); // Optionally go back to login page or directly to home
                } else {
                  Fluttertoast.showToast(msg: "Registration Failed");
                }
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
