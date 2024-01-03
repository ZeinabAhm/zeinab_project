import 'package:flutter/material.dart';
import 'package:zeinab_project/Welcome_Screen.dart';
import 'package:zeinab_project/data/expense_data.dart';
import 'package:zeinab_project/login.dart';
import 'package:provider/provider.dart';
import 'signup.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context)=>ExpenseData(),
    builder:(context,child)=> MaterialApp(
     debugShowCheckedModeBanner:false,
     home:LoginScreen(),
      routes:{
    '/signup':(context)=>Signup(),
    '/login':(context)=>LoginScreen(),
    '/welcomescreen':(context)=>WelcomeScreen()

    },
    ),
    );
  }
}