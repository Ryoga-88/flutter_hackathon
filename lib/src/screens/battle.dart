import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

// ゴブリンのモックデータを定義するクラス
class GoblinData {
  final int level;
  final int hp;
  final int power;
  final int exp;
  final String imagePath;

  GoblinData({
    required this.level,
    required this.hp,
    required this.power,
    required this.exp,
    required this.imagePath,
  });
}

// ゴブリンのモックデータリスト
final List<GoblinData> goblins = [
  GoblinData(
    level: 1,
    hp: 100,
    power: 5,
    exp: 10,
    imagePath: 'lib/src/public/enemy/1.png',
  ),
  GoblinData(
    level: 2,
    hp: 300,
    power: 8,
    exp: 15,
    imagePath: 'lib/src/public/enemy/2.png',
  ),
  GoblinData(
    level: 3,
    hp: 600,
    power: 12,
    exp: 25,
    imagePath: 'lib/src/public/enemy/3.png',
  ),
  GoblinData(
    level: 4,
    hp: 1200,
    power: 18,
    exp: 40,
    imagePath: 'lib/src/public/enemy/4.png',
  ),
  GoblinData(
    level: 5,
    hp: 2000,
    power: 25,
    exp: 60,
    imagePath: 'lib/src/public/enemy/5.png',
  ),
];

class BattleScreen extends StatefulWidget {
  final Map<String, dynamic>? taskData;
  
  const BattleScreen({super.key, this.taskData});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Timer? _timer;
  int _damage = 300; // ダメージ値
  // ValueNotifierを使用して、タイマーの更新を必要な部分だけに限定
  final ValueNotifier<Duration> _remainingTime = ValueNotifier<Duration>(Duration.zero);
  bool _isTaskCompleted = false;
  bool _showPowerUp = false; // 攻撃力アップ表示のフラグ
  bool _showGoblinAttack = false; // ゴブリンの攻撃力表示のフラグ
  Timer? _goblinAttackTimer; // ゴブリンの攻撃表示用タイマー
  int _heroCurrentHp = 0; // 勇者の現在のHP（見た目用）
  
  // 勇者のステータスデータ
  Map<String, dynamic>? _heroData;
  bool _isLoading = true;
  String? _errorMessage;
  
  // 選択されたゴブリン
  late GoblinData _selectedGoblin;
  // ゴブリンの現在のHP
  late int _currentGoblinHp;

