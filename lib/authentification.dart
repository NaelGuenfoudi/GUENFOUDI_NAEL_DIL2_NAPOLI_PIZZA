import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';


class DioClient {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://pizzas.shrp.dev',
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
    ),
  );
  final FlutterSecureStorage storage = FlutterSecureStorage();

  DioClient() {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        var token = await storage.read(key: "accessToken");
        if (token != null) {
          options.headers["Authorization"] = "Bearer $token";
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        handler.next(response);
      },
      onError: (DioError e, handler) async {
        if (e.response?.statusCode == 401) {
          await   refreshToken();
          handler.resolve(await retry(e.requestOptions));
        } else {
          handler.next(e);
        }
      },
    ));
  }

  Future<void> refreshToken() async {
    var refreshToken = await storage.read(key: "refreshToken");
    var response = await dio.post('/auth/refresh', data: {
      'refresh_token': refreshToken,
    });
    if (response.statusCode == 200) {
      await storage.write(key: "accessToken", value: response.data['access_token']);
      await storage.write(key: "refreshToken", value: response.data['refresh_token']);
    }
  }

  Future<Response> retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return dio.request(requestOptions.path,
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
        options: options);
  }
}



class AuthService extends ChangeNotifier {
  final DioClient _dioClient;
  User? _user;

  AuthService(this._dioClient);

  User? get user => _user;

  Future<bool> signUp(String email, String password) async {
    try {
      var response = await _dioClient.dio.post('/users', data: {
        'role': "bad526d9-bc5a-45f1-9f0b-eafadcd4fc15",
        'email': email,
        'password': password,
      });
      if (response.statusCode == 200) {
        // Gérer la réponse après l'inscription, si nécessaire
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      var response = await _dioClient.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      if (response.statusCode == 200) {
        var data = response.data['data']; 
        
        
        _user = User(
          email: email,
          token: data['access_token'],
          refreshToken: data['refresh_token']
        );
        notifyListeners();  // Notifie les écouteurs du changement
        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  void signOut() {
    _user = null;
    notifyListeners();  // Notifie les écouteurs du changement
  }
}
class User {
  final String email;
  final String token;
  final String refreshToken;

  User({required this.email, required this.token, required this.refreshToken});
}

