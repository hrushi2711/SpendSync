import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart';
import '../repositories/card_repository.dart';
import '../repositories/transaction_repository.dart';
import '../providers/auth_provider.dart';
import '../utils/categories.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.watch<AuthProvider>().currentUserId;
    final txRepo = context.watch<TransactionRepository>();
    final cardRepo = context.watch<CardRepository>();
    final transactions = txRepo.getByUserId(userId)
      ..sort((a, b) => b.date.compareTo(a.date));
    final colorScheme = Theme.of(context).colorScheme;
    final currencyFormat =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Scaffold(
      body: transactions.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.wallet_rounded,
                        size: 56,
                        color: colorScheme.onSurfaceVariant.withOpacity(0.4)),
                    const SizedBox(height: 16),
                    Text(
                      'No expenses yet',
                      style:
                          Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Log your first expense to start tracking your spending habits.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: () => _showFormSheet(context, null),
                      icon: const Icon(Icons.add),
                      label: const Text('Add your first expense'),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: transactions.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Expenses',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage and track your transactions.',
                          style: TextStyle(
                              color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  );
                }

                final tx = transactions[index - 1];
                final card = tx.cardId != null
                    ? cardRepo.getById(tx.cardId!)
                    : null;
                final catColor = getCategoryColor(tx.category);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _showFormSheet(context, tx),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: catColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                getCategoryIcon(tx.category),
                                color: catColor,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tx.description,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                            fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today,
                                          size: 12,
                                          color: colorScheme
                                              .onSurfaceVariant),
                                      const SizedBox(width: 4),
                                      Text(
                                        DateFormat('MMM dd, yyyy')
                                            .format(tx.date),
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: colorScheme
                                                .onSurfaceVariant),
                                      ),
                                      const SizedBox(width: 8),
                                      Text('•',
                                          style: TextStyle(
                                              color: colorScheme
                                                  .onSurfaceVariant)),
                                      const SizedBox(width: 8),
                                      Text(
                                        tx.category,
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: colorScheme
                                                .onSurfaceVariant),
                                      ),
                                      if (card != null) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 2),
                                          decoration: BoxDecoration(
                                            color: colorScheme.primary
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            card.name,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: colorScheme.primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  currencyFormat.format(tx.amount),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                          fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap: () =>
                                          _showFormSheet(context, tx),
                                      borderRadius:
                                          BorderRadius.circular(8),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Icon(Icons.edit_outlined,
                                            size: 18,
                                            color: colorScheme.onSurfaceVariant),
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    InkWell(
                                      onTap: () =>
                                          _confirmDelete(context, txRepo, tx),
                                      borderRadius:
                                          BorderRadius.circular(8),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Icon(Icons.delete_outline,
                                            size: 18,
                                            color: colorScheme.error
                                                .withOpacity(0.7)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: transactions.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _showFormSheet(context, null),
              icon: const Icon(Icons.add),
              label: const Text('Add Expense'),
            )
          : null,
    );
  }

  void _confirmDelete(BuildContext context, TransactionRepository repo,
      TransactionModel tx) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Transaction?'),
        content:
            const Text('This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              repo.delete(tx);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Transaction deleted')),
              );
            },
            child: Text('Delete',
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  void _showFormSheet(BuildContext context, TransactionModel? existing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _ExpenseFormSheet(existing: existing),
    );
  }
}

class _ExpenseFormSheet extends StatefulWidget {
  final TransactionModel? existing;

  const _ExpenseFormSheet({this.existing});

  @override
  State<_ExpenseFormSheet> createState() => _ExpenseFormSheetState();
}

class _ExpenseFormSheetState extends State<_ExpenseFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descCtrl;
  late TextEditingController _amountCtrl;
  late TextEditingController _notesCtrl;
  late DateTime _selectedDate;
  late String _selectedCategory;
  late String _selectedPaymentMode;
  int? _selectedCardId;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _amountCtrl =
        TextEditingController(text: e != null ? e.amount.toString() : '');
    _notesCtrl = TextEditingController(text: e?.notes ?? '');
    _selectedDate = e?.date ?? DateTime.now();
    _selectedCategory = e?.category ?? expenseCategories.first;
    _selectedPaymentMode = e?.paymentMode ?? paymentModes.first;
    _selectedCardId = e?.cardId;
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final txRepo = context.read<TransactionRepository>();
    final amount = double.tryParse(_amountCtrl.text) ?? 0;

    if (widget.existing != null) {
      final tx = widget.existing!;
      tx.description = _descCtrl.text.trim();
      tx.amount = amount;
      tx.date = _selectedDate;
      tx.category = _selectedCategory;
      tx.paymentMode = _selectedPaymentMode;
      tx.cardId = _selectedCardId;
      tx.notes = _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim();
      txRepo.update(tx);
    } else {
      final userId = context.read<AuthProvider>().currentUserId;
      txRepo.create(
        description: _descCtrl.text.trim(),
        amount: amount,
        date: _selectedDate,
        category: _selectedCategory,
        paymentMode: _selectedPaymentMode,
        cardId: _selectedCardId,
        notes:
            _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        userId: userId,
      );
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(widget.existing != null
              ? 'Transaction updated'
              : 'Transaction added')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardRepo = context.read<CardRepository>();
    final cards = cardRepo.cards;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.existing != null ? 'Edit Expense' : 'New Expense',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),

              // Description
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.edit_note_rounded),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              // Amount & Date row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _amountCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Amount (₹)'),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (double.tryParse(v) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(14),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          prefixIcon: Icon(Icons.calendar_today_rounded, size: 20),
                        ),
                        child: Text(
                          DateFormat('yyyy-MM-dd').format(_selectedDate),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Category & Payment Mode row
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        prefixIcon: Icon(Icons.category_outlined, size: 20),
                      ),
                      items: expenseCategories
                          .map((c) =>
                              DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedCategory = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedPaymentMode,
                      decoration: const InputDecoration(
                        labelText: 'Payment Mode',
                        prefixIcon: Icon(Icons.payment_rounded, size: 20),
                      ),
                      items: paymentModes
                          .map((m) =>
                              DropdownMenuItem(value: m, child: Text(m)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedPaymentMode = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Card selector (only if Credit Card)
              if (_selectedPaymentMode == 'Credit Card' && cards.isNotEmpty)
                DropdownButtonFormField<int?>(
                  value: _selectedCardId,
                  decoration: const InputDecoration(
                    labelText: 'Credit Card (Optional)',
                    prefixIcon: Icon(Icons.credit_card_rounded),
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                        value: null, child: Text('None / Not tracked')),
                    ...cards.map((c) => DropdownMenuItem<int?>(
                        value: c.id, child: Text(c.name))),
                  ],
                  onChanged: (v) => setState(() => _selectedCardId = v),
                ),
              const SizedBox(height: 12),
              
              TextFormField(
                controller: _notesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 20),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _save,
                      child: const Text('Save Expense'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
