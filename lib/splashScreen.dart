import 'package:adminfejem/constants.dart';
import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:page_transition/page_transition.dart';

import 'StartPage.dart';
 // Assurez-vous de créer cette page

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: 'assets/images/logo.png', // Assurez-vous de placer votre logo dans assets
      nextScreen: const StartPage(), // Remplacez par la page de destination après le splash
      splashTransition: SplashTransition.scaleTransition,
      pageTransitionType: PageTransitionType.bottomToTop,
      backgroundColor: primaryColor, // Couleur primaire, modifiez selon votre besoin
      duration: 8000, // Durée de l'animation en millisecondes
    );
  }
}
