import 'package:flutter/material.dart';
import 'dart:math';

// ---------------------------------------------------------
// DYNAMIC ODDS ENGINE (~3.87% APY)
// Adjusts based on Recovery Stage
// ---------------------------------------------------------
int generateRaindropPrize(int recoveryStage) {
  double roll = Random().nextDouble() * 100;

  if (recoveryStage == 1) {
    // Stage 1: High Variance (Like a standard lottery/Premium Bonds)
    if (roll < 0.02) return 10000;
    if (roll < 0.20) return 1000;
    if (roll < 1.00) return 250;
    if (roll < 3.00) return 100;
    if (roll < 10.00) return 30;
    if (roll < 30.00) return 10;
    if (roll < 90.00) return 5;
    return 0;
  } else if (recoveryStage == 2) {
    // Stage 2: Medium Variance (Fewer massive hits, better baseline)
    if (roll < 0.10) return 1000;
    if (roll < 1.00) return 250;
    if (roll < 5.00) return 100;
    if (roll < 20.00) return 25;
    if (roll < 70.00) return 10;
    if (roll < 95.00) return 5;
    return 2;
  } else {
    // Stage 3: Low Variance (Consistent, predictable savings yield)
    if (roll < 2.00) return 100;
    if (roll < 15.00) return 30;
    if (roll < 85.00) return 15; // Extremely common, consistent hit
    return 10;
  }
}

// ---------------------------------------------------------
// RAFFLE ODDS ENGINE
// ---------------------------------------------------------
String generateRafflePrize() {
  double roll = Random().nextDouble() * 100;

  if (roll < 0.02) return "Legendary Bundle";
  if (roll < 0.20) return "Epic Bundle"; // 0.02 + 0.18
  if (roll < 0.80) return "Rare Bundle"; // 0.20 + 0.60
  if (roll < 10.80) return "10 Drops"; // 0.80 + 10.0
  return "Try Again"; // 89.2%
}

void main() {
  runApp(const RainsaveApp());
}

class RainsaveApp extends StatelessWidget {
  const RainsaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rainsave',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E67A0),
          primary: const Color(0xFF2E67A0),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0; // Defaulting to Home tab

  // Global Mock App State
  double linkedBalance = 1842.37;
  int totalTickets = 12;
  int playableTickets = 12;
  int rewards = 12800;
  double learningProgress = 0.66;
  bool isEVLessonDone = false;

  // Settings & Limits
  String _intensityLevel = 'High';
  bool _isLocked = false;
  int _maxDailyTickets = 5;
  int _ticketsPlayedToday = 0;

  // Hackathon Feature: Recovery Stage (1 = High Variance, 3 = Low Variance)
  int _recoveryStage = 1;

  // Raffle State
  int _usedRaffleEntries = 0;
  final int _maxRaffleEntries = 3;

  // Controllers for ticket inputs
  final TextEditingController _buyController = TextEditingController();
  final TextEditingController _sellController = TextEditingController();

  @override
  void dispose() {
    _buyController.dispose();
    _sellController.dispose();
    super.dispose();
  }

  void _toggleLock() {
    setState(() {
      _isLocked = !_isLocked;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isLocked
            ? "App Locked. Transactions & gameplay disabled."
            : "App Unlocked."),
        backgroundColor: _isLocked ? Colors.red[700] : Colors.green[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Hackathon Feature: Trigger Alert for Relapse Detection
  void _triggerTrustedContactAlert(String triggerReason) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.shield, color: Color(0xFF2E67A0)),
            SizedBox(width: 8),
            Text("Safety Trigger",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Text(
          "Unusual activity detected: $triggerReason.\n\n"
          "As part of your recovery plan, a secure notification has been sent to your trusted contact (Warren Buffet) so they can check in with you.",
          style: const TextStyle(fontSize: 15, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Understood",
                style: TextStyle(
                    color: Color(0xFF2E67A0), fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  void _purchaseStoreItem(int cost, String itemName) {
    if (_isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Unlock the app to make purchases."),
          behavior: SnackBarBehavior.floating));
      return;
    }

    if (rewards >= cost) {
      setState(() {
        rewards -= cost;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Successfully redeemed: $itemName!"),
          backgroundColor: Colors.green[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Not enough Raindrops for this item."),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _buyTickets() {
    if (_isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Unlock the app to buy tickets."),
          behavior: SnackBarBehavior.floating));
      return;
    }

    int qty = int.tryParse(_buyController.text) ?? 0;
    if (qty > 0 && linkedBalance >= (qty * 10)) {
      // Relapse Detection Alert
      if (qty >= 10) {
        _triggerTrustedContactAlert("Large ticket purchase (£${qty * 10})");
      }

      setState(() {
        linkedBalance -= qty * 10;
        totalTickets += qty;
        playableTickets += qty;
        _buyController.clear();
      });
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Bought $qty tickets!"),
          backgroundColor: Colors.green[700]));
    }
  }

  void _sellTickets() {
    if (_isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Unlock the app to sell tickets."),
          behavior: SnackBarBehavior.floating));
      return;
    }

    int qty = int.tryParse(_sellController.text) ?? 0;
    if (qty > 0 && totalTickets >= qty) {
      // Relapse Detection Alert
      if (qty >= 10) {
        _triggerTrustedContactAlert("Large withdrawal (£${qty * 10})");
      }

      setState(() {
        linkedBalance += qty * 10;
        totalTickets -= qty;
        if (playableTickets > totalTickets) playableTickets = totalTickets;
        _sellController.clear();
      });
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Sold $qty tickets!"),
          backgroundColor: Colors.blue[700]));
    }
  }

