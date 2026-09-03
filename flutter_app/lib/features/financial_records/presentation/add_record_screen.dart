import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/financial_record.dart';
import '../services/financial_record_service.dart';
import '../../../core/errors/api_exceptions.dart';

class AddRecordScreen extends StatefulWidget {
  const AddRecordScreen({Key? key}) : super(key: key);

  @override
  State<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _personController = TextEditingController();
  final _descController = TextEditingController();

  Direction _direction = Direction.owedToMe;
  Category _category = Category.other;
  DateTime? _dueDate;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Record')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SegmentedButton<Direction>(
                  segments: const [
                    ButtonSegment(value: Direction.owedToMe, label: Text('Owed to Me')),
                    ButtonSegment(value: Direction.iOwe, label: Text('I Owe')),
                  ],
                  selected: {_direction},
                  onSelectionChanged: (Set<Direction> newSelection) {
                    setState(() {
                      _direction = newSelection.first;
                    });
                  },
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(labelText: 'Amount', prefixText: '\$ ', border: OutlineInputBorder()),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    final parsed = double.tryParse(value);
                    if (parsed == null || parsed <= 0) return 'Must be a positive number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Category>(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                  items: Category.values.map((c) => DropdownMenuItem(value: c, child: Text(c.value))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _category = val);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _personController,
                  decoration: const InputDecoration(labelText: 'Person / Organization', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(_dueDate == null ? 'Select Due Date' : 'Due: ${_dueDate!.toIso8601String().split('T')[0]}'),
                  trailing: const Icon(Icons.calendar_today),
                  shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(4)),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) setState(() => _dueDate = date);
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveRecord,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: _isLoading ? const CircularProgressIndicator() : const Text('Save Record'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final record = FinancialRecord(
        id: '', // Backend generates ID
        direction: _direction,
        title: _titleController.text,
        description: _descController.text.isNotEmpty ? _descController.text : null,
        personOrOrganization: _personController.text.isNotEmpty ? _personController.text : null,
        amount: double.parse(_amountController.text),
        currency: 'USD',
        category: _category,
        dueDate: _dueDate,
        status: Status.pending,
        recurrenceType: RecurrenceType.none,
      );

      await context.read<FinancialRecordService>().createRecord(record);
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Record created successfully')));
      }
    } catch (e) {
      if (mounted) {
        final msg = e is ApiException ? e.message : 'Unexpected error occurred';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _personController.dispose();
    _descController.dispose();
    super.dispose();
  }
}
