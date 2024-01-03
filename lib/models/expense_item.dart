class ExpenseItem {
  final String name;
  final String amount;
  final DateTime dateTime;

  ExpenseItem({
    required this.name,
    required this.amount,
    required this.dateTime,
  });

  factory ExpenseItem.fromJson(Map<String, dynamic> json) {
    return ExpenseItem(
      name: json['name'] ?? '',
      amount: json['price'] ?? '',

      dateTime: DateTime.parse(json['date'] ?? ''),
    );
  }

  String displayInfo() {
    return 'Name: $name, Amount: $amount, Date: $dateTime';
  }
}