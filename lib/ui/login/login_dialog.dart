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
    _animController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    loginBloc = Provider.of<LoginBloc>(context, listen: false);
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
    double widthMargin = screenWidth * 0.0 / 2;
    double screenHeight = MediaQuery.of(context).size.height;
    double heightMargin = screenHeight * 0.6 / 2;

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
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.centerRight,
                  child: CloseButton(),
                ),
                Text("請選擇任一種登入方式"),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(FontAwesomeIcons.facebook),
                      onPressed: () => loginBloc.facebookLogin(),
                    ),
                    IconButton(
                      icon: Icon(FontAwesomeIcons.google),
                      onPressed: () => loginBloc.googleLogin(),
                    ),
                    IconButton(
                      icon: Icon(FontAwesomeIcons.userSecret),
                      onPressed: () {},
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
