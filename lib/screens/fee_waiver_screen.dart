import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/card_model.dart';
import '../repositories/card_repository.dart';
import '../repositories/transaction_repository.dart';
import '../providers/auth_provider.dart';

class FeeWaiverScreen extends StatelessWidget {
  const FeeWaiverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.watch<AuthProvider>().currentUserId;
    final cardRepo = context.watch<CardRepository>();
    final txRepo = context.watch<TransactionRepository>();
    final cards = cardRepo.getByUserId(userId);
    final colorScheme = Theme.of(context).colorScheme;
    final currencyFormat =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Scaffold(
      body: cards.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.credit_card_rounded,
                        size: 56,
                        color: colorScheme.onSurfaceVariant.withOpacity(0.4)),
                    const SizedBox(height: 16),
                    Text(
                      'No cards tracked',
                      style:
                          Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add your credit cards to start tracking your annual fee waiver progress.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: () => _showFormSheet(context, null),
                      icon: const Icon(Icons.add),
                      label: const Text('Add a credit card'),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: cards.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fee Waivers',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Track your progress towards annual fee waivers.',
                          style: TextStyle(
                              color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  );
                }

                final card = cards[index - 1];
                final currentSpend = _calculateSpend(card, txRepo, userId);
                final threshold = card.waiverThreshold;
                final progress =
                    threshold > 0 ? (currentSpend / threshold).clamp(0.0, 1.0) : 0.0;
                final isAchieved = currentSpend >= threshold;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: BorderSide(
                        color: colorScheme.outlineVariant.withOpacity(0.4),
                      ),
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          // Left color strip
                          Container(
                            width: 5,
                            color: isAchieved
                                ? Colors.green.shade500
                                : colorScheme.primary,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  // Header row
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              card.name,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w800),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Cycle: ${DateFormat('MMM dd, yyyy').format(card.cycleStart)} - ${DateFormat('MMM dd, yyyy').format(card.cycleEnd)}',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: colorScheme
                                                      .onSurfaceVariant),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Action buttons
                                      IconButton(
                                        icon: Icon(Icons.edit_outlined,
                                            size: 20,
                                            color: colorScheme
                                                .onSurfaceVariant),
                                        onPressed: () =>
                                            _showFormSheet(context, card),
                                        visualDensity:
                                            VisualDensity.compact,
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete_outline,
                                            size: 20,
                                            color: colorScheme.error
                                                .withOpacity(0.7)),
                                        onPressed: () => _confirmDelete(
                                            context, cardRepo, card),
                                        visualDensity:
                                            VisualDensity.compact,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Stats row
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding:
                                              const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: colorScheme
                                                .surfaceContainerHighest
                                                .withOpacity(0.4),
                                            borderRadius:
                                                BorderRadius.circular(14),
                                            border: Border.all(
                                                color: colorScheme
                                                    .outlineVariant
                                                    .withOpacity(0.4)),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'ANNUAL FEE',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight:
                                                      FontWeight.w600,
                                                  color: colorScheme
                                                      .onSurfaceVariant,
                                                  letterSpacing: 0.8,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                currencyFormat
                                                    .format(card.annualFee),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall
                                                    ?.copyWith(
                                                        fontWeight:
                                                            FontWeight
                                                                .w700),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Container(
                                          padding:
                                              const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: colorScheme
                                                .surfaceContainerHighest
                                                .withOpacity(0.4),
                                            borderRadius:
                                                BorderRadius.circular(14),
                                            border: Border.all(
                                                color: colorScheme
                                                    .outlineVariant
                                                    .withOpacity(0.4)),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'TARGET SPEND',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight:
                                                      FontWeight.w600,
                                                  color: colorScheme
                                                      .onSurfaceVariant,
                                                  letterSpacing: 0.8,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                currencyFormat
                                                    .format(threshold),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall
                                                    ?.copyWith(
                                                        fontWeight:
                                                            FontWeight
                                                                .w700),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Progress section
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${currencyFormat.format(currentSpend)} spent',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 13),
                                      ),
                                      if (isAchieved)
                                        Row(
                                          children: [
                                            Icon(Icons.check_circle,
                                                size: 16,
                                                color: Colors
                                                    .green.shade600),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Waiver Achieved',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                                color: Colors
                                                    .green.shade600,
                                              ),
                                            ),
                                          ],
                                        )
                                      else
                                        Text(
                                          '${(progress * 100).round()}%',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                            color: colorScheme.primary,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(6),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      minHeight: 10,
                                      backgroundColor: colorScheme
                                          .surfaceContainerHighest,
                                      valueColor:
                                          AlwaysStoppedAnimation(
                                        isAchieved
                                            ? Colors.green.shade500
                                            : colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                  if (!isAchieved) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.info_outline,
                                            size: 13,
                                            color: colorScheme
                                                .onSurfaceVariant),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Spend ${currencyFormat.format(threshold - currentSpend)} more to waive the fee',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: colorScheme
                                                .onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: cards.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _showFormSheet(context, null),
              icon: const Icon(Icons.add),
              label: const Text('Add Card'),
            )
          : null,
    );
  }

  double _calculateSpend(CardModel card, TransactionRepository txRepo, int userId) {
    return txRepo.getByUserId(userId)
        .where((tx) => tx.cardId == card.id)
        .where((tx) =>
            !tx.date.isBefore(card.cycleStart) &&
            !tx.date.isAfter(card.cycleEnd))
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  void _confirmDelete(
      BuildContext context, CardRepository repo, CardModel card) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Card?'),
        content: const Text('This will stop tracking this card.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              repo.delete(card);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Card deleted')),
              );
            },
            child: Text('Delete',
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  void _showFormSheet(BuildContext context, CardModel? existing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _CardFormSheet(existing: existing),
    );
  }
}

