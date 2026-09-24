import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const WaterTrackerApp());
}

class WaterTrackerApp extends StatelessWidget {
  const WaterTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Water Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF2F9FF),
      ),
      home: const WaterTrackerHome(),
    );
  }
}

class WaterTrackerHome extends StatefulWidget {
  const WaterTrackerHome({super.key});

  @override
  State<WaterTrackerHome> createState() => _WaterTrackerHomeState();
}

class _WaterTrackerHomeState extends State<WaterTrackerHome> {
  int _selectedIndex = 0;

  int waterConsumed = 0;
  int dailyGoal = 2000;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // Load saved data
  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      waterConsumed = prefs.getInt('waterConsumed') ?? 0;
      dailyGoal = prefs.getInt('dailyGoal') ?? 2000;
    });
  }

  // Save water intake
  Future<void> saveWater() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('waterConsumed', waterConsumed);
  }

  // Save daily goal
  Future<void> saveGoal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('dailyGoal', dailyGoal);
  }

  // Add water
  void addWater(int amount) {
    setState(() {
      waterConsumed += amount;

      if (waterConsumed > dailyGoal) {
        waterConsumed = dailyGoal;
      }
    });

    saveWater();
  }

  // Reset today's intake
  void resetWater() {
    setState(() {
      waterConsumed = 0;
    });

    saveWater();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      buildHomePage(),
      buildAddWaterPage(),
      buildGoalPage(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.water_drop_outlined),
            selectedIcon: Icon(Icons.water_drop),
            label: 'Add Water',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Goal',
          ),
        ],
      ),
    );
  }

  // ---------------- HOME PAGE ----------------

  Widget buildHomePage() {
    double progress = dailyGoal == 0 ? 0 : waterConsumed / dailyGoal;

    if (progress > 1) {
      progress = 1;
    }

    int remaining = dailyGoal - waterConsumed;

    if (remaining < 0) {
      remaining = 0;
    }

    int percentage = (progress * 100).round();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            const Row(
              children: [
                Icon(
                  Icons.water_drop,
                  color: Colors.blue,
                  size: 35,
                ),
                SizedBox(width: 10),
                Text(
                  'Water Tracker',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Progress Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  children: [
                    const Text(
                      "Today's Progress",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Icon(
                      Icons.water_drop,
                      size: 70,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      '$waterConsumed ml',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    Text(
                      'of $dailyGoal ml',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 25),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 12,
                      borderRadius: BorderRadius.circular(10),
                      backgroundColor: Colors.blue.shade100,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$percentage% completed',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$remaining ml remaining',
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Quick Add
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Quick Add',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      addWater(250);
                    },
                    icon: const Icon(Icons.water_drop),
                    label: const Text('+250 ml'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      addWater(500);
                    },
                    icon: const Icon(Icons.water_drop),
                    label: const Text('+500 ml'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            OutlinedButton.icon(
              onPressed: resetWater,
              icon: const Icon(Icons.refresh),
              label: const Text('Reset Today'),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- ADD WATER PAGE ----------------

  Widget buildAddWaterPage() {
    final TextEditingController controller = TextEditingController();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'Add Water',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.local_drink,
                        size: 70,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Water amount',
                          hintText: 'Enter amount in ml',
                          prefixIcon: const Icon(Icons.water_drop),
                          suffixText: 'ml',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (controller.text.isNotEmpty) {
                              int amount = int.tryParse(controller.text) ?? 0;

                              if (amount > 0) {
                                addWater(amount);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '$amount ml added successfully!',
                                    ),
                                  ),
                                );

                                controller.clear();
                              }
                            }
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(14),
                            child: Text(
                              'Add Water',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Text(
              'Today: $waterConsumed ml / $dailyGoal ml',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- GOAL PAGE ----------------

  Widget buildGoalPage() {
    final TextEditingController goalController =
        TextEditingController(text: dailyGoal.toString());

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'Daily Goal',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.flag,
                      size: 70,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Set your daily water goal',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: goalController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Daily goal',
                        suffixText: 'ml',
                        prefixIcon: const Icon(Icons.water_drop),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          int? newGoal = int.tryParse(goalController.text);

                          if (newGoal != null && newGoal > 0) {
                            setState(() {
                              dailyGoal = newGoal;

                              if (waterConsumed > dailyGoal) {
                                waterConsumed = dailyGoal;
                              }
                            });

                            saveGoal();
                            saveWater();

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Daily goal updated successfully!',
                                ),
                              ),
                            );
                          }
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(14),
                          child: Text(
                            'Save Goal',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              '💧 Stay hydrated and drink water regularly!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
