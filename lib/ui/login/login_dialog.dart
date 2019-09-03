import 'package:boba_explorer/ui/login/login_bloc.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class LoginDialog extends StatefulWidget {
  @override
  _LoginDialogState createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog>
    with SingleTickerProviderStateMixin {
  AnimationController _animController;
  LoginBloc loginBloc;

  @override
  void initState() {
    super.initState();
    loginBloc = Provider.of<LoginBloc>(context, listen: false);
    _animController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double widthMargin = screenWidth * 0.08 / 2;
    double screenHeight = MediaQuery.of(context).size.height;
    double heightMargin = screenHeight * 0.58 / 2;

    return ScaleTransition(
      scale: Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animController,
          curve: Curves.fastOutSlowIn,
        ),
      ),
      child: Container(
        margin: EdgeInsets.symmetric(
            horizontal: widthMargin, vertical: heightMargin),
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      "請選擇登入方式",
                      style: Theme.of(context).textTheme.subhead,
                    ),
                    Spacer(),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close),
                    ),
                  ],
                ),
                Divider(endIndent: 36),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      _buildFbLoginBtn(),
                      _buildGoogleLoginBtn(),
                      _buildGuestLoginBtn(),
                    ],
                  ),
                ),
                Center(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        WidgetSpan(
                          alignment: PlaceholderAlignment.top,
                          child: Icon(
                            Icons.warning,
                            size: 16,
                            color: Colors.black54,
                          ),
                        ),
                        TextSpan(
                            text: " 訪客模式無法將資料保存於雲端",
                            style: Theme.of(context).textTheme.caption),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFbLoginBtn() {
    const Color fbBlue = Color.fromARGB(255, 66, 103, 178);
    return InkWell(
      onTap: () async {
        final user = await loginBloc.facebookLogin();
        Navigator.pop(context, user);
      },
      child: Container(
        height: 42,
        decoration: ShapeDecoration(
          color: fbBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: InkWell(
          child: Row(
            children: <Widget>[
              SizedBox(width: 8),
              Icon(
                FontAwesomeIcons.facebookSquare,
                color: Colors.white,
                size: 26,
              ),
              Expanded(
                child: Text(
                  "使用 Facebook 帳號登入",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleLoginBtn() {
    const Color googleBlue = Color.fromARGB(255, 66, 133, 244);
    return InkWell(
      onTap: () async {
        final user = await loginBloc.googleLogin();
        Navigator.pop(context, user);
      },
      child: Container(
        height: 42,
        decoration: ShapeDecoration(
          color: googleBlue,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: googleBlue),
          ),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 40,
              height: double.infinity,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(),
              ),
              child: Center(
                child: Image.asset(
                  "assets/images/icon_google_48.png",
                  width: 20,
                  height: 20,
                ),
              ),
            ),
            Expanded(
              child: Text(
                "使用 Google 帳號登入",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestLoginBtn() {
    return InkWell(
      onTap: () => loginBloc.guestLogin(),
      child: Container(
        padding: const EdgeInsets.only(left: 12),
        height: 40,
        decoration: ShapeDecoration(
          color: Colors.grey.shade300,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          overflow: Overflow.clip,
          children: <Widget>[
            Positioned(
              left: 0,
              right: 0,
              top: -14,
              bottom: -3,
              child: FittedBox(
                child: Icon(
                  FontAwesomeIcons.userSecret,
                  color: Colors.grey.withOpacity(0.45),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                alignment: Alignment(0, 0.3),
                child: Text(
                  "使用訪客身份登入",
                  style: TextStyle(
                    letterSpacing: 0.4,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