class _CardFormSheet extends StatefulWidget {
  final CardModel? existing;

  const _CardFormSheet({this.existing});

  @override
  State<_CardFormSheet> createState() => _CardFormSheetState();
}

class _CardFormSheetState extends State<_CardFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _feeCtrl;
  late TextEditingController _thresholdCtrl;
  late DateTime _cycleStart;
  late DateTime _cycleEnd;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _feeCtrl = TextEditingController(
        text: e != null ? e.annualFee.toStringAsFixed(0) : '');
    _thresholdCtrl = TextEditingController(
        text: e != null ? e.waiverThreshold.toStringAsFixed(0) : '');
    _cycleStart =
        e?.cycleStart ?? DateTime(DateTime.now().year, 1, 1);
    _cycleEnd =
        e?.cycleEnd ?? DateTime(DateTime.now().year, 12, 31);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _feeCtrl.dispose();
    _thresholdCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _cycleStart : _cycleEnd,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _cycleStart = picked;
        } else {
          _cycleEnd = picked;
        }
      });
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final cardRepo = context.read<CardRepository>();

    if (widget.existing != null) {
      final card = widget.existing!;
      card.name = _nameCtrl.text.trim();
      card.annualFee = double.tryParse(_feeCtrl.text) ?? 0;
      card.waiverThreshold = double.tryParse(_thresholdCtrl.text) ?? 0;
      card.cycleStart = _cycleStart;
      card.cycleEnd = _cycleEnd;
      cardRepo.update(card);
    } else {
      final userId = context.read<AuthProvider>().currentUserId;
      cardRepo.create(
        name: _nameCtrl.text.trim(),
        annualFee: double.tryParse(_feeCtrl.text) ?? 0,
        waiverThreshold: double.tryParse(_thresholdCtrl.text) ?? 0,
        cycleStart: _cycleStart,
        cycleEnd: _cycleEnd,
        userId: userId,
      );
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(widget.existing != null
              ? 'Card updated'
              : 'Card added')),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                widget.existing != null
                    ? 'Edit Card Tracking'
                    : 'Track New Card',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Card Name',
                  prefixIcon: Icon(Icons.credit_card_rounded),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _feeCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Annual Fee (₹)',
                        prefixIcon: Icon(Icons.attach_money_rounded),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _thresholdCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Waiver Target (₹)',
                        prefixIcon: Icon(Icons.track_changes_rounded),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickDate(true),
                      borderRadius: BorderRadius.circular(14),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Cycle Start',
                          prefixIcon: Icon(Icons.calendar_month_rounded, size: 20),
                        ),
                        child: Text(
                            DateFormat('yyyy-MM-dd').format(_cycleStart)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickDate(false),
                      borderRadius: BorderRadius.circular(14),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Cycle End',
                          prefixIcon: Icon(Icons.calendar_month_rounded, size: 20),
                        ),
                        child: Text(
                            DateFormat('yyyy-MM-dd').format(_cycleEnd)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

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
                      child: const Text('Save Card'),
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
