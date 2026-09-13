import 'package:flutter/material.dart';
import '../../domain/entities/capital_allocation_entity.dart';
import '../../domain/entities/ipo_application_entity.dart';
import '../../domain/entities/ipo_profile_entity.dart';
import '../../domain/entities/ipo_trade_entity.dart';

/// Modal sheet for placing a new ASBA IPO Bid
class CreateBidSheet extends StatefulWidget {
  final List<IpoProfileEntity> profiles;
  final String? selectedProfileId;
  final double availableBalance;
  final void Function({
    required String profileId,
    required String ipoName,
    required double bidAmount,
    required int sharesApplied,
  }) onSubmit;

  const CreateBidSheet({
    super.key,
    required this.profiles,
    this.selectedProfileId,
    required this.availableBalance,
    required this.onSubmit,
  });

  @override
  State<CreateBidSheet> createState() => _CreateBidSheetState();
}

class _CreateBidSheetState extends State<CreateBidSheet> {
  final _formKey = GlobalKey<FormState>();
  late String _profileId;
  final _ipoNameController = TextEditingController();
  final _bidAmountController = TextEditingController();
  final _sharesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _profileId = widget.selectedProfileId ??
        (widget.profiles.isNotEmpty ? widget.profiles.first.id : '');
  }

  @override
  void dispose() {
    _ipoNameController.dispose();
    _bidAmountController.dispose();
    _sharesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF161B22) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0),
            ),
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'NEW ASBA BID',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: textColor,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Funds are frozen in the working pool. Zero expense entries are created until allotment.',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 20),

              // Profile Selector
              DropdownButtonFormField<String>(
                initialValue: _profileId,
                dropdownColor: isDark ? const Color(0xFF21262D) : Colors.white,
                style: TextStyle(color: textColor, fontSize: 14),
                decoration: _inputDecoration('Bidding Profile', isDark),
                items: widget.profiles.map((p) {
                  return DropdownMenuItem(
                    value: p.id,
                    child: Text('${p.name} (${p.type.nameString})'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _profileId = val);
                },
              ),
              const SizedBox(height: 14),

              // IPO Name
              TextFormField(
                controller: _ipoNameController,
                style: TextStyle(color: textColor, fontSize: 14),
                decoration: _inputDecoration('IPO Name (e.g. Premier Energies)', isDark),
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'Enter IPO name' : null,
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _bidAmountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(color: textColor, fontSize: 14),
                      decoration: _inputDecoration('Bid Amount (₹)', isDark),
                      validator: (val) {
                        final amt = double.tryParse(val ?? '');
                        if (amt == null || amt <= 0) return 'Invalid amount';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _sharesController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: textColor, fontSize: 14),
                      decoration: _inputDecoration('Shares Applied', isDark),
                      validator: (val) {
                        final sh = int.tryParse(val ?? '');
                        if (sh == null || sh <= 0) return 'Invalid count';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A), // Executive deep navy
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final bidAmount = double.parse(_bidAmountController.text.trim());
                    final shares = int.parse(_sharesController.text.trim());
                    widget.onSubmit(
                      profileId: _profileId,
                      ipoName: _ipoNameController.text.trim(),
                      bidAmount: bidAmount,
                      sharesApplied: shares,
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  'CONFIRM ASBA HOLD',
                  style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, bool isDark) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        fontSize: 13,
        color: isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF30363D) : const Color(0xFFCBD5E1),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF30363D) : const Color(0xFFCBD5E1),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
      ),
    );
  }
}

/// Modal sheet for Capital Allocations (Injection, Repatriation, Parent Retention)
class CapitalAllocationSheet extends StatefulWidget {
  final List<IpoProfileEntity> profiles;
  final String? selectedProfileId;
  final void Function({
    required String profileId,
    required AllocationType type,
    required double amount,
    required String notes,
  }) onSubmit;

