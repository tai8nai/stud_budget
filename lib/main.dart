import 'package:flutter/material.dart';

void main() {
  runApp(const BudgetApp());
}

class BudgetApp extends StatelessWidget {
  const BudgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Учет бюджета',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const BudgetHomePage(),
    );
  }
}

class BudgetHomePage extends StatefulWidget {
  const BudgetHomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BudgetHomePageState createState() => _BudgetHomePageState();
}

class _BudgetHomePageState extends State<BudgetHomePage> {
  final List<Map<String, dynamic>> _transactions = [];
  final List<String> _categories = ['Продукты', 'Транспорт', 'Развлечения'];
  double _balance = 0.0;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String? _selectedCategory;

  final TextEditingController _categoryController = TextEditingController();

  void _addTransaction(String title, double amount, bool isIncome, String? category) {
    setState(() {
      _transactions.add({
        'title': title,
        'amount': amount,
        'isIncome': isIncome,
        'category': category ?? 'Без категории',
      });

      // Обновляем баланс
      if (isIncome) {
        _balance += amount;
      } else {
        _balance -= amount;
      }
    });
  }

  void _deleteTransaction(int index) {
    setState(() {
      final transaction = _transactions[index];
      if (transaction['isIncome']) {
        _balance -= transaction['amount'];
      } else {
        _balance += transaction['amount'];
      }
      _transactions.removeAt(index);
    });
  }

  void _showAddTransactionDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Добавить транзакцию'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Название'),
            ),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Сумма'),
              keyboardType: TextInputType.number,
            ),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              decoration: const InputDecoration(labelText: 'Категория'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              final title = _titleController.text;
              final amount = double.tryParse(_amountController.text) ?? 0.0;

              if (title.isNotEmpty && amount > 0) {
                _addTransaction(title, amount, true, _selectedCategory); // Доход
                Navigator.of(ctx).pop();
                _titleController.clear();
                _amountController.clear();
                                setState(() {
                  _selectedCategory = null;
                });
              }
            },
            child: const Text('Добавить доход'),
          ),
          TextButton(
            onPressed: () {
              final title = _titleController.text;
              final amount = double.tryParse(_amountController.text) ?? 0.0;

              if (title.isNotEmpty && amount > 0) {
                _addTransaction(title, amount, false, _selectedCategory); // Расход
                Navigator.of(ctx).pop();
                _titleController.clear();
                _amountController.clear();
                setState(() {
                  _selectedCategory = null;
                });
              }
            },
            child: const Text('Добавить расход'),
          ),
        ],
      ),
    );
  }

  void _showManageCategoriesDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Управление категориями'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Новая категория'),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _categories.length,
                itemBuilder: (ctx, index) => ListTile(
                  title: Text(_categories[index]),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _categories.removeAt(index);
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Закрыть'),
          ),
          TextButton(
            onPressed: () {
              final newCategory = _categoryController.text.trim();
              if (newCategory.isNotEmpty && !_categories.contains(newCategory)) {
                setState(() {
                  _categories.add(newCategory);
                });
                _categoryController.clear();
              }
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Учет бюджета'),
        actions: [
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: _showManageCategoriesDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Баланс
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.green[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Баланс:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_balance.toStringAsFixed(2)} ₽',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Список транзакций
          Expanded(
            child: ListView.builder(
              itemCount: _transactions.length,
              itemBuilder: (ctx, index) {
                final transaction = _transactions[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          transaction['isIncome'] ? Colors.green : Colors.red,
                      child: Icon(
                        transaction['isIncome']
                                                    ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(transaction['title']),
                    subtitle:
                        Text('${transaction['amount'].toStringAsFixed(2)} ₽'),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(transaction['category'] ?? 'Без категории'),
                        IconButton(
                          icon:
                              const Icon(Icons.delete, size: 20, color: Colors.grey),
                          onPressed: () => _deleteTransaction(index),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // Кнопка добавления транзакции
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransactionDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
