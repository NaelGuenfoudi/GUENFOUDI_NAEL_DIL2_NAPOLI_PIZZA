import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'authentification.dart';  // Assurez-vous d'avoir AuthService dans ce fichier

class LoginPage extends StatelessWidget {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              
              controller: _emailController..text="guenfmen@gmail.com",
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController..text="azerty123",
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                bool success = await authService.signIn(
                  _emailController.text,
                  _passwordController.text,
                );
                if (success) {
                  Navigator.pushReplacementNamed(context, '/home');
                } else {
                  Fluttertoast.showToast(msg: "Login Failed");
                }
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
