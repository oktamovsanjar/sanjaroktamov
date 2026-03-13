import 'package:flutter/material.dart';
import '../api_service.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  List<dynamic> habits = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHabits();
  }

  Future<void> _fetchHabits() async {
    setState(() => isLoading = true);
    final data = await ApiService.getHabits();
    setState(() {
      habits = data;
      isLoading = false;
    });
  }

  void _showAddHabitModal() {
    final TextEditingController _cardController = TextEditingController();
    String _frequency = "daily";
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                top: 24, left: 24, right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text("Yangi odat",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _cardController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: "Odatni kiriting...",
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text("Qaysi vaqt oralig'i:", style: TextStyle(color: Colors.white70)),
                      const SizedBox(width: 16),
                      DropdownButton<String>(
                        dropdownColor: Theme.of(context).canvasColor,
                        value: _frequency,
                        items: const [
                          DropdownMenuItem(value: "daily", child: Text("Har kunlik")),
                          DropdownMenuItem(value: "weekly", child: Text("Haftalik")),
                        ],
                        onChanged: (String? value) {
                          if (value != null) {
                            setModalState(() {
                              _frequency = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () async {
                      if (_cardController.text.isNotEmpty) {
                        Navigator.pop(context);
                        await ApiService.addHabit(_cardController.text, frequency: _frequency);
                        _fetchHabits();
                      }
                    },
                    child: const Text("Qo'shish", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Foydali Odatlar", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(onPressed: _fetchHabits, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : habits.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.local_fire_department, size: 80, color: Colors.white.withOpacity(0.2)),
                      const SizedBox(height: 16),
                      Text("Hali maqsadlar qo'shilmagan",
                          style: TextStyle(color: Colors.white.withOpacity(0.5))),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: habits.length,
                  itemBuilder: (context, index) {
                    final habit = habits[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.04),
                            Theme.of(context).colorScheme.secondary.withOpacity(0.05)
                          ]
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                          child: Icon(Icons.local_fire_department, color: Theme.of(context).colorScheme.secondary),
                        ),
                        title: Text(habit['title'],
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            habit['frequency'] == 'daily' ? 'Har kungi odat' : 'Haftalik odat',
                            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddHabitModal,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),
    );
  }
}
