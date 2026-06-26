import 'package:client_app/utility/extensions.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
        userHint: 'Email',
        passwordHint: 'Password',
        signupButton: 'SIGN UP',
        confirmSignupIntro:
            'A verification code has been sent to your email. Enter it below to finish.',
        confirmationCodeHint: 'Email code',
        resendCodeButton: 'Resend code',
        confirmSignupSuccess: 'Email verified!',
      ),
      loginAfterSignUp: false, // we verify the email OTP before logging in
      logo: const AssetImage('assets/images/logo.png'),
      onLogin: (LoginData loginData) => context.userProvider.login(loginData),
      // Signup sends an email OTP; the confirm step verifies it and logs in.
      onSignup: (SignupData data) async {
        final name = (data.additionalSignupData?['name'] ?? '').toString();
        return await context.userProvider
            .requestEmailOtp(email: data.name ?? '', name: name);
      },
      onConfirmSignup: (String code, LoginData data) async {
        return await context.userProvider
            .verifyEmailOtp(email: data.name, code: code);
      },
      onResendCode: (SignupData data) async {
        return await context.userProvider.requestEmailOtp(email: data.name ?? '');
      },
      additionalSignupFields: [
        UserFormField(
          keyName: 'name',
          displayName: 'Full Name',
          icon: const Icon(Icons.person),
        ),
      ],
      // "Continue with Google" button.
      loginProviders: [
        LoginProvider(
          icon: FontAwesomeIcons.google,
          label: 'Continue with Google',
          callback: () async {
            return await context.userProvider.signInWithGoogle();
          },
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
