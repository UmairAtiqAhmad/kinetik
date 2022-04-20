import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kinetik/Models/kinetik_user.dart';
import 'package:kinetik/Services/authentication.dart';
import 'package:kinetik/Views/Homepage/homepage.dart';
import 'package:kinetik/Views/Registration/login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<KinetikUser?>(
        stream: AuthService().onAuthStateChanged,
        builder: (context, snapshot) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Kinetik',
            theme: ThemeData(primarySwatch: Colors.red, fontFamily: 'Poppins'),
            home: snapshot.hasData && snapshot.data!.email!.isNotEmpty
                ? const Homepage()
                : const LoginView(
                    authFormType: AuthFormType.signIn,
                  ),
            routes: <String, WidgetBuilder>{
              '/signUp': (BuildContext context) => const LoginView(
                    authFormType: AuthFormType.signUp,
                  ),
              '/signIn': (BuildContext context) => const LoginView(
                    authFormType: AuthFormType.signIn,
                  ),
              '/home': (BuildContext context) => const Homepage(),
            },
          );
        });
  }
}
