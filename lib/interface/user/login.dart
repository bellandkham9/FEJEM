/*
import 'package:adminfejem/constants.dart';
import 'package:adminfejem/interface/Home/homeNews.dart';
import 'package:adminfejem/interface/user/signup.dart';
import 'package:adminfejem/theme_Provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../../Home.dart';
import '../../service/auth.dart';
import 'forgot_password.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String email = "", password = "";
  TextEditingController mailcontroller = new TextEditingController();
  TextEditingController passwordcontroller = new TextEditingController();

  final FirebaseAuth auth = FirebaseAuth.instance;
  bool _obscureText = true;

  final _formkey = GlobalKey<FormState>();

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserInfo(
      String? email) async {
    final userCollection = FirebaseFirestore.instance.collection('User');
    try {
      final userDoc =
          await userCollection.where('email', isEqualTo: email).get();
      return userDoc.docs.first;
    } catch (error) {
      print("Error fetching user info: $error");
      // Handle the error appropriately (e.g., show a snackbar to the user)
      return Future.error(error); // Or return a null DocumentSnapshot
    }
  }

  userLogin() async {
    if (_formkey.currentState!.validate()) {
      try {
        email = mailcontroller.text
            .trim(); // Trim to remove leading/trailing whitespaces
        password = passwordcontroller.text.trim();

        if (email.isNotEmpty && password.isNotEmpty) {
          await FirebaseAuth.instance
              .signInWithEmailAndPassword(email: email, password: password);
          final userDoc = await getUserInfo(auth.currentUser!.email);
          if (userDoc.exists) {
            final userData = userDoc.data()!;
            final userName =
                userData['name'] ?? ""; // Handle potential missing field
            final userImgUrl =
                userData['imgUrl'] ?? ""; // Handle potential missing field
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => NewsScreen(
                    userInfo: {
                      "email": auth.currentUser!.email,
                      "name": userName,
                      "imgUrl": userImgUrl
                    },
                  ),
                ));
          } else {
            print("No data found for this user");
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "Email or Password cannot be empty",
              style: TextStyle(fontSize: 18.0),
            ),
          ));
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "No User Found for that Email",
              style: TextStyle(fontSize: 18.0),
            ),
          ));
        } else if (e.code == 'wrong-password') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "Wrong Password Provided by User",
              style: TextStyle(fontSize: 18.0),
            ),
          ));
        }
      }
    }
  }

  Future<Map<String, dynamic>> getCurrentUserInfo() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    User? currentUser = auth.currentUser;

    if (currentUser == null) {
      throw Exception('No user is currently signed in.');
    }

    try {
      DocumentSnapshot userDoc =
          await firestore.collection('User').doc(currentUser.uid).get();

      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      } else {
        throw Exception('User document does not exist in Firestore.');
      }
    } catch (e) {
      throw Exception('Error getting user info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final uiProvider = Provider.of<UiProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: uiProvider.isDark ? uiProvider.darkTheme.primaryColorDark:Colors.white,
        body: SingleChildScrollView(
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 70,
                  ),
                  _header(context),
                  _inputField(context),
                  _forgotPassword(context),
                  _signup(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _header(context) {
    return const Column(
      children: [
        Text(
          "Welcome Back",
          style: TextStyle(
              fontSize: 40, fontWeight: FontWeight.bold, color: secondaryColor),
        ),
        Text("Enter your credential to login",
            style: TextStyle(fontSize: 15, color: Colors.grey)),
        SizedBox(
          height: 70,
        )
      ],
    );
  }

  _inputField(context) {
    final uiProvider = Provider.of<UiProvider>(context);
    return Form(
      key: _formkey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please Enter mail';
              }
              return null;
            },
            controller: mailcontroller,
            decoration: InputDecoration(
                hintText: "Mail",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none),
                fillColor: uiProvider.isDark ?  Colors.grey.withOpacity(0.4):Colors.grey.withOpacity(0.1),
                filled: true,
                prefixIcon: const Icon(Icons.mail)),
          ),
          const SizedBox(height: 20),
          TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please Enter Password';
              }
              return null;
            },
            controller: passwordcontroller,
            decoration: InputDecoration(
              hintText: "Password",
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none),
              fillColor: uiProvider.isDark ?  Colors.grey.withOpacity(0.4):Colors.grey.withOpacity(0.1),
              filled: true,
              prefixIcon: const Icon(Icons.password),
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
                child: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                ),
              ),
            ),
            obscureText: _obscureText,
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              if (_formkey.currentState!.validate()) {
                setState(() {
                  email = mailcontroller.text;
                  password = passwordcontroller.text;
                });
              }
              userLogin();
            },
            child: ElevatedButton(
              onPressed: () {
                userLogin();
              },
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: primaryColor,
              ),
              child: const Text(
                "Login",
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.grey,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 1,
                        offset:
                            const Offset(0, 1), // changes position of shadow
                      ),
                    ],
                  ),
                  child: TextButton(
                    onPressed: () {
                      Future<Map<String, dynamic>> UserInfos =
                          AuthMethods().signInWithGoogle(context);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 30.0,
                          width: 30.0,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage('assets/images/google.png'),
                                fit: BoxFit.cover),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 18),
                        const Text(
                          "Sign In with Google",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _forgotPassword(context) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ForgotPassword()),
        );
      },
      child: const Text(
        "Forgot password?",
        style: TextStyle(color: primaryColor),
      ),
    );
  }

  _signup(context) {
    final uiProvider = Provider.of<UiProvider>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Dont have an account? ",style: TextStyle(color: uiProvider.isDark ? Colors.white: Colors.grey),),
        TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SignupPage()),
              );
            },
            child: const Text(
              "Sign Up",
              style: TextStyle(color: primaryColor),
            ))
      ],
    );
  }
}
*/