  const CapitalAllocationSheet({
    super.key,
    required this.profiles,
    this.selectedProfileId,
    required this.onSubmit,
  });

  @override
  State<CapitalAllocationSheet> createState() => _CapitalAllocationSheetState();
}

class _CapitalAllocationSheetState extends State<CapitalAllocationSheet> {
  final _formKey = GlobalKey<FormState>();
  late String _profileId;
  AllocationType _type = AllocationType.fundInjection;
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _profileId = widget.selectedProfileId ??
        (widget.profiles.isNotEmpty ? widget.profiles.first.id : '');
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF161B22) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0),
            ),
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'CAPITAL ALLOCATION',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: textColor,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Allocation Type Selector (Segmented buttons)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AllocationType.values.map((type) {
                  final isSelected = _type == type;
                  return ChoiceChip(
                    label: Text(
                      type == AllocationType.fundInjection
                          ? 'Fund Injected'
                          : type == AllocationType.repatriation
                              ? 'Repatriated Back'
                              : 'Parent Retention',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : textColor,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: type == AllocationType.fundInjection
                        ? const Color(0xFF0F766E) // Teal
                        : type == AllocationType.repatriation
                            ? const Color(0xFF1E3A8A) // Navy
                            : const Color(0xFFB45309), // Amber/Brown
                    backgroundColor: isDark ? const Color(0xFF21262D) : const Color(0xFFF1F5F9),
                    onSelected: (selected) {
                      if (selected) setState(() => _type = type);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Profile Selector
              DropdownButtonFormField<String>(
                initialValue: _profileId,
                dropdownColor: isDark ? const Color(0xFF21262D) : Colors.white,
                style: TextStyle(color: textColor, fontSize: 14),
                decoration: _inputDecoration('Profile Pool', isDark),
                items: widget.profiles.map((p) {
                  return DropdownMenuItem(
                    value: p.id,
                    child: Text('${p.name} (${p.type.nameString})'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _profileId = val);
                },
              ),
              const SizedBox(height: 14),

              // Amount
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: textColor, fontSize: 14),
                decoration: _inputDecoration('Amount (₹)', isDark),
                validator: (val) {
                  final amt = double.tryParse(val ?? '');
                  if (amt == null || amt <= 0) return 'Enter valid amount';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Notes / Reason
              TextFormField(
                controller: _notesController,
                style: TextStyle(color: textColor, fontSize: 14),
                decoration: _inputDecoration(
                  _type == AllocationType.parentRetention
                      ? 'Reason (e.g. Mom kept ₹6,000 for groceries, Dad rounded off)'
                      : 'Notes / Reference',
                  isDark,
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final amount = double.parse(_amountController.text.trim());
                    widget.onSubmit(
                      profileId: _profileId,
                      type: _type,
                      amount: amount,
                      notes: _notesController.text.trim(),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  'RECORD CAPITAL ALLOCATION',
                  style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, bool isDark) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        fontSize: 13,
        color: isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF30363D) : const Color(0xFFCBD5E1),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF30363D) : const Color(0xFFCBD5E1),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
      ),
    );
  }
}

/// Dialog for Confirming Allotment
class AllotmentConfirmDialog extends StatefulWidget {
  final IpoApplicationEntity application;
  final void Function(int allottedShares, double debitAmount) onConfirm;

  const AllotmentConfirmDialog({
    super.key,
    required this.application,
    required this.onConfirm,
  });

  @override
  State<AllotmentConfirmDialog> createState() => _AllotmentConfirmDialogState();
}

class _AllotmentConfirmDialogState extends State<AllotmentConfirmDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _sharesController;
  late TextEditingController _debitAmountController;

  @override
  void initState() {
    super.initState();
    _sharesController = TextEditingController(
      text: widget.application.sharesApplied.toString(),
    );
    _debitAmountController = TextEditingController(
      text: widget.application.bidAmount.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _sharesController.dispose();
    _debitAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF161B22) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return AlertDialog(
      backgroundColor: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CONFIRM ALLOTMENT',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.application.ipoName,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF3B82F6),
            ),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF21262D) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet_outlined, size: 18, color: Color(0xFF10B981)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This triggers a true DEBIT of this amount in your official expense ledger.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? const Color(0xFFC9D1D9) : const Color(0xFF334155),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _sharesController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: textColor, fontSize: 14),
              decoration: const InputDecoration(
                labelText: 'Allotted Shares',
                border: OutlineInputBorder(),
              ),
              validator: (val) {
                final s = int.tryParse(val ?? '');
                if (s == null || s <= 0) return 'Invalid shares';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _debitAmountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(color: textColor, fontSize: 14),
              decoration: const InputDecoration(
                labelText: 'Debit Amount (₹)',
                border: OutlineInputBorder(),
              ),
              validator: (val) {
                final a = double.tryParse(val ?? '');
                if (a == null || a <= 0) return 'Invalid amount';
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: isDark ? Colors.grey : Colors.black54)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF059669), // Emerald green
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final shares = int.parse(_sharesController.text.trim());
              final debitAmount = double.parse(_debitAmountController.text.trim());
              widget.onConfirm(shares, debitAmount);
              Navigator.pop(context);
            }
          },
          child: const Text('DEBIT LEDGER & ALLOT'),
        ),
      ],
    );
  }
}

