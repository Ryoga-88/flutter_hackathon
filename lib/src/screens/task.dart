import 'battle.dart'; 
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _titleController = TextEditingController();
  DateTime _startTime = DateTime.now();
  int _durationMinutes = 30;

  // Firestoreからタスクを取得
  Stream<QuerySnapshot> _fetchTasks() {
    print('Firestoreからタスクの取得を開始します');
    return _firestore.collection('tasks')
      .orderBy('createdAt', descending: true)
      .snapshots();
  }

  // タスクを追加
  Future<void> _addTask() async {
    if (_titleController.text.isEmpty) {
      print('タイトルが空のため、タスクを追加しません');
      return;
    }
    try {
      await _firestore.collection('tasks').add({
        'title': _titleController.text,
        'startTime': _startTime,
        'durationMinutes': _durationMinutes,
        'isCompleted': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('タスクが正常に追加されました: ${_titleController.text}');
      _titleController.clear();
    } catch (error) {
      print('タスクの追加に失敗しました: $error');
    }
  }

  // タスクを削除
  Future<void> _deleteTask(String documentId) async {
    try {
      await _firestore.collection('tasks').doc(documentId).delete();
      print('タスクが正常に削除されました: $documentId');
    } catch (error) {
      print('タスクの削除に失敗しました: $error');
    }
  }

  // タスクの完了状態を切り替え
  Future<void> _toggleTaskCompletion(String documentId, bool currentStatus) async {
    try {
      await _firestore.collection('tasks').doc(documentId).update({
        'isCompleted': !currentStatus,
      });
      print('タスクの完了状態が更新されました: $documentId, 新しい状態: ${!currentStatus}');
    } catch (error) {
      print('タスクの完了状態の更新に失敗しました: $error');
    }
  }

  // 開始時間の選択
  Future<void> _selectStartTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _startTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_startTime),
      );

      if (pickedTime != null) {
        setState(() {
          _startTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
        print('開始時間が選択されました: $_startTime');
      } else {
        print('時間の選択がキャンセルされました');
      }
    } else {
      print('日付の選択がキャンセルされました');
    }
  }

  // タスク追加ダイアログを表示
  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('新しいタスクを追加'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'タイトル',
                        hintText: 'タスクのタイトルを入力してください',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('開始時間'),
                      subtitle: Text(
                        DateFormat('yyyy/MM/dd HH:mm').format(_startTime)
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        await _selectStartTime(context);
                        setState(() {}); // ダイアログ内の状態を更新
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('所要時間（分）: '),
                        Expanded(
                          child: Slider(
                            value: _durationMinutes.toDouble(),
                            min: 5,
                            max: 180,
                            divisions: 35,
                            label: _durationMinutes.toString(),
                            onChanged: (value) {
                              setState(() {
                                _durationMinutes = value.toInt();
                              });
                              print('所要時間が更新されました: $_durationMinutes分');
                            },
                          ),
                        ),
                        Text('$_durationMinutes分'),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    print('タスク追加ダイアログがキャンセルされました');
                    Navigator.pop(context);
                  },
                  child: const Text('キャンセル'),
                ),
                TextButton(
                  onPressed: () {
                    _addTask();
                    Navigator.pop(context);
                  },
                  child: const Text('追加'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('TaskScreenのbuildメソッドが呼び出されました');
    return Scaffold(
      appBar: AppBar(title: const Text("タスクリスト")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _fetchTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            print('Firestoreからのデータ取得中...');
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            print('Firestoreからのデータ取得でエラーが発生しました: ${snapshot.error}');
            return Center(child: Text("データ取得エラー: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            print('Firestoreにタスクが存在しません');
            return const Center(child: Text("タスクがありません"));
          }
          
          final tasks = snapshot.data!.docs;
          print('Firestoreからタスクを${tasks.length}件取得しました');
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              final data = task.data() as Map<String, dynamic>;
              final taskId = task.id;

              final taskTitle = data['title'] ?? 'タイトルなし';
              final taskStartTime = data['startTime'] != null 
                  ? (data['startTime'] as Timestamp).toDate() 
                  : DateTime.now();
              final taskDuration = data['durationMinutes'] ?? 0;
              final isCompleted = data['isCompleted'] ?? false;

              // return Card(
              //   margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              //   child: ListTile(
              //     title: Text(
              //       taskTitle,
              //       style: TextStyle(
              //         decoration: isCompleted ? TextDecoration.lineThrough : null,
              //       ),
              //     ),
              //     subtitle: Text(
              //       '開始時間: ${DateFormat('yyyy/MM/dd HH:mm').format(taskStartTime)}\n'
              //       '所要時間: $taskDuration分',
              //     ),
              //     trailing: Row(
              //       mainAxisSize: MainAxisSize.min,
              //       children: [
              //         Checkbox(
              //           value: isCompleted,
              //           onChanged: (value) => _toggleTaskCompletion(taskId, isCompleted),
              //         ),
              //         IconButton(
              //           icon: const Icon(Icons.delete, color: Colors.red),
              //           onPressed: () => _deleteTask(taskId),
              //         ),
              //       ],
              //     ),
              //   ),
              // );
              // Inside the ListView.builder in TaskScreen
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  title: Text(
                    taskTitle,
                    style: TextStyle(
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Text(
                    '開始時間: ${DateFormat('yyyy/MM/dd HH:mm').format(taskStartTime)}\n'
                    '所要時間: $taskDuration分',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: isCompleted,
                        onChanged: (value) => _toggleTaskCompletion(taskId, isCompleted),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteTask(taskId),
                      ),
                    ],
                  ),
                  // CORRECT USAGE
                  // タスクカードのonTap部分を修正
                  // ListView.builder内のonTap部分を修正
                  onTap: () {
                    // 残り時間がプラスかどうかチェック
                    final taskStartTime = (data['startTime'] as Timestamp).toDate();
                    final taskDuration = data['durationMinutes'];
                    final endTime = taskStartTime.add(Duration(minutes: taskDuration));
                    
                    if (!(data['isCompleted'] ?? false))  {
                      // 残り時間があり、未完了のタスクのみバトル画面へ遷移
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BattleScreen(
                            taskData: {
                              'id': task.id,
                              'title': data['title'],
                              'description': data['description'] ?? '',
                              'startTime': taskStartTime,
                              'durationMinutes': taskDuration,
                              'isCompleted': data['isCompleted'],
                              'createdAt': data['createdAt']?.toDate() ?? DateTime.now(),
                            },
                          ),
                        ),
                      );
                    } else if (data['isCompleted'] ?? false) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('このタスクは既に完了しています')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('このタスクは既に期限切れです')),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}


