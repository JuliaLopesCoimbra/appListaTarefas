import 'package:flutter/material.dart';

void main() => runApp(ToDoApp());

class Task {
  String title;
  String description;
  TimeOfDay? time;
  String? imageUrl;

  Task({required this.title, this.description = '', this.time, this.imageUrl});
}

class ToDoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Tarefas',
      home: ToDoListPage(),
    );
  }
}

class ToDoListPage extends StatefulWidget {
  @override
  _ToDoListPageState createState() => _ToDoListPageState();
}

class _ToDoListPageState extends State<ToDoListPage> {
  List<Task> _tasks = [];

  void _addTask() {
    TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Nova Tarefa'),
        content: TextField(
          controller: _controller,
          decoration: InputDecoration(hintText: 'Título da tarefa'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_controller.text.trim().isNotEmpty) {
                setState(() {
                  _tasks.add(Task(title: _controller.text.trim()));
                });
              }
              Navigator.pop(context);
            },
            child: Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  void _openTaskDetails(Task task, int index) async {
    final updatedTask = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaskDetailPage(task: task),
      ),
    );

    if (updatedTask != null && updatedTask is Task) {
      setState(() {
        _tasks[index] = updatedTask;
      });
    }
  }

  void _removeTask(int index) {
    setState(() => _tasks.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lista de Tarefas')),
      body: _tasks.isEmpty
          ? Center(child: Text('Nenhuma tarefa adicionada.'))
          : ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(_tasks[index].title),
                subtitle: _tasks[index].time != null
                    ? Text('Horário: ${_tasks[index].time!.format(context)}')
                    : null,
                onTap: () => _openTaskDetails(_tasks[index], index),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeTask(index),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: Icon(Icons.add),
      ),
    );
  }
}

class TaskDetailPage extends StatefulWidget {
  final Task task;

  TaskDetailPage({required this.task});

  @override
  _TaskDetailPageState createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  late TextEditingController _descriptionController;
  late TextEditingController _imageController;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    _descriptionController =
        TextEditingController(text: widget.task.description);
    _imageController = TextEditingController(text: widget.task.imageUrl ?? '');
    _selectedTime = widget.task.time;
    super.initState();
  }

  void _pickTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _saveTask() {
    Navigator.pop(
      context,
      Task(
        title: widget.task.title,
        description: _descriptionController.text,
        time: _selectedTime,
        imageUrl: _imageController.text.trim().isEmpty
            ? null
            : _imageController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Tarefa'),
        actions: [
          IconButton(onPressed: _saveTask, icon: Icon(Icons.save)),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('Descrição'),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            SizedBox(height: 16),
            Text('Imagem (URL)'),
            TextField(
              controller: _imageController,
              decoration: InputDecoration(
                  hintText: 'https://...', border: OutlineInputBorder()),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickTime,
              icon: Icon(Icons.access_time),
              label: Text(_selectedTime == null
                  ? 'Selecionar Horário'
                  : 'Horário: ${_selectedTime!.format(context)}'),
            ),
            SizedBox(height: 16),
            if (_imageController.text.trim().isNotEmpty)
              Image.network(_imageController.text.trim(),
                  height: 200, fit: BoxFit.cover),
          ],
        ),
      ),
    );
  }
}
