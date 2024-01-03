import 'package:flutter/material.dart';
import 'package:zeinab_project/pages/home.page.dart';
import 'package:zeinab_project/More_Info_Page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zeinab_project/data/expense_data.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;

class WelcomeScreen extends StatelessWidget {

  Future<void> checkAndResetExpensesAndBudgets() async {
    final prefs = await SharedPreferences.getInstance();
    final lastResetDate = prefs.getString('lastResetDate') ?? '';
    final expenseData = ExpenseData();
    final currentDay = expenseData.getDayName(DateTime.now());

    if (currentDay == 'Mon' && lastResetDate != expenseData.getFormattedDate(DateTime.now())) {
      final response = await http.get(Uri.parse('https://zeinabahmad2000.000webhostapp.com/resetWeekly.php'));

      if (response.statusCode == 200) {
        prefs.setString('lastResetDate', expenseData.getFormattedDate(DateTime.now()));
      } else {
        print('Failed to reset expenses and budgets. Status code: ${response.statusCode}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to Expense App',
              style: TextStyle(
                fontSize: 30,
                foreground: Paint()
                  ..shader = ui.Gradient.linear(
                    const Offset(0, 20),
                    const Offset(150, 20),
                    <Color>[
                      Colors.black,
                      Colors.grey,
                    ],
                  ),
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                checkAndResetExpensesAndBudgets();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.grey,
              ),
              child: Text(
                'Expense Your Day',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Info',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MoreInfoPage()),
          );
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.info),
      ),
    );
  }
}