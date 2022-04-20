import 'package:flutter/material.dart';
import 'package:kinetik/Constants/app_colors.dart';
import 'package:kinetik/Models/kinetik_user.dart';

import '../../Services/authentication.dart';

class Homepage extends StatelessWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.pink,
        leading: Container(),
        actions: [
          GestureDetector(
              onTap: () {
                AuthService().signOut();
                Navigator.of(context).pushReplacementNamed('/signIn');
              },
              child: Row(
                children: const [
                  Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Text('Logout'),
                  ),
                ],
              ))
        ],
      ),
      body: Center(
          child: StreamBuilder<KinetikUser?>(
              stream: AuthService().onAuthStateChanged,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    'Hello, ${snapshot.data!.email!}',
                    style: const TextStyle(color: fontColor),
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              })),
    );
  }
}
