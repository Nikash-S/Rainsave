import 'package:flutter/material.dart';

void main() => runApp(const VoltApp());

class VoltApp extends StatelessWidget {
  const VoltApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const Dashboard(),
    );
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // 1.0 = High Gambling UI, 0.0 = Pure Financial Zen UI
  double dopamineLevel = 1.0; 

  @override
  Widget build(BuildContext context) {
    // Dynamic Colors based on the 'Taper'
    Color primaryColor = Color.lerp(Colors.blueGrey, Colors.purpleAccent, dopamineLevel)!;
    Color bgColor = Color.lerp(Colors.black, const Color(0xFF1A1A1A), 1 - dopamineLevel)!;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(dopamineLevel > 0.5 ? "VOLT: HIGH STAKES" : "Volt Finance"),
        backgroundColor: primaryColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dopamineLevel > 0.5 ? "WIN BIG" : "Total Net Worth",
              style: TextStyle(fontSize: 24, color: primaryColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              "\$4,250.00",
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 50),
            
            // The "Taper" Slider for the demo
            Text("Simulation: Addiction Recovery Progress"),
            Slider(
              value: dopamineLevel,
              onChanged: (val) => setState(() => dopamineLevel = val),
              activeColor: primaryColor,
            ),
            
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              onPressed: () {
                // Future: Logic for Loot Boxes or Savings
              }, 
              child: Text(dopamineLevel > 0.5 ? "SPIN TO SAVE" : "Deposit Funds"),
            )
          ],
        ),
      ),
    );
  }
}