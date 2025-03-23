import 'package:flutter/material.dart';

class BattleScreen extends StatelessWidget {
  const BattleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Battle'),
      ),
      body: const Center(
          child: Text('Battle画面', style: TextStyle(fontSize: 32.0))
      ),
    );
  }
}
