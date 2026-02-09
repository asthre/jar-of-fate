import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const JarofFate());
}

class JarofFate extends StatelessWidget {
  const JarofFate({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jar of Fate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
        primaryColor: const Color(0xFFFFD700), // Gold
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color(0xFF6C63FF), // Soft Purple
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontFamily: 'Roboto', fontSize: 16),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // "Jar" is the default mode now
  String _currentMode = 'Jar';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // UNIFIED BACKGROUND GRADIENT
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // --- CUSTOM APP BAR WITH DROPDOWN ---
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 10.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // THE DROPDOWN TITLE
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _currentMode,
                          dropdownColor: const Color(0xFF252545),
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Color(0xFFFFD700),
                          ),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Jar',
                              child: Text('The Jar'),
                            ),
                            DropdownMenuItem(
                              value: 'Sponty',
                              child: Text('Sponty Wheel'),
                            ),
                          ],
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() => _currentMode = newValue);
                            }
                          },
                        ),
                      ),
                    ),

                    // ACTION BUTTONS (Changes based on mode)
                    if (_currentMode == 'Jar')
                      // View Jar Contents Button
                      IconButton(
                        icon: const Icon(Icons.list_alt, color: Colors.white70),
                        tooltip: 'View Jar',
                        onPressed: () =>
                            _jarKey.currentState?.viewJarContents(),
                      )
                    else
                      // Clear Sponty Button
                      IconButton(
                        icon: const Icon(
                          Icons.delete_sweep,
                          color: Colors.white70,
                        ),
                        tooltip: 'Clear Wheel',
                        onPressed: () => _spontyKey.currentState?.clearAll(),
                      ),
                  ],
                ),
              ),

              // --- BODY CONTENT ---
              Expanded(
                child: _currentMode == 'Jar'
                    ? JarView(key: _jarKey)
                    : SpontyView(key: _spontyKey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Global Keys to access methods from the AppBar
final GlobalKey<_JarViewState> _jarKey = GlobalKey();
final GlobalKey<_SpontyViewState> _spontyKey = GlobalKey();

// ==========================================
// VIEW 1: THE JAR (Default)
// ==========================================
class JarView extends StatefulWidget {
  const JarView({Key? key}) : super(key: key);

  @override
  State<JarView> createState() => _JarViewState();
}

class _JarViewState extends State<JarView> with SingleTickerProviderStateMixin {
  List<String> _jarItems = [];
  final TextEditingController _jarController = TextEditingController();
  late AnimationController _shakeController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _loadJarData();
  }

  Future<void> _loadJarData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _jarItems = prefs.getStringList('jar_items') ?? [];
      _isLoading = false;
    });
  }

  Future<void> _saveJarData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('jar_items', _jarItems);
  }

  void _addToJar() {
    if (_jarController.text.isNotEmpty) {
      setState(() {
        _jarItems.add(_jarController.text);
        _jarController.clear();
      });
      _saveJarData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Added to Jar"),
          backgroundColor: Color(0xFF6C63FF),
          duration: Duration(milliseconds: 500),
        ),
      );
    }
  }

  void _pickFromJar() async {
    if (_jarItems.isEmpty) return;

    _shakeController.repeat(reverse: true);
    await Future.delayed(const Duration(seconds: 2));
    _shakeController.stop();
    _shakeController.reset();

    final winner = _jarItems[Random().nextInt(_jarItems.length)];

    if (mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF252545),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'The Jar Picked:',
            style: TextStyle(color: Colors.white70),
          ),
          content: Text(
            winner,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFD700),
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Keep it',
                style: TextStyle(color: Colors.white38),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() => _jarItems.remove(winner));
                _saveJarData();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
              ),
              child: const Text('Done & Remove'),
            ),
          ],
        ),
      );
    }
  }

  // Public method accessed via GlobalKey
  void viewJarContents() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF13132A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    "Inside the Jar",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: _jarItems.isEmpty
                        ? const Center(
                            child: Text(
                              "Jar is empty!",
                              style: TextStyle(color: Colors.white38),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _jarItems.length,
                            itemBuilder: (context, index) {
                              return Card(
                                color: const Color(0xFF1F1F35),
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                child: ListTile(
                                  title: Text(
                                    _jarItems[index],
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () {
                                      setState(() => _jarItems.removeAt(index));
                                      _saveJarData();
                                      setSheetState(() {});
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
        // VISUAL JAR
        Expanded(
          flex: 2,
          child: Center(
            child: GestureDetector(
              onTap: _pickFromJar,
              child: AnimatedBuilder(
                animation: _shakeController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_shakeController.value * 10, 0),
                    child: child,
                  );
                },
                child: Container(
                  width: 180,
                  height: 220,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    border: Border.all(color: Colors.white24, width: 2),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                      bottom: Radius.circular(40),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C63FF).withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.all_inclusive,
                        size: 50,
                        color: Colors.white24,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "${_jarItems.length}",
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        "Items",
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        if (_jarItems.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: ElevatedButton(
              onPressed: _pickFromJar,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 10,
              ),
              child: const Text(
                "SHAKE THE JAR",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),

        // INPUT AREA
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFF13132A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _jarController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Add to jar...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                    filled: true,
                    fillColor: const Color(0xFF1F1F35),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  onSubmitted: (_) => _addToJar(),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF6C63FF),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_upward, color: Colors.white),
                  onPressed: _addToJar,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ==========================================
// VIEW 2: SPONTY (Wheel)
// ==========================================
class SpontyView extends StatefulWidget {
  const SpontyView({Key? key}) : super(key: key);

  @override
  State<SpontyView> createState() => _SpontyViewState();
}

class _SpontyViewState extends State<SpontyView> {
  final StreamController<int> _selected = StreamController<int>();
  final TextEditingController _controller = TextEditingController();
  List<String> _options = [];
  bool _isSpinning = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSpontyData();
  }

  Future<void> _loadSpontyData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _options = prefs.getStringList('sponty_items') ?? [];
      _isLoading = false;
    });
  }

  Future<void> _saveSpontyData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('sponty_items', _options);
  }

  @override
  void dispose() {
    _selected.close();
    _controller.dispose();
    super.dispose();
  }

  void _addOption() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _options.add(_controller.text);
        _controller.clear();
      });
      _saveSpontyData();
    }
  }

  void _removeOption(int index) {
    setState(() {
      _options.removeAt(index);
    });
    _saveSpontyData();
  }

  // Public method accessed via GlobalKey
  void clearAll() {
    if (_options.isEmpty) return;
    setState(() {
      _options.clear();
    });
    _saveSpontyData();
  }

  void _spin() {
    if (_isSpinning || _options.length < 2) return;

    setState(() => _isSpinning = true);
    final randomIndex = Random().nextInt(_options.length);
    _selected.add(randomIndex);

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() => _isSpinning = false);
        _showResult(_options[randomIndex]);
      }
    });
  }

  void _showResult(String winner) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF252545),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '✨ Sponty Decided!',
          style: TextStyle(color: Colors.white70),
        ),
        content: Text(
          winner,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFFD700),
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Nice'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
        // WHEEL AREA
        SizedBox(
          height: 320,
          child: _options.length < 2
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.pie_chart_outline,
                        size: 80,
                        color: Colors.white.withOpacity(0.1),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Add at least 2 items to spin!",
                        style: TextStyle(color: Colors.white.withOpacity(0.3)),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: FortuneWheel(
                    selected: _selected.stream,
                    animateFirst: false,
                    physics: CircularPanPhysics(
                      duration: const Duration(seconds: 1),
                      curve: Curves.decelerate,
                    ),
                    items: [
                      for (var it in _options)
                        FortuneItem(
                          child: Text(
                            it,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: const FortuneItemStyle(
                            color: Color(0xFF6C63FF), // Unified Purple
                            borderColor: Color(0xFF1A1A2E),
                            borderWidth: 3,
                          ),
                        ),
                    ],
                  ),
                ),
        ),

        // SPIN BUTTON
        if (_options.length >= 2)
          ElevatedButton(
            onPressed: _isSpinning ? null : _spin,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700), // Gold
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 10,
            ),
            child: const Text(
              "SPIN IT",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

        const SizedBox(height: 20),

        // INPUT & LIST
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF13132A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Add option...',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                          ),
                          filled: true,
                          fillColor: const Color(0xFF1F1F35),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                        ),
                        onSubmitted: (_) => _addOption(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF6C63FF),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: _addOption,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: ListView.builder(
                    itemCount: _options.length,
                    itemBuilder: (context, index) => Card(
                      color: const Color(0xFF1F1F35),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(
                          _options[index],
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.white24,
                          ),
                          onPressed: () => _removeOption(index),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
