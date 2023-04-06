import 'package:avandra/resources/authentication.dart';
import 'package:avandra/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SavedPinsScreen extends StatefulWidget {
  const SavedPinsScreen({super.key});

  @override
  State<SavedPinsScreen> createState() => _SavedPinsScreenState();
}

class _SavedPinsScreenState extends State<SavedPinsScreen> {
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
        body: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 90.0, top: 170.0),
          children: [
            ListTile(
              leading: Icon(
                Icons.home,
                color: Colors.black,
                size: 30,
              ),
              title: Text('',
                  style: TextStyle(color: Colors.black, fontSize: 23)),
            ),
            ListTile(
              leading:
                  Icon(Icons.account_circle, color: Colors.black, size: 30),
              title: Text('',
                  style: TextStyle(color: Colors.black, fontSize: 23)),
            ),
            ListTile(
              leading: Icon(Icons.push_pin, color: Colors.black, size: 30),
              title: Text('',
                  style: TextStyle(color: Colors.black, fontSize: 23)),
            ),
            ListTile(
              leading: Icon(Icons.map_outlined, color: Colors.black, size: 30),
              title: Text('',
                  style: TextStyle(color: Colors.black, fontSize: 23)),
            ),
            Divider(
              color: Colors.black,
              endIndent: 90,
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.black, size: 30),
              title: Text('',
                  style: TextStyle(color: Colors.black, fontSize: 23)),
              onTap: () => AuthMethods().signOut(),
            ),
          ],
        ));
  }
}
