import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/content_api.dart';

// কুইজ / দোয়া / হাদিস ম্যানেজমেন্ট
class ContentScreen extends StatelessWidget {
  const ContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('কনটেন্ট ম্যানেজ'),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'কুইজ'),
              Tab(text: 'দোয়া'),
              Tab(text: 'হাদিস'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _QuizTab(),
            _DuaTab(),
            _HadithTab(),
          ],
        ),
      ),
    );
  }
}

abstract class _BaseTabState<T extends StatefulWidget> extends State<T> {
  String get fileName => '';
  List<Map<String, dynamic>> items = [];
  String? sha;
  bool loading = true;

  Future<String> _token() async {
    final p = await SharedPreferences.getInstance();
    return p.getString('ds_pat') ?? '';
  }

  Future<void> loadItems() async {
    final t = await _token();
    final res = await ContentApi(t).load(fileName);
    if (!mounted) return;
    setState(() {
      loading = false;
      if (res != null) {
        sha = res['sha'] as String;
        items = (res['items'] as List)
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    });
  }

  Future<bool> saveItems() async {
    final t = await _token();
    if (sha == null) return false;
    return ContentApi(t).save(fileName, items, sha!);
  }

  void notifySaved(BuildContext context, bool ok) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(ok ? '✅ সেভ হয়েছে!' : '❌ সেভ হয়নি'),
        backgroundColor:
            ok ? const Color(0xFF0E6B3E) : Colors.red,
      ),
    );
    if (ok) loadItems();
  }
}

class _QuizTab extends StatefulWidget {
  const _QuizTab();
  @override
  State<_QuizTab> createState() => _QuizTabState();
}

class _QuizTabState extends _BaseTabState<_QuizTab> {
  @override
  String get fileName => 'quiz';
  @override
  void initState() {
    super.initState();
    loadItems();
  }

  void _add() {
    final q = TextEditingController();
    final o1 = TextEditingController();
    final o2 = TextEditingController();
    final o3 = TextEditingController();
    final o4 = TextEditingController();
    int correct = 0;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: const Text('নতুন প্রশ্ন'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: q,
                    decoration: const InputDecoration(
                        labelText: 'প্রশ্ন')),
                for (int i = 0; i < 4; i++)
                  Row(
                    children: [
                      Radio<int>(
                        value: i,
                        groupValue: correct,
                        onChanged: (v) =>
                            setD(() => correct = v!),
                      ),
                      Expanded(
                        child: TextField(
                          controller: [o1, o2, o3, o4][i],
                          decoration: InputDecoration(
                              labelText: 'অপশন ${i + 1}'),
                        ),
                      ),
                    ],
                  ),
                const Text('✓ = সঠিক উত্তর',
                    style: TextStyle(
                        fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('বাতিল')),
            ElevatedButton(
              onPressed: () async {
                if (q.text.trim().isEmpty) return;
                setState(() {
                  items.add({
                    'q': q.text.trim(),
                    'options': [
                      o1.text.trim(),
                      o2.text.trim(),
                      o3.text.trim(),
                      o4.text.trim()
                    ],
                    'correct': correct,
                  });
                });
                Navigator.pop(ctx);
                notifySaved(
                    context, await saveItems());
              },
              child: const Text('যোগ করো'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text('${items.length}টি প্রশ্ন',
              style: const TextStyle(color: Colors.black54)),
        ),
        Expanded(
          child: ListView.builder(
            padding:
                const EdgeInsets.symmetric(horizontal: 12),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final e = items[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text('${e['q']}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  subtitle: Text(
                      'সঠিক: ${(e['options'] as List)[e['correct']]}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete,
                        color: Colors.red),
                    onPressed: () async {
                      setState(
                          () => items.removeAt(i));
                      notifySaved(
                          context, await saveItems());
                    },
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _add,
            icon: const Icon(Icons.add),
            label: const Text('নতুন প্রশ্ন যোগ করো'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0E6B3E),
              foregroundColor: Colors.white,
              minimumSize:
                  const Size(double.infinity, 50),
            ),
          ),
        ),
      ],
    );
  }
}

class _DuaTab extends StatefulWidget {
  const _DuaTab();
  @override
  State<_DuaTab> createState() => _DuaTabState();
}

class _DuaTabState extends _BaseTabState<_DuaTab> {
  @override
  String get fileName => 'duas';
  @override
  void initState() {
    super.initState();
    loadItems();
  }

