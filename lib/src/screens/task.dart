import 'package:flutter/material.dart';

class TaskScreen extends StatelessWidget {
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Task'),
      ),
      body: const Center(
          child: Text('Task画面', style: TextStyle(fontSize: 32.0))
      ),
    );
  }
}