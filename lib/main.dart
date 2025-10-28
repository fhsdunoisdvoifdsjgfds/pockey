// ignore_for_file: deprecated_member_use, use_super_parameters, duplicate_ignore, unnecessary_string_interpolations, curly_braces_in_flow_control_structures

import 'dart:async';
import 'dart:math';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pockey/trade_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final appsFlyerOptions = AppsFlyerOptions(
    afDevKey: 'doJsrj8CyhTUWPZyAYTByE',
    appId: '6754536767',
    showDebug: false,
    timeToWaitForATTUserAuthorization: 50,
  );

  await AppTrackingTransparency.requestTrackingAuthorization();
  final AppsflyerSdk appsflyerSdk = AppsflyerSdk(appsFlyerOptions);
  await appsflyerSdk.initSdk(
    registerConversionDataCallback: true,
    registerOnAppOpenAttributionCallback: true,
    registerOnDeepLinkingCallback: true,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => TradeProvider(),
      child: PocketOptionApp(appsflyerSdk: appsflyerSdk),
    ),
  );
}

class PocketOptionApp extends StatelessWidget {
  final AppsflyerSdk appsflyerSdk;

  const PocketOptionApp({super.key, required this.appsflyerSdk});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pocket Option Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF0A1628),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF1E88E5),
          secondary: Color(0xFF42A5F5),
          surface: Color(0xFF132337),
          background: Color(0xFF0A1628),
        ),
      ),
      home: FutureBuilder<GetNews>(
        future: checkLatestNews(appsflyerSdk),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingScreen();
          }

          if (snapshot.hasData && snapshot.data!.shouldShowWebView) {
            return NewsPage(news_link: snapshot.data!.fetchedDatax);
          }

          return const MainScreen();
        },
      ),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  // ignore: use_super_parameters
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0A1628),
      body: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
          strokeWidth: 3,
        ),
      ),
    );
  }
}

class GetNews {
  final bool shouldShowWebView;
  final String fetchedDatax;

  GetNews({required this.shouldShowWebView, required this.fetchedDatax});
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const NotesScreen(),
    const TipsScreen(),
    const CalculatorsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    AppTrackingTransparency.requestTrackingAuthorization();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF132337),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          backgroundColor: Colors.transparent,
          selectedItemColor: const Color(0xFF42A5F5),
          unselectedItemColor: Colors.grey,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.poppins(),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.note_alt),
              label: 'Trades',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.lightbulb), label: 'Quiz'),
            BottomNavigationBarItem(
              icon: Icon(Icons.calculate),
              label: 'Tools',
            ),
          ],
        ),
      ),
    );
  }
}

class NotesScreen extends StatefulWidget {
  const NotesScreen({Key? key}) : super(key: key);

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  String selectedCategory = 'All';