/// Dialog for Executing Sale / Exit of Allotted Shares
class SellExecutionDialog extends StatefulWidget {
  final IpoApplicationEntity application;
  final IpoTradeEntity trade;
  final void Function({
    required double sellPricePerShare,
    required double grossProceeds,
    required double netProfit,
  }) onConfirm;

  const SellExecutionDialog({
    super.key,
    required this.application,
    required this.trade,
    required this.onConfirm,
  });

  @override
  State<SellExecutionDialog> createState() => _SellExecutionDialogState();
}

class _SellExecutionDialogState extends State<SellExecutionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _sellPriceController = TextEditingController();
  double _grossProceeds = 0.0;
  double _netProfit = 0.0;

  @override
  void initState() {
    super.initState();
    _sellPriceController.addListener(_recalculate);
  }

  void _recalculate() {
    final price = double.tryParse(_sellPriceController.text.trim()) ?? 0.0;
    final proceeds = price * widget.trade.allottedShares;
    final profit = proceeds - widget.trade.debitAmount;
    setState(() {
      _grossProceeds = proceeds;
      _netProfit = profit;
    });
  }

  @override
  void dispose() {
    _sellPriceController.removeListener(_recalculate);
    _sellPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF161B22) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return AlertDialog(
      backgroundColor: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SELL / EXIT HOLDING',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${widget.application.ipoName} (${widget.trade.allottedShares} shares)',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF3B82F6),
            ),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _sellPriceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(color: textColor, fontSize: 14),
              decoration: const InputDecoration(
                labelText: 'Sell Price per Share (₹)',
                border: OutlineInputBorder(),
              ),
              validator: (val) {
                final p = double.tryParse(val ?? '');
                if (p == null || p <= 0) return 'Invalid price';
                return null;
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF21262D) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Purchase Cost:'),
                      Text('₹${widget.trade.debitAmount.toStringAsFixed(0)}'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Gross Proceeds:'),
                      Text(
                        '₹${_grossProceeds.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Net Realized Profit:'),
                      Text(
                        '${_netProfit >= 0 ? '+' : ''}₹${_netProfit.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: _netProfit >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: isDark ? Colors.grey : Colors.black54)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E3A8A),
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final price = double.parse(_sellPriceController.text.trim());
              widget.onConfirm(
                sellPricePerShare: price,
                grossProceeds: _grossProceeds,
                netProfit: _netProfit,
              );
              Navigator.pop(context);
            }
          },
          child: const Text('CREDIT LEDGER & EXIT'),
        ),
      ],
    );
  }
}
