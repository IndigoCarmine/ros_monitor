import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ros_monitor/control.dart';
import 'package:ros_monitor/settings.dart';
import 'package:ros_monitor/status.dart';
import 'package:roslibdart/roslibdart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ROS Monitor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainPage(title: 'ROS Monitor'),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late Ros ros;
  late Topic topic;
  int _selectedIndex = 0;
  static final _screens = <Widget>[StatusPage(), ControlPage(), SettingsPage()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.keyboard_control),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Status',
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: 'Settings'),
          ],
          currentIndex: _selectedIndex,
          onTap: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          }),
      floatingActionButton: FloatingActionButton(
          onPressed: websocketConnect,
          tooltip: 'connect',
          child: const Icon(
            Icons.cast_connected_rounded,
          ) // This trailing comma makes auto-formatting nicer for build methods.
          ),
    );
  }

  Future<void> websocketConnect() async {
    ros = Ros(url: 'ws://127.0.0.1:9090');
    topic = Topic(
        ros: ros,
        name: '/topic',
        type: "std_msgs/String",
        reconnectOnClose: true,
        queueLength: 10,
        queueSize: 10);
    ros.connect();
    await topic.subscribe(subscribeHandler);

    // show snackbar
    SnackBar a = const SnackBar(content: Text('connected'));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(a);

    setState(() {});
  }

  Future<void> subscribeHandler(Map<String, dynamic> args) async {
    setState(() {
      String msgReceived = json.decoder.convert(args['msg']);
    });
  }
}
