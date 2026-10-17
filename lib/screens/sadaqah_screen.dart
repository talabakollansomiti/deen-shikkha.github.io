import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// সদকা ট্র্যাকার
class SadaqahScreen extends StatefulWidget {
  const SadaqahScreen({super.key});

  @override
  State<SadaqahScreen> createState() => _SadaqahScreenState();
}

class _SadaqahScreenState extends State<SadaqahScreen> {
  List<Map<String, dynamic>> _entries = [];
  final _amount = TextEditingController();
  final _note = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString('sadaqah_entries');
    if (raw != null) {
      setState(() {
        _entries = (json.decode(raw) as List)
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      });
    }
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('sadaqah_entries', json.encode(_entries));
  }

  void _add() {
    final amt = double.tryParse(_amount.text);
    if (amt == null || amt <= 0) return;
    setState(() {
      _entries.insert(0, {
        'amount': amt,
        'note': _note.text.trim(),
        'date': DateTime.now().toIso8601String().substring(0, 10),
      });
      _amount.clear();
      _note.clear();
    });
    _save();
  }

  void _delete(int i) {
    setState(() => _entries.removeAt(i));
    _save();
  }

  @override
  Widget build(BuildContext context) {
    final total =
        _entries.fold<double>(0, (s, e) => s + (e['amount'] as num));
    return Scaffold(
      appBar: AppBar(title: const Text('সদকা ট্র্যাকার')),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0E6B3E), Color(0xFF0A4D2D)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text('মোট সদকা',
                    style:
                        TextStyle(color: Colors.white70, fontSize: 15)),
                Text(
                  '৳ ${total.toStringAsFixed(0)}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.bold),
                ),
                Text('${_entries.length} বার',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _amount,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'টাকা',
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _note,
                    decoration: InputDecoration(
                      hintText: 'নোট (ঐচ্ছিক)',
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _add,
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF0E6B3E)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _entries.isEmpty
                ? const Center(
                    child: Text('এখনো কোনো সদকা যোগ হয়নি',
                        style:
                            TextStyle(color: Colors.black54)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _entries.length,
                    itemBuilder: (context, i) {
                      final e = _entries[i];
                      return Card(
                        margin:
                            const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(
                              Icons.volunteer_activism,
                              color: Color(0xFF0E6B3E)),
                          title: Text(
                              '৳ ${(e['amount'] as num).toStringAsFixed(0)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17)),
                          subtitle: Text(
                              '${e['note']}'.isEmpty
                                  ? e['date']
                                  : '${e['note']} • ${e['date']}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.red),
                            onPressed: () => _delete(i),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
