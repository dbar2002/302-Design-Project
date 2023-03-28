import 'package:avandra/utils/colors.dart';
import 'package:avandra/widgets/input_box.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/fonts.dart';

class SearchBar extends StatefulWidget {
  final TextEditingController searchController;
  const SearchBar({
    Key? key,
    required this.searchController,
  }) : super(key: key);

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  bool isShowOrganizations = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: backgroundColor,
          title: Form(
            child: TextFormField(
              style: GoogleFonts.montserrat(
                fontSize: regularTextSize,
                color: regularTextSizeColor,
              ),
              controller: widget.searchController,
              decoration: InputDecoration(
                hintStyle: GoogleFonts.montserrat(
                  fontSize: regularTextSize,
                  color: smallerTextColor,
                ),
                hintText: 'Organization',
              ),
              onFieldSubmitted: (String _) {
                setState(() {
                  isShowOrganizations = true;
                });
                print(_);
              },
            ),
          ),
        ),
        body: isShowOrganizations
            ? FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('organizations')
                    .where(
                      'name',
                      isGreaterThanOrEqualTo: widget.searchController.text,
                    )
                    .get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: (snapshot.data! as dynamic).docs.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () => setState(() {
                          
                        }),
                        child: Text(
                          (snapshot.data! as dynamic).docs[index]['name'],
                          style: GoogleFonts.montserrat(
                            fontSize: regularTextSize,
                            color: regularTextSizeColor,
                          ),
                        ),
                      );
                    },
                  );
                },
              )
            : FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('Organizations')
                    .get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return StaggeredGridView.countBuilder(
                    crossAxisCount: 3,
                    itemCount: (snapshot.data! as dynamic).docs.length,
                    itemBuilder: (context, index) => Image.network(
                      (snapshot.data! as dynamic).docs[index]['postUrl'],
                      fit: BoxFit.cover,
                    ),
                    staggeredTileBuilder: (index) => MediaQuery.of(context)
                                .size
                                .width >
                            290
                        ? StaggeredTile.count(
                            (index % 7 == 0) ? 1 : 1, (index % 7 == 0) ? 1 : 1)
                        : StaggeredTile.count(
                            (index % 7 == 0) ? 2 : 1, (index % 7 == 0) ? 2 : 1),
                    mainAxisSpacing: 8.0,
                    crossAxisSpacing: 8.0,
                  );
                }));
  }
}
