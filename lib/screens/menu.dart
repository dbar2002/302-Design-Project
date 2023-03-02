import 'package:avandra/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back_ios,
                size: 25,
                color: Colors.black,
              )),
      ),
      body: 
      ListView(
        children: [
          ListTile(
                leading: Icon(Icons.home, color: Colors.black),
                title: Text('Home', style: TextStyle(color: Colors.black)),
                onTap: () => Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false),
          ),
          ListTile(
            leading: Icon(Icons.account_circle, color: Colors.black),
            title: Text('Profile', style: TextStyle(color: Colors.black)),
            onTap: () => print('Profile'),
          ),
          ListTile(
            leading: Icon(Icons.push_pin, color: Colors.black),
            title: Text('Pins', style: TextStyle(color: Colors.black)),
            onTap: () => print('Pins'),
          ),
          ListTile(
            leading: Icon(Icons.map_outlined, color: Colors.black),
            title: Text('Select Map', style: TextStyle(color: Colors.black)),
            onTap: () => print('Select Map'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.black),
            title: Text('Log out', style: TextStyle(color: Colors.black)),
            onTap: () => print('Log out'),
          ),
        ],
      )
    );
  }
}
