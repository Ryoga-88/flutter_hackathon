import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _heroData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchHeroData();
  }

  Future<void> _fetchHeroData() async {
    try {
      // Firestoreのインスタンスを取得
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      
      print('Firestoreからデータ取得を開始します');
      print('コレクション: states, ドキュメントID: QtayhJ5Pu5K9vrOsKha1');
      
      // statesコレクションから特定のドキュメントを取得
      final DocumentSnapshot doc = await firestore
          .collection('states')
          .doc('QtayhJ5Pu5K9vrOsKha1')
          .get();

      print('ドキュメント取得結果: ${doc.exists ? '存在します' : '存在しません'}');
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        print('取得したデータ: $data');
        
        setState(() {
          _heroData = data;
          _isLoading = false;
        });
      } else {
        print('ドキュメントが存在しません');
        
        // コレクション内の全ドキュメントを確認
        final QuerySnapshot querySnapshot = await firestore.collection('states').get();
        print('statesコレクション内のドキュメント数: ${querySnapshot.docs.length}');
        
        if (querySnapshot.docs.isNotEmpty) {
          print('利用可能なドキュメントID:');
          for (var doc in querySnapshot.docs) {
            print('- ${doc.id}');
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

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '未ログイン';
    
    if (timestamp is Timestamp) {
      final DateTime dateTime = timestamp.toDate();
      return DateFormat('yyyy年MM月dd日 HH:mm').format(dateTime);
    } else {
      return timestamp.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('勇者のプロフィール'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
              : _buildHeroProfile(),
    );
  }

  Widget _buildHeroProfile() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                const Icon(Icons.person, size: 80, color: Colors.blue),
                const SizedBox(height: 8),
                Text(
                  _heroData?['name'] ?? '名無しの勇者',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Lv. ${_heroData?['lv'] ?? 0}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildStatusCard(),
          const SizedBox(height: 16),
          _buildLastLoginInfo(),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ステータス',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildStatusRow('HP', '${_heroData?['hp'] ?? 0}'),
            _buildStatusRow('攻撃力', '${_heroData?['power'] ?? 0}'),
            _buildStatusRow('経験値', '${_heroData?['experience'] ?? 0}'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildLastLoginInfo() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '最終ログイン',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Text(
              _formatTimestamp(_heroData?['lastlogin']),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
