import 'package:flutter/material.dart';

class StatusScreen extends StatelessWidget {
  const StatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Status'),
      ),
      body: const Center(
          child: Text('Status画面', style: TextStyle(fontSize: 32.0))
      ),
    );
  }
}