import 'package:avandra/screens/edit_profile.dart';
import 'package:avandra/widgets/basic_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../utils/fonts.dart';
import '../utils/colors.dart';
import '../utils/global.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

enum MenuAction { logout }

// TickerProviderStateMixin is to allow the tabContoller to work
class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  final double coverHeight = 150;
  final double profileHeight = 100;
  String username = "Jane Doe";

  // TODO: connect the pins and organizations to user's stored ones
  List<String> pins = [
    "Physics Class",
    "Global Christianity",
    "Circuits",
    "English class",
    "FYE",
    "Engineering Statistics"
  ];
  List<String> organizations = [
    "California Baptist University",
    "University of California Riverside",
    "Riverside Public Library",
    "University of California Irvine",
  ];
  TabController? _tabController;
  ScrollController? _scrollController;

  // initState() must be included to activate the controllers
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: buttonColor,
        elevation: 1,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pushNamed('/Menu');
          },
        ),
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogoutDialog(context);
                  if (shouldLogout) {
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('/Login', (route) => false);
                  }
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                    value: MenuAction.logout, child: Text('Logout'))
              ];
            },
          )
        ],
      ),
      body: ListView(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: <Widget>[
          // FIXME: for some reason, the cover image is low down on the page
          buildTop(),
          Divider(height: 15),
          buildContent(),
          Padding(
              padding: const EdgeInsets.only(top: 20),
              child: BasicButton(
                  text: "Add New Organization",
                  onPressed: () async {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        '/addNewOrg', (route) => false);
                  })),

          // TODO: figure out the right height for this thing
          Divider(height: coverHeight),
          buildBottom(),
        ],
      ),
    );
  }

  /* this widget creates the top background of the profile page */
  Widget buildTop() {
    return Center(
        // Stack lets you overlap things
        child: Stack(
      clipBehavior: Clip.none,
      alignment: AlignmentDirectional.center,

      // all widgets in children will be overlapped because they're in the
      // Stack Widget
      children: [
        // this creates the backgroundImage
        Positioned(
          top: 0,
          bottom: -20,
          child: Container(
            child: buildCoverImage(Alignment.center, coverHeight),
          ),
        ),

        // this creates the profile image
        // Positioned(
        //   // top: 0,
        //   child:
        Container(
          alignment: AlignmentDirectional.center,
          child: buildProfileImage(),
        ),
        // ),

        // this text button creates a route to the edit profile page
        Positioned(
          // setting top and right to 0 positions the button to the top right
          top: 0,
          right: 0,
          child: Container(
            alignment: AlignmentDirectional.topEnd,
            child: TextButton(
              style: TextButton.styleFrom(
                  textStyle: const TextStyle(
                      fontSize: regularTextSize, color: buttonColor)),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => EditProfilePage(),
                ));
              },
              child: const Text("Edit Profile",
                  style: TextStyle(
                    color: Colors.white,
                  )),
            ),
          ),
        ),
      ],
    ));
  }

  /* this widget creates the profile name, city, and saved pins */
  Widget buildContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Divider(height: 10),
        Text(
          // this will need to be updated from the edit profile page
          username,
          style: TextStyle(fontSize: titleSize, color: regularTextSizeColor),
        ),
        const SizedBox(height: 8),
        Text(
          'San Francisco',
          style: TextStyle(fontSize: titleSize, color: regularTextSizeColor),
        ),

        Align(
            alignment: Alignment.centerLeft,
            child: TabBar(
              controller: _tabController,
              indicatorColor: darkerNavigationColor,
              tabs: [
                Tab(
                    child: Text("My Pins",
                        style: TextStyle(
                          fontSize: regularTextSize,
                          color: regularTextSizeColor,
                        ))),
                Tab(
                    child: Text("My Organizations",
                        style: TextStyle(
                          fontSize: regularTextSize,
                          color: regularTextSizeColor,
                        ))),
              ],
            )),

// TODO: once pins and organizations are set up, sync them here
        Container(
          padding: const EdgeInsets.only(left: 20),
          height: regularTextSize + 3,
          child: TabBarView(
            controller: _tabController,
            clipBehavior: Clip.hardEdge,
            children: [
              // this will hold all the saved pins
              Expanded(
                  child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      controller: _scrollController,
                      shrinkWrap: true,
                      itemCount: pins.length,
                      separatorBuilder: (BuildContext context, int index) {
                        return VerticalDivider(
                          width: 15.0,
                          // color: darkerNavigationColor,
                          // thickness: 2.0,
                        );
                      },
                      // ignore: non_constant_identifier_names
                      itemBuilder: (BuildContext context, int index) {
                        return Text(pins[index],
                            style: TextStyle(
                              fontSize: regularTextSize,
                              color: regularTextSizeColor,
                            ));
                      })),

              // this holds all the organizations
              Expanded(
                  child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: false,
                      controller: _scrollController,
                      itemCount: organizations.length,
                      separatorBuilder: (BuildContext context, int index) {
                        return VerticalDivider(
                          width: 15.0,
                        );
                      },
                      // ignore: non_constant_identifier_names
                      itemBuilder: (BuildContext context, int index) {
                        return Text(organizations[index],
                            overflow: TextOverflow.visible,
                            style: TextStyle(
                              fontSize: regularTextSize,
                              color: regularTextSizeColor,
                            ));
                      })),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildBottom() {
    return Container(
      child: buildCoverImage(Alignment.bottomCenter, coverHeight),
    );
  }

  /* this widget build the cover image */
  Widget buildCoverImage(Alignment pos, double givenHeight) => Container(
      color: backgroundColor,
      alignment: pos,
      child: Container(
        height: givenHeight,
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("lib/assets/images/cover_image.png"),
            fit: BoxFit.fitWidth,
          ),
        ),
      ));

  /* this widget builds the profile iamge */
  Widget buildProfileImage() => CircleAvatar(
        radius: profileHeight / 2,
        backgroundColor: Colors.white,
        backgroundImage:
            AssetImage("lib/assets/images/influencer_profile_pic.jpeg"),
      );
}

Future<bool> showLogoutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Log out'),
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}
