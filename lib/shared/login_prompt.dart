import 'package:bysykkelen_stavanger/shared/localization/localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UsernameAndPassword {
  final String userName;
  final String password;
  final bool saveCredentials;

  UsernameAndPassword(this.userName, this.password, this.saveCredentials);
}

Future<UsernameAndPassword> promptForUsernameAndPassword(
  BuildContext context,
) async {
  return showDialog(
    context: context,
    builder: (context) {
      return PromptForUserNameAndPassword();
    },
  );
}

class PromptForUserNameAndPassword extends StatefulWidget {
  @override
  _PromptForUserNameAndPasswordState createState() =>
      _PromptForUserNameAndPasswordState();
}

class _PromptForUserNameAndPasswordState
    extends State<PromptForUserNameAndPassword> {
  String userName;
  String password;
  bool saveCredentials = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final TextStyle infoTextStyle = themeData.textTheme.body2;
    final TextStyle linkStyle =
        themeData.textTheme.body2.copyWith(color: themeData.accentColor);
    final localization = Localization.of(context);

    return AlertDialog(
      title: Text(localization.logIn),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            autofocus: true,
            decoration:
                InputDecoration(labelText: localization.userName),
            autocorrect: false,
            onChanged: (value) {
              userName = value;
            },
          ),
          TextField(
            decoration:
                InputDecoration(labelText: localization.password),
            autocorrect: false,
            obscureText: true,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              password = value;
            },
          ),
          CheckboxListTile(
            title: Text(localization.remember),
            controlAffinity: ListTileControlAffinity.leading,
            value: saveCredentials,
            onChanged: (value) => setState(() {
                  saveCredentials = value;
                }),
          ),
          Padding(padding: EdgeInsets.only(top: 8)),
          RichText(
            text: TextSpan(children: [
              TextSpan(
                style: infoTextStyle,
                text: localization.createUserInfo,
              ),
              _LinkTextSpan(
                style: linkStyle,
                text: 'bysykkelen.no',
                url: 'https://my.bysykkelen.no/nb/account/register',
              ),
              TextSpan(
                style: infoTextStyle,
                text: '.',
              )
            ]),
          ),
        ],
      ),
      actions: [
        FlatButton(
          child: Text(localization.ok),
          onPressed: () {
            Navigator.of(context).pop(UsernameAndPassword(
              userName,
              password,
              saveCredentials,
            ));
          },
        ),
      ],
    );
  }
}

class _LinkTextSpan extends TextSpan {
  _LinkTextSpan({
    TextStyle style,
    @required String url,
    String text,
  }) : super(
          style: style,
          text: text ?? url,
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              launch(url, forceSafariVC: false);
            },
        );
}
