import 'package:flutter/material.dart';

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
  int _selectedIndex = 3; // Defaulting to Tickets tab to see changes immediately

  // Global Mock App State
  double linkedBalance = 1842.37;
  int rainTickets = 12;
  int rewards = 1280; // "Raindrops" currency
  double learningProgress = 0.66; 

  // Controllers for ticket inputs
  final TextEditingController _buyController = TextEditingController();
  final TextEditingController _sellController = TextEditingController();

  @override
  void dispose() {
    _buyController.dispose();
    _sellController.dispose();
    super.dispose();
  }

  void _purchaseStoreItem(int cost, String itemName) {
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
    int qty = int.tryParse(_buyController.text) ?? 0;
    if (qty > 0 && linkedBalance >= (qty * 10)) {
      setState(() {
        linkedBalance -= qty * 10;
        rainTickets += qty;
        _buyController.clear();
      });
      FocusScope.of(context).unfocus(); // hide keyboard
    }
  }

  void _sellTickets() {
    int qty = int.tryParse(_sellController.text) ?? 0;
    if (qty > 0 && rainTickets >= qty) {
      setState(() {
        linkedBalance += qty * 10;
        rainTickets -= qty;
        _sellController.clear();
      });
      FocusScope.of(context).unfocus(); // hide keyboard
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
          _buildTicketsTab(), // Updated Tickets Tab
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
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded), label: 'Learn'),
          BottomNavigationBarItem(icon: Icon(Icons.sports_esports), label: 'Games'),
          BottomNavigationBarItem(icon: Icon(Icons.confirmation_num), label: 'Tickets'),
          BottomNavigationBarItem(icon: Icon(Icons.storefront), label: 'Store'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), activeIcon: Icon(Icons.chat_bubble), label: 'Help'),
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
            child: Text("RS", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Rainsave", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text("Principal-protected", style: TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ],
      ),
      actions: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(20)),
          child: Row(
            children: [
              const Icon(Icons.water_drop, size: 14, color: Color(0xFF2E67A0)),
              Text(" $rewards", style: const TextStyle(color: Color(0xFF2E67A0), fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.lock_outline, size: 16),
            label: const Text("Lock"),
            style: OutlinedButton.styleFrom(
              visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
            const Text("Today", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            Chip(
              label: const Text("6-day streak", style: TextStyle(color: Color(0xFF2E67A0), fontSize: 12, fontWeight: FontWeight.w600)),
              backgroundColor: Colors.blue[50],
              side: BorderSide.none,
              avatar: const Icon(Icons.local_fire_department, size: 16, color: Color(0xFF2E67A0)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildBalanceCard("Linked bank balance", "£${linkedBalance.toStringAsFixed(2)}", "Connected current account", "Available now"),
        const SizedBox(height: 12),
        _buildRainBalanceCard(),
        const SizedBox(height: 12),
        _buildRewardsCard(),
        const SizedBox(height: 24),
        const Text("Quick actions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _actionRow("Buy tickets", true, () => setState(() => _selectedIndex = 3)),
        _actionRow("Go to Games", false, () => setState(() => _selectedIndex = 2)),
        _actionRow("Do a 3-min lesson", false, () => setState(() => _selectedIndex = 1)),
        const SizedBox(height: 24),
        _buildRiskNudgeCard(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildRewardsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[200]!)),
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
                    const Text("Rewards", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("Earn from Learn + weekly draws", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    const Icon(Icons.water_drop, size: 14, color: Color(0xFF2E67A0)),
                    Text(" $rewards", style: const TextStyle(color: Color(0xFF2E67A0), fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          Text("Redeem in Store, or enter streak raffles.", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildRiskNudgeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[200]!)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Risk-aware nudge", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text("Fridays can be higher-risk. You've protected £${rainTickets * 10} by choosing Rain over risk.", style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Calm mode progress", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              Text("42%", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: 0.42, 
            backgroundColor: Colors.grey[100], 
            color: const Color(0xFF192A41), 
            borderRadius: BorderRadius.circular(10), 
            minHeight: 8
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                side: BorderSide(color: Colors.grey[300]!),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 14)
              ),
              onPressed: () {},
              child: const Text("Turn on stronger prompts", style: TextStyle(fontWeight: FontWeight.w600)),
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
      padding: const EdgeInsets.all(16),
      children: [
        const Text("Learn", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildDailyGoalCard(),
        const SizedBox(height: 24),
        _buildLessonUnit("EV & Odds", "Unit 1", 0.66, 30, true),
        _buildLessonUnit("Variance & Streaks", "Unit 1", 0.30, 40, false),
        _buildLessonUnit("Budget Basics", "Unit 2", 0.0, 50, false, locked: true),
      ],
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
            const Text("Games", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  const Icon(Icons.confirmation_number_outlined, size: 14, color: Color(0xFF2E67A0)),
                  Text(" $rainTickets tickets", style: const TextStyle(color: Color(0xFF2E67A0), fontWeight: FontWeight.bold, fontSize: 13)),
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
        _buildSaferLimitsCard(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildGamesMainCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[200]!)),
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
                    const Text("Weekly Draw", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text("PB-style distribution •\nsmall wins, rare big hit", style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.3)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                child: const Column(
                  children: [
                    Text("Intensity:", style: TextStyle(color: Color(0xFF2E67A0), fontSize: 11)),
                    Text("Medium", style: TextStyle(color: Color(0xFF2E67A0), fontWeight: FontWeight.bold, fontSize: 13)),
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
                  decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Your tickets", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      const SizedBox(height: 4),
                      Text("$rainTickets", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                      const SizedBox(height: 4),
                      Text("More tickets =\nmore chances", style: TextStyle(fontSize: 11, color: Colors.grey[500], height: 1.2)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Next draw", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      const SizedBox(height: 4),
                      const Text("Sun\n7pm", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, height: 1.1)),
                      const SizedBox(height: 4),
                      Text("Weekly", style: TextStyle(fontSize: 11, color: Colors.grey[500])),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
              ),
              onPressed: () {}, 
              child: const Text("Play", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))
            ),
          ),
          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(color: const Color(0xFFF0F4F8), borderRadius: BorderRadius.circular(12)),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                iconColor: const Color(0xFF2E67A0),
                collapsedIconColor: const Color(0xFF2E67A0),
                tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                title: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 20, color: Color(0xFF2E67A0)),
                    const SizedBox(width: 8),
                    const Text("View odds", style: TextStyle(color: Color(0xFF192A41), fontWeight: FontWeight.w600, fontSize: 15)),
                    const Spacer(),
                    Text("Tap to expand", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ],
                ),
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Odds of winning:\n\n• £1000 prize: 1 in 10,000\n• £10 prize: 1 in 100\n• £1 prize: 1 in 10\n\nYour principal is never at risk.", 
                      style: TextStyle(color: Colors.grey[700], fontSize: 13, height: 1.4)
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

  Widget _buildCalmModeSettings() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[200]!)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Calm mode", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Text("Visual intensity reduces as your streak grows. You keep the yield, but the stimulation tapers.", style: TextStyle(color: Colors.grey[700], height: 1.4)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                side: BorderSide(color: Colors.grey[300]!),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 14)
              ),
              onPressed: () {}, 
              child: const Text("Adjust taper settings", style: TextStyle(fontWeight: FontWeight.w600))
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSaferLimitsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[200]!)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Safer limits", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          _settingsRow("Set play window"),
          _settingsRow("Hide animations"),
          _settingsRow("Emergency lock", isLast: true),
        ],
      ),
    );
  }

  Widget _settingsRow(String title, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  // --- TAB 4: TICKETS (UPDATED) ---
  Widget _buildTicketsTab() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        const Text("Tickets", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
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
        border: Border.all(color: Colors.grey[200]!)
      ),
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
                  const Text("Rain Ticket", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 4),
                  Text("Price always £10 •\nredeemable anytime • weekly\nRaindrop draw", style: TextStyle(color: Colors.grey[500], fontSize: 13, height: 1.3)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                child: Column(
                  children: [
                    const Text("Holding:", style: TextStyle(color: Color(0xFF2E67A0), fontSize: 11)),
                    Text("$rainTickets", style: const TextStyle(color: Color(0xFF2E67A0), fontWeight: FontWeight.bold, fontSize: 14)),
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
              _miniStat("Holdings", "$rainTickets", "tickets"),
              const SizedBox(width: 12),
              _miniStat("Redeem", "£10.00", "each"),
            ],
          ),
          const SizedBox(height: 24),
          
          // BUY SECTION
          Text("Buy quantity", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(height: 8),
          TextField(
            controller: _buyController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "e.g. 5",
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF2E67A0))),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
              ),
              onPressed: _buyTickets, 
              child: const Text("Buy", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))
            ),
          ),
          const SizedBox(height: 20),

          // SELL SECTION
          Text("Sell quantity", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(height: 8),
          TextField(
            controller: _sellController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "e.g. 3",
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF2E67A0))),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                side: BorderSide(color: Colors.grey[300]!),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 14)
              ),
              onPressed: _sellTickets, 
              child: const Text("Sell / Redeem", style: TextStyle(fontWeight: FontWeight.w600))
            ),
          ),
          const SizedBox(height: 24),

          // ODDS DROPDOWN
          Container(
            decoration: BoxDecoration(color: const Color(0xFFF0F4F8), borderRadius: BorderRadius.circular(12)),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                iconColor: const Color(0xFF2E67A0),
                collapsedIconColor: const Color(0xFF2E67A0),
                tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                title: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 20, color: Color(0xFF2E67A0)),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text("RainTicket odds\n(weekly)", style: TextStyle(color: Color(0xFF192A41), fontWeight: FontWeight.w600, fontSize: 15, height: 1.2)),
                    ),
                    Text("Tap to\nexpand", textAlign: TextAlign.right, style: TextStyle(color: Colors.grey[500], fontSize: 11, height: 1.2)),
                  ],
                ),
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _oddsRow("89.878%", "0 Raindrops"),
                        _oddsRow("8%", "10 Raindrops"),
                        _oddsRow("1.5%", "20 Raindrops"),
                        _oddsRow("0.22%", "60 Raindrops"),
                        _oddsRow("0.3%", "30 Raindrops"),
                        _oddsRow("0.08%", "80 Raindrops"),
                        _oddsRow("0.02%", "270 Raindrops"),
                        _oddsRow("0.002%", "5,000 Raindrops"),
                        const SizedBox(height: 16),
                        Text(
                          "Expected value ≈ 1.54 Raindrops/week per ticket (~4% annually at current conversion).", 
                          style: TextStyle(color: Colors.grey[600], fontSize: 12, height: 1.4)
                        )
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
          Text(percentage, style: const TextStyle(color: Color(0xFF2E67A0), fontSize: 13, fontWeight: FontWeight.w500)),
          Text(payout, style: const TextStyle(color: Color(0xFF2E67A0), fontSize: 13)),
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
            const Text("Store", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  const Icon(Icons.water_drop, size: 16, color: Color(0xFF2E67A0)),
                  Text(" $rewards", style: const TextStyle(color: Color(0xFF2E67A0), fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        const Text("Vouchers & Gift Cards", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildStoreItemCard("£5 Supermarket Voucher", "Groceries and essentials", 500, Icons.local_grocery_store_outlined),
        _buildStoreItemCard("£10 Coffee Card", "Treat yourself", 1000, Icons.coffee_outlined),
        
        const SizedBox(height: 24),
        const Text("Give Back", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildStoreItemCard("£5 Charity Donation", "Mental health support fund", 500, Icons.volunteer_activism_outlined),

        const SizedBox(height: 24),
        const Text("Low-Intensity Raffles", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildStoreItemCard("Weekend Retreat Entry", "Drawn monthly, no visual animations", 50, Icons.landscape_outlined),
      ],
    );
  }

  Widget _buildStoreItemCard(String title, String subtitle, int cost, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: const Color(0xFF2E67A0), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[50],
              foregroundColor: const Color(0xFF2E67A0),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
            ),
            onPressed: () => _purchaseStoreItem(cost, title),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.water_drop, size: 14),
                const SizedBox(width: 4),
                Text("$cost"),
              ],
            ),
          )
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
            const Text("Live chat", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            Chip(
              label: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified_user_outlined, size: 14, color: Color(0xFF2E67A0)),
                  SizedBox(width: 4),
                  Text("Support", style: TextStyle(color: Color(0xFF2E67A0), fontSize: 12)),
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
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[200]!)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Support is here", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Text("If you're feeling at risk, talk to someone now.", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E67A0), foregroundColor: Colors.white, elevation: 0),
                      onPressed: () {},
                      child: const Text("Start live chat"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.black, side: BorderSide(color: Colors.grey[300]!)),
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
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[200]!)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Quick question", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Type your question...",
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E67A0),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                    ),
                    onPressed: () {},
                    child: const Text("Send"),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text("(Placeholder UI — wire up to your provider later.)", style: TextStyle(color: Colors.grey[500], fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[200]!)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("FAQ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              _buildFaqItem("What are Raindrops?", "A reward currency earned through learning and weekly ticket draws."),
              const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
              _buildFaqItem("How do tickets work?", "Tickets enter a weekly Raindrop draw. Tap 'View odds' for details."),
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
        Text(question, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        const SizedBox(height: 4),
        Text(answer, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
      ],
    );
  }

  // --- REUSABLE HELPER WIDGETS ---

  Widget _buildBalanceCard(String title, String amt, String sub, String trailing) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[200]!)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(amt, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(sub, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              Text(trailing, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRainBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[200]!)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Rain Balance", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text("£${rainTickets * 10}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          Text("Principal-protected tickets", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(height: 20),
          Row(
            children: [
              _miniStat("Tickets", "$rainTickets", "held"),
              const SizedBox(width: 8),
              _miniStat("Next draw", "Sun\n7pm", "weekly"),
              const SizedBox(width: 8),
              _miniStat("Intensity", "Medium", "tapering"),
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
        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
            border: Border.all(color: Colors.grey[200]!)
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(color: primary ? Colors.white : Colors.black, fontWeight: FontWeight.w600)),
              Icon(Icons.chevron_right, color: primary ? Colors.white : Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyGoalCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Daily goal", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text("3 minutes • earn rewards", style: TextStyle(color: Colors.grey)),
                ],
              ),
              CircleAvatar(backgroundColor: Colors.blue[600], child: const Text("+50", style: TextStyle(color: Colors.white, fontSize: 12))),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(value: learningProgress, backgroundColor: Colors.grey[100], borderRadius: BorderRadius.circular(10), minHeight: 8),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E67A0), foregroundColor: Colors.white),
              child: const Text("Continue"),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLessonUnit(String title, String unit, double progress, int reward, bool active, {bool locked = false}) {
    return Opacity(
      opacity: locked ? 0.5 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bolt, color: Color(0xFF2E67A0)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(unit, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                if (!locked) Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                  child: Text("+$reward", style: const TextStyle(color: Color(0xFF2E67A0), fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (!locked) LinearProgressIndicator(value: progress, backgroundColor: Colors.grey[100], minHeight: 6),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(locked ? "Complete previous to unlock" : "Quick lesson", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                TextButton(onPressed: locked ? null : () {}, child: Text(locked ? "Locked" : "Start")),
              ],
            )
          ],
        ),
      ),
    );
  }
}