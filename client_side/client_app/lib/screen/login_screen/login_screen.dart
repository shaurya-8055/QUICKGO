import 'package:client_app/utility/extensions.dart';
import '../../utility/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import '../home_screen.dart';
import 'otp_verification_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      messages: LoginMessages(
        userHint: 'Email / Username / Phone',
        passwordHint: 'Password',
      ),
      loginAfterSignUp: false,
      logo: const AssetImage('assets/images/logo.png'),
      onLogin: (LoginData loginData) => context.userProvider.login(loginData),
      onSignup: (SignupData data) async {
        final err = await context.userProvider.register(data);
        if (err == null && context.mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const OtpVerificationScreen()),
          );
        }
        return err;
      },
      additionalSignupFields: const [
        UserFormField(keyName: 'phone', displayName: 'Phone number'),
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
      // Use recover button as "Login via OTP" path
      onRecoverPassword: (String phone) async {
        final err = await context.userProvider.requestOtp(phone);
        if (err == null && context.mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (_) => OtpVerificationScreen(phone: phone)),
          );
        }
        return err;
      },
      hideForgotPasswordButton: true,
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
