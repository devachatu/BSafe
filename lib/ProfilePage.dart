// import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:login_ui/Constants.dart';
import 'package:login_ui/ProfileListUi.dart';
import 'package:login_ui/services/AuthenticationService.dart';
import 'package:login_ui/services/DatabaseService.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'home.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = " ";
  String email = " ";

  getDetails() async {
    await DatabaseService(uid: auth.FirebaseAuth.instance.currentUser.uid)
        .getName()
        .then((value) {
      name = value;
    });
    await DatabaseService(uid: auth.FirebaseAuth.instance.currentUser.uid)
        .getEmail()
        .then((value) {
      email = value;
    });
    setState(() {});
  }

  @override
  void initState() {
    getDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, height: 896, width: 414, allowFontScaling: true);

    var profileInfo = Expanded(
      child: Column(
        children: <Widget>[
          Container(
            height: kSpacingUnit.w * 30,
            width: kSpacingUnit.w * 30,
            margin: EdgeInsets.only(top: kSpacingUnit.w * 3),
            child: Stack(
              children: <Widget>[
                CircleAvatar(
                  radius: kSpacingUnit.w * 15,
                  // backgroundColor: Colors.brown.shade800,
                  child: Text(
                    'CS',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 100,
                      color: Colors.black,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    height: kSpacingUnit.w * 2.5,
                    width: kSpacingUnit.w * 2.5,
                    decoration: BoxDecoration(
                      color: Theme.of(context).accentColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      heightFactor: kSpacingUnit.w * 1.5,
                      widthFactor: kSpacingUnit.w * 1.5,
                      child: Icon(
                        LineAwesomeIcons.pen,
                        color: kDarkPrimaryColor,
                        size: ScreenUtil().setSp(kSpacingUnit.w * 1.5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: kSpacingUnit.w * 2),
          Text(
            name != null ? name : "",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black,
              fontFamily: 'Montserrat',
            ),
          ),
          SizedBox(height: kSpacingUnit.w * 0.5),
          Text(
            email != null ? email : "",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: Colors.black,
              fontFamily: 'Montserrat',
            ),
          ),
          SizedBox(height: kSpacingUnit.w * 4),
          Divider(
            thickness: 2,
          ),
          ListTile(
            leading: Icon(Icons.power_settings_new),
            onTap: () {
              Provider.of<AuthenticationService>(context, listen: false)
                  .signOut();
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Home()));
            },
            title: Text("LogOut",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: 20,
                  // color: Colors.black,
                  fontFamily: 'Montserrat',
                )),
          ),
          Divider(
            thickness: 2,
          ),
          SizedBox(height: kSpacingUnit.w * 10),
          Text(
            "SE Project\n\nDeva Chaitanya\nKaran\nVersion 1",
            textAlign: TextAlign.center,
          )
        ],
      ),
    );

    var header = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(width: kSpacingUnit.w * 3),
        Icon(
          LineAwesomeIcons.arrow_left,
          size: ScreenUtil().setSp(kSpacingUnit.w * 3),
        ),
        profileInfo,
        // themeSwitcher,
        SizedBox(width: kSpacingUnit.w * 3),
      ],
    );

    return Builder(
      builder: (context) {
        return Scaffold(
          body: Column(
            children: <Widget>[
              SizedBox(height: kSpacingUnit.w * 5),
              header,
            ],
          ),
        );
      },
    );
  }
}
