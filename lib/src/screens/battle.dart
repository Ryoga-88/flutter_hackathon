import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class BattleScreen extends StatefulWidget {
  final Map<String, dynamic>? taskData;
  
  const BattleScreen({super.key, this.taskData});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  Timer? _timer;
  int _damage = 300; // ダメージ値
  Duration _remainingTime = Duration.zero;
  bool _isTaskCompleted = false;
  double _completionPercentage = 0.0;
  bool _showCompletionPercentage = false;

  @override
  void initState() {
    super.initState();
    _calculateRemainingTime();
    
    // 1秒ごとに残り時間を更新
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _calculateRemainingTime();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _calculateRemainingTime() {
    if (widget.taskData == null || 
        widget.taskData!['startTime'] == null || 
        widget.taskData!['durationMinutes'] == null) return;

    final DateTime startTime = widget.taskData!['startTime'];
    final int duration = widget.taskData!['durationMinutes'];
    final DateTime endTime = startTime.add(Duration(minutes: duration));
    
    setState(() {
      _remainingTime = endTime.difference(DateTime.now());
    });
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
      final progress = _getProgressRatio();
      // 進捗率をパーセンテージに変換して保存
      _completionPercentage = progress * 100;
      _showCompletionPercentage = true;
      
      // 5秒後に表示を消す
      Future.delayed(Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _showCompletionPercentage = false;
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
                          top: 50,
                          child: Image.asset(
                            'lib/src/public/enemy/1.PNG',
                            width: 120,
                            height: 120,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 120,
                                height: 120,
                                color: Colors.green.withOpacity(0.7),
                                child: Center(
                                  child: Text('ゴブリン',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        
                        // 右側の自分のキャラクター（天使）
                        Positioned(
                          right: 20,
                          bottom: 10,
                          child: Image.asset(
                            'lib/src/public/enemy/2.PNG',
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
                        ),
                        
                        // バトルテキスト（ダメージなど）
                        if (_showCompletionPercentage)
                        Positioned(
                          top: size.height * 0.5 * 0.3,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'タスク完了！ 効率: ${_completionPercentage.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
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
                                'ゴブリン Lv:2',
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
                                      width: 120 * (10 / 40), // 10/40のHP
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.orange,
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        '10 / 40',
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'RYOGA Lv:4',
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
                                      width: 120, // 満タン
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.blue,
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        '80 / 80',
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
                    Expanded(  // FlexibleからExpandedに変更
                      child: ListView.builder(
                        padding: EdgeInsets.zero, // パディングを削除
                        itemCount: widget.taskData != null ? 1 : 0, 
                        itemBuilder: (context, index) {
                          final tasks = [
                            if (widget.taskData != null)
                              {
                                'title': widget.taskData!['title'] ?? 'タスク名',
                                'remainingRatio': _remainingTime.inSeconds / (widget.taskData!['durationMinutes'] * 60),
                                'isCompleted': _isTaskCompleted,
                                'iconType': 'school',
                                'progressText': '${(_getProgressRatio() * 100).toInt()}%',
                              },
                              // ダミーデータ
                            {
                              'title': '請求書を提出する',
                              'remainingRatio': 0.5,
                              'isCompleted': false,
                              'iconType': 'receipt',
                              'progressText': '20 / 40',
                            },
                            {
                              'title': '推薦書を見てもらう',
                              'remainingRatio': 1.0,
                              'isCompleted': false,
                              'iconType': 'assignment',
                              'progressText': '0 / 60',
                            },
                          ];

                          return Column(
                            children: tasks.map((task) => _buildTaskItem(
                              task['title'] as String,
                              task['remainingRatio'] as double,
                              task['isCompleted'] as bool,
                              task['iconType'] as String,
                              task['progressText'] as String,
                            )).toList(),
                          );
                        },
                      ),
                    ),

                    // タスクを進めるボタン
                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: ElevatedButton(
                    //         onPressed: _isTaskCompleted ? null : _completeTask,
                    //         style: ElevatedButton.styleFrom(
                    //           backgroundColor: Colors.blue,
                    //           foregroundColor: Colors.white,
                    //           disabledBackgroundColor: Colors.grey,
                    //         ),
                    //         child: Text('タスクを進める？'),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    // SizedBox(height: 8),
                    // // タスクの補充ボタン（task.dartに戻る）
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

  Widget _buildTaskItem(String title, double remainingRatio, bool isCompleted, String iconType, String progressText) {
    IconData getIconData() {
      switch(iconType) {
        case 'school': return Icons.school;
        case 'receipt': return Icons.receipt;
        case 'assignment': return Icons.assignment;
        default: return Icons.check;
      }
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // チェックボックスを追加
            Checkbox(
              value: isCompleted,
              onChanged: (bool? value) {
                if (!isCompleted) {
                  _completeTask();
                }
              },
            ),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
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
                    // ここで_getProgressRatio()を直接呼び出す
                    Container(
                      height: 20,
                      width: MediaQuery.of(context).size.width * 0.7 * _getProgressRatio(),
                      color: _getProgressRatio() == 1.0 ? Colors.blue : 
                            _getProgressRatio() == 0.0 ? Colors.red : Colors.orange,
                    ),
                    Positioned.fill(
                      child: Center(
                        child: Text(
                          '${(_getProgressRatio() * 100).toStringAsFixed(0)}%',
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
                child: Icon(getIconData(), color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '残り: ${_formatRemainingTime(_remainingTime)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }
}
