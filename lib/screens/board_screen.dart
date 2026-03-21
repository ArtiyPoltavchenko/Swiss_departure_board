import 'package:flutter/material.dart';

class BoardScreen extends StatelessWidget {
  const BoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Swiss Departure Board'),
      ),
      body: const Center(
        child: Text('Departure board — coming in Phase 3'),
      ),
    );
  }
}
