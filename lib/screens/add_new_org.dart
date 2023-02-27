import 'package:avandra/widgets/input_box.dart';
import 'package:avandra/utils/colors.dart';
import 'package:avandra/utils/fonts.dart';
import 'package:avandra/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart';

class AddNewOrg extends StatefulWidget {
  const AddNewOrg({super.key});

  @override
  State<AddNewOrg> createState() => _AddNewOrgState();
}

class _AddNewOrgState extends State<AddNewOrg> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          backgroundColor: backgroundColor,
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
      body: Text('placeholder add org page'),
    );
  }
}