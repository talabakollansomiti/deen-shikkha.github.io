import 'package:flutter/material.dart';

class ZakatScreen extends StatefulWidget {
  const ZakatScreen({super.key});

  @override
  State<ZakatScreen> createState() => _ZakatScreenState();
}

class _ZakatScreenState extends State<ZakatScreen> {
  final _cash = TextEditingController();
  final _gold = TextEditingController(); // গ্রাম
  final _silver = TextEditingController(); // গ্রাম
  final _business = TextEditingController();
  final _debt = TextEditingController();
  double? _zakat;

  // আনুমানিক বাজার দর (টাকা/গ্রাম) — ইউজার বদলাতে পারবে
  final _goldRate = TextEditingController(text: '8500');
  final _silverRate = TextEditingController(text: '110');

  void _calc() {
    final cash = double.tryParse(_cash.text) ?? 0;
    final goldG = double.tryParse(_gold.text) ?? 0;
    final silverG = double.tryParse(_silver.text) ?? 0;
    final biz = double.tryParse(_business.text) ?? 0;
    final debt = double.tryParse(_debt.text) ?? 0;
    final gRate = double.tryParse(_goldRate.text) ?? 8500;
    final sRate = double.tryParse(_silverRate.text) ?? 110;

    final total =
        cash + (goldG * gRate) + (silverG * sRate) + biz - debt;
    // নিসাব: সাড়ে ৫২ তোলা রূপা ≈ ৬১২ গ্রাম
    final nisab = 612 * sRate;
    setState(() {
      _zakat = total >= nisab ? total * 0.025 : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('যাকাত ক্যালকুলেটর')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            color: Color(0xFFE6F4EA),
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                'যাকাত ফরজ হয়: নিসাব পরিমাণ সম্পদ (সাড়ে ৭ তোলা স্বর্ণ বা সাড়ে ৫২ তোলা রূপা বা সমমূল্য) ১ বছর থাকলে। হার: ২.৫%',
                style: TextStyle(fontSize: 14, height: 1.7),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _field(_cash, 'নগদ টাকা', TextInputType.number),
          _field(_gold, 'স্বর্ণ (গ্রাম)', TextInputType.number),
          _field(_silver, 'রূপা (গ্রাম)', TextInputType.number),
          _field(_business, 'ব্যবসায়িক পণ্য (টাকা)', TextInputType.number),
          _field(_debt, 'ঋণ/দেনা (টাকা)', TextInputType.number),
          const SizedBox(height: 8),
          const Text('বাজার দর (টাকা/গ্রাম)',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _field(_goldRate, 'স্বর্ণ', TextInputType.number)),
              const SizedBox(width: 10),
              Expanded(
                  child: _field(_silverRate, 'রূপা', TextInputType.number)),
            ],
          ),
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
          if (_zakat != null) ...[
            const SizedBox(height: 16),
            Card(
              color: _zakat! > 0
                  ? const Color(0xFF0E6B3E)
                  : Colors.grey.shade200,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      _zakat! > 0
                          ? 'তোমার যাকাত'
                          : 'যাকাত ফরজ হয়নি',
                      style: TextStyle(
                          color: _zakat! > 0
                              ? Colors.white70
                              : Colors.black54,
                          fontSize: 15),
                    ),
                    if (_zakat! > 0)
                      Text(
                        '৳ ${_zakat!.toStringAsFixed(0)}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold),
                      )
                    else
                      const Text(
                        'নিসাব পূর্ণ হয়নি',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          const Text(
            '⚠️ এটি আনুমানিক হিসাব। সঠিক মাসআলার জন্য আলেমের পরামর্শ নাও।',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String hint, TextInputType kb) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        keyboardType: kb,
        decoration: InputDecoration(
          labelText: hint,
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
