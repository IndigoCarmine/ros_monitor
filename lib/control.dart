import 'package:flutter/material.dart';

class ControlPage extends StatefulWidget {
  ControlPage({Key? key}) : super(key: key);

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Control Page'),
      ),
    );
  }
}
