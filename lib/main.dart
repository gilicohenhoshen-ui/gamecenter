import 'package:flutter/material.dart';

void main() => runApp(const TasksApp());

class TasksApp extends StatelessWidget {
  const TasksApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF6750A4);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'המשימות שלי',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light),
        scaffoldBackgroundColor: const Color(0xFFF7F5FA),
        fontFamily: 'Arial',
      ),
      home: const TasksHomePage(),
    );
  }
}

enum TaskFilter { all, active, completed }

class TaskItem {
  TaskItem(this.title);
  final String title;
  bool isDone = false;
}

class TasksHomePage extends StatefulWidget {
  const TasksHomePage({super.key});

  @override
  State<TasksHomePage> createState() => _TasksHomePageState();
}

class _TasksHomePageState extends State<TasksHomePage> {
  final List<TaskItem> _tasks = [
    TaskItem('לסדר את שולחן העבודה'),
    TaskItem('לסיים שיעורי בית'),
    TaskItem('לקרוא במשך 20 דקות'),
  ];
  TaskFilter _filter = TaskFilter.all;

  int get _completedCount => _tasks.where((task) => task.isDone).length;

  List<TaskItem> get _visibleTasks => _tasks.where((task) {
        switch (_filter) {
          case TaskFilter.active:
            return !task.isDone;
          case TaskFilter.completed:
            return task.isDone;
          case TaskFilter.all:
            return true;
        }
      }).toList();

  Future<void> _addTask() async {
    final controller = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('משימה חדשה'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => Navigator.pop(dialogContext, controller.text),
            decoration: InputDecoration(
              hintText: 'מה צריך לעשות?',
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('ביטול'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, controller.text),
              child: const Text('הוספה'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (title != null && title.trim().isNotEmpty) {
      setState(() => _tasks.insert(0, TaskItem(title.trim())));
    }
  }

  void _deleteTask(TaskItem task) {
    setState(() => _tasks.remove(task));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('המשימה נמחקה')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleTasks;
    final total = _tasks.length;
    final progress = total == 0 ? 0.0 : _completedCount / total;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _addTask,
          icon: const Icon(Icons.add),
          label: const Text('משימה חדשה'),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 28, 22, 110),
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(Icons.checklist_rounded,
                            size: 29, color: Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('המשימות שלי',
                                style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800)),
                            SizedBox(height: 3),
                            Text('מתקדמים צעד אחד בכל פעם',
                                style: TextStyle(color: Color(0xFF77717F), fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6750A4), Color(0xFF8B75C7)],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ההתקדמות שלך',
                            style: TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('$_completedCount',
                                style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold)),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6, right: 7),
                              child: Text('מתוך $total משימות הושלמו',
                                  style: const TextStyle(color: Colors.white, fontSize: 14)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 9,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 27),
                  Row(
                    children: [
                      const Expanded(
                        child: Text('רשימת משימות',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                      ),
                      Text('$total בסך הכול',
                          style: const TextStyle(color: Color(0xFF77717F), fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 13),
                  Wrap(
                    spacing: 8,
                    children: [
                      _filterChip('הכול', TaskFilter.all),
                      _filterChip('לביצוע', TaskFilter.active),
                      _filterChip('הושלמו', TaskFilter.completed),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (visible.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 38, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.inbox_rounded, size: 42,
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6)),
                          const SizedBox(height: 10),
                          Text(_tasks.isEmpty ? 'עדיין אין משימות' : 'אין משימות בתצוגה הזו',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                          const SizedBox(height: 5),
                          const Text('אפשר להוסיף משימה חדשה באמצעות הכפתור למטה',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Color(0xFF77717F))),
                        ],
                      ),
                    )
                  else
                    ...visible.map(_taskCard),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _filterChip(String label, TaskFilter filter) {
    final selected = _filter == filter;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _filter = filter),
      showCheckmark: false,
      labelStyle: TextStyle(
        color: selected ? Colors.white : const Color(0xFF625D68),
        fontWeight: FontWeight.w600,
      ),
      selectedColor: Theme.of(context).colorScheme.primary,
      backgroundColor: Colors.white,
      side: BorderSide.none,
    );
  }

  Widget _taskCard(TaskItem task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFECE8F0)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsetsDirectional.only(start: 8, end: 8, top: 5, bottom: 5),
        leading: Checkbox(
          value: task.isDone,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          onChanged: (value) => setState(() => task.isDone = value ?? false),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: task.isDone ? const Color(0xFF99939F) : const Color(0xFF292531),
            decoration: task.isDone ? TextDecoration.lineThrough : TextDecoration.none,
          ),
        ),
        trailing: IconButton(
          tooltip: 'מחיקת משימה',
          onPressed: () => _deleteTask(task),
          icon: const Icon(Icons.delete_outline_rounded),
          color: const Color(0xFF9A929F),
        ),
      ),
    );
  }
}
