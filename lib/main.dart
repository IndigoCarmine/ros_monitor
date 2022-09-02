import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ros_monitor/control.dart';
import 'package:ros_monitor/settings.dart';
import 'package:ros_monitor/status.dart';
import 'package:roslibdart/roslibdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  //default values
  late Ros ros;
  late Topic topic;
  int _selectedIndex = 0;
  late List<Widget> _screens;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  @override
  void initState() {
    super.initState();
    ros = Ros(url: 'ws://192.168.3.6:8080');
    _screens = <Widget>[
      StatusPage(),
      ControlPage(ros: ros),
      const SettingsPage()
    ];
  }

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
    ros.url = await _prefs.then((SharedPreferences prefs) =>
        prefs.getString("iPAddress") ?? 'ws://127.0.0.1:9090');
    ros.connect();
    while (ros.status != Status.connecting) {
      await Future.delayed(const Duration(seconds: 1));
    }
    if (ros.status == Status.connected) {
      // show snackbar
      SnackBar a = const SnackBar(content: Text('connected'));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(a);
    } else {
      // show snackbar
      SnackBar a = const SnackBar(content: Text('can not connect'));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(a);
    }
  }
}
