import 'package:flutter/material.dart';
import '../data/dynamic_content.dart';
import '../data/animations.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<QuizQuestion> _questions;
  int _index = 0;
  int _score = 0;
  int? _selected;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    final all = DynamicContent.allQuiz;
    _questions = List.of(all)..shuffle();
    _questions = _questions.take(10).toList();
  }

  void _answer(int i) {
    if (_selected != null) return;
    setState(() {
      _selected = i;
      if (i == _questions[_index].correctIndex) _score++;
    });
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() {
        if (_index < _questions.length - 1) {
          _index++;
          _selected = null;
        } else {
          _finished = true;
        }
      });
    });
  }

  void _restart() {
    setState(() {
      final all = DynamicContent.allQuiz;
      _questions = List.of(all)..shuffle();
      _questions = _questions.take(10).toList();
      _index = 0;
      _score = 0;
      _selected = null;
      _finished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ইসলামিক কুইজ')),
      body: _finished ? _resultView() : _quizView(),
    );
  }

  Widget _quizView() {
    final q = _questions[_index];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('প্রশ্ন ${_index + 1}/${_questions.length}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF6A4FB3).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('স্কোর: $_score',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6A4FB3))),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_index + 1) / _questions.length,
            backgroundColor: Colors.black12,
            color: const Color(0xFF6A4FB3),
          ),
          const SizedBox(height: 20),
          Card(
            color: const Color(0xFF6A4FB3),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                q.question,
                style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.6),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(q.options.length, (i) {
            Color? bg;
            if (_selected != null) {
              if (i == q.correctIndex) {
                bg = Colors.green.shade100;
              } else if (i == _selected) {
                bg = Colors.red.shade100;
              }
            }
            return Card(
              color: bg,
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF6A4FB3).withOpacity(0.12),
                  child: Text(
                    String.fromCharCode(65 + i),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6A4FB3)),
                  ),
                ),
                title: Text(q.options[i],
                    style: const TextStyle(fontSize: 15)),
                trailing: _selected != null && i == q.correctIndex
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : _selected != null && i == _selected
                        ? const Icon(Icons.cancel, color: Colors.red)
                        : null,
                onTap: () => _answer(i),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _resultView() {
    final pct = (_score / _questions.length * 100).round();
    String msg;
    if (pct >= 80) {
      msg = 'মাশাআল্লাহ! চমৎকার জ্ঞান! 🌟';
    } else if (pct >= 50) {
      msg = 'ভালো চেষ্টা! আরও শিখুন 📖';
    } else {
      msg = 'হাল ছাড়বেন না, আবার চেষ্টা করুন 💪';
    }
    final resultContent = Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$_score/${_questions.length}',
              style: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6A4FB3)),
            ),
            const SizedBox(height: 8),
            Text(msg,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _restart,
              icon: const Icon(Icons.refresh),
              label: const Text('আবার খেলুন'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A4FB3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
    // ৮০%+ স্কোরে confetti 🎉
    if (pct >= 80) {
      return ConfettiOverlay(child: resultContent);
    }
    return resultContent;
  }
}
