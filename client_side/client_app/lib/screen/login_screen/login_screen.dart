import 'package:client_app/utility/extensions.dart';
import '../../utility/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import '../home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      messages: LoginMessages(
        userHint: 'Email / Username',
        passwordHint: 'Password',
      ),
      loginAfterSignUp: true, // Auto-login after signup
      logo: const AssetImage('assets/images/logo.png'),
      onLogin: (LoginData loginData) => context.userProvider.login(loginData),
      onSignup: (SignupData data) async {
        return await context.userProvider.register(data);
      },
      additionalSignupFields: [
        UserFormField(
          keyName: 'name',
          displayName: 'Full Name',
          icon: Icon(Icons.person),
        ),
      ],
      onSubmitAnimationCompleted: () {
        if (context.userProvider.getLoginUsr()?.sId != null) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) {
              return const HomeScreen();
            },
          ));
        } else {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) {
              return const LoginScreen();
            },
          ));
        }
      },
      onRecoverPassword: (String email) async {
        return await context.userProvider.recoverPassword(email);
      },
      hideForgotPasswordButton: false,
      theme: LoginTheme(
          primaryColor: AppColor.darkGrey,
          accentColor: AppColor.darkOrange,
          buttonTheme: const LoginButtonTheme(
            backgroundColor: AppColor.darkOrange,
          ),
          cardTheme: const CardTheme(
              color: Colors.white, surfaceTintColor: Colors.white),
          titleStyle: const TextStyle(color: Colors.black)),
    );
  }
}
