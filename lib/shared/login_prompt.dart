import 'package:flutter/material.dart';

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
    return AlertDialog(
      title: Text('Log in'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            autofocus: true,
            decoration: InputDecoration(labelText: 'User name'),
            autocorrect: false,
            onChanged: (value) {
              userName = value;
            },
          ),
          TextField(
            decoration: InputDecoration(labelText: 'Password'),
            autocorrect: false,
            obscureText: true,
            onChanged: (value) {
              password = value;
            },
          ),
          CheckboxListTile(
            title: Text('Remember?'),
            controlAffinity: ListTileControlAffinity.leading,
            value: saveCredentials,
            onChanged: (value) => setState(() {
                  saveCredentials = value;
                }),
          ),
        ],
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('Ok'),
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