  final categories = [
    'All',
    'Forex',
    'Crypto',
    'Stocks',
    'Commodities',
    'Indices',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<TradeProvider>(
      builder: (context, tradeProvider, child) {
        if (!tradeProvider.isLoaded) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF1E88E5)),
            ),
          );
        }

        final filteredNotes = selectedCategory == 'All'
            ? tradeProvider.notes
            : tradeProvider.notes
                  .where((n) => n.category == selectedCategory)
                  .toList();

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 280,
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xFF0A1628),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF1E88E5).withOpacity(0.3),
                          const Color(0xFF0A1628),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const LiveClock(),
                          const SizedBox(height: 24),
                          Text(
                            'My Trades',
                            style: GoogleFonts.poppins(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'Total P/L',
                                  '${tradeProvider.totalProfit >= 0 ? '+' : ''}\$${tradeProvider.totalProfit.toStringAsFixed(2)}',
                                  tradeProvider.totalProfit >= 0
                                      ? Colors.green
                                      : Colors.red,
                                  Icons.trending_up,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  'Win Rate',
                                  '${tradeProvider.winRate.toStringAsFixed(1)}%',
                                  const Color(0xFF42A5F5),
                                  Icons.percent,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = selectedCategory == category;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => selectedCategory = category),
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFF1E88E5),
                                      Color(0xFF42A5F5),
                                    ],
                                  )
                                : null,
                            color: isSelected ? null : const Color(0xFF132337),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : const Color(0xFF1E3A5F),
                            ),
                          ),
                          child: Text(
                            category,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              filteredNotes.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox,
                              size: 64,
                              color: Colors.grey[700],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No trades yet',
                              style: GoogleFonts.poppins(
                                color: Colors.grey,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final note = filteredNotes[index];
                          final originalIndex = tradeProvider.notes.indexOf(
                            note,
                          );
                          return Dismissible(
                            key: Key(note.date.toString()),
                            background: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 24),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) {
                              tradeProvider.deleteNote(note);
                            },
                            child: GestureDetector(
                              onTap: () =>
                                  _showEditDialog(context, note, originalIndex),
                              child: _buildTradeCard(note),
                            ),
                          );
                        }, childCount: filteredNotes.length),
                      ),
                    ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddNoteDialog(context),
            backgroundColor: const Color(0xFF1E88E5),
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(
              'Add Trade',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF132337),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 11),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTradeCard(InvestmentNote note) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1E3A5F), const Color(0xFF132337)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E88E5).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: note.type == 'Call'
                            ? Colors.green.withOpacity(0.2)
                            : Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        note.type == 'Call'
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        color: note.type == 'Call' ? Colors.green : Colors.red,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.title,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          note.category,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF42A5F5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: note.type == 'Call'
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    note.type,
                    style: GoogleFonts.poppins(
                      color: note.type == 'Call' ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0A1628).withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailItem(
                          'Investment',
                          '\$${note.amount.toStringAsFixed(2)}',
                          Icons.payments,
                        ),
                      ),
                      Container(width: 1, height: 40, color: Colors.grey[800]),
                      Expanded(
                        child: _buildDetailItem(
                          'Profit/Loss',
                          '${note.profit >= 0 ? '+' : ''}\$${note.profit.toStringAsFixed(2)}',
                          Icons.trending_up,
                          color: note.profit >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: Color(0xFF1E3A5F)),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailItem(
                          'Timeframe',
                          note.timeframe,
                          Icons.access_time,
                        ),
                      ),
                      Container(width: 1, height: 40, color: Colors.grey[800]),
                      Expanded(
                        child: _buildDetailItem(
                          'Strategy',
                          note.strategy,
                          Icons.psychology,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (note.notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A1628).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.note, color: Color(0xFF42A5F5), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        note.notes,
                        style: GoogleFonts.poppins(
                          color: Colors.grey[400],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              '${note.date.day}/${note.date.month}/${note.date.year} ${note.date.hour}:${note.date.minute.toString().padLeft(2, '0')}',
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color ?? const Color(0xFF42A5F5), size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(color: Colors.grey, fontSize: 10),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: color ?? Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showAddNoteDialog(BuildContext context) {
    _showTradeDialog(context, null, null);
  }

  void _showEditDialog(BuildContext context, InvestmentNote note, int index) {
    _showTradeDialog(context, note, index);
  }

  void _showTradeDialog(
    BuildContext context,
    InvestmentNote? note,
    int? index,
  ) {
    final titleController = TextEditingController(text: note?.title ?? '');
    final amountController = TextEditingController(
      text: note?.amount.toString() ?? '',
    );
    final profitController = TextEditingController(
      text: note?.profit.toString() ?? '',
    );
    final notesController = TextEditingController(text: note?.notes ?? '');
    String selectedType = note?.type ?? 'Call';
    String selectedCategory = note?.category ?? 'Forex';
    String selectedTimeframe = note?.timeframe ?? '5 min';
    String selectedStrategy = note?.strategy ?? 'Trend Following';

    final timeframes = [
      '1 min',
      '5 min',
      '15 min',
      '30 min',
      '1 hour',
      '4 hour',
    ];
    final strategies = [
      'Trend Following',
      'Breakout',
      'Reversal',
      'Support/Resistance',
      'Scalping',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1E3A5F), Color(0xFF0A1628)],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      note == null ? 'Add New Trade' : 'Edit Trade',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildModalInputField(
                        'Trade Pair',
                        titleController,
                        Icons.currency_exchange,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildModalInputField(
                              'Amount (\$)',
                              amountController,
                              Icons.payments,
                              isNumber: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildModalInputField(
                              'P/L (\$)',
                              profitController,
                              Icons.trending_up,
                              isNumber: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Trade Type',
                        style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTypeButton(
                              'Call',
                              selectedType == 'Call',
                              Colors.green,
                              () {
                                setModalState(() => selectedType = 'Call');
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTypeButton(
                              'Put',
                              selectedType == 'Put',
                              Colors.red,
                              () {
                                setModalState(() => selectedType = 'Put');
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Category',
                        style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: categories.skip(1).map((cat) {
                          return GestureDetector(
                            onTap: () =>
                                setModalState(() => selectedCategory = cat),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: selectedCategory == cat
                                    ? const Color(0xFF1E88E5)
                                    : const Color(0xFF132337),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selectedCategory == cat
                                      ? const Color(0xFF42A5F5)
                                      : const Color(0xFF1E3A5F),
                                ),
                              ),
                              child: Text(
                                cat,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: selectedCategory == cat
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      _buildDropdownField(
                        'Timeframe',
                        selectedTimeframe,
                        timeframes,
                        (val) {
                          setModalState(() => selectedTimeframe = val!);
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildDropdownField(
                        'Strategy',
                        selectedStrategy,
                        strategies,
                        (val) {
                          setModalState(() => selectedStrategy = val!);
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildModalInputField(
                        'Notes (Optional)',
                        notesController,
                        Icons.note,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            if (titleController.text.isEmpty ||
                                amountController.text.isEmpty ||
                                profitController.text.isEmpty) {
                              return;
                            }
                            final tradeProvider = context.read<TradeProvider>();
                            final newNote = InvestmentNote(
                              title: titleController.text,
                              amount: double.parse(amountController.text),
                              profit: double.parse(profitController.text),
                              date: DateTime.now(),
                              type: selectedType,
                              category: selectedCategory,
                              timeframe: selectedTimeframe,
                              strategy: selectedStrategy,
                              notes: notesController.text,
                            );
                            if (note == null) {
                              tradeProvider.addNote(newNote);
                            } else {
                              tradeProvider.updateNote(index!, newNote);
                            }
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E88E5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            note == null ? 'Add Trade' : 'Update Trade',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModalInputField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      style: GoogleFonts.poppins(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.grey),
        prefixIcon: Icon(icon, color: const Color(0xFF42A5F5)),
        filled: true,
        fillColor: const Color(0xFF132337),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF1E3A5F)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF1E3A5F)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
        ),
      ),
    );
  }

  Widget _buildTypeButton(
    String label,
    bool isSelected,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : const Color(0xFF132337),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : const Color(0xFF1E3A5F),
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: isSelected ? color : Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF132337),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E3A5F)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: const Color(0xFF132337),
          style: GoogleFonts.poppins(color: Colors.white),
          items: items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
          hint: Text(label, style: GoogleFonts.poppins(color: Colors.grey)),
        ),
      ),
    );
  }
}

class LiveClock extends StatefulWidget {
  const LiveClock({Key? key}) : super(key: key);

  @override
  State<LiveClock> createState() => _LiveClockState();
}

class _LiveClockState extends State<LiveClock> {
  late Timer _timer;
  String _timeString = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) => _updateTime(),
    );
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _timeString =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF132337),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1E88E5).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today,
                color: Color(0xFF42A5F5),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.access_time, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(
                _timeString,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class TipsScreen extends StatefulWidget {
  const TipsScreen({Key? key}) : super(key: key);

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> {
  int? selectedLevel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Trading Quiz',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: selectedLevel == null
          ? _buildLevelSelection()
          : QuizLevelScreen(
              level: selectedLevel!,
              onBack: () => setState(() => selectedLevel = null),
            ),
    );
  }

  Widget _buildLevelSelection() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Test Your Knowledge',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose your difficulty level and answer 5 questions',
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 32),
            _buildLevelCard(
              'Beginner',
              'Basic concepts and terminology',
              Icons.star_border,
              const Color(0xFF4CAF50),
              1,
            ),
            const SizedBox(height: 16),
            _buildLevelCard(
              'Intermediate',
              'Strategies and risk management',
              Icons.star_half,
              const Color(0xFF2196F3),
              2,
            ),
            const SizedBox(height: 16),
            _buildLevelCard(
              'Advanced',
              'Technical analysis and advanced trading',
              Icons.star,
              const Color(0xFFFF9800),
              3,
            ),
            const SizedBox(height: 16),
            _buildLevelCard(
              'Expert',
              'Complex trading strategies',
              Icons.verified,
              const Color(0xFFD81B60),
              4,
            ),
            const SizedBox(height: 16),
            _buildLevelCard(
              'Master',
              'Real-world trading scenarios',
              Icons.emoji_events,
              const Color(0xFF7B1FA2),
              5,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelCard(
    String title,
    String description,
    IconData icon,
    Color color,
    int level,
  ) {
    return GestureDetector(
      onTap: () => setState(() => selectedLevel = level),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.2), const Color(0xFF132337)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.4), width: 2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      color: Colors.grey[400],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}

class QuizLevelScreen extends StatefulWidget {
  final int level;
  final VoidCallback onBack;

  const QuizLevelScreen({Key? key, required this.level, required this.onBack})
    : super(key: key);

  @override
  State<QuizLevelScreen> createState() => _QuizLevelScreenState();
}

class _QuizLevelScreenState extends State<QuizLevelScreen> {
  int currentQuestion = 0;
  int score = 0;
  bool answered = false;
  int? selectedAnswer;
  bool quizCompleted = false;

  late List<QuizQuestion> questions;

  @override
  void initState() {
    super.initState();
    questions = _getQuestionsForLevel(widget.level);
  }

  List<QuizQuestion> _getQuestionsForLevel(int level) {
    if (level == 1) {
      return [
        QuizQuestion('What is a binary option?', [
          'A type of stock',
          'A fixed return financial option',
          'A cryptocurrency',
          'A forex pair',
        ], 1),
        QuizQuestion('What does "Call" option mean?', [
          'Price will go down',
          'Price will go up',
          'Price stays same',
          'Market closes',
        ], 1),
        QuizQuestion('What is the maximum risk in binary options?', [
          'Unlimited',
          'Your investment amount',
          '50% of investment',
          'Depends on market',
        ], 1),
        QuizQuestion('What is a "Put" option?', [
          'Betting price goes up',
          'Betting price goes down',
          'Holding position',
          'Closing trade',
        ], 1),
        QuizQuestion('What is the typical payout in binary options?', [
          '50-90%',
          '100-200%',
          '200-500%',
          'Variable unlimited',
        ], 0),
      ];
    } else if (level == 2) {
      return [
        QuizQuestion('What is the recommended risk per trade?', [
          '10-20%',
          '20-50%',
          '2-5%',
          '50-100%',
        ], 2),
        QuizQuestion('What is a support level?', [
          'Price ceiling',
          'Price floor',
          'Average price',
          'Opening price',
        ], 1),
        QuizQuestion('What does RSI indicator measure?', [
          'Volume',
          'Momentum and overbought/oversold',
          'Moving average',
          'Volatility',
        ], 1),
        QuizQuestion('What is the best time to trade forex?', [
          'Weekend',
          'Market overlap sessions',
          'Late night',
          'Random times',
        ], 1),
        QuizQuestion('What is martingale strategy?', [
          'Always same amount',
          'Double after loss',
          'Reduce after win',
          'Random amounts',
        ], 1),
      ];
    } else if (level == 3) {
      return [
        QuizQuestion('What is a Japanese Candlestick pattern?', [
          'Price chart type',
          'Trading robot',
          'Market indicator',
          'Currency pair',
        ], 0),
        QuizQuestion('What does a "Doji" candle indicate?', [
          'Strong trend',
          'Market indecision',
          'High volume',
          'Market close',
        ], 1),
        QuizQuestion('What is Fibonacci retracement used for?', [
          'Predict time',
          'Identify support/resistance',
          'Calculate profit',
          'Measure volume',
        ], 1),
        QuizQuestion('What is implied volatility?', [
          'Past price movement',
          'Expected future volatility',
          'Trading volume',
          'Market cap',
        ], 1),
        QuizQuestion('What is "hedging" in trading?', [
          'Increasing risk',
          'Offsetting risk',
          'Closing account',
          'Adding funds',
        ], 1),
      ];
    } else if (level == 4) {
      return [
        QuizQuestion('What is the Kelly Criterion used for?', [
          'Chart analysis',
          'Position sizing',
          'Market timing',
          'Tax calculation',
        ], 1),
        QuizQuestion('What does a "Gamma" represent in options?', [
          'Price movement',
          'Rate of delta change',
          'Time decay',
          'Volatility',
        ], 1),
        QuizQuestion('What is a straddle strategy?', [
          'Betting on no movement',
          'Betting on large movement',
          'Hedging losses',
          'Fixed income',
        ], 1),
        QuizQuestion('What is a limit order?', [
          'Market execution',
          'Price-specific order',
          'Stop-loss order',
          'Random order',
        ], 1),
        QuizQuestion('What does ATR measure?', [
          'Trend strength',
          'Average true range',
          'Price momentum',
          'Volume',
        ], 1),
      ];
    } else {
      return [
        QuizQuestion('How does a black swan event affect markets?', [
          'Predictable gains',
          'Extreme volatility',
          'Stable prices',
          'No impact',
        ], 1),
        QuizQuestion('What is the impact of a central bank rate hike?', [
          'Lower prices',
          'Higher borrowing costs',
          'More liquidity',
          'No change',
        ], 1),
        QuizQuestion('What is arbitrage?', [
          'Risky trading',
          'Exploiting price differences',
          'Long-term holding',
          'Hedging',
        ], 1),
        QuizQuestion('What does a high VIX indicate?', [
          'Low volatility',
          'High volatility',
          'Stable market',
          'Bullish trend',
        ], 1),
        QuizQuestion('What is a synthetic position?', [
          'Real stock holding',
          'Mimicking another position',
          'Cash reserve',
          'Tax strategy',
        ], 1),
      ];
    }
  }

  void _selectAnswer(int index) {
    if (answered) return;
    setState(() {
      selectedAnswer = index;
      answered = true;
      if (index == questions[currentQuestion].correctAnswer) {
        score++;
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (currentQuestion < questions.length - 1) {
        setState(() {
          currentQuestion++;
          answered = false;
          selectedAnswer = null;
        });
      } else {
        setState(() => quizCompleted = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (quizCompleted) {
      return _buildResultScreen();
    }

    final question = questions[currentQuestion];
    final progress = (currentQuestion + 1) / questions.length;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Question ${currentQuestion + 1}/${questions.length}',
                      style: GoogleFonts.poppins(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: const Color(0xFF132337),
                        valueColor: const AlwaysStoppedAnimation(
                          Color(0xFF1E88E5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A5F), Color(0xFF132337)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              question.question,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: question.options.length,
              itemBuilder: (context, index) {
                Color? backgroundColor;
                Color? borderColor;

                if (answered) {
                  if (index == question.correctAnswer) {
                    backgroundColor = Colors.green.withOpacity(0.2);
                    borderColor = Colors.green;
                  } else if (index == selectedAnswer) {
                    backgroundColor = Colors.red.withOpacity(0.2);
                    borderColor = Colors.red;
                  }
                } else if (index == selectedAnswer) {
                  backgroundColor = const Color(0xFF1E88E5).withOpacity(0.2);
                  borderColor = const Color(0xFF1E88E5);
                }

                return GestureDetector(
                  onTap: () => _selectAnswer(index),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: backgroundColor ?? const Color(0xFF132337),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: borderColor ?? const Color(0xFF1E3A5F),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color:
                                borderColor?.withOpacity(0.2) ??
                                const Color(0xFF0A1628),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              String.fromCharCode(65 + index),
                              style: GoogleFonts.poppins(
                                color: borderColor ?? Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            question.options[index],
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (answered && index == question.correctAnswer)
                          const Icon(Icons.check_circle, color: Colors.green),
                        if (answered &&
                            index == selectedAnswer &&
                            index != question.correctAnswer)
                          const Icon(Icons.cancel, color: Colors.red),
                      ],
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

  Widget _buildResultScreen() {
    final percentage = (score / questions.length * 100).round();
    Color resultColor;
    String resultText;
    IconData resultIcon;

    if (percentage >= 80) {
      resultColor = Colors.green;
      resultText = 'Excellent!';
      resultIcon = Icons.emoji_events;
    } else if (percentage >= 60) {
      resultColor = const Color(0xFF2196F3);
      resultText = 'Good Job!';
      resultIcon = Icons.thumb_up;
    } else {
      resultColor = Colors.orange;
      resultText = 'Keep Learning!';
      resultIcon = Icons.school;
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: resultColor.withOpacity(0.2),
            ),
            child: Icon(resultIcon, size: 80, color: resultColor),
          ),
          const SizedBox(height: 32),
          Text(
            resultText,
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your Score',
            style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            '$score/${questions.length}',
            style: GoogleFonts.poppins(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: resultColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$percentage% Correct',
            style: GoogleFonts.poppins(color: Colors.grey, fontSize: 18),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  currentQuestion = 0;
                  score = 0;
                  answered = false;
                  selectedAnswer = null;
                  quizCompleted = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Try Again',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: widget.onBack,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF1E88E5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Back to Levels',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E88E5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CalculatorsScreen extends StatelessWidget {
  const CalculatorsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Calculators',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCalculatorCard(
            context,
            'Risk Calculator',
            'Calculate position size and risk metrics',
            Icons.shield,
            const Color(0xFF1E88E5),
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RiskCalculator()),
            ),
          ),
          _buildCalculatorCard(
            context,
            'Compound Interest',
            'Project investment growth with detailed breakdown',
            Icons.trending_up,
            const Color(0xFF42A5F5),
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CompoundCalculator()),
            ),
          ),
          _buildCalculatorCard(
            context,
            'Mortgage Calculator',
            'Estimate mortgage payments and total costs',
            Icons.home,
            const Color(0xFF64B5F6),
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MortgageCalculator()),
            ),
          ),
          _buildCalculatorCard(
            context,
            'Pip Value Calculator',
            'Calculate pip value for Forex trading',
            Icons.currency_exchange,
            const Color(0xFF0288D1),
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PipValueCalculator()),
            ),
          ),
          _buildCalculatorCard(
            context,
            'Position Size Calculator',
            'Optimize trade size based on risk',
            Icons.account_balance_wallet,
            const Color(0xFF1976D2),
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PositionSizeCalculator()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatorCard(
    BuildContext context,
    String title,
    String desc,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.2), const Color(0xFF132337)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      desc,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class RiskCalculator extends StatefulWidget {
  const RiskCalculator({Key? key}) : super(key: key);

  @override
  State<RiskCalculator> createState() => _RiskCalculatorState();
}

class _RiskCalculatorState extends State<RiskCalculator> {
  final _capitalController = TextEditingController();
  final _riskController = TextEditingController(text: '2');
  double _positionSize = 0;
  double _riskAmount = 0;
  double _stopLoss = 0;

  void _calculate() {
    final capital = double.tryParse(_capitalController.text) ?? 0;
    final risk = double.tryParse(_riskController.text) ?? 0;
    setState(() {
      _riskAmount = capital * (risk / 100);
      _positionSize = _riskAmount;
      _stopLoss = _riskAmount * 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Risk Calculator', style: GoogleFonts.poppins()),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildInputField('Total Capital (\$)', _capitalController),
            const SizedBox(height: 16),
            _buildInputField('Risk Per Trade (%)', _riskController),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _calculate,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Calculate',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A5F), Color(0xFF132337)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    'Results',
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildResultItem(
                    'Risk Amount',
                    '\$${_riskAmount.toStringAsFixed(2)}',
                    Colors.white,
                  ),
                  _buildResultItem(
                    'Position Size',
                    '\$${_positionSize.toStringAsFixed(2)}',
                    const Color(0xFF42A5F5),
                  ),
                  _buildResultItem(
                    'Recommended Stop-Loss',
                    '\$${_stopLoss.toStringAsFixed(2)}',
                    Colors.green,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: GoogleFonts.poppins(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF132337),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class CompoundCalculator extends StatefulWidget {
  const CompoundCalculator({Key? key}) : super(key: key);

  @override
  State<CompoundCalculator> createState() => _CompoundCalculatorState();
}

class _CompoundCalculatorState extends State<CompoundCalculator> {
  final _principalController = TextEditingController();
  final _rateController = TextEditingController();
  final _timeController = TextEditingController();
  double _finalAmount = 0;
  List<double> _yearlyGrowth = [];

  void _calculate() {
    final p = double.tryParse(_principalController.text) ?? 0;
    final r = double.tryParse(_rateController.text) ?? 0;
    final t = double.tryParse(_timeController.text) ?? 0;
    setState(() {
      _finalAmount = p * pow(1 + r / 100, t);
      _yearlyGrowth = List.generate(
        t.ceil(),
        (i) => p * pow(1 + r / 100, i + 1),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Compound Interest', style: GoogleFonts.poppins()),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildInputField('Principal Amount (\$)', _principalController),
            const SizedBox(height: 16),
            _buildInputField('Annual Rate (%)', _rateController),
            const SizedBox(height: 16),
            _buildInputField('Time Period (Years)', _timeController),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _calculate,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF42A5F5),
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Calculate',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A5F), Color(0xFF132337)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    'Final Amount',
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_finalAmount.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF42A5F5),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Profit: ${(_finalAmount - (double.tryParse(_principalController.text) ?? 0)).toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      color: Colors.green,
                      fontSize: 18,
                    ),
                  ),
                  if (_yearlyGrowth.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Yearly Growth',
                      style: GoogleFonts.poppins(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _yearlyGrowth.length,
                        itemBuilder: (context, index) => Container(
                          width: 120,
                          margin: const EdgeInsets.only(right: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF132337),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Year ${index + 1}',
                                style: GoogleFonts.poppins(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '\$${_yearlyGrowth[index].toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: GoogleFonts.poppins(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF132337),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class MortgageCalculator extends StatefulWidget {
  const MortgageCalculator({Key? key}) : super(key: key);

  @override
  State<MortgageCalculator> createState() => _MortgageCalculatorState();
}

class _MortgageCalculatorState extends State<MortgageCalculator> {
  final _loanController = TextEditingController();
  final _rateController = TextEditingController();
  final _yearsController = TextEditingController();
  double _monthlyPayment = 0;
  double _totalInterest = 0;
  List<Map<String, double>> _amortization = [];

  void _calculate() {
    final p = double.tryParse(_loanController.text) ?? 0;
    final annualRate = double.tryParse(_rateController.text) ?? 0;
    final years = double.tryParse(_yearsController.text) ?? 0;

    final monthlyRate = annualRate / 100 / 12;
    final numPayments = years * 12;

    setState(() {
      if (monthlyRate == 0) {
        _monthlyPayment = p / numPayments;
      } else {
        _monthlyPayment =
            p *
            (monthlyRate * pow(1 + monthlyRate, numPayments)) /
            (pow(1 + monthlyRate, numPayments) - 1);
      }
      _totalInterest = (_monthlyPayment * numPayments) - p;
      _amortization = List.generate(
        5,
        (i) => {
          'month': (i + 1).toDouble(),
          'payment': _monthlyPayment,
          'remaining':
              p * pow(1 + monthlyRate, i + 1) -
              (_monthlyPayment *
                  ((pow(1 + monthlyRate, i + 1) - 1) / monthlyRate)),
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mortgage Calculator', style: GoogleFonts.poppins()),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildInputField('Loan Amount (\$)', _loanController),
            const SizedBox(height: 16),
            _buildInputField('Annual Interest Rate (%)', _rateController),
            const SizedBox(height: 16),
            _buildInputField('Loan Term (Years)', _yearsController),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _calculate,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF64B5F6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Calculate',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A5F), Color(0xFF132337)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    'Monthly Payment',
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${_monthlyPayment.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF42A5F5),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Total Interest: ${_totalInterest.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      color: Colors.green,
                      fontSize: 18,
                    ),
                  ),
                  if (_amortization.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Amortization Preview (First 5 Months)',
                      style: GoogleFonts.poppins(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    ..._amortization.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Month ${entry['month']!.toInt()}',
                              style: GoogleFonts.poppins(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              'Remaining: \$${entry['remaining']!.toStringAsFixed(2)}',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: GoogleFonts.poppins(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF132337),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class PipValueCalculator extends StatefulWidget {
  const PipValueCalculator({Key? key}) : super(key: key);

  @override
  State<PipValueCalculator> createState() => _PipValueCalculatorState();
}

class _PipValueCalculatorState extends State<PipValueCalculator> {
  final _lotSizeController = TextEditingController();
  final _exchangeRateController = TextEditingController();
  String _accountCurrency = 'USD';
  double _pipValue = 0;

  final _currencies = ['USD', 'EUR', 'GBP', 'JPY'];

  void _calculate() {
    final lotSize = double.tryParse(_lotSizeController.text) ?? 0;
    final exchangeRate = double.tryParse(_exchangeRateController.text) ?? 1;
    setState(() {
      _pipValue = (0.0001 / exchangeRate) * lotSize * 100000;
      if (_accountCurrency == 'JPY') _pipValue *= 100;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pip Value Calculator', style: GoogleFonts.poppins()),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildInputField('Lot Size', _lotSizeController),
            const SizedBox(height: 16),
            _buildInputField('Exchange Rate', _exchangeRateController),
            const SizedBox(height: 16),
            _buildDropdownField(
              'Account Currency',
              _accountCurrency,
              _currencies,
              (val) => setState(() => _accountCurrency = val!),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _calculate,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0288D1),
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Calculate',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A5F), Color(0xFF132337)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    'Pip Value',
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${_pipValue.toStringAsFixed(4)}',
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF42A5F5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: GoogleFonts.poppins(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF132337),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF132337),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E3A5F)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: const Color(0xFF132337),
          style: GoogleFonts.poppins(color: Colors.white),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
          hint: Text(label, style: GoogleFonts.poppins(color: Colors.grey)),
        ),
      ),
    );
  }
}

class PositionSizeCalculator extends StatefulWidget {
  const PositionSizeCalculator({Key? key}) : super(key: key);

  @override
  State<PositionSizeCalculator> createState() => _PositionSizeCalculatorState();
}

class _PositionSizeCalculatorState extends State<PositionSizeCalculator> {
  final _accountSizeController = TextEditingController();
  final _riskPercentController = TextEditingController(text: '2');
  final _stopLossController = TextEditingController();
  double _positionSize = 0;
  double _shares = 0;
  final _assetPriceController = TextEditingController();

  void _calculate() {
    final accountSize = double.tryParse(_accountSizeController.text) ?? 0;
    final riskPercent = double.tryParse(_riskPercentController.text) ?? 0;
    final stopLoss = double.tryParse(_stopLossController.text) ?? 0;
    final assetPrice = double.tryParse(_assetPriceController.text) ?? 1;
    setState(() {
      final riskAmount = accountSize * (riskPercent / 100);
      _positionSize = riskAmount;
      _shares = riskAmount / stopLoss;
      if (_shares * assetPrice > accountSize)
        _shares = accountSize / assetPrice;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Position Size Calculator', style: GoogleFonts.poppins()),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildInputField('Account Size (\$)', _accountSizeController),
            const SizedBox(height: 16),
            _buildInputField('Risk Per Trade (%)', _riskPercentController),
            const SizedBox(height: 16),
            _buildInputField('Stop Loss Distance (\$)', _stopLossController),
            const SizedBox(height: 16),
            _buildInputField('Asset Price (\$)', _assetPriceController),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _calculate,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Calculate',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A5F), Color(0xFF132337)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    'Position Size',
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${_positionSize.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF42A5F5),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Shares/Contracts: ${_shares.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      color: Colors.green,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: GoogleFonts.poppins(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF132337),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswer;

  QuizQuestion(this.question, this.options, this.correctAnswer);
}

class TipItem {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  TipItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
