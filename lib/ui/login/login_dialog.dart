import 'dart:math';

import 'package:boba_explorer/ui/boba_map_page/boba_map.dart';
import 'package:boba_explorer/ui/login/login_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class LoginDialog extends StatefulWidget {
  @override
  _LoginDialogState createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog>
    with SingleTickerProviderStateMixin {
  AnimationController _dialogAnimController;
  LoginBloc loginBloc;

  @override
  void initState() {
    super.initState();
    loginBloc = Provider.of<LoginBloc>(context, listen: false);
    _dialogAnimController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    _dialogAnimController.forward();
  }

  @override
  void dispose() {
    _dialogAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    double screenWidth = mediaQuery.size.width;
    double widthMargin = screenWidth * 0.04 / 2;
    double screenHeight = mediaQuery.size.height;
    double heightMargin = screenHeight * 0.52 / 2;
    return WillPopScope(
      onWillPop: () async {
        await _dialogAnimController.reverse();
        return true;
      },
      child: ScaleTransition(
        scale: Tween(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _dialogAnimController,
            curve: Curves.fastOutSlowIn,
          ),
        ),
        child: Container(
          alignment: Alignment.topCenter,
          margin: EdgeInsets.symmetric(
              horizontal: widthMargin, vertical: heightMargin),
          child: Dialog(
            insetAnimationDuration: Duration(milliseconds: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 0, 8),
                  child: StreamBuilder<FirebaseUser>(
                    stream: loginBloc.currentUser,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.none) {
                        return Center(child: CircularProgressIndicator());
                      }
                      final currentUser = snapshot.data;
                      String title;
                      if (currentUser == null) {
                        title = "歡迎！\n您可以透過以下方式登入";
                      } else if (currentUser.isAnonymous) {
                        title = "哈囉, 訪客！您可以連結社群帳號以同步資料至雲端";
                      } else {
                        title = "哈囉！${currentUser.displayName ?? ""}，需要什麼服務嗎？";
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    title,
                                    style: Theme.of(context).textTheme.subhead,
                                  ),
                                ),
                                InkWell(
                                  onTap: () async {
                                    await _dialogAnimController.reverse();
                                    Navigator.pop(context);
                                  },
                                  child: Icon(Icons.close),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                    height: 1, color: Colors.grey.shade200),
                              ),
                              SizedBox(width: 25),
                              _buildQuestionBtn(),
                            ],
                          ),
                          SizedBox(height: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                //_buildQuestionBtn(),
                                //SizedBox(height: 12),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        _buildFbLoginBtn(currentUser),
                                        _buildGoogleLoginBtn(currentUser),
                                        if (currentUser == null)
                                          _buildGuestLoginBtn()
                                        else
                                          _buildLogoutBtn(currentUser),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (currentUser == null)
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
                                        style: Theme.of(context)
                                            .textTheme
                                            .caption),
                                  ],
                                ),
                              ),
                            )
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionBtn() {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        return showDialog(
          context: context,
          builder: (context) => _SuggestionDialog(),
        );
      },
      child: Stack(
        fit: StackFit.passthrough,
        children: <Widget>[
          Container(
            alignment: Alignment.centerRight,
            child: Container(
              width: 40,
              height: 35,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(12),
                ),
              ),
              child: Icon(FontAwesomeIcons.questionCircle),
            ),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            width: 1,
            child: Container(color: Colors.white),
          )
        ],
      ),
    );
  }

  Widget _buildFbLoginBtn(FirebaseUser user) {
    const Color fbBlue = Color.fromARGB(255, 66, 103, 178);
    String text = user == null ? "使用 Facebook 帳號登入" : "以 Facebook 帳號繼續";
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
                  text,
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

  Widget _buildGoogleLoginBtn(FirebaseUser user) {
    const Color googleBlue = Color.fromARGB(255, 66, 133, 244);
    String text = user == null ? "使用 Google 帳號登入" : "以 Google 帳號繼續";
    return InkWell(
      onTap: () async {
        final googleUser = await loginBloc.googleLogin();
        if (user?.isAnonymous == true) {
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => _buildSyncDataDialog());
          //TODO:Call and await sync data function, then dismiss dialog
          Navigator.pop(context);
        }
        Navigator.pop(context, googleUser);
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
                text,
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
      onTap: () async {
        final user = await loginBloc.guestLogin();
        Navigator.pop(context, user);
      },
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

  Widget _buildLogoutBtn(FirebaseUser currentUser) {
    return OutlineButton.icon(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      borderSide: BorderSide(color: Colors.redAccent.shade100),
      onPressed: () async {
        if (currentUser?.isAnonymous == true) {
          showDialog(
            context: context,
            builder: (context) => _buildClearDataRequestDialog(),
          );
          return;
        }
        Navigator.pop(context);
        await loginBloc.logout();
      },
      icon: Icon(FontAwesomeIcons.signOutAlt),
      label: Text("登出"),
    );
  }

  Widget _buildSyncDataDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        child: Column(
          children: <Widget>[
            Text("雲端資料同步中..."),
            SizedBox(height: 12),
            //TODO: Syncing data animation
            Placeholder(),
          ],
        ),
      ),
    );
  }

  Widget _buildClearDataRequestDialog() {
    return AlertDialog(
      title: Text('清除訪客資料'),
      content: Text("請問是否要清除店家收藏紀錄？"),
      actions: <Widget>[
        FlatButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text("不登出"),
        ),
        FlatButton(
          onPressed: () async {
            await loginBloc.logout();
            Navigator.popUntil(context, ModalRoute.withName(BobaMap.routeName));
          },
          child: Text("否"),
        ),
        FlatButton(
          onPressed: () async {
            await loginBloc.deleteAllFavoriteShops();
            await loginBloc.logout();
            Navigator.popUntil(context, ModalRoute.withName(BobaMap.routeName));
          },
          child: Text("是"),
        ),
      ],
    );
  }
}

