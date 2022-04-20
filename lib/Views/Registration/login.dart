import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kinetik/Constants/app_colors.dart';
import 'package:kinetik/Constants/validators.dart';
import 'package:kinetik/Services/authentication.dart';

import '../Widgets/error_dialog.dart';

enum AuthFormType { signUp, signIn, reset }

class LoginView extends StatefulWidget {
  final AuthFormType authFormType;

  const LoginView({Key? key, required this.authFormType}) : super(key: key);
  @override
  _LoginViewState createState() =>
      // ignore: no_logic_in_create_state
      _LoginViewState(authFormType: authFormType);
}

class _LoginViewState extends State<LoginView> {
  AuthFormType authFormType;
  _LoginViewState({required this.authFormType});

  final formKey = GlobalKey<FormState>();
  String? _email, _password, _name, _warning;
  bool isLoading = false;
  bool showPassword = false;

  void switchFormState(String state) {
    formKey.currentState!.reset();
    if (state == 'signUp') {
      setState(() {
        authFormType = AuthFormType.signUp;
      });
    } else if (state == 'signIn') {
      setState(() {
        authFormType = AuthFormType.signIn;
      });
    } else if (state == 'homeController') {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  bool validate() {
    final form = formKey.currentState;

    form!.save();
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  void submit() async {
    if (validate()) {
      try {
        switch (authFormType) {
          case AuthFormType.signUp:
            setState(() {
              isLoading = true;
            });

            await AuthService().createUserWithEmailAndPassword(
                _email!.trim(), _password!, _name!.trim());
            Navigator.of(context).pushReplacementNamed('/home');
            break;
          case AuthFormType.signIn:
            setState(() {
              isLoading = true;
            });
            await AuthService()
                .signInWithEmailAndPassword(_email!.trim(), _password!);
            Navigator.of(context).pushReplacementNamed('/home');
            break;
          case AuthFormType.reset:
            await AuthService().sendPasswordResetEmail(_email!.trim());
            showDialog(
                context: context,
                builder: (BuildContext context) => ErrorDialog(
                    message: 'A password reset link has been sent to $_email'));

            setState(() {
              authFormType = AuthFormType.signIn;
            });
            break;
        }
      } on FirebaseAuthException catch (error) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }

        _warning = error.message;
        showDialog(
            context: context,
            builder: (BuildContext context) => ErrorDialog(message: _warning!));
      }
    }
  }

  signInWithGoogle() async {
    setState(() => isLoading = true);
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? account = await _googleSignIn.signIn();

    final result =
        await _firebaseAuth.fetchSignInMethodsForEmail(account!.email);
    if (!result.contains('password')) {
      try {
        final GoogleSignInAuthentication _googleAuth =
            await account.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
            idToken: _googleAuth.idToken, accessToken: _googleAuth.accessToken);
        await _firebaseAuth.signInWithCredential(credential);
        Navigator.pushReplacementNamed(context, '/home');
      } catch (error) {
        setState(() => isLoading = false);
        showDialog(
            context: context,
            builder: (BuildContext context) =>
                const ErrorDialog(message: 'Google sign in failed'));
      }
    } else {
      setState(() => isLoading = false);
      showDialog(
          context: context,
          builder: (BuildContext context) =>
              const ErrorDialog(message: 'Email already in use'));
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: SingleChildScrollView(
          child: GestureDetector(
            onTap: () {
              SystemChannels.textInput.invokeMethod('TextInput.hide');
            },
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Image.asset(
                    'assets/logo.png',
                    width: size.width * 0.5,
                  ),

                  Text(
                    authFormType == AuthFormType.reset
                        ? 'RESET PASSWORD'
                        : authFormType == AuthFormType.signIn
                            ? 'WELCOME BACK'
                            : 'CREATE NEW ACCOUNT',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: fontColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: formKey,
                    child: Column(
                      children: buildInputs(size) + buildButtons(size, false),
                    ),
                  ),
                  //Spacer(),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: buildButtons(size, true)),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  List<Widget> buildInputs(Size size) {
    List<Widget> textFields = [];

    // If we're in the Reset Password state, only Email field will be displayed
    if (authFormType == AuthFormType.reset) {
      textFields.add(
        Container(
          width: size.width * 0.7,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: TextFormField(
            keyboardType: TextInputType.emailAddress,
            obscureText: false,
            cursorColor: darkRedColor,
            textAlign: TextAlign.start,
            style: const TextStyle(color: darkRedColor, fontSize: 16),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.all(8),
              hintText: 'Email',
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(
                  color: darkRedColor,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(
                  color: borderColor,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(
                  color: borderColor,
                ),
              ),
            ),
            validator: EmailValidator.validate,
            onSaved: (val) {
              _email = val!.trim();
            },
          ),
        ),
      );

      return textFields;
    }
    // For SignUp state only, add Name field
    if ([
      AuthFormType.signUp,
    ].contains(authFormType)) {
      textFields.add(Container(
        width: size.width * 0.7,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: TextFormField(
          obscureText: false,
          cursorColor: darkRedColor,
          textAlign: TextAlign.start,
          style: const TextStyle(color: darkRedColor, fontSize: 16),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.all(8),
            hintText: 'Name',
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(
                color: darkRedColor,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(
                color: Color(0xff7251a0),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(
                color: Color(0xff7251a0),
              ),
            ),
          ),
          validator: NameValidator.validate,
          onSaved: (val) {
            _name = val!.trim();
          },
        ),
      ));
    }
    // For SignIn & SignUp states, add Email & Password fields
    textFields.add(Container(
      width: size.width * 0.7,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        obscureText: false,
        cursorColor: darkRedColor,
        textAlign: TextAlign.start,
        style: const TextStyle(color: darkRedColor, fontSize: 16),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.all(8),
          hintText: 'Email',
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(
              color: darkRedColor,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(
              color: borderColor,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(
              color: borderColor,
            ),
          ),
        ),
        validator: EmailValidator.validate,
        onSaved: (val) {
          _email = val!.trim();
        },
      ),
    ));

    textFields.add(Container(
      width: size.width * 0.7,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        obscureText: !showPassword,
        cursorColor: darkRedColor,
        textAlign: TextAlign.start,
        style: const TextStyle(color: darkRedColor, fontSize: 16),
        decoration: InputDecoration(
          suffixStyle: TextStyle(
              color: showPassword ? borderColor : lightRedColor, fontSize: 12),
          suffix: GestureDetector(
              onTap: () {
                setState(() {
                  showPassword = !showPassword;
                });
              },
              child: Text(showPassword ? 'Hide' : 'Show')),
          isDense: true,
          contentPadding: const EdgeInsets.all(8),
          hintText: 'Password',
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(
              color: borderColor,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(
              color: borderColor,
            ),
          ),
        ),
        validator: PasswordValidator.validate,
        onSaved: (val) {
          _password = val!.trim();
        },
      ),
    ));

    return textFields;
  }

  List<Widget> buildButtons(Size size, bool isCreateNewButtonOnly) {
    String _switchButtonText = '', _newFormState = '', _submitButtonText = '';
    bool _showForgotPassword = false;
    bool _showSocial = true;

    if (authFormType == AuthFormType.signIn) {
      _switchButtonText = 'Don\'t have an account? Sign up';
      _newFormState = 'signUp';
      _submitButtonText = 'Sign in';
      _showForgotPassword = true;
    } else if (authFormType == AuthFormType.signUp) {
      _switchButtonText = 'Already a user? Sign in';
      _newFormState = 'signIn';
      _submitButtonText = 'Sign up';
      _showSocial = false;
    } else if (authFormType == AuthFormType.reset) {
      _switchButtonText = 'Back';
      _newFormState = 'signIn';
      _submitButtonText = 'Submit';
      _showSocial = false;
    }
    if (!isCreateNewButtonOnly) {
      return [
        Padding(
          padding: EdgeInsets.only(
              bottom: 5, top: authFormType == AuthFormType.reset ? 40 : 10),
          child: InkWell(
            onTap: submit,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              height: 40,
              width: size.width * 0.7,
              child: Center(
                child: Text(
                  _submitButtonText,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: showForgotPassword(size, _showForgotPassword),
        ),
        authFormType == AuthFormType.reset
            ? const SizedBox(height: 80)
            : const SizedBox(height: 10),
        buildSocialIcons(size, _showSocial),
      ];
    } else {
      return [
        Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: GestureDetector(
            onTap: () {
              switchFormState(_newFormState);
            },
            child: Text(
              _switchButtonText,
              style: const TextStyle(
                decoration: TextDecoration.underline,
                color: fontColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ];
    }
  }

  Widget showForgotPassword(Size size, bool visible) {
    return Visibility(
      child: GestureDetector(
        onTap: () {
          setState(() {
            authFormType = AuthFormType.reset;
          });
        },
        child: SizedBox(
          width: size.width * .7,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: const [
              Text(
                'Forgot password?',
                style: TextStyle(
                    fontSize: 12,
                    color: greyColor,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
      visible: visible,
    );
  }

  Widget buildSocialIcons(Size size, bool visible) {
    return Visibility(
      child: Column(
        children: <Widget>[
          const Text(
            'OR',
            style: TextStyle(
                fontSize: 14, color: fontColor, fontWeight: FontWeight.w700),
          ),
          Divider(
            indent: size.width * .15,
            endIndent: size.width * .15,
            height: 30,
            thickness: 1,
          ),
          SizedBox(
            width: size.width * .7,
            child: SignInButton(
              Buttons.GoogleDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              //mini: true,
              onPressed: signInWithGoogle,
            ),
          ),
        ],
      ),
      visible: visible,
    );
  }
}