import 'package:adminfejem/constants.dart';
import 'package:adminfejem/interface/Home/homeNews.dart';
import 'package:adminfejem/interface/user/signup.dart';
import 'package:adminfejem/theme_Provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../../Home.dart';
import '../../service/auth.dart';
import 'forgot_password.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _mailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _obscureText = true;
  final _formKey = GlobalKey<FormState>();

  Future<DocumentSnapshot<Map<String, dynamic>>> _getUserInfo(String? email) async {
    final userCollection = FirebaseFirestore.instance.collection('User');
    try {
      final userDoc = await userCollection.where('email', isEqualTo: email).get();
      return userDoc.docs.first;
    } catch (error) {
      print("Error fetching user info: $error");
      return Future.error(error);
    }
  }

  Future<void> _userLogin() async {
    if (_formKey.currentState!.validate()) {
      try {
        final email = _mailController.text.trim();
        final password = _passwordController.text.trim();

        if (email.isNotEmpty && password.isNotEmpty) {
          await _auth.signInWithEmailAndPassword(email: email, password: password);
          final userDoc = await _getUserInfo(_auth.currentUser!.email);
          if (userDoc.exists) {
            final userData = userDoc.data()!;
            final userName = userData['name'] ?? "";
            final userImgUrl = userData['imgUrl'] ?? "";
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => NewsScreen(
                  userInfo: {
                    "email": _auth.currentUser!.email,
                    "name": userName,
                    "imgUrl": userImgUrl
                  },
                ),
              ),
            );
          } else {
            print("No data found for this user");
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "Email or Password cannot be empty",
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "No User Found for that Email",
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          );
        } else if (e.code == 'wrong-password') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "Wrong Password Provided by User",
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final uiProvider = Provider.of<UiProvider>(context);
    return Scaffold(
      backgroundColor: uiProvider.isDark ? uiProvider.darkTheme.primaryColorDark : Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 70),
                _header(context),
                _inputField(context),
                _forgotPassword(context),
                _signup(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return const Column(
      children: [
        Text(
          "Welcome Back",
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: secondaryColor,
          ),
        ),
        Text(
          "Enter your credential to login",
          style: TextStyle(fontSize: 15, color: Colors.grey),
        ),
        SizedBox(height: 70),
      ],
    );
  }

  Widget _inputField(BuildContext context) {
    final uiProvider = Provider.of<UiProvider>(context);
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please Enter mail';
              }
              return null;
            },
            controller: _mailController,
            decoration: InputDecoration(
              hintText: "Mail",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              fillColor: uiProvider.isDark ? Colors.grey.withOpacity(0.4) : Colors.grey.withOpacity(0.1),
              filled: true,
              prefixIcon: const Icon(Icons.mail),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please Enter Password';
              }
              return null;
            },
            controller: _passwordController,
            decoration: InputDecoration(
              hintText: "Password",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              fillColor: uiProvider.isDark ? Colors.grey.withOpacity(0.4) : Colors.grey.withOpacity(0.1),
              filled: true,
              prefixIcon: const Icon(Icons.password),
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
                child: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                ),
              ),
            ),
            obscureText: _obscureText,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _userLogin,
            style: ElevatedButton.styleFrom(
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: primaryColor,
            ),
            child: const Text(
              "Login",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          _googleSignInButton(context),
        ],
      ),
    );
  }

  Widget _googleSignInButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        AuthMethods().signInWithGoogle(context);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 45,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.grey),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 1,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 30.0,
                  width: 30.0,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/google.png'),
                      fit: BoxFit.cover,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 18),
                const Text(
                  "Sign In with Google",
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _forgotPassword(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ForgotPassword()),
        );
      },
      child: const Text(
        "Forgot password?",
        style: TextStyle(color: primaryColor),
      ),
    );
  }

  Widget _signup(BuildContext context) {
    final uiProvider = Provider.of<UiProvider>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(color: uiProvider.isDark ? Colors.white : Colors.grey),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SignupPage()),
            );
          },
          child: const Text(
            "Sign Up",
            style: TextStyle(color: primaryColor),
          ),
        ),
      ],
    );
  }
}
