import 'package:flutter/material.dart';

const kBg = Color(0xFF0E1222);
const kCard = Color(0xFF232B54);
const kAccent = Color(0xFFF2B138);
const kText = Color(0xFFEDF0FA);
const kTextDim = Color(0x99EDF0FA);
const kDanger = Color(0xFFE5737F);

void main() {
  runApp(const MyApp());
}

class Expense {
  final int id;
  final String name;
  final String category;
  final double amount;
  final DateTime date;
  final String notes;

  Expense({
    required this.id,
    required this.name,
    required this.category,
    required this.amount,
    required this.date,
    this.notes = '',
  });
}

const categories = <String, Color>{
  'Food': Color(0xFFF2B138),
  'Transport': Color(0xFF5DA9F2),
  'Shopping': Color(0xFFE56FB0),
  'Bills': Color(0xFFE5873F),
  'Entertainment': Color(0xFF9B7BF2),
  'Health': Color(0xFF55C08C),
  'Education': Color(0xFF4FC3D9),
  'Other': Color(0xFF9AA0BF),
};

String formatRupiah(double value) {
  final s = value.round().abs().toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return 'Rp$buf';
}

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
];

String formatDisplayDate(DateTime d) =>
    '${d.day} ${_months[d.month - 1]} ${d.year}';

