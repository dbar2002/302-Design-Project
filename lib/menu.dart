import 'package:flutter/material.dart';

class Menu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
        shrinkWrap: true,
        padding: EdgeInsets.all(16),
        children: [
          ListTile(
            contentPadding: EdgeInsets.all(25),
            leading: Icon(Icons.arrow_back),
            title: Text('Back'),
            onTap: () => print('Back'),
          ),
          UserAccountsDrawerHeader(  
            accountName: Text('User Name', style: TextStyle(color: Colors.black54)), 
            accountEmail: Text('example@universityemail.com', style: TextStyle(color: Colors.black54)),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: Image.network(
                  'https://oflutter.com/wp-content/uploads/2021/02/girl-profile.png',
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              // image: DecorationImage(
              //   image: NetworkImage(
              //     'https://oflutter.com/wp-content/uploads/2021/02/profile-bg3.jpg'
              //   ),
              //   fit: BoxFit.cover,
              
              ),
            ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () => Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false),
          ),
          ListTile(
            leading: Icon(Icons.account_circle),
            title: Text('Profile'),
            onTap: () => print('Profile'),
          ),
          ListTile(
            leading: Icon(Icons.push_pin),
            title: Text('Pins'),
            onTap: () => print('Pins'),
          ),          
          ListTile(
            leading: Icon(Icons.map_outlined),
            title: Text('Select Map'),
            onTap: () => print('Select Map'),
          ),          
          Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Log out'),
            onTap: () => print('Log out'),
          ),          
        ],
    );
  }
}