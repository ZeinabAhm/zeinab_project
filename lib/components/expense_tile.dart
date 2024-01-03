import 'package:flutter/material.dart';

class ExpenseTile extends StatelessWidget {
  final String name;
  final String amount;
  final DateTime dateTime;
  final VoidCallback onDelete;

  const ExpenseTile({
    Key? key,
    required this.name,
    required this.amount,
    required this.dateTime,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name),
      subtitle: Text(
        '${dateTime.day}/${dateTime.month}/${dateTime.year}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '\$$amount',
            style: TextStyle(color: Colors.green),
          ),
          SizedBox(width: 16),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: onDelete,
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}