  void _add() {
    final t = TextEditingController();
    final a = TextEditingController();
    final tr = TextEditingController();
    final m = TextEditingController();
    final v = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('নতুন দোয়া'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: t,
                  decoration:
                      const InputDecoration(labelText: 'শিরোনাম')),
              TextField(
                  controller: a,
                  maxLines: 2,
                  decoration:
                      const InputDecoration(labelText: 'আরবি')),
              TextField(
                  controller: tr,
                  decoration: const InputDecoration(
                      labelText: 'উচ্চারণ')),
              TextField(
                  controller: m,
                  maxLines: 2,
                  decoration:
                      const InputDecoration(labelText: 'অর্থ')),
              TextField(
                  controller: v,
                  decoration:
                      const InputDecoration(labelText: 'ফজিলত')),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('বাতিল')),
          ElevatedButton(
            onPressed: () async {
              if (t.text.trim().isEmpty) return;
              setState(() {
                items.add({
                  'title': t.text.trim(),
                  'arabic': a.text.trim(),
                  'transliteration': tr.text.trim(),
                  'meaning': m.text.trim(),
                  'virtue': v.text.trim(),
                });
              });
              Navigator.pop(ctx);
              notifySaved(context, await saveItems());
            },
            child: const Text('যোগ করো'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text('${items.length}টি দোয়া',
              style: const TextStyle(color: Colors.black54)),
        ),
        Expanded(
          child: ListView.builder(
            padding:
                const EdgeInsets.symmetric(horizontal: 12),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final e = items[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text('${e['title']}'),
                  subtitle: Text('${e['meaning']}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete,
                        color: Colors.red),
                    onPressed: () async {
                      setState(
                          () => items.removeAt(i));
                      notifySaved(
                          context, await saveItems());
                    },
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _add,
            icon: const Icon(Icons.add),
            label: const Text('নতুন দোয়া যোগ করো'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0E6B3E),
              foregroundColor: Colors.white,
              minimumSize:
                  const Size(double.infinity, 50),
            ),
          ),
        ),
      ],
    );
  }
}

class _HadithTab extends StatefulWidget {
  const _HadithTab();
  @override
  State<_HadithTab> createState() => _HadithTabState();
}

class _HadithTabState extends _BaseTabState<_HadithTab> {
  @override
  String get fileName => 'hadiths';
  @override
  void initState() {
    super.initState();
    loadItems();
  }

  void _add() {
    final a = TextEditingController();
    final b = TextEditingController();
    final s = TextEditingController();
    final t = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('নতুন হাদিস'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: a,
                  maxLines: 2,
                  decoration:
                      const InputDecoration(labelText: 'আরবি')),
              TextField(
                  controller: b,
                  maxLines: 2,
                  decoration:
                      const InputDecoration(labelText: 'বাংলা অর্থ')),
              TextField(
                  controller: s,
                  decoration:
                      const InputDecoration(labelText: 'উৎস')),
              TextField(
                  controller: t,
                  decoration:
                      const InputDecoration(labelText: 'বিষয়')),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('বাতিল')),
          ElevatedButton(
            onPressed: () async {
              if (b.text.trim().isEmpty) return;
              setState(() {
                items.add({
                  'arabic': a.text.trim(),
                  'bangla': b.text.trim(),
                  'source': s.text.trim(),
                  'topic': t.text.trim().isEmpty
                      ? 'সাধারণ'
                      : t.text.trim(),
                });
              });
              Navigator.pop(ctx);
              notifySaved(context, await saveItems());
            },
            child: const Text('যোগ করো'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text('${items.length}টি হাদিস',
              style: const TextStyle(color: Colors.black54)),
        ),
        Expanded(
          child: ListView.builder(
            padding:
                const EdgeInsets.symmetric(horizontal: 12),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final e = items[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text('${e['bangla']}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  subtitle: Text('${e['source']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete,
                        color: Colors.red),
                    onPressed: () async {
                      setState(
                          () => items.removeAt(i));
                      notifySaved(
                          context, await saveItems());
                    },
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _add,
            icon: const Icon(Icons.add),
            label: const Text('নতুন হাদিস যোগ করো'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0E6B3E),
              foregroundColor: Colors.white,
              minimumSize:
                  const Size(double.infinity, 50),
            ),
          ),
        ),
      ],
    );
  }
}
