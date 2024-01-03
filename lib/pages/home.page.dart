import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zeinab_project/components/expense_summar.dart';
import 'package:zeinab_project/components/expense_tile.dart';
import 'package:zeinab_project/data/expense_data.dart';
import 'package:zeinab_project/models/expense_item.dart';
import 'package:zeinab_project/login.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String user_name = '';
  final newExpenseNameController = TextEditingController();
  final newExpenseAmountController = TextEditingController();
  final newExpenseBudgetController = TextEditingController();
  final String baseUrl = 'https://zeinabahmad2000.000webhostapp.com';
  bool isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _loadUserName();
    });
  }

  void _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String name = prefs.getString('loggedInUser') ?? '';

    setState(() {
      user_name = name;
      checkAndShowBudgetDialog();
      loadAndDisplayExpenses();
    });
  }

  Future<void> checkAndShowBudgetDialog() async {
    final userName = user_name;
    final userBudget = await getUserBudget(userName);

    if (userBudget == 0) {
      showBudgetDialog();
    }
  }

  Future<double> getUserBudget(String userName) async {
    final response = await http.post(
      Uri.parse('$baseUrl/getUserBudget.php'),
      body: {'username': userName},
    );

    if (response.statusCode == 200) {
      try {
        return double.parse(response.body);
      } catch (e) {
        print('Error parsing user budget: $e');
        return 0.0;
      }
    } else {
      print('Failed to fetch user budget. Status code: ${response.statusCode}');
      return 0.0;
    }
  }

  void showBudgetDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Set Budget for this week'),
        content: TextField(
          controller: newExpenseBudgetController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: "Enter your budget",
          ),
        ),
        actions: [
          MaterialButton(
            onPressed: () {
              saveBudget();
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void saveBudget() async {
    final userName = user_name;
    final enteredBudget = double.tryParse(newExpenseBudgetController.text) ?? 0.0;

    final response = await http.post(
      Uri.parse('$baseUrl/saveBudget.php'),
      body: {'username': userName.toString(), 'budget': enteredBudget.toString()},
    );

    if (response.statusCode == 200) {
    } else {
      print('Failed to save budget. Status code: ${response.statusCode}');
    }
  }

  void addNewExpense() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add new expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: newExpenseNameController,
              decoration: const InputDecoration(
                hintText: "Expense Name",
              ),
            ),
            TextField(
              controller: newExpenseAmountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Dollar",
              ),
            ),
          ],
        ),
        actions: [
          MaterialButton(
            onPressed: save,
            child: Text('Save'),
          ),
          MaterialButton(
            onPressed: cancel,
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  double _calculateTotalExpense() {
    List<ExpenseItem> allExpenses = Provider.of<ExpenseData>(context, listen: false).getAllExpenseList();
    return allExpenses
        .map((expense) => double.tryParse(expense.amount) ?? 0.0)
        .fold(0, (previous, current) => previous + current);
  }

  void save() async {
    String name = newExpenseNameController.text;
    double budget = await getUserBudget(user_name);
    double expenseAmount = double.tryParse(newExpenseAmountController.text) ?? 0.0;
    double totalExpense = _calculateTotalExpense();
    DateTime now = DateTime.now().toUtc();

    if ((totalExpense + expenseAmount)> budget) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Oops, Budget Exceeded', style: TextStyle(color: Colors.red)),
          content: Text('The expense amount exceeds your budget.', style: TextStyle(color: Colors.red)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/saveExpense.php'),
      body: {
        'username': user_name,
        'name': name,
        'date': now.toIso8601String(),
        'price': expenseAmount.toString(),
      },
    );

    if (response.statusCode == 200) {
      Provider.of<ExpenseData>(context, listen: false).addNewExpense(
        ExpenseItem(
          name: name,
          amount: expenseAmount.toString(),
          dateTime: now,
        ),
      );
    } else {
      print('Failed to save expense. Status code: ${response.statusCode}');
    }

    Navigator.pop(context);
    clear();
  }

  void cancel() {
    Navigator.pop(context);
    clear();
  }

  void finish() {
    List<ExpenseItem> allExpenses = Provider.of<ExpenseData>(context, listen: false).getAllExpenseList();
    double totalAmount = allExpenses
        .map((expense) => double.tryParse(expense.amount) ?? 0.0)
        .fold(0, (previous, current) => previous + current);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Total Expenses'),
        content: Text('The total amount of your expenses is $totalAmount.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void clear() {
    newExpenseNameController.clear();
    newExpenseAmountController.clear();
  }

  void logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  Future<void> loadAndDisplayExpenses() async {
    final response = await http.post(
      Uri.parse('$baseUrl/getExpenses.php'),
      body: {'username': user_name},
    );

    if (response.statusCode == 200) {
      try {
        final List<dynamic> expenses = convert.json.decode(response.body);
        final List<ExpenseItem> expenseList = expenses
            .map((expense) => ExpenseItem.fromJson(expense))
            .toList();
        Provider.of<ExpenseData>(context, listen: false).updateExpenses(expenseList);
      } catch (e) {
        print('Error parsing expenses: $e');
      }
    } else {
      print('Failed to fetch expenses. Status code: ${response.statusCode}');
    }
  }

  void deleteExpense(ExpenseItem expense) async {
    final response = await http.post(
      Uri.parse('$baseUrl/deleteExpense.php'),
      body: {
        'username': user_name,
        'name': expense.name,
        'date': expense.dateTime.toIso8601String(),
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        Provider.of<ExpenseData>(context, listen: false).deleteExpense(expense);
      });
    } else {
      print('Failed to delete expense. Status code: ${response.statusCode}');
    }
  }

  void toggleMenu() {
    setState(() {
      isMenuOpen = !isMenuOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseData>(
      builder: (context, value, child) => Scaffold(
        appBar: AppBar(
          title: Text('Expense App'),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.black,
          actions: [
            IconButton(
              icon: Icon(Icons.exit_to_app),
              tooltip: 'Logout',
              onPressed: logout,
            ),
          ],
        ),
        backgroundColor: Colors.grey[300],
        floatingActionButton: FloatingActionButton(
          tooltip: 'Menu',
          onPressed: toggleMenu,
          backgroundColor: Colors.black,
          child: Icon(isMenuOpen ? Icons.close : Icons.more_vert),
        ),
        body: Stack(
          children: [
            ListView(
              children: [
                ExpenseSummary(startOfWeek: value.startOfWeekDate()),
                const SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: value.getAllExpenseList().length,
                  itemBuilder: (context, index) => ExpenseTile(
                    name: value.getAllExpenseList()[index].name,
                    amount: value.getAllExpenseList()[index].amount,
                    dateTime: value.getAllExpenseList()[index].dateTime,
                    onDelete: () => deleteExpense(value.getAllExpenseList()[index]),
                  ),
                ),
              ],
            ),
            Visibility(
              visible: isMenuOpen,
              child: Positioned(
                bottom: 100.0,
                right: 16.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FloatingActionButton(
                      tooltip: 'Add Expense',
                      heroTag: 'addExpense',
                      onPressed: addNewExpense,
                      backgroundColor: Colors.black,
                      child: const Icon(Icons.add),
                    ),
                    SizedBox(height: 16),
                    FloatingActionButton(
                      tooltip: 'Total',
                      heroTag: 'finish',
                      onPressed: finish,
                      backgroundColor: Colors.black,
                      child: const Icon(Icons.attach_money),
                    ),
                    SizedBox(height: 25),
                    FloatingActionButton(
                      tooltip: 'Change Budget',
                      heroTag: 'changeBudget',
                      onPressed: showBudgetDialog,
                      backgroundColor: Colors.black,
                      child: const Icon(Icons.monetization_on),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}