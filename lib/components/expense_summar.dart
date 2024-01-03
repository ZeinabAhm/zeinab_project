import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zeinab_project/bargraph/bar_graph.dart';
import 'package:zeinab_project/data/expense_data.dart';
import 'package:zeinab_project/datetime/date_time_helper.dart';

class ExpenseSummary extends StatelessWidget {
final DateTime startOfWeek;

  const ExpenseSummary({
    super.key,
required this.startOfWeek,
});

  @override
  Widget build(BuildContext context) {

    String monday=convertDateTimeToString(startOfWeek.add(const Duration(days:0)));
    String tuesday=convertDateTimeToString(startOfWeek.add(const Duration(days:1)));
    String wednesday=convertDateTimeToString(startOfWeek.add(const Duration(days:2)));
    String thuresday=convertDateTimeToString(startOfWeek.add(const Duration(days:3)));
    String friday=convertDateTimeToString(startOfWeek.add(const Duration(days:4)));
    String saturday=convertDateTimeToString(startOfWeek.add(const Duration(days:5)));
    String sunday=convertDateTimeToString(startOfWeek.add( const Duration(days:6)));

    return Consumer<ExpenseData>(
      builder: (context,value,child)=>SizedBox(
        height: 200,
        child: MyBarGraph(
            maxY:100,
            monAmount: value.calculateDailyExpenseSummary()[monday]??0,
            tuesAmount: value.calculateDailyExpenseSummary()[tuesday]??0,
            wedAmount: value.calculateDailyExpenseSummary()[wednesday]??0,
            thurAmount: value.calculateDailyExpenseSummary()[thuresday]??0,
            friAmount: value.calculateDailyExpenseSummary()[friday]??0,
            satAmount: value.calculateDailyExpenseSummary()[saturday]??0,
            sunAmount: value.calculateDailyExpenseSummary()[sunday]??0,
        ),
      ),
    );
  }
}