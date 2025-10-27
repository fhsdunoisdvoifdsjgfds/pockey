import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class InvestmentNote {
  final String title;
  final double amount;
  final double profit;
  final DateTime date;
  final String type;
  final String category;
  final String timeframe;
  final String strategy;
  final String notes;

  InvestmentNote({
    required this.title,
    required this.amount,
    required this.profit,
    required this.date,
    required this.type,
    required this.category,
    required this.timeframe,
    required this.strategy,
    required this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'amount': amount,
      'profit': profit,
      'date': date.toIso8601String(),
      'type': type,
      'category': category,
      'timeframe': timeframe,
      'strategy': strategy,
      'notes': notes,
    };
  }

  factory InvestmentNote.fromJson(Map<String, dynamic> json) {
    return InvestmentNote(
      title: json['title'],
      amount: json['amount'],
      profit: json['profit'],
      date: DateTime.parse(json['date']),
      type: json['type'],
      category: json['category'],
      timeframe: json['timeframe'],
      strategy: json['strategy'],
      notes: json['notes'],
    );
  }
}

class RemoteConfigData {
  final bool shouldShowWebView;
  final String url;

  RemoteConfigData({required this.shouldShowWebView, required this.url});
}

class TradeProvider extends ChangeNotifier {
  List<InvestmentNote> _notes = [];
  bool _isLoaded = false;

  List<InvestmentNote> get notes => _notes;
  bool get isLoaded => _isLoaded;

  TradeProvider() {
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notesJson = prefs.getString('trades');
      final defaultsDeleted = prefs.getBool('defaults_deleted') ?? false;

      if (notesJson != null) {
        final List<dynamic> decoded = json.decode(notesJson);
        _notes = decoded.map((e) => InvestmentNote.fromJson(e)).toList();
      } else if (!defaultsDeleted) {
        // Только показываем дефолтные записи если они не были удалены
        _notes = [
          InvestmentNote(
            title: 'EUR/USD',
            amount: 250.0,
            profit: 175.0,
            date: DateTime.now().subtract(const Duration(days: 1)),
            type: 'Call',
            category: 'Forex',
            timeframe: '5 min',
            strategy: 'Trend Following',
            notes: 'Strong uptrend on H4',
          ),
          InvestmentNote(
            title: 'BTC/USD',
            amount: 500.0,
            profit: -150.0,
            date: DateTime.now().subtract(const Duration(days: 2)),
            type: 'Put',
            category: 'Crypto',
            timeframe: '15 min',
            strategy: 'Breakout',
            notes: 'False breakout',
          ),
        ];
      }

      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading notes: $e');
      _isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> _saveNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notesJson = json.encode(_notes.map((e) => e.toJson()).toList());
      await prefs.setString('trades', notesJson);

      // Если список пуст, отмечаем что дефолтные записи были удалены
      if (_notes.isEmpty) {
        await prefs.setBool('defaults_deleted', true);
      }
    } catch (e) {
      debugPrint('Error saving notes: $e');
    }
  }

  void addNote(InvestmentNote note) {
    _notes.insert(0, note);
    _saveNotes();
    notifyListeners();
  }

  void updateNote(int index, InvestmentNote note) {
    if (index >= 0 && index < _notes.length) {
      _notes[index] = note;
      _saveNotes();
      notifyListeners();
    }
  }

  void deleteNote(InvestmentNote note) {
    _notes.remove(note);
    _saveNotes();
    notifyListeners();
  }

  void deleteNoteAt(int index) {
    if (index >= 0 && index < _notes.length) {
      _notes.removeAt(index);
      _saveNotes();
      notifyListeners();
    }
  }

  double get totalProfit {
    return _notes.fold<double>(0, (sum, note) => sum + note.profit);
  }

  double get winRate {
    if (_notes.isEmpty) return 0.0;
    return _notes.where((n) => n.profit > 0).length / _notes.length * 100;
  }
}

class WebPage extends StatefulWidget {
  final String url;

  const WebPage({Key? key, required this.url}) : super(key: key);

  @override
  State<WebPage> createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {
  InAppWebViewController? webViewController;
  bool isLoading = true;
  double progress = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: SafeArea(
        child: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(widget.url)),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                useShouldOverrideUrlLoading: true,
                mediaPlaybackRequiresUserGesture: false,
                allowsInlineMediaPlayback: true,
                useHybridComposition: true,
              ),
              onWebViewCreated: (controller) {
                webViewController = controller;
              },
              onLoadStart: (controller, url) {
                setState(() {
                  isLoading = true;
                });
              },
              onLoadStop: (controller, url) async {
                setState(() {
                  isLoading = false;
                });
              },
              onProgressChanged: (controller, progress) {
                setState(() {
                  this.progress = progress / 100;
                });
              },
              onLoadError: (controller, url, code, message) {
                print('WebView error: $message');
              },
              onConsoleMessage: (controller, consoleMessage) {
                print('Console: ${consoleMessage.message}');
              },
            ),
            if (isLoading)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.deepPurple,
                      ),
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