String formatFieldDate(DateTime d) =>
    '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year}';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Expense',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBg,
        colorScheme: const ColorScheme.dark(
          primary: kAccent,
          surface: kCard,
        ),
      ),
      home: const MyHomePage(title: 'MyExpense'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Expense> _expenses = [];
  int _nextId = 1;

  double get _total => _expenses.fold(0.0, (sum, e) => sum + e.amount);

  Future<void> _openForm({Expense? expense}) async {
    final result = await Navigator.push<Expense>(
      context,
      MaterialPageRoute(builder: (_) => ExpenseFormScreen(expense: expense)),
    );
    if (result == null) return; 

    setState(() {
      if (expense == null) {
        _expenses.add(Expense(
          id: _nextId++,
          name: result.name,
          category: result.category,
          amount: result.amount,
          date: result.date,
          notes: result.notes,
        ));
      } else {
        final i = _expenses.indexWhere((e) => e.id == expense.id);
        if (i != -1) {
          _expenses[i] = Expense(
            id: expense.id,
            name: result.name,
            category: result.category,
            amount: result.amount,
            date: result.date,
            notes: result.notes,
          );
        }
      }
    });
  }

  Future<void> _confirmDelete(Expense e) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delete this expense?',
              style: TextStyle(
                color: kText,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${e.name} (${formatRupiah(e.amount)}) will be removed from your list.',
              style: const TextStyle(color: kTextDim, fontSize: 15),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      foregroundColor: kText,
                      side: const BorderSide(color: kTextDim),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      backgroundColor: kDanger,
                      foregroundColor: kBg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      setState(() => _expenses.removeWhere((x) => x.id == e.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final count = _expenses.length;

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 22, top: 32, right: 22, bottom: 24),
          child: Text(
            widget.title,
            style: const TextStyle(
              color: kText,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        toolbarHeight: 100,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Expenses',
                    style: TextStyle(color: kText, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatRupiah(_total),
                    style: const TextStyle(
                      color: kText,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const LinearProgressIndicator(
                    value: 1,
                    backgroundColor: kText,
                    color: kAccent,
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '$count ${count == 1 ? 'expense' : 'expenses'}',
                    style: const TextStyle(color: kText, fontSize: 14),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _expenses.isEmpty
                  ? const Center(
                      child: Text(
                        'No expenses yet. Add your first expense!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: kTextDim, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 22, bottom: 80),
                      itemCount: _expenses.length,
                      itemBuilder: (context, i) {
                        final e = _expenses[i];
                        return _ExpenseCard(
                          expense: e,
                          onEdit: () => _openForm(expense: e),
                          onDelete: () => _confirmDelete(e),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: kAccent,
        foregroundColor: kBg,
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ExpenseCard({
    required this.expense,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dotColor = categories[expense.category] ?? kAccent;

    return Card(
      color: kCard,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.name,
                        style: const TextStyle(color: kText, fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: dotColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            expense.category,
                            style: const TextStyle(color: kText, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatRupiah(expense.amount),
                      style: const TextStyle(color: kText, fontSize: 20),
                    ),
                    Text(
                      formatDisplayDate(expense.date),
                      style: const TextStyle(color: kTextDim, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
            if (expense.notes.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                expense.notes,
                style: const TextStyle(color: kText, fontSize: 14),
              ),
            ],
            const SizedBox(height: 12),
            const Divider(height: 1, color: kTextDim),
            const SizedBox(height: 12),
            Row(
              children: [
                GestureDetector(
                  onTap: onEdit,
                  child: const Text(
                    'Edit',
                    style: TextStyle(
                      color: kAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 22),
                GestureDetector(
                  onTap: onDelete,
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: kDanger, fontSize: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ExpenseFormScreen extends StatefulWidget {
  final Expense? expense; 

  const ExpenseFormScreen({super.key, this.expense});

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _dateCtrl;
  late final TextEditingController _notesCtrl;
  String? _category;
  late DateTime _date;

  bool get _isEdit => widget.expense != null;

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    _date = e?.date ?? DateTime.now();
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _amountCtrl =
        TextEditingController(text: e == null ? '' : e.amount.round().toString());
    _dateCtrl = TextEditingController(text: formatFieldDate(_date));
    _notesCtrl = TextEditingController(text: e?.notes ?? '');
    _category = e?.category;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _dateCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
        _dateCtrl.text = formatFieldDate(picked);
      });
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      Expense(
        id: widget.expense?.id ?? 0,
        name: _nameCtrl.text.trim(),
        category: _category!,
        amount: double.parse(_amountCtrl.text.trim()),
        date: _date,
        notes: _notesCtrl.text.trim(),
      ),
    );
  }

  InputDecoration _decoration({String? prefix, Widget? suffix}) {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: c, width: w),
        );
    return InputDecoration(
      filled: true,
      fillColor: kCard,
      prefixText: prefix,
      prefixStyle: const TextStyle(color: kTextDim, fontWeight: FontWeight.bold),
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: border(Colors.transparent),
      enabledBorder: border(Colors.transparent),
      focusedBorder: border(kAccent, 2),
      errorBorder: border(kDanger),
      focusedErrorBorder: border(kDanger, 2),
      errorStyle: const TextStyle(color: kDanger),
    );
  }

  Widget _label(String text, {String? suffix}) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 8),
        child: Text.rich(
          TextSpan(
            text: text,
            style: const TextStyle(
              color: kText,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            children: [
              if (suffix != null)
                TextSpan(
                  text: ' $suffix',
                  style: const TextStyle(
                    color: kTextDim,
                    fontWeight: FontWeight.normal,
                  ),
                ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          _isEdit ? 'Edit Expense' : 'Add Expense',
          style: const TextStyle(
            color: kText,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 28),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Expense name'),
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: _decoration(),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter an expense name'
                    : null,
              ),
              _label('Category'),
              DropdownButtonFormField<String>(
                value: _category,
                dropdownColor: kCard,
                borderRadius: BorderRadius.circular(16),
                decoration: _decoration(),
                hint: const Text('Choose a category',
                    style: TextStyle(color: kTextDim)),
                items: categories.keys
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v),
                validator: (v) => v == null ? 'Please choose a category' : null,
              ),
              _label('Amount'),
              TextFormField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  signed: true,
                  decimal: true,
                ),
                decoration: _decoration(prefix: 'Rp  '),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter an amount';
                  }
                  final n = double.tryParse(v.trim());
                  if (n == null) return 'Please enter a valid number';
                  if (n <= 0) return 'Amount must be greater than zero';
                  return null;
                },
              ),
              _label('Date'),
              TextFormField(
                controller: _dateCtrl,
                readOnly: true,
                onTap: _pickDate,
                decoration: _decoration(
                  suffix: const Icon(Icons.calendar_today_outlined,
                      size: 20, color: kText),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Please select a date' : null,
              ),
              _label('Notes', suffix: '(optional)'),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 3,
                decoration: _decoration(),
              ),
              const SizedBox(height: 28),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: kAccent,
                  foregroundColor: kBg,
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: _save,
                child: const Text('Save Expense',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: kText,
                  side: const BorderSide(color: kTextDim),
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}