class _SuggestionDialog extends StatefulWidget {
  @override
  _SuggestionDialogState createState() => _SuggestionDialogState();
}

class _SuggestionDialogState extends State<_SuggestionDialog> {
  ValueNotifier<_SuggestionType> suggestionTypeNotifier;
  ValueNotifier<String> shopNameNotifier;

  @override
  void initState() {
    super.initState();
    suggestionTypeNotifier = ValueNotifier(null);
    shopNameNotifier = ValueNotifier(null);
  }

  @override
  void dispose() {
    suggestionTypeNotifier.dispose();
    shopNameNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: LayoutBuilder(
        builder: (context, constraint) {
          return Container(
            height: min(screenHeight * 0.58, constraint.maxHeight),
            child: ListView(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(12),
                  //height: constraint.maxHeight * 0.5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          InkWell(
                            onTap: () {},
                            child: Icon(Icons.arrow_back),
                          ),
                          SizedBox(width: 12),
                          Text(
                            "我有話要說 ( ～'ω')～",
                            style: Theme.of(context).textTheme.title,
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        "問題類型",
                        style: Theme.of(context).textTheme.subtitle,
                      ),
                      SizedBox(height: 4),
                      Container(
                        height: 40,
                        decoration: ShapeDecoration(
                          color: Colors.grey.shade100,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: ValueListenableBuilder<_SuggestionType>(
                            valueListenable: suggestionTypeNotifier,
                            builder: (context, suggestionType, child) {
                              return DropdownButton<_SuggestionType>(
                                hint: Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Text("請選擇問題類型"),
                                ),
                                value: suggestionType,
                                items: _SuggestionType.values.map((option) {
                                  String text;
                                  switch (option) {
                                    case _SuggestionType.bugReport:
                                      text = "Bug 回報";
                                      break;
                                    case _SuggestionType.wish:
                                      text = "許願新增店家 / 功能";
                                      break;
                                    case _SuggestionType.opinion:
                                      text = "提供意見、建議";
                                      break;
                                  }
                                  return DropdownMenuItem(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Text(text),
                                    ),
                                    value: option,
                                  );
                                }).toList(),
                                onChanged: (value) =>
                                    suggestionTypeNotifier.value = value,
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      ValueListenableBuilder<_SuggestionType>(
                        valueListenable: suggestionTypeNotifier,
                        builder: (context, suggestionType, child) {
                          if (suggestionType == null) {
                            return Container();
                          }
                          return IndexedStack(
                            sizing: StackFit.passthrough,
                            index:
                                _SuggestionType.values.indexOf(suggestionType),
                            children: <Widget>[
                              _buildBugReportContent(),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBugReportContent() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("錯誤簡述"),
          SizedBox(height: 4),
          TextFormField(
            decoration: InputDecoration(
              hintText: "請輸入您遇到的問題",
              helperText: "ex: App 閃退？哪個功能、畫面出錯？",
            ),
          ),
        ],
      ),
    );
  }
}

enum _SuggestionType { bugReport, wish, opinion }
