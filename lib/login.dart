import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  FocusNode passwordFocus = FocusNode();
  FocusNode usernameFocus = FocusNode();
  bool isPasswordIncorrect = false;
  final String baseUrl = 'https://zeinabahmad2000.000webhostapp.com';

  Future<void> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login.php'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: convert.jsonEncode(<String, String>{
          'username': username,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = convert.json.decode(response.body);

        if (responseBody.containsKey('result')) {
          String result = responseBody['result'];
          if (result == 'Login successful') {
            await _storeLoggedInUser(username);
            Navigator.pushReplacementNamed(context, '/welcomescreen');
          } else {
            setState(() {
              isPasswordIncorrect = true;
            });
            showErrorSnackBar('$result');
          }
        } else {
          print('Unexpected response format');
        }
      } else {
        print('Failed to log in. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to log in: $e');
      showErrorSnackBar('Failed to log in. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              focusNode: usernameFocus,
              decoration: InputDecoration(labelText: 'Username',errorText: isPasswordIncorrect ? '' : null),
            ),
            TextField(
              controller: passwordController,
              focusNode: passwordFocus,
              decoration: InputDecoration(
                  labelText: 'Password',
                  errorText: isPasswordIncorrect ? 'Incorrect password' : null
              ),
              obscureText: true,
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                String username = usernameController.text;
                String password = passwordController.text;
                setState(() {
                  isPasswordIncorrect = false;
                });
                await login(username, password);
                if (isPasswordIncorrect) {
                  FocusScope.of(context).requestFocus(passwordFocus);
                  FocusScope.of(context).requestFocus(usernameFocus);
                }
              },
              child: Text('Login'),
              style: ElevatedButton.styleFrom(
                primary: Colors.black,
              ),
            ),
            SizedBox(height: 10.0),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signup');
              },
              child: Text('Don\'t have an account? Sign up here'),
              style: TextButton.styleFrom(
                primary: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }
  void showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
Future<void> _storeLoggedInUser(String username) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('loggedInUser', username);
}