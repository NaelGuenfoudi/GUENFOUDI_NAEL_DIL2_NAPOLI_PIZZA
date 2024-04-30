import 'package:flutter/material.dart';
import 'package:pizza/pizza_list_screen.dart';
import 'package:provider/provider.dart';
import 'authentification.dart';
import 'login_page.dart'; // Assurez-vous que ce fichier contient LoginPage et SignUpPage
import 'register_page.dart'; // Assurez-vous que ce fichier contient LoginPage et SignUpPage

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DioClient>(
          create: (_) => DioClient(),
          dispose: (_, dioClient) => dioClient.dio.close(),
        ),
        ChangeNotifierProvider<AuthService>(
          create: (context) => AuthService(Provider.of<DioClient>(context, listen: false)),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: LoginPage(),
        routes: {
          '/login': (context) => LoginPage(),
          '/signup': (context) => SignUpPage(),
          '/home': (context) => PizzaListScreen(),
        },
      ),
    );
  }
}

