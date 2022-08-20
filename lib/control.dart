import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:roslibdart/roslibdart.dart';

class ControlPage extends StatefulWidget {
  final Ros ros;
  const ControlPage({Key? key, required this.ros}) : super(key: key);

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  StickDragDetails _rightDragDetails = StickDragDetails(0, 0);
  StickDragDetails _leftDragDetails = StickDragDetails(0, 0);
  late Ros ros;
  late Topic joytopic;

  @override
  void initState() {
    super.initState();
    ros = widget.ros;
    joytopic = Topic(ros: ros, name: '/joy', type: 'sensor_msgs/Joy');

    Timer.periodic(const Duration(microseconds: 100), rosPublish);
  }

  bool _isChanged = false;
  void rosPublish(Timer timer) {
    if (!_isChanged) return;
    Map<String, dynamic> msg = {
      'header': {
        'seq': 0,
        'stamp': {'secs': 0, 'nsecs': 0},
        'frame_id': '',
      },
      'axes': [
        _rightDragDetails.x,
        _rightDragDetails.y,
        _leftDragDetails.x,
        _leftDragDetails.y
      ],
      'buttons': []
    };
    joytopic.publish(msg);
    _isChanged = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(children: [
        Joystick(listener: (StickDragDetails data) {
          setState(() {
            _leftDragDetails = data;
            _isChanged = true;
          });
        }, onStickDragEnd: () {
          setState(() {
            _leftDragDetails = StickDragDetails(0, 0);
            _isChanged = true;
          });
        }),
        Joystick(listener: (StickDragDetails data) {
          setState(() {
            _rightDragDetails = data;
            _isChanged = true;
          });
        }, onStickDragEnd: () {
          setState(() {
            _rightDragDetails = StickDragDetails(0, 0);
            _isChanged = true;
          });
        })
      ]),
    );
  }
}
