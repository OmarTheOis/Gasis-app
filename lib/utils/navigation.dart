import 'package:flutter/material.dart';

import '../features/auth/Screens/login_screen.dart';
import '../features/auth/Screens/onboarding.dart';
import '../features/auth/Screens/otpverfication_screen.dart';
import '../features/auth/Screens/register_screen.dart';
import '../features/auth/Screens/splash_screen.dart';




class Navigations {
 static Map<String, Widget Function(BuildContext)> routes = {
    SplashScreen.pageRouteName : (context)=> SplashScreen(),
    OnboardingScreen.pageRouteName : (context)=>OnboardingScreen(),
    LoginScreen.pageRouteName : (context)=> LoginScreen(),
    RegisterScreen.pageRouteName : (context)=> RegisterScreen(),
    OtpVerificationScreen.pageRouteName : (context)=>OtpVerificationScreen()


  };






}