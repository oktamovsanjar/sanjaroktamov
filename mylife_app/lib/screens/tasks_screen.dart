import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api_service.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<dynamic> tasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    setState(() => isLoading = true);
    final data = await ApiService.getTasks();
    setState(() {
      tasks = data.where((t) => t['is_completed'] == false).toList();
      isLoading = false;
    });
  }

  void _showAddTaskModal() {
    final TextEditingController _cardController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
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
              Text(
                "Yangi vazifa",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _cardController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Vazifani kiriting...",
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () async {
                  if (_cardController.text.isNotEmpty) {
                    Navigator.pop(context);
                    await ApiService.addTask(_cardController.text);
                    _fetchTasks();
                  }
                },
                child: const Text("Qo'shish", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bajarilishi kerak bo'lgan ishlar", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(onPressed: _fetchTasks, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : tasks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.done_all, size: 80, color: Colors.white.withOpacity(0.2)),
                      const SizedBox(height: 16),
                      Text("Ajoyib! Hamma ishlar bajarilgan.",
                          style: TextStyle(color: Colors.white.withOpacity(0.5))),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    DateTime dt = DateTime.parse(task['created_at']);
                    String formattedDate = DateFormat('dd.MM.yyyy HH:mm').format(dt.toLocal());
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: InkWell(
                          onTap: () async {
                            await ApiService.completeTask(task['id']);
                            _fetchTasks();
                          },
                          child: Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
                            ),
                          ),
                        ),
                        title: Text(task['title'],
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                        subtitle: Padding(
                          padding: const EdgeInsets.topOnly(top: 8),
                          child: Row(
                            children: [
                              Icon(Icons.access_time, size: 14, color: Colors.white.withOpacity(0.4)),
                              const SizedBox(width: 4),
                              Text(formattedDate, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                            ],
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete_outline, color: Colors.red.withOpacity(0.7)),
                          onPressed: () async {
                            await ApiService.deleteTask(task['id']);
                            _fetchTasks();
                          },
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskModal,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),
    );
  }
}

extension PaddingModifier on EdgeInsets {
  EdgeInsets get topOnly => const EdgeInsets.only(top: 8);
}
