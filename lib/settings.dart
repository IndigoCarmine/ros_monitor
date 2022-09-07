import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool enableCustom = true;

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String? iPAddress;
  @override
  void initState() {
    super.initState();
    _prefs.then((SharedPreferences prefs) {
      iPAddress = prefs.getString("iPAddress") ?? 'ws://127.0.0.1:9090';
      setState((() {}));
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SettingsList(
        sections: [
          SettingsSection(
            title: const Text('Common'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const Icon(Icons.connected_tv),
                title: const Text('Server IP Address'),
                value: Text(iPAddress ?? "error"),
                onPressed: (BuildContext context) async {
                  String? newIPAddress = await inputDialog(context);
                  if (newIPAddress != null && newIPAddress != "") {
                    setState(() {
                      iPAddress = newIPAddress;
                    });
                    _prefs.then((SharedPreferences prefs) {
                      prefs.setString("iPAddress", newIPAddress);
                    });
                  }
                },
              ),
              SettingsTile.switchTile(
                onToggle: (value) {
                  setState(() {
                    enableCustom = value;
                  });
                },
                initialValue: enableCustom,
                leading: const Icon(Icons.format_paint),
                title: const Text('Enable custom theme'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<String?> inputDialog(BuildContext context) async {
    TextEditingController editingController = TextEditingController();
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Server IP Address'),
            content: TextField(
              controller: editingController,
              decoration: const InputDecoration(hintText: "ここに入力"),
            ),
            actions: <Widget>[
              TextButton(
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.white)),
                child:
                    const Text('キャンセル', style: TextStyle(color: Colors.black)),
                onPressed: () {
                  editingController.text = "";
                  Navigator.pop(context);
                },
              ),
              TextButton(
                autofocus: true,
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.white)),
                child: const Text('OK', style: TextStyle(color: Colors.black)),
                onPressed: () {
                  //OKを押したあとの処理
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
    return editingController.text;
  }
}
