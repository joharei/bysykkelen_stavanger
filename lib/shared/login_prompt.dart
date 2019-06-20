import 'package:flutter/material.dart';

class UsernameAndPassword {
  final String userName;
  final String password;

  UsernameAndPassword(this.userName, this.password);
}

Future<UsernameAndPassword> promptForUsernameAndPassword(
  BuildContext context,
) async {
  String userName;
  String password;
  return showDialog(
      context: context,
      builder: (context) {
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
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context)
                    .pop(UsernameAndPassword(userName, password));
              },
            ),
          ],
        );
      });
}
