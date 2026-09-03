import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/financial_record.dart';
import '../services/financial_record_service.dart';

class RecordListScreen extends StatefulWidget {
  final Direction? initialDirection;
  
  const RecordListScreen({Key? key, this.initialDirection}) : super(key: key);

  @override
  State<RecordListScreen> createState() => _RecordListScreenState();
}

class _RecordListScreenState extends State<RecordListScreen> {
  late Future<List<FinancialRecord>> _recordsFuture;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  void _loadRecords() {
    final service = context.read<FinancialRecordService>();
    _recordsFuture = service.getRecords(direction: widget.initialDirection);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialDirection == Direction.owedToMe ? 'Owed to Me' : 'I Owe'),
      ),
      body: FutureBuilder<List<FinancialRecord>>(
        future: _recordsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          final records = snapshot.data ?? [];
          if (records.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              return ListTile(
                title: Text(record.title),
                subtitle: Text(record.personOrOrganization ?? ''),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${record.currency} ${record.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(record.status.value, style: TextStyle(fontSize: 12, color: _getStatusColor(record.status))),
                  ],
                ),
                onTap: () => context.go('/records/detail/${record.id}'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/records/add'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No financial records yet.', style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 8),
          const Text('Start by adding a record.', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/records/add'),
            child: const Text('Add Record'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(Status status) {
    switch (status) {
      case Status.pending: return Colors.orange;
      case Status.paid: return Colors.green;
      case Status.overdue: return Colors.red;
      case Status.cancelled: return Colors.grey;
    }
  }
}
