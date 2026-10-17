import 'package:flutter/material.dart';

// ফিতরা ক্যালকুলেটর
class FitraScreen extends StatefulWidget {
  const FitraScreen({super.key});

  @override
  State<FitraScreen> createState() => _FitraScreenState();
}

class _FitraScreenState extends State<FitraScreen> {
  String _item = 'চাল';
  final _members = TextEditingController(text: '4');
  final _rate = TextEditingController(text: '70');
  double? _total;

  // ২০২৪-২৫ আনুমানিক হার (টাকা/কেজি)
  final Map<String, double> _items = {
    'চাল': 70,
    'গম': 55,
    'খেজুর': 400,
    'কিশমিশ': 500,
    'পনির': 800,
  };

  // ফিতরা পরিমাণ: অর্ধ সা (গম) বা ১ সা (অন্যান্য) ≈
  final Map<String, double> _qtyKg = {
    'চাল': 3.3,
    'গম': 1.65,
    'খেজুর': 3.3,
    'কিশমিশ': 3.3,
    'পনির': 3.3,
  };

  void _calc() {
    final m = int.tryParse(_members.text) ?? 0;
    final r = double.tryParse(_rate.text) ?? _items[_item]!;
    setState(() => _total = m * r * _qtyKg[_item]!);
  }

  @override
  void initState() {
    super.initState();
    _rate.text = '${_items[_item]!.toInt()}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ফিতরা ক্যালকুলেটর')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            color: Color(0xFFE6F4EA),
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                'সদকাতুল ফিতর: রমজান শেষে ঈদের নামাজের আগে প্রত্যেক মুসলিমের (ছোট-বড়) পক্ষ থেকে আদায় করা ওয়াজিব।',
                style: TextStyle(fontSize: 14, height: 1.7),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text('খাদ্য নির্বাচন',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _items.keys.map((k) {
              final sel = _item == k;
              return ChoiceChip(
                label: Text(k),
                selected: sel,
                selectedColor: const Color(0xFF0E6B3E),
                labelStyle: TextStyle(
                    color: sel ? Colors.white : Colors.black87),
                onSelected: (_) => setState(() {
                  _item = k;
                  _rate.text = '${_items[k]!.toInt()}';
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _members,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'পরিবারের সদস্য সংখ্যা',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _rate,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'বাজার দর (টাকা/কেজি)',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 6),
          Text('পরিমাণ: ${_qtyKg[_item]} কেজি/জন',
              style:
                  const TextStyle(color: Colors.black54, fontSize: 13)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _calc,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0E6B3E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child:
                const Text('হিসাব করো', style: TextStyle(fontSize: 16)),
          ),
          if (_total != null) ...[
            const SizedBox(height: 16),
            Card(
              color: const Color(0xFF0E6B3E),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text('মোট ফিতরা',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 15)),
                    Text(
                      '৳ ${_total!.toStringAsFixed(0)}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