  void _startEVLesson() async {
    final bool? passedQuiz = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => const EVLessonScreen()));

    if (passedQuiz == true && !isEVLessonDone) {
      setState(() {
        isEVLessonDone = true;
        learningProgress = 1.0;
        rewards += 300;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text("Lesson completed! +300 Raindrops added."),
            backgroundColor: Colors.green[700]));
      }
    }
  }

  void _showRaffleRules() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Raffle Prizes & Odds",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _oddsRow("0.02%",
                    "Legendary Bundle (Rare Avatar + Theme + 5K Drops)"),
                _oddsRow("0.18%", "Epic Bundle (Theme + 1K Drops)"),
                _oddsRow("0.60%", "Rare Bundle (Avatar + 500 Drops)"),
                _oddsRow("10.0%", "Consolation (10 Raindrops)"),
                _oddsRow("89.2%", "Try Again (No Win)"),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E67A0),
                        foregroundColor: Colors.white),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Understood"),
                  ),
                )
              ],
            ),
          );
        });
  }

  void _enterRaffle() async {
    if (_isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("App is locked!"),
          behavior: SnackBarBehavior.floating));
      return;
    }
    if (_usedRaffleEntries >= _maxRaffleEntries) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("No free entries left today! Come back tomorrow."),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating));
      return;
    }

    setState(() {
      _usedRaffleEntries++;
    });

    final String? wonItem = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => const RaffleSpinScreen()));

    if (wonItem != null) {
      if (wonItem == "10 Drops") {
        setState(() => rewards += 10);
      }
      if (mounted && wonItem != "Try Again") {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("You won: $wonItem!"),
            backgroundColor: Colors.green[700]));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeTab(),
          _buildLearnTab(),
          _buildGamesTab(),
          _buildTicketsTab(),
          _buildStoreTab(),
          _buildHelpTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2E67A0),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_rounded), label: 'Learn'),
          BottomNavigationBarItem(
              icon: Icon(Icons.sports_esports), label: 'Games'),
          BottomNavigationBarItem(
              icon: Icon(Icons.confirmation_num), label: 'Tickets'),
          BottomNavigationBarItem(icon: Icon(Icons.storefront), label: 'Store'),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: 'Help'),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFF2E67A0),
            child: Text("TO",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Togi",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text("View profile",
                  style: TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ],
      ),
      actions: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
              color: Colors.blue[50], borderRadius: BorderRadius.circular(20)),
          child: Row(
            children: [
              const Icon(Icons.water_drop, size: 14, color: Color(0xFF2E67A0)),
              Text(" $rewards",
                  style: const TextStyle(
                      color: Color(0xFF2E67A0),
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: OutlinedButton.icon(
            onPressed: _toggleLock,
            icon: Icon(_isLocked ? Icons.lock : Icons.lock_open, size: 16),
            label: Text(_isLocked ? "Unlock" : "Lock"),
            style: OutlinedButton.styleFrom(
              foregroundColor:
                  _isLocked ? Colors.red[700] : const Color(0xFF2E67A0),
              side: BorderSide(
                  color: _isLocked ? Colors.red[200]! : Colors.grey[300]!),
              visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }

  // --- TAB 1: HOME ---
  Widget _buildHomeTab() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Today",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            Chip(
              label: const Text("6-day streak",
                  style: TextStyle(
                      color: Color(0xFF2E67A0),
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
              backgroundColor: Colors.blue[50],
              side: BorderSide.none,
              avatar: const Icon(Icons.local_fire_department,
                  size: 16, color: Color(0xFF2E67A0)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildBalanceCard(
            "Linked bank balance",
            "£${linkedBalance.toStringAsFixed(2)}",
            "Connected current account",
            "Available now"),
        const SizedBox(height: 12),
        _buildRainBalanceCard(),
        const SizedBox(height: 12),
        _buildRewardsCard(),
        const SizedBox(height: 24),
        const Text("Quick actions",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        // HACKATHON DEMO BUTTON: Advance Recovery Stage
        _actionRow("⏩ Demo: Advance Recovery Stage", true, () {
          setState(() {
            if (_recoveryStage < 3) {
              _recoveryStage++;
              // Automatically taper intensity as they recover
              if (_recoveryStage == 2) _intensityLevel = 'Medium';
              if (_recoveryStage == 3) _intensityLevel = 'Low';

              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    "Advanced to Stage $_recoveryStage! Odds tightened, visual intensity lowered."),
                backgroundColor: Colors.deepPurple,
              ));
            } else {
              // Reset for the next judge
              _recoveryStage = 1;
              _intensityLevel = 'High';
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Reset to Stage 1 (High Variance).")));
            }
          });
        }),

        _actionRow("Buy + Sell tickets", false,
            () => setState(() => _selectedIndex = 3)),
        _actionRow("Play", false, () => setState(() => _selectedIndex = 2)),
        _actionRow("Learn", false, () => setState(() => _selectedIndex = 1)),
        const SizedBox(height: 24),
        _buildRiskNudgeCard(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildRewardsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Rewards",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("Earn from Learn + weekly games",
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    const Icon(Icons.water_drop,
                        size: 14, color: Color(0xFF2E67A0)),
                    Text(" $rewards",
                        style: const TextStyle(
                            color: Color(0xFF2E67A0),
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          Text("Redeem in Store, or enter streak raffles.",
              style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildRiskNudgeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Risk-aware nudge",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(
              "Don't give in to the end of week urge. You've protected £${totalTickets * 10} by choosing Rain over risk.",
              style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Calm mode progress",
                  style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              Text("Stage $_recoveryStage",
                  style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
              value: _recoveryStage / 3.0,
              backgroundColor: Colors.grey[100],
              color: const Color(0xFF192A41),
              borderRadius: BorderRadius.circular(10),
              minHeight: 8),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: () {},
              child: const Text("Turn on stronger prompts",
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          )
        ],
      ),
    );
  }

  // --- TAB 2: LEARN ---
  Widget _buildLearnTab() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Learn",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Chip(
                  label: const Text("6 days",
                      style: TextStyle(
                          color: Color(0xFF2E67A0),
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                  backgroundColor: Colors.blue[50],
                  side: BorderSide.none,
                  avatar: const Icon(Icons.local_fire_department,
                      size: 16, color: Color(0xFF2E67A0)),
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(width: 8),
                Chip(
                  label: const Text("+Rewards",
                      style: TextStyle(
                          color: Color(0xFF2E67A0),
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                  backgroundColor: Colors.blue[50],
                  side: BorderSide.none,
                  avatar: const Icon(Icons.water_drop,
                      size: 16, color: Color(0xFF2E67A0)),
                  padding: EdgeInsets.zero,
                ),
              ],
            )
          ],
        ),
        const SizedBox(height: 24),
        _buildDailyGoalCard(),
        const SizedBox(height: 32),
        _buildPathCard(
          title: "EV & Odds",
          unit: "Unit 1",
          reward: 300,
          completion: isEVLessonDone ? 1.0 : learningProgress,
          status: isEVLessonDone ? "Done" : "Now",
          iconData: Icons.bolt,
          timeLabel: "3 min lesson",
          onTap: isEVLessonDone ? null : _startEVLesson,
        ),
        _buildDottedLine(),
        _buildPathCard(
          title: "Variance & Streaks",
          unit: "Unit 1",
          reward: 400,
          completion: 0.30,
          status: isEVLessonDone ? "Now" : "Next",
          iconData: Icons.auto_awesome,
          timeLabel: "Quick lesson",
          onTap: isEVLessonDone
              ? () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const OddsLessonScreen()));
                }
              : null,
        ),
        _buildDottedLine(),
        _buildPathCard(
          title: "Budget Basics",
          unit: "Unit 2",
          reward: 500,
          completion: 0.0,
          status: "Locked",
          iconData: Icons.star_border,
          timeLabel: "Quick lesson",
          onTap: null,
        ),
        _buildDottedLine(),
        _buildPathCard(
          title: "Bonds & Yield",
          unit: "Unit 2",
          reward: 600,
          completion: 0.0,
          status: "Locked",
          iconData: Icons.emoji_events_outlined,
          timeLabel: "Quick lesson",
          onTap: null,
        ),
        const SizedBox(height: 40),
        Text(
          "Tip: rewards here are Raindrops (same currency as weekly draws).",
          style: TextStyle(color: Colors.grey[500], fontSize: 13),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDailyGoalCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!, width: 1.5),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Daily goal",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  SizedBox(height: 4),
                  Text("3 minutes • earn rewards",
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                    color: Color(0xFF005B9F), shape: BoxShape.circle),
                child: const Text("+500",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Progress",
                  style: TextStyle(color: Colors.grey[500], fontSize: 13)),
              Text(isEVLessonDone ? "3/3 mins" : "2/3 mins",
                  style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
                value: isEVLessonDone ? 1.0 : learningProgress,
                backgroundColor: Colors.grey[100],
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF1E293B)),
                minHeight: 12),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: isEVLessonDone ? null : _startEVLesson,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005B9F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: Text(isEVLessonDone ? "Goal Reached!" : "Continue",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPathCard({
    required String title,
    required String unit,
    required int reward,
    required double completion,
    required String status,
    required IconData iconData,
    required String timeLabel,
    required VoidCallback? onTap,
  }) {
    bool isLocked = status == "Locked";
    bool isNow = status == "Now";
    bool isDone = status == "Done";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.blueGrey.withOpacity(0.06),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8))
        ],
        border: Border.all(color: Colors.grey[100]!, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isLocked
                      ? Colors.grey[100]
                      : (isDone ? Colors.green[600] : const Color(0xFF005B9F)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(isDone ? Icons.check : iconData,
                    color: isLocked ? Colors.grey[400] : Colors.white,
                    size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            height: 1.2)),
                    const SizedBox(height: 4),
                    Text(unit,
                        style:
                            TextStyle(color: Colors.grey[500], fontSize: 13)),
                  ],
                ),
              ),
              if (!isDone)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.water_drop,
                          size: 12, color: Color(0xFF2E67A0)),
                      const SizedBox(width: 4),
                      Text("+$reward",
                          style: const TextStyle(
                              color: Color(0xFF2E67A0),
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isNow
                      ? Colors.blue[100]
                      : (isDone ? Colors.green[50] : Colors.grey[100]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: isNow
                        ? const Color(0xFF005B9F)
                        : (isDone ? Colors.green[800] : Colors.grey[500]),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (isLocked)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text("Complete previous to unlock",
                  style: TextStyle(color: Colors.grey[500], fontSize: 14)),
            )
          else
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Completion",
                        style:
                            TextStyle(color: Colors.grey[500], fontSize: 13)),
                    Text("${(completion * 100).toInt()}%",
                        style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: completion,
                    backgroundColor: Colors.grey[100],
                    valueColor: AlwaysStoppedAnimation<Color>(
                        isDone ? Colors.green : const Color(0xFF1E293B)),
                    minHeight: 12,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(timeLabel,
                  style: TextStyle(color: Colors.grey[400], fontSize: 14)),
              isLocked || isDone
                  ? Text("—",
                      style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 16,
                          fontWeight: FontWeight.bold))
                  : InkWell(
                      onTap: onTap,
                      child: const Text("Start",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black)),
                    ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDottedLine() {
    return SizedBox(
      height: 30,
      child: Center(
        child: CustomPaint(
          size: const Size(2, 30),
          painter: DottedLinePainter(),
        ),
      ),
    );
  }

  // --- TAB 3: GAMES ---
  Widget _buildGamesTab() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Games",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  const Icon(Icons.confirmation_number_outlined,
                      size: 14, color: Color(0xFF2E67A0)),
                  Text(" $playableTickets / $totalTickets tickets",
                      style: const TextStyle(
                          color: Color(0xFF2E67A0),
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildGamesMainCard(),
        const SizedBox(height: 16),
        _buildCalmModeSettings(),
        const SizedBox(height: 16),
        _buildTicketLimitSettings(),
        const SizedBox(height: 24),
      ],
    );
  }

  void _onPlayPressed() async {
    if (_isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("App is locked! Unlock to play."),
          behavior: SnackBarBehavior.floating));
      return;
    }

    if (playableTickets <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("No playable tickets left this week!"),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating));
      return;
    }

    if (_ticketsPlayedToday >= _maxDailyTickets) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Daily ticket limit reached!"),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating));
      return;
    }

    setState(() {
      playableTickets--;
      _ticketsPlayedToday++;
    });

    int? wonDrops;
    // Pass the recovery stage into the games to enforce the dynamic odds
    if (_intensityLevel == 'High') {
      wonDrops = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  GravityDropScreen(recoveryStage: _recoveryStage)));
    } else if (_intensityLevel == 'Medium') {
      wonDrops = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  VaultUnboxingScreen(recoveryStage: _recoveryStage)));
    } else {
      wonDrops = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  InterestRevealScreen(recoveryStage: _recoveryStage)));
    }

    if (wonDrops != null && wonDrops > 0) {
      final int dropsToAdd = wonDrops;
      setState(() {
        rewards += dropsToAdd;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Added +$dropsToAdd Raindrops to your balance!"),
            backgroundColor: Colors.green[700]));
      }
    }
  }

  Widget _buildGamesMainCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Weekly Draw",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(
                        "Stage $_recoveryStage Distribution •\nodds adapt to your progress",
                        style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                            height: 1.3)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8)),
                child: Column(
                  children: [
                    const Text("Intensity:",
                        style:
                            TextStyle(color: Color(0xFF2E67A0), fontSize: 11)),
                    Text(_intensityLevel,
                        style: const TextStyle(
                            color: Color(0xFF2E67A0),
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Your tickets",
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600])),
                      const SizedBox(height: 4),
                      Text("$playableTickets",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 22)),
                      const SizedBox(height: 4),
                      Text("Playable this week",
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                              height: 1.2)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Next weekly",
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600])),
                      const SizedBox(height: 4),
                      const Text("Sun 7pm",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              height: 1.1)),
                      const SizedBox(height: 4),
                      Text("Game",
                          style:
                              TextStyle(fontSize: 11, color: Colors.grey[500])),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E67A0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                onPressed: _onPlayPressed,
                child: const Text("Play",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
                color: const Color(0xFFF0F4F8),
                borderRadius: BorderRadius.circular(12)),
            child: Theme(
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                iconColor: const Color(0xFF2E67A0),
                collapsedIconColor: const Color(0xFF2E67A0),
                tilePadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                title: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        size: 20, color: Color(0xFF2E67A0)),
                    const SizedBox(width: 8),
                    const Text("View odds",
                        style: TextStyle(
                            color: Color(0xFF192A41),
                            fontWeight: FontWeight.w600,
                            fontSize: 15)),
                    const Spacer(),
                    Text("Tap to expand",
                        style:
                            TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ],
                ),
                children: [
                  Container(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    alignment: Alignment.centerLeft,
                    child: Text(
                        "Odds currently adapt based on your recovery stage (Stage $_recoveryStage).\n\n"
                        "As you progress, the highest possible prizes are lowered and combined with the lowest possible prizes, resulting in a much more consistent, low-variance yield while maintaining the same ~3.87% annual expected value.",
                        style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 13,
                            height: 1.4)),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showIntensitySettings() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Adjust visual intensity",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text("Choose how stimulating you want your rewards to be.",
                    style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                const SizedBox(height: 24),
                _intensityOption('High', 'Full animations (Gravity Drop)'),
                _intensityOption('Medium', 'Standard reveal (Vault Unboxing)'),
                _intensityOption('Low', 'Text only (Interest Reveal)'),
                const SizedBox(height: 16),
              ],
            ),
          );
        });
  }

  Widget _intensityOption(String level, String description) {
    bool isSelected = _intensityLevel == level;
    return InkWell(
      onTap: () {
        setState(() => _intensityLevel = level);
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : Colors.white,
          border: Border.all(
              color: isSelected ? const Color(0xFF2E67A0) : Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? const Color(0xFF2E67A0) : Colors.grey,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(level,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? const Color(0xFF2E67A0)
                              : Colors.black)),
                  Text(description,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCalmModeSettings() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Calm mode",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Text(
              "Visual intensity reduces as your streak grows. You keep the yield, but the stimulation tapers.",
              style: TextStyle(color: Colors.grey[700], height: 1.4)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: _showIntensitySettings,
                child: const Text("Adjust taper settings",
                    style: TextStyle(fontWeight: FontWeight.w600))),
          )
        ],
      ),
    );
  }

  void _showLimitSlider() {
    double tempLimit = _maxDailyTickets.toDouble();
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Max tickets per day",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Text("Limit: ${tempLimit.toInt()}",
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E67A0))),
                  Slider(
                    value: tempLimit,
                    min: 1,
                    max: 10,
                    divisions: 9,
                    activeColor: const Color(0xFF2E67A0),
                    onChanged: (val) {
                      setModalState(() {
                        tempLimit = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E67A0),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        setState(() {
                          _maxDailyTickets = tempLimit.toInt();
                        });
                        Navigator.pop(context);
                      },
                      child: const Text("Save Limit"),
                    ),
                  )
                ],
              ),
            );
          });
        });
  }

  Widget _buildTicketLimitSettings() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Play Limits",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Text(
              "Set a cap on your daily ticket usage to maintain healthy habits. Current limit: $_maxDailyTickets/day.",
              style: TextStyle(color: Colors.grey[700], height: 1.4)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: _showLimitSlider,
                child: const Text("Adjust max tickets per day",
                    style: TextStyle(fontWeight: FontWeight.w600))),
          )
        ],
      ),
    );
  }

  // --- TAB 4: TICKETS ---
  Widget _buildTicketsTab() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        const Text("Tickets",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildTicketPurchaseCard(),
      ],
    );
  }

  Widget _buildTicketPurchaseCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Rain Ticket",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(
                      "Price always £10 •\nredeemable anytime • weekly\nRaindrop draw",
                      style: TextStyle(
                          color: Colors.grey[500], fontSize: 13, height: 1.3)),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8)),
                child: Column(
                  children: [
                    const Text("Holding:",
                        style:
                            TextStyle(color: Color(0xFF2E67A0), fontSize: 11)),
                    Text("$totalTickets",
                        style: const TextStyle(
                            color: Color(0xFF2E67A0),
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _miniStat("Price", "£10.00", "fixed"),
              const SizedBox(width: 12),
              _miniStat("Playable", "$playableTickets", "this week"),
              const SizedBox(width: 12),
              _miniStat("Redeem", "£10.00", "each"),
            ],
          ),
          const SizedBox(height: 24),
          Text("Buy quantity",
              style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(height: 8),
          TextField(
            controller: _buyController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "e.g. 5",
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF2E67A0))),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E67A0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                onPressed: _buyTickets,
                child: const Text("Buy",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
          ),
          const SizedBox(height: 20),
          Text("Sell quantity",
              style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(height: 8),
          TextField(
            controller: _sellController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "e.g. 3",
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF2E67A0))),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: _sellTickets,
                child: const Text("Sell / Redeem",
                    style: TextStyle(fontWeight: FontWeight.w600))),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
                color: const Color(0xFFF0F4F8),
                borderRadius: BorderRadius.circular(12)),
            child: Theme(
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                iconColor: const Color(0xFF2E67A0),
                collapsedIconColor: const Color(0xFF2E67A0),
                tilePadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                title: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        size: 20, color: Color(0xFF2E67A0)),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text("Dynamic Odds Info\n(weekly)",
                          style: TextStyle(
                              color: Color(0xFF192A41),
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              height: 1.2)),
                    ),
                    Text("Tap to\nexpand",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 11,
                            height: 1.2)),
                  ],
                ),
                children: [
                  Container(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "Your current odds reflect Stage $_recoveryStage of the recovery model. Expected value is maintained at ~3.87%, but the spread of prizes is tighter to promote calmer interactions.",
                            style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                                height: 1.4))
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _oddsRow(String percentage, String payout) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(percentage,
              style: const TextStyle(
                  color: Color(0xFF2E67A0),
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
          Text(payout,
              style: const TextStyle(color: Color(0xFF2E67A0), fontSize: 13)),
        ],
      ),
    );
  }

  // --- TAB 5: STORE ---
  Widget _buildStoreTab() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Store",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  const Icon(Icons.water_drop,
                      size: 16, color: Color(0xFF2E67A0)),
                  Text(" $rewards",
                      style: const TextStyle(
                          color: Color(0xFF2E67A0),
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildStoreMainCard(
            titleIcon: const Text("£",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            title: "Redeem to money",
            subtitle: "Convert Raindrops into cash-out vouchers.",
            children: [
              _buildStoreDetailedItem(
                  "£5 cash-out", "10,000 drops", 10000, "Redeem £5"),
              const SizedBox(height: 12),
              _buildStoreDetailedItem(
                  "£10 cash-out", "20,000 drops", 20000, "Redeem £10"),
            ]),
        const SizedBox(height: 16),
        _buildStoreMainCard(
            titleIcon: const Icon(Icons.card_giftcard, size: 20),
            title: "Redeem Raindrops",
            subtitle: "Earn real life item bundles",
            children: [
              _buildStoreDetailedItem("Men's Grooming Kit",
                  "Stay sharp all year round", 15000, "Redeem"),
              const SizedBox(height: 12),
              _buildStoreDetailedItem("£3 Tesco Gift Card", "", 5000, "Redeem"),
            ]),
        const SizedBox(height: 16),
        _buildStreakRafflesCard(),
      ],
    );
  }

  Widget _buildStoreMainCard(
      {required Widget titleIcon,
      required String title,
      required String subtitle,
      required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              titleIcon,
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Text(subtitle,
              style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildStoreDetailedItem(
      String title, String subtitle, int cost, String btnText) {
    bool canAfford = rewards >= cost;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const Icon(Icons.water_drop,
                        size: 14, color: Color(0xFF2E67A0)),
                    const SizedBox(width: 4),
                    Text("$cost",
                        style: const TextStyle(
                            color: Color(0xFF2E67A0),
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    canAfford ? const Color(0xFF2E67A0) : Colors.grey[100],
                foregroundColor: canAfford ? Colors.white : Colors.grey[400],
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed:
                  canAfford ? () => _purchaseStoreItem(cost, title) : null,
              child: Text(canAfford ? btnText : "Not enough",
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStreakRafflesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.confirmation_number_outlined, size: 20),
                  const SizedBox(width: 8),
                  Text("Streak raffles",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12)),
                child: const Row(
                  children: [
                    Icon(Icons.local_fire_department,
                        size: 14, color: Color(0xFF2E67A0)),
                    SizedBox(width: 4),
                    Text("6 days",
                        style: TextStyle(
                            color: Color(0xFF2E67A0),
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          Text("Entries come from your daily learning streak (not money).",
              style: TextStyle(
                  color: Colors.grey[600], fontSize: 13, height: 1.3)),
          const SizedBox(height: 20),
          _streakRow("Daily free entries", "$_maxRaffleEntries"),
          _streakRow("Used today", "$_usedRaffleEntries"),
          _streakRow("Remaining", "${_maxRaffleEntries - _usedRaffleEntries}"),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E67A0),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _enterRaffle,
              child: const Text("Enter today's raffle",
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                side: BorderSide(color: Colors.grey[300]!),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _showRaffleRules,
              child: const Text("View prizes & rules",
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: const Color(0xFFF0F4F8),
                borderRadius: BorderRadius.circular(12)),
            child: Text(
                "Raffles use streak entries to keep motivation positive and harm-reduction focused.",
                style: TextStyle(
                    color: Colors.grey[700], fontSize: 13, height: 1.4)),
          )
        ],
      ),
    );
  }

  Widget _streakRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  // --- TAB 6: HELP ---
  Widget _buildHelpTab() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Live chat",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            Chip(
              label: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified_user_outlined,
                      size: 14, color: Color(0xFF2E67A0)),
                  SizedBox(width: 4),
                  Text("Support",
                      style: TextStyle(color: Color(0xFF2E67A0), fontSize: 12)),
                ],
              ),
              backgroundColor: Colors.blue[50],
              side: BorderSide.none,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Support is here",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Text("If you're feeling at risk, talk to someone now.",
                  style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E67A0),
                          foregroundColor: Colors.white,
                          elevation: 0),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LiveChatScreen()));
                      },
                      child: const Text("Start live chat"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          side: BorderSide(color: Colors.grey[300]!)),
                      onPressed: () {},
                      child: const Text("View resources"),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("FAQ",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              _buildFaqItem("What are Raindrops?",
                  "A reward currency earned through learning and weekly ticket draws."),
              const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1)),
              _buildFaqItem("How do tickets work?",
                  "Tickets enter a weekly Raindrop draw. Tap 'View odds' in the Games tab for details."),
              const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1)),
              _buildFaqItem("How do I unlock Calm Mode?",
                  "Calm Mode can be unlocked via long learning streaks and sustained progress in gambling recovery. You can demo it in the Home tab!"),
              const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1)),
              _buildFaqItem("Is my real money at risk?",
                  "No. Rainsave is a principal-protected savings app. Your linked bank balance never decreases unless you withdraw."),
              const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1)),
              _buildFaqItem("What happens if I lose my streak?",
                  "You'll miss out on daily free raffle entries, but your accumulated Raindrops and actual savings remain perfectly safe."),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        const SizedBox(height: 4),
        Text(answer, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
      ],
    );
  }

  // --- REUSABLE HELPER WIDGETS ---

  Widget _buildBalanceCard(
      String title, String amt, String sub, String trailing) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(amt,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(sub,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              Text(trailing,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRainBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Rain Balance",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text("£${totalTickets * 10}",
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          Text("Principal-protected tickets",
              style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(height: 20),
          Row(
            children: [
              _miniStat("Tickets", "$totalTickets", "held"),
              const SizedBox(width: 8),
              _miniStat("Next weekly", "Sun 7pm", "game"),
              const SizedBox(width: 8),
              _miniStat("Intensity", _intensityLevel, ""),
            ],
          )
        ],
      ),
    );
  }

  Widget _miniStat(String label, String val, String sub) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(val,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Text(sub, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _actionRow(String label, bool primary, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
              color: primary ? const Color(0xFF2E67A0) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: TextStyle(
                      color: primary ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w600)),
              Icon(Icons.chevron_right,
                  color: primary ? Colors.white : Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// NEW QUIZ SCREEN
// ---------------------------------------------------------
class EVQuizScreen extends StatefulWidget {
  const EVQuizScreen({super.key});

  @override
  State<EVQuizScreen> createState() => _EVQuizScreenState();
}

class _EVQuizScreenState extends State<EVQuizScreen> {
  int? _selectedAnswer;

  void _submit() {
    if (_selectedAnswer == null) return;

    if (_selectedAnswer == 1) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
                title: const Text("Correct! 🎉"),
                content: const Text(
                    "Great job. You've completed the lesson and earned +300 Raindrops!"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Pop dialog
                      Navigator.pop(context, true); // Pop quiz, return true
                    },
                    child: const Text("Collect Reward",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  )
                ],
              ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            const Text("Not quite right! Review the formula and try again."),
        backgroundColor: Colors.orange[800],
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Knowledge Check",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "If a coin flip gives you a 50% chance to win £10 and a 50% chance to win £0, what is the Expected Value (EV)?",
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, height: 1.4),
            ),
            const SizedBox(height: 32),
            _buildQuizOption(0, "A) £0"),
            _buildQuizOption(1, "B) £5"),
            _buildQuizOption(2, "C) £10"),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedAnswer != null
                      ? const Color(0xFF005B9F)
                      : Colors.grey[300],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _selectedAnswer != null ? _submit : null,
                child: const Text("Submit Answer",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildQuizOption(int index, String text) {
    bool isSelected = _selectedAnswer == index;
    return InkWell(
      onTap: () => setState(() => _selectedAnswer = index),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : Colors.white,
          border: Border.all(
              color: isSelected ? const Color(0xFF005B9F) : Colors.grey[300]!,
              width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? const Color(0xFF005B9F) : Colors.black87),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// GAME: INTEREST REVEAL (LOW INTENSITY)
// ---------------------------------------------------------
class InterestRevealScreen extends StatefulWidget {
  final int recoveryStage;
  const InterestRevealScreen({super.key, required this.recoveryStage});

  @override
  State<InterestRevealScreen> createState() => _InterestRevealScreenState();
}

class _InterestRevealScreenState extends State<InterestRevealScreen> {
  int _prize = 0;
  bool _revealed = false;

  void _reveal() {
    setState(() {
      _prize = generateRaindropPrize(widget.recoveryStage);
      _revealed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Daily Interest",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.water_drop,
                    size: 64, color: Color(0xFF2E67A0)),
                const SizedBox(height: 24),
                const Text("Today's Raindrop Yield",
                    style: TextStyle(color: Colors.grey, fontSize: 16)),
                const SizedBox(height: 12),
                Text(
                  _revealed ? "$_prize Drops" : "??? Drops",
                  style: const TextStyle(
                      color: Color(0xFF2E67A0),
                      fontSize: 42,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E67A0),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _revealed
                        ? () => Navigator.pop(context, _prize)
                        : _reveal,
                    child: Text(_revealed ? "COLLECT & EXIT" : "TAP TO REVEAL",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// GAME: GRAVITY DROP (HIGH INTENSITY)
// ---------------------------------------------------------
class GravityDropScreen extends StatefulWidget {
  final int recoveryStage;
  const GravityDropScreen({super.key, required this.recoveryStage});

  @override
  State<GravityDropScreen> createState() => _GravityDropScreenState();
}

class _GravityDropScreenState extends State<GravityDropScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Offset> _ballPath = [];
  bool _isPlaying = false;
  int _prize = 0;

  final int _rows = 8;
  final double _pegSpacingX = 40.0;
  final double _pegSpacingY = 50.0;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _controller.addListener(() => setState(() {}));
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _isPlaying = false);
        _showPrizeDialog();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dropBall() {
    if (_isPlaying) return;

    _prize = generateRaindropPrize(widget.recoveryStage);
    _ballPath.clear();

    // Map the prize to the Plinko binomial distribution bins (0 to 8)
    int targetRights;
    final random = Random();

    if (_prize >= 1000) {
      targetRights = random.nextBool() ? 0 : 8; // Rarest bins (Edges)
    } else if (_prize >= 100) {
      targetRights = random.nextBool() ? 1 : 7;
    } else if (_prize >= 30) {
      targetRights = random.nextBool() ? 2 : 6;
    } else if (_prize > 0) {
      targetRights = random.nextBool() ? 3 : 5;
    } else {
      targetRights = 4; // Center bin (Most common)
    }

    // Generate a random path that satisfies the target bin
    List<bool> moves = List.generate(8, (index) => index < targetRights);
    moves.shuffle();

    double currentX = 0.0;
    double currentY = 0.0;
    _ballPath.add(Offset(currentX, currentY));

    for (int i = 0; i < _rows; i++) {
      bool goRight = moves[i];
      currentX += goRight ? (_pegSpacingX / 2) : -(_pegSpacingX / 2);
      currentY += _pegSpacingY;
      _ballPath.add(Offset(currentX, currentY));
    }

    setState(() => _isPlaying = true);
    _controller.forward(from: 0.0);
  }

  void _showPrizeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Drop Complete!"),
        content: Text("You won $_prize Raindrops!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(this.context).pop(_prize);
            },
            child: const Text("Collect & Exit"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        title:
            const Text("Gravity Drop", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Drop the ball to win Raindrops!",
                style: TextStyle(color: Colors.white70)),
          ),
          Expanded(
            child: Center(
              child: CustomPaint(
                size: const Size(300, 450),
                painter: PlinkoPainter(
                  rows: _rows,
                  spacingX: _pegSpacingX,
                  spacingY: _pegSpacingY,
                  path: _ballPath,
                  progress: _controller.value,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigoAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _isPlaying ? null : _dropBall,
                child: const Text("DROP BALL",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class PlinkoPainter extends CustomPainter {
  final int rows;
  final double spacingX;
  final double spacingY;
  final List<Offset> path;
  final double progress;

  PlinkoPainter(
      {required this.rows,
      required this.spacingX,
      required this.spacingY,
      required this.path,
      required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final pegPaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.fill;
    final ballPaint = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.fill;

    final origin = Offset(size.width / 2, 20);

    for (int row = 1; row <= rows; row++) {
      int pegCount = row + 1;
      double startX = origin.dx - ((pegCount - 1) * spacingX) / 2;
      for (int i = 0; i < pegCount; i++) {
        canvas.drawCircle(
            Offset(startX + (i * spacingX), origin.dy + (row * spacingY)),
            4,
            pegPaint);
      }
    }

    if (path.isNotEmpty) {
      double totalSegments = path.length - 1.0;
      double currentSegmentRaw = progress * totalSegments;
      int currentIndex = currentSegmentRaw.floor();

      if (currentIndex >= path.length - 1) {
        currentIndex = path.length - 2;
      }

      double segmentProgress = currentSegmentRaw - currentIndex;

      Offset start = path[currentIndex];
      Offset end = path[currentIndex + 1];

      double currentX =
          origin.dx + start.dx + (end.dx - start.dx) * segmentProgress;
      double bounce = sin(segmentProgress * pi) * -15.0;
      double currentY =
          origin.dy + start.dy + (end.dy - start.dy) * segmentProgress + bounce;

      canvas.drawCircle(Offset(currentX, currentY), 10, ballPaint);
    }
  }

  @override
  bool shouldRepaint(covariant PlinkoPainter oldDelegate) => true;
}

// ---------------------------------------------------------
// GAME: VAULT UNBOXING (MEDIUM INTENSITY)
// ---------------------------------------------------------
class VaultUnboxingScreen extends StatefulWidget {
  final int recoveryStage;
  const VaultUnboxingScreen({super.key, required this.recoveryStage});

  @override
  State<VaultUnboxingScreen> createState() => _VaultUnboxingScreenState();
}

class _VaultUnboxingScreenState extends State<VaultUnboxingScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _shakeController;
  final List<int> _rewards = [];

  bool _isSpinning = false;
  bool _showCrate = true;

  final double _itemWidth = 100.0;
  final double _horizontalMargin = 4.0;

  @override
  void initState() {
    super.initState();
    _generateRewards();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _generateRewards() {
    _rewards.clear();
    final random = Random();

    // Generate an exciting "visual" reel filled with high-tier prizes
    for (int i = 0; i < 100; i++) {
      int visualValue;
      double roll = random.nextDouble();
      if (roll < 0.1)
        visualValue = 10000;
      else if (roll < 0.3)
        visualValue = 1000;
      else if (roll < 0.6)
        visualValue = 250;
      else if (roll < 0.8)
        visualValue = 100;
      else
        visualValue = 50;
      _rewards.add(visualValue);
    }
  }

  void _openCrate() async {
    if (_isSpinning) return;

    _shakeController.forward(from: 0.0);
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _showCrate = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _spinReel();
    });
  }

  void _spinReel() async {
    setState(() => _isSpinning = true);

    final randomTargetIndex = Random().nextInt(40) + 50;

    // Inject the TRUE calculated prize into the target index, passing the stage in
    int truePrize = generateRaindropPrize(widget.recoveryStage);
    _rewards[randomTargetIndex] = truePrize;

    final double actualItemWidth = _itemWidth + (_horizontalMargin * 2);
    final screenWidth = MediaQuery.of(context).size.width;

    final offset = (randomTargetIndex * actualItemWidth) -
        (screenWidth / 2) +
        (actualItemWidth / 2);

    await _scrollController.animateTo(
      offset,
      duration: const Duration(seconds: 4),
      curve: Curves.easeOutCirc,
    );

    setState(() => _isSpinning = false);

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text("Vault Opened!"),
          content: Text("You found ${_rewards[randomTargetIndex]} Raindrops!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(this.context, _rewards[randomTargetIndex]);
              },
              child: const Text("Collect & Exit"),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        title:
            const Text("Vault Unboxing", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: _showCrate ? _buildCrateView() : _buildSpinnerView(),
      ),
    );
  }

  Widget _buildCrateView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Tap the crate to reveal your prize!",
            style: TextStyle(color: Colors.white70, fontSize: 18)),
        const SizedBox(height: 60),
        GestureDetector(
          onTap: _openCrate,
          child: AnimatedBuilder(
            animation: _shakeController,
            builder: (context, child) {
              final sineValue = sin(_shakeController.value * 4 * pi);
              return Transform.translate(
                offset: Offset(sineValue * 15, 0),
                child: child,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.deepPurpleAccent.withOpacity(0.2),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Colors.deepPurpleAccent.withOpacity(0.4),
                      blurRadius: 40,
                      spreadRadius: 10)
                ],
              ),
              child:
                  const Icon(Icons.inventory_2, size: 140, color: Colors.amber),
            ),
          ),
        ),
        const SizedBox(height: 80),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _openCrate,
              child: const Text("OPEN VAULT",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildSpinnerView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Spinning...",
            style: TextStyle(color: Colors.white70, fontSize: 18)),
        const SizedBox(height: 40),
        SizedBox(
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _rewards.length,
                itemBuilder: (context, index) {
                  bool isJackpot = _rewards[index] >= 1000;
                  return Container(
                    width: _itemWidth,
                    margin: EdgeInsets.symmetric(horizontal: _horizontalMargin),
                    decoration: BoxDecoration(
                      color: isJackpot
                          ? Colors.amber
                          : Colors.deepPurpleAccent.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: isJackpot
                              ? Colors.white
                              : Colors.deepPurpleAccent,
                          width: 2),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.water_drop,
                              color: isJackpot ? Colors.black87 : Colors.white,
                              size: 24),
                          const SizedBox(height: 8),
                          Text(
                            "${_rewards[index]}",
                            style: TextStyle(
                                color:
                                    isJackpot ? Colors.black87 : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Container(
                width: 4,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: const [
                    BoxShadow(color: Colors.redAccent, blurRadius: 8)
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }
}

// ---------------------------------------------------------
// GAME: RAFFLE SPIN (STORE TAB)
// ---------------------------------------------------------
class RaffleSpinScreen extends StatefulWidget {
  const RaffleSpinScreen({super.key});

  @override
  State<RaffleSpinScreen> createState() => _RaffleSpinScreenState();
}

class _RaffleSpinScreenState extends State<RaffleSpinScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<String> _rewards = [];
  bool _isSpinning = false;

  final double _itemWidth = 120.0;
  final double _horizontalMargin = 6.0;

  @override
  void initState() {
    super.initState();
    _generateRewards();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _spinReel();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _generateRewards() {
    _rewards.clear();
    final random = Random();

    // Generate an exciting "visual" reel
    for (int i = 0; i < 100; i++) {
      double roll = random.nextDouble();
      if (roll < 0.05)
        _rewards.add("Legendary Bundle");
      else if (roll < 0.2)
        _rewards.add("Epic Bundle");
      else if (roll < 0.5)
        _rewards.add("Rare Bundle");
      else
        _rewards.add("10 Drops");
    }
  }

  void _spinReel() async {
    setState(() => _isSpinning = true);

    final randomTargetIndex = Random().nextInt(40) + 50;

    // Inject the TRUE calculated prize into the target index
    String truePrize = generateRafflePrize();
    _rewards[randomTargetIndex] = truePrize;

    final double actualItemWidth = _itemWidth + (_horizontalMargin * 2);
    final screenWidth = MediaQuery.of(context).size.width;

    final offset = (randomTargetIndex * actualItemWidth) -
        (screenWidth / 2) +
        (actualItemWidth / 2);

    await _scrollController.animateTo(
      offset,
      duration: const Duration(seconds: 4),
      curve: Curves.easeOutCirc,
    );

    setState(() => _isSpinning = false);

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(truePrize == "Try Again" ? "Unlucky!" : "Raffle Winner!"),
          content: Text(truePrize == "Try Again"
              ? "Better luck next time!"
              : "You won the $truePrize!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(this.context, truePrize);
              },
              child: const Text("Collect & Exit"),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A1E1E), // Dark reddish tone
      appBar: AppBar(
        title:
            const Text("Daily Raffle", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Spinning your free entry...",
              style: TextStyle(color: Colors.white70, fontSize: 18)),
          const SizedBox(height: 40),
          SizedBox(
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _rewards.length,
                  itemBuilder: (context, index) {
                    String prize = _rewards[index];
                    Color cardColor;
                    IconData icon;

                    if (prize.contains("Legendary")) {
                      cardColor = Colors.orange;
                      icon = Icons.diamond;
                    } else if (prize.contains("Epic")) {
                      cardColor = Colors.purple;
                      icon = Icons.star;
                    } else if (prize.contains("Rare")) {
                      cardColor = Colors.blue;
                      icon = Icons.card_giftcard;
                    } else if (prize.contains("10 Drops")) {
                      cardColor = Colors.green;
                      icon = Icons.water_drop;
                    } else {
                      cardColor = Colors.grey;
                      icon = Icons.sentiment_dissatisfied;
                    }

                    return Container(
                      width: _itemWidth,
                      margin:
                          EdgeInsets.symmetric(horizontal: _horizontalMargin),
                      decoration: BoxDecoration(
                        color: cardColor.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(icon, color: Colors.white, size: 36),
                            const SizedBox(height: 8),
                            Text(
                              prize,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                Container(
                  width: 4,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: const [
                      BoxShadow(color: Colors.amber, blurRadius: 10)
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// LIVE CHAT SCREEN
// ---------------------------------------------------------
class LiveChatScreen extends StatefulWidget {
  const LiveChatScreen({super.key});

  @override
  State<LiveChatScreen> createState() => _LiveChatScreenState();
}

class _LiveChatScreenState extends State<LiveChatScreen> {
  final TextEditingController _chatController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      "text":
          "Hi Togi! I'm Sarah from Rainsave support. How can I help you today?",
      "isMe": false
    },
    {
      "text": "Hi, I just wanted to know how the weekly draws are calculated?",
      "isMe": true
    },
    {
      "text":
          "Great question! Our weekly draws use a Premium Bonds-style distribution. Every ticket you hold is entered into a random number generator that pays out prizes from £0 to £1,000 without ever risking your initial deposit. You can view the exact odds in the Games tab!",
      "isMe": false
    },
  ];

  void _sendMessage() {
    if (_chatController.text.trim().isEmpty) return;
    setState(() {
      _messages.add({"text": _chatController.text, "isMe": true});
      _chatController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFF2E67A0),
                child:
                    Icon(Icons.support_agent, color: Colors.white, size: 20)),
            SizedBox(width: 10),
            Text("Support Chat",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                bool isMe = msg["isMe"];
                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFF2E67A0) : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft:
                            isMe ? const Radius.circular(16) : Radius.zero,
                        bottomRight:
                            isMe ? Radius.zero : const Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5)
                      ],
                    ),
                    child: Text(
                      msg["text"],
                      style: TextStyle(
                          color: isMe ? Colors.white : Colors.black87,
                          fontSize: 15,
                          height: 1.4),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _chatController,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(color: Colors.grey[300]!)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(color: Colors.grey[300]!)),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: const Color(0xFF2E67A0),
                    radius: 24,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(Offset(size.width / 2, startY),
          Offset(size.width / 2, startY + 4), paint);
      startY += 10;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------
// LESSON SCREENS
// ---------------------------------------------------------
class EVLessonScreen extends StatelessWidget {
  const EVLessonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Expected Value (EV)",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12)),
              child: const Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Color(0xFF005B9F)),
                  SizedBox(width: 12),
                  Expanded(
                      child: Text(
                          "Expected Value is the mathematical average of all possible outcomes.")),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text("How it works",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text(
              "To calculate EV, you multiply each possible outcome by its probability, and then add them all together. If the EV is positive, the bet is profitable in the long run.",
              style:
                  TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!)),
              child: const Column(
                children: [
                  Text("The Formula",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Text("EV = Σ [ P(Outcome) × Value(Outcome) ]",
                      style:
                          TextStyle(fontSize: 18, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text("Video Lesson",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildVideoLinkCard(
              title: "Understanding EV in Poker & Finance",
              duration: "4:15",
              thumbnailColor: Colors.redAccent,
              context: context,
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: () async {
              final passed = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const EVQuizScreen()));
              if (passed == true) {
                if (context.mounted) Navigator.pop(context, true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF005B9F),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Take Quiz to Complete (+300 Drops)",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoLinkCard(
      {required String title,
      required String duration,
      required Color thumbnailColor,
      required BuildContext context}) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Opening YouTube link...")));
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Container(
              width: 120,
              height: 80,
              decoration: BoxDecoration(
                color: thumbnailColor,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16)),
              ),
              child: const Center(
                  child: Icon(Icons.play_circle_fill,
                      color: Colors.white, size: 36)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text("YouTube • $duration",
                        style:
                            TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class OddsLessonScreen extends StatelessWidget {
  const OddsLessonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Variance & Streaks",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.deepPurple[50],
                  borderRadius: BorderRadius.circular(12)),
              child: const Row(
                children: [
                  Icon(Icons.show_chart, color: Colors.deepPurple),
                  SizedBox(width: 12),
                  Expanded(
                      child: Text(
                          "Variance measures how far results can spread out from the Expected Value (EV).")),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text("Why Streaks Happen",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text(
              "Even if a game has a positive EV, high variance means you can still experience long losing streaks (downswings). Proper bankroll management protects you during these statistical anomalies.",
              style:
                  TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!)),
              child: const Column(
                children: [
                  Text("Key Takeaway",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Text(
                      "EV is your destination. Variance is the bumpy road you take to get there.",
                      style:
                          TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text("Video Lesson",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildVideoLinkCard(
              title: "Surviving Variance & Downswings",
              duration: "6:30",
              thumbnailColor: Colors.deepPurpleAccent,
              context: context,
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF005B9F),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Complete Lesson (+400 Raindrops)",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoLinkCard(
      {required String title,
      required String duration,
      required Color thumbnailColor,
      required BuildContext context}) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Opening YouTube link...")));
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Container(
              width: 120,
              height: 80,
              decoration: BoxDecoration(
                color: thumbnailColor,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16)),
              ),
              child: const Center(
                  child: Icon(Icons.play_circle_fill,
                      color: Colors.white, size: 36)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text("YouTube • $duration",
                        style:
                            TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
