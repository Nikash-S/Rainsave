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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E67A0)),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        useMaterial3: true,
        fontFamily: 'sans-serif',
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
  int _selectedIndex = 0;

  // Mock Data
  double linkedBalance = 1842.37;
  int rainTickets = 12;
  int rewards = 1280;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _buildHomeView(),
      const Center(child: Text("Learn Section")),
      const Center(child: Text("Games Module")),
      _buildTicketsView(),
      const Center(child: Text("Store")),
      const Center(child: Text("Help")),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF2E67A0),
              child: const Text("RS", style: TextStyle(color: Colors.white, fontSize: 14)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Rainsave", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("Principal-protected", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(20)),
            child: Row(
              children: [
                const Icon(Icons.water_drop, size: 16, color: Color(0xFF2E67A0)),
                Text(" $rewards", style: const TextStyle(color: Color(0xFF2E67A0), fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.lock_outline, size: 18),
            label: const Text("Lock"),
            style: OutlinedButton.styleFrom(shape: StadiumBorder()),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex > 4 ? 0 : _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2E67A0),
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book_outlined), label: 'Learn'),
          BottomNavigationBarItem(icon: Icon(Icons.sports_esports_outlined), label: 'Games'),
          BottomNavigationBarItem(icon: Icon(Icons.confirmation_number_outlined), label: 'Tickets'),
          BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), label: 'Store'),
        ],
      ),
    );
  }

  Widget _buildHomeView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Today", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            Chip(
              avatar: const Icon(Icons.local_fire_department, size: 16, color: Colors.blue),
              label: const Text("6-day streak"),
              backgroundColor: Colors.blue[50],
              side: BorderSide.none,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoCard("Linked bank balance", "£$linkedBalance", "Connected current account", "Available now"),
        const SizedBox(height: 16),
        _buildRainBalanceCard(),
        const SizedBox(height: 16),
        _buildQuickActions(),
        const SizedBox(height: 16),
        _buildRiskNudge(),
      ],
    );
  }

  Widget _buildInfoCard(String title, String val, String sub, String trailing) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey[200]!)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(val, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
      ),
    );
  }

  Widget _buildRainBalanceCard() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey[200]!)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Rain Balance", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text("Principal-protected tickets", style: TextStyle(color: Colors.grey)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("£${rainTickets * 10}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    Text("$rainTickets tickets", style: const TextStyle(color: Colors.grey)),
                  ],
                )
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildStatMiniCard("Tickets", "$rainTickets", "held"),
                const SizedBox(width: 8),
                _buildStatMiniCard("Next draw", "Sun\n7pm", "weekly"),
                const SizedBox(width: 8),
                _buildStatMiniCard("Intensity", "Medium", "tapering"),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatMiniCard(String label, String val, String sub) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(sub, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Quick actions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 12),
        _actionButton("Buy tickets", Icons.chevron_right, true),
        const SizedBox(height: 8),
        _actionButton("Go to Games", Icons.chevron_right, false),
        const SizedBox(height: 8),
        _actionButton("Do a 3-min lesson", Icons.chevron_right, false),
      ],
    );
  }

  Widget _actionButton(String text, IconData icon, bool primary) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary ? const Color(0xFF2E67A0) : Colors.white,
          foregroundColor: primary ? Colors.white : Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[300]!),
          ),
        ),
        onPressed: () {
          if (text == "Buy tickets") setState(() => _selectedIndex = 3);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(text, style: const TextStyle(fontWeight: FontWeight.w600)), Icon(icon)],
        ),
      ),
    );
  }

  Widget _buildRiskNudge() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Risk-aware nudge", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            const Text("Fridays can be higher-risk. You've protected £120 by choosing Rain over risk."),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text("Calm mode progress", style: TextStyle(color: Colors.grey)), Text("42%")],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: 0.42, backgroundColor: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(onPressed: () {}, child: const Text("Turn on stronger prompts")),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTicketsView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("Tickets", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Rain Ticket", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                      child: Text("Holding: $rainTickets", style: const TextStyle(color: Colors.blue)),
                    )
                  ],
                ),
                const Text("Price always £10 • redeemable anytime", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ticketStat("Price", "£10.00", "fixed"),
                    _ticketStat("Holdings", "$rainTickets", "tickets"),
                    _ticketStat("Redeem", "£10.00", "each"),
                  ],
                ),
                const SizedBox(height: 24),
                const Text("Buy quantity", style: TextStyle(color: Colors.grey)),
                const TextField(decoration: InputDecoration(hintText: "e.g. 5")),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E67A0), foregroundColor: Colors.white),
                    onPressed: () {
                      setState(() {
                        rainTickets++;
                        linkedBalance -= 10;
                      });
                    },
                    child: const Text("Buy"),
                  ),
                ),
                const SizedBox(height: 16),
                const Text("Sell quantity", style: TextStyle(color: Colors.grey)),
                const TextField(decoration: InputDecoration(hintText: "e.g. 3")),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      if (rainTickets > 0) {
                        setState(() {
                          rainTickets--;
                          linkedBalance += 10;
                        });
                      }
                    },
                    child: const Text("Sell / Redeem"),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _ticketStat(String label, String val, String sub) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}