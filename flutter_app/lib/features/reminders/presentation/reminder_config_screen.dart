import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/reminder.dart';
import '../services/reminder_service.dart';
import '../../../core/errors/api_exceptions.dart';

class ReminderConfigScreen extends StatefulWidget {
  final String recordId;

  const ReminderConfigScreen({Key? key, required this.recordId}) : super(key: key);

  @override
  State<ReminderConfigScreen> createState() => _ReminderConfigScreenState();
}

class _ReminderConfigScreenState extends State<ReminderConfigScreen> {
  late Future<List<Reminder>> _remindersFuture;
  int _daysBefore = 1;
  bool _notification = true;
  bool _alarm = false;
  bool _voice = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  void _loadReminders() {
    _remindersFuture = context.read<ReminderService>().getReminders(widget.recordId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: FutureBuilder<List<Reminder>>(
        future: _remindersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final reminders = snapshot.data ?? [];

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: reminders.length,
                  itemBuilder: (context, index) {
                    final rem = reminders[index];
                    return ListTile(
                      title: Text(rem.daysBefore == 0 ? 'On due date' : '${rem.daysBefore} days before'),
                      subtitle: Text('Notifications: ${rem.notificationEnabled}, Alarm: ${rem.alarmEnabled}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteReminder(rem.id),
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Add Reminder', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      initialValue: _daysBefore,
                      decoration: const InputDecoration(labelText: 'When to remind', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 7, child: Text('7 days before')),
                        DropdownMenuItem(value: 2, child: Text('2 days before')),
                        DropdownMenuItem(value: 1, child: Text('1 day before')),
                        DropdownMenuItem(value: 0, child: Text('On the due date')),
                      ],
                      onChanged: (val) => setState(() => _daysBefore = val ?? 1),
                    ),
                    SwitchListTile(
                      title: const Text('Push Notification'),
                      value: _notification,
                      onChanged: (val) => setState(() => _notification = val),
                    ),
                    SwitchListTile(
                      title: const Text('Alarm'),
                      value: _alarm,
                      onChanged: (val) => setState(() => _alarm = val),
                    ),
                    SwitchListTile(
                      title: const Text('Voice Reminder (Premium)'),
                      subtitle: const Text('Coming soon in Phase 3'),
                      value: _voice,
                      onChanged: (val) => setState(() => _voice = val),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _addReminder,
                      child: _isSaving ? const CircularProgressIndicator() : const Text('Add Reminder'),
                    )
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Future<void> _addReminder() async {
    setState(() => _isSaving = true);
    try {
      final rem = Reminder(
        id: '',
        financialRecordId: widget.recordId,
        daysBefore: _daysBefore,
        notificationEnabled: _notification,
        alarmEnabled: _alarm,
        voiceEnabled: _voice,
      );
      await context.read<ReminderService>().createReminder(widget.recordId, rem);
      
      setState(() {
        _loadReminders();
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reminder added')));
    } catch (e) {
      if (mounted) {
        String msg = e is ApiException ? e.message : 'Error adding reminder';
        if (msg.contains('UNIQUE constraint')) {
          msg = 'A reminder for this time already exists.';
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteReminder(String id) async {
    try {
      await context.read<ReminderService>().deleteReminder(id);
      setState(() {
        _loadReminders();
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