  @override
  void initState() {
    super.initState();
    _calculateRemainingTime();
    _fetchHeroData(); // 勇者のデータを取得
    
    // ランダムにゴブリンを選択
    _selectRandomGoblin();
    
    // 1秒ごとに残り時間を更新
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _calculateRemainingTime();
    });
    
    // ゴブリンの攻撃表示用タイマーを設定（10秒おき）
    _goblinAttackTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      setState(() {
        _showGoblinAttack = true;
        
        // ゴブリンの攻撃で勇者のHPを減らす
        if (_heroData != null && _heroCurrentHp > 0) {
          _heroCurrentHp = _heroCurrentHp - _selectedGoblin.power;
          if (_heroCurrentHp < 0) _heroCurrentHp = 0;
        }
        
        // 2秒後に攻撃表示を消す
        Future.delayed(Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _showGoblinAttack = false;
            });
          }
        });
      });
    });
  }
  
  // ランダムにゴブリンを選択する
  void _selectRandomGoblin() {
    final random = Random();
    _selectedGoblin = goblins[random.nextInt(goblins.length)];
    _currentGoblinHp = _selectedGoblin.hp;
  }
  
  // Firestoreから勇者のデータを取得
  Future<void> _fetchHeroData() async {
    try {
      print('Firestoreから勇者データの取得を開始します');
      
      // statesコレクションから特定のドキュメントを取得
      final DocumentSnapshot doc = await _firestore
          .collection('states')
          .doc('QtayhJ5Pu5K9vr0sKha1')
          .get();

      print('ドキュメント取得結果: ${doc.exists ? '存在します' : '存在しません'}');
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        print('取得した勇者データ: $data');
        
        setState(() {
          _heroData = data;
          _heroCurrentHp = data['hp'] ?? 100; // 勇者の現在HPを初期化
          _isLoading = false;
        });
      } else {
        print('勇者のデータが存在しません');
        
        // コレクション内の全ドキュメントを確認
        final QuerySnapshot querySnapshot = await _firestore.collection('states').get();
        print('statesコレクション内のドキュメント数: ${querySnapshot.docs.length}');
        
        if (querySnapshot.docs.isNotEmpty) {
          print('利用可能なドキュメントID:');
          for (var doc in querySnapshot.docs) {
            print('- ${doc.id}');
          }
          
          // 最初のドキュメントを使用
          if (querySnapshot.docs.isNotEmpty) {
            final firstDoc = querySnapshot.docs.first;
            print('最初のドキュメントを使用します: ${firstDoc.id}');
            setState(() {
              _heroData = firstDoc.data() as Map<String, dynamic>;
              _heroCurrentHp = _heroData?['hp'] ?? 100; // 勇者の現在HPを初期化
              _isLoading = false;
            });
            return;
          }
        }
        
        setState(() {
          _errorMessage = '勇者のデータが見つかりませんでした';
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('エラーが発生しました: $e');
      print('スタックトレース: $stackTrace');
      
      setState(() {
        _errorMessage = 'データの取得中にエラーが発生しました: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _goblinAttackTimer?.cancel();
    _remainingTime.dispose();
    super.dispose();
  }

  void _calculateRemainingTime() {
    if (widget.taskData == null || 
        widget.taskData!['startTime'] == null || 
        widget.taskData!['durationMinutes'] == null) return;

    final DateTime startTime = widget.taskData!['startTime'];
    final int duration = widget.taskData!['durationMinutes'];
    final DateTime endTime = startTime.add(Duration(minutes: duration));
    
    _remainingTime.value = endTime.difference(DateTime.now());
  }

  double _getProgressRatio() {
  if (widget.taskData == null) return 0.0;
  if (_isTaskCompleted) return 1.0;

  final DateTime startTime = widget.taskData!['startTime'];
  final int durationMinutes = widget.taskData!['durationMinutes'];
  final DateTime endTime = startTime.add(Duration(minutes: durationMinutes));
  final DateTime now = DateTime.now();

  if (now.isBefore(startTime)) {
    // 開始前：残り時間100%
    return 1.0;
  } else if (now.isAfter(endTime)) {
    // 期限切れ：残り時間0%
    return 0.0;
  } else {
    // 残り時間の比率を計算（残り時間が短いほど値が小さくなる）
    final totalDuration = endTime.difference(startTime);
    final remainingDuration = endTime.difference(now);
    return remainingDuration.inSeconds / totalDuration.inSeconds;
  }
}

// Firestoreから未完了のタスクを取得
Stream<QuerySnapshot> _fetchUncompletedTasks() {
  return _firestore.collection('tasks')
    .where('isCompleted', isEqualTo: false)
    // orderByを完全に削除して複合インデックスの必要性を回避
    .snapshots();
}

  // 残り時間の表示形式
  String _formatRemainingTime(Duration duration) {
    if (duration.isNegative) return '0';
    
    if (duration.inHours > 0) {
      return '${duration.inHours}時間${(duration.inMinutes % 60)}分';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}分${(duration.inSeconds % 60)}秒';
    } else {
      return '${duration.inSeconds}秒';
    }
  }

  // タスク完了時の処理
  void _completeTask() {
    setState(() {
      _isTaskCompleted = true;
      _showPowerUp = true; // 攻撃力アップ表示を有効化
      
      // 勇者の攻撃でゴブリンのHPを減らす
      int heroPower = _heroData?['power'] ?? 0;
      heroPower += 50; // 攻撃力+500の効果を適用
      
      _currentGoblinHp = _currentGoblinHp - heroPower;
      if (_currentGoblinHp < 0) _currentGoblinHp = 0;
      
      // 5秒後に表示を消す
      Future.delayed(Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _showPowerUp = false; // 攻撃力アップ表示を消す
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskData = widget.taskData;
    final progress = _getProgressRatio();
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            // バトル部分（画面上半分）
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity, 
                height: double.infinity, 
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('lib/src/public/background.jpg'),
                    fit: BoxFit.cover, 
                  ),
                ),
              child: Stack(
                children: [
                  // バトルキャラクター部分 (上半分の7割)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: size.height * 0.5 * 0.7,
                    child: Stack(
                      children: [
                        // 左側の敵キャラクター（ゴブリン）
                        Positioned(
                          left: 20,
                          bottom: 40,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                _selectedGoblin.imagePath,
                                width: 120,
                                height: 120,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 120,
                                    height: 120,
                                    color: Colors.green.withOpacity(0.7),
                                    child: Center(
                                      child: Text('ゴブリン Lv.${_selectedGoblin.level}',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              // ゴブリンの攻撃力表示
                              if (_showGoblinAttack)
                                Positioned(
                                  top: 0,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                    child: Text(
                                      '攻撃力: ${_selectedGoblin.power}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        
                        // 右側の自分のキャラクター（天使）
                        Positioned(
                          right: 20,
                          bottom: 10,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                'lib/src/public/hero/5.png',
                                width: 150,
                                height: 150,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 150,
                                    height: 150,
                                    color: Colors.purple.withOpacity(0.7),
                                    child: Center(
                                      child: Text('RYOGA',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              // 攻撃力アップ表示
                              if (_showPowerUp)
                                Positioned(
                                  top: 0,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                    child: Text(
                                      '攻撃力+50',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        
                      ],
                    ),
                  ),
                  
                  // HP表示部分 (上半分の下3割)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: size.height * 0.5 * 0.3,
                    child: Container(
                      color: Colors.black.withOpacity(0.4),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 敵のステータス
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'ゴブリン Lv:${_selectedGoblin.level}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 5),
                              // HP表示
                              Container(
                                width: 120,
                                height: 20,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: Stack(
                                  children: [
                                    Container(
                                      width: 120 * (_currentGoblinHp / _selectedGoblin.hp), // 現在のHP/最大HP
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.orange,
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        '$_currentGoblinHp / ${_selectedGoblin.hp}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                '攻撃力: ${_selectedGoblin.power}  経験値: ${_selectedGoblin.exp}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          
                          // VSマーク
                          Text(
                            'VS',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          
                          // プレイヤーのステータス
                          _isLoading 
                          ? Center(child: CircularProgressIndicator(color: Colors.white))
                          : Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${_heroData?['name'] ?? '勇者'} Lv:${_heroData?['lv'] ?? 1}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 5),
                              // HP表示
                              Container(
                                width: 120,
                                height: 20,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: Stack(
                                  children: [
                                    Container(
                                      width: _heroData != null ? 
                                        120 * (_heroCurrentHp / (_heroData!['hp'] ?? 100)) : 120, // 現在のHP/最大HP
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.blue,
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        '$_heroCurrentHp / ${_heroData?['hp'] ?? 0}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                '攻撃力: ${_heroData?['power'] ?? 0}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              ),
            ),
            
            // タスク部分（画面下半分）
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.all(24),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '今日のタスク',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8), // 小さな余白を追加
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: _fetchUncompletedTasks(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          
                          if (snapshot.hasError) {
                            return Center(child: Text("データ取得エラー: ${snapshot.error}"));
                          }

                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Center(child: Text("未完了のタスクがありません"));
                          }
                          
                          final tasks = snapshot.data!.docs;
                          
                          return ListView.builder(
                            padding: EdgeInsets.zero,
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

                              return TaskProgressItem(
                                taskId: taskId,
                                title: taskTitle,
                                startTime: taskStartTime,
                                durationMinutes: taskDuration,
                                isCompleted: isCompleted,
                                iconType: 'school',
                                onComplete: (bool completed, String taskId) {
                                  // タスク完了時の処理
                                  _completeTask();
                                  
                                  // Firestoreのタスクを完了状態に更新
                                  _firestore.collection('tasks').doc(taskId).update({
                                    'isCompleted': true,
                                    'completedAt': FieldValue.serverTimestamp(),
                                  }).then((_) {
                                    print('タスクを完了状態に更新しました: $taskId');
                                  }).catchError((error) {
                                    print('タスクの更新中にエラーが発生しました: $error');
                                  });
                                },
                              );
                              
                              // // 残り時間の計算
                              // final endTime = taskStartTime.add(Duration(minutes: taskDuration));
                              // final remainingTime = endTime.difference(DateTime.now());
                              // final totalDuration = endTime.difference(taskStartTime);
                              // final remainingRatio = remainingTime.inSeconds > 0 
                              //     ? remainingTime.inSeconds / totalDuration.inSeconds
                              //     : 0.0;
                              
                              // return _buildTaskItem(
                              //   taskTitle,
                              //   remainingRatio,
                              //   isCompleted,
                              //   'school', // デフォルトのアイコンタイプ
                              //   '${(remainingRatio * 100).toStringAsFixed(0)}%',
                              // );
                            },
                          );
                        },
                      ),
                    ),

                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 48),
                      ),
                      child: Text('タスクの補充'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// タスク項目用の独立したStatefulWidget
class TaskProgressItem extends StatefulWidget {
  final String taskId;
  final String title;
  final DateTime startTime;
  final int durationMinutes;
  final bool isCompleted;
  final String iconType;
  final Function(bool, String) onComplete;

  const TaskProgressItem({
    required this.taskId,
    required this.title,
    required this.startTime,
    required this.durationMinutes,
    required this.isCompleted,
    required this.iconType,
    required this.onComplete,
  });

  @override
  State<TaskProgressItem> createState() => _TaskProgressItemState();
}

class _TaskProgressItemState extends State<TaskProgressItem> {
  late Timer _timer;
  double _progressRatio = 1.0;
  
  @override
  void initState() {
    super.initState();
    _calculateProgress();
    
    // 1秒ごとに進捗を更新
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _calculateProgress();
        });
      }
    });
  }
  
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
  
  void _calculateProgress() {
    if (widget.isCompleted) {
      _progressRatio = 1.0;
      return;
    }
    
    final DateTime endTime = widget.startTime.add(Duration(minutes: widget.durationMinutes));
    final DateTime now = DateTime.now();
    
    if (now.isBefore(widget.startTime)) {
      _progressRatio = 1.0;
    } else if (now.isAfter(endTime)) {
      _progressRatio = 0.0;
    } else {
      final totalDuration = endTime.difference(widget.startTime);
      final remainingDuration = endTime.difference(now);
      _progressRatio = remainingDuration.inSeconds / totalDuration.inSeconds;
    }
  }
  
  // 残り時間を文字列で取得
  String _formatRemainingTime() {
    if (widget.isCompleted) return '完了';
    
    final DateTime endTime = widget.startTime.add(Duration(minutes: widget.durationMinutes));
    final DateTime now = DateTime.now();
    
    if (now.isAfter(endTime)) return '期限切れ';
    
    final Duration remaining = endTime.difference(now);
    
    if (remaining.inHours > 0) {
      return '残り ${remaining.inHours}時間${remaining.inMinutes % 60}分';
    } else if (remaining.inMinutes > 0) {
      return '残り ${remaining.inMinutes}分${remaining.inSeconds % 60}秒';
    } else {
      return '残り ${remaining.inSeconds}秒';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // 残り時間のテキスト
    String remainingTimeText = _formatRemainingTime();
    // 進捗率（パーセンテージ）
    String progressText = '${(_progressRatio * 100).toStringAsFixed(0)}%';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: widget.isCompleted,
              onChanged: (bool? value) {
                if (!widget.isCompleted) {
                  widget.onComplete(true, widget.taskId);
                }
              },
            ),
            SizedBox(width: 8),
            Text(
              widget.title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                decoration: widget.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        // Row(
        //   children: [
        //     Expanded(
        //       child: ClipRRect(
        //         borderRadius: BorderRadius.circular(4),
        //         child: Stack(
        //           children: [
        //             Container(
        //               height: 20,
        //               color: Colors.grey.shade300,
        //             ),
        //             Container(
        //               height: 20,
        //               width: MediaQuery.of(context).size.width * 0.7 * _progressRatio,
        //               color: _progressRatio >= 0.9 ? Colors.blue : 
        //                     _progressRatio <= 0.2 ? Colors.red : Colors.orange,
        //             ),
        //             Positioned.fill(
        //               child: Center(
        //                 child: Text(
        //                   progressText,
        //                   style: TextStyle(
        //                     color: Colors.black,
        //                     fontWeight: FontWeight.bold,
        //                     fontSize: 12,
        //                   ),
        //                 ),
        //               ),
        //             ),
        //           ],
        //         ),
        //       ),
        //     ),
        //     SizedBox(width: 8),
        //     Container(
        //       width: 36,
        //       height: 36,
        //       decoration: BoxDecoration(
        //         color: Colors.black,
        //         shape: BoxShape.circle,
        //       ),
        //       child: Center(
        //         child: Icon(_getIconData(), color: Colors.white, size: 18),
        //       ),
        //     ),
        //   ],
        // ),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Stack(
                  children: [
                    Container(
                      height: 20,
                      color: Colors.grey.shade300,
                    ),
                    FractionallySizedBox(
                      widthFactor: _progressRatio, // 進捗率を直接指定
                      child: Container(
                        height: 20,
                        color: _progressRatio >= 0.9
                            ? Colors.blue
                            : _progressRatio <= 0.2
                                ? Colors.red
                                : Colors.orange,
                      ),
                    ),
                    Positioned.fill(
                      child: Center(
                        child: Text(
                          remainingTimeText, // 残り時間を表示
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 8),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(_getIconData(), color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            remainingTimeText, // 残り時間を表示
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }
  
  IconData _getIconData() {
    switch(widget.iconType) {
      case 'school': return Icons.school;
      case 'receipt': return Icons.receipt;
      case 'assignment': return Icons.assignment;
      default: return Icons.check;
    }
  }
}
