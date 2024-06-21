/*
import 'package:adminfejem/constants.dart';
import 'package:adminfejem/interface/Home/homeNews.dart';
import 'package:adminfejem/interface/user/login.dart';
import 'package:adminfejem/theme_Provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Home.dart';
import '../../service/database.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  String email = "", password = "", name = "";
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController mailController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  registration() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
            email: mailController.text, password: passwordController.text);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "Registered Successfully",
            style: TextStyle(fontSize: 20.0),
          ),
        ));

        Map<String, dynamic> userInfoMap = {
          "email": userCredential.user!.email,
          "imgUrl": userCredential.user!.photoURL,
          "name": usernameController.text,
          "isLeader": false,
          "id": userCredential.user!.uid
        };

        // Ajouter l'utilisateur à Firestore
        await DatabaseMethods()
            .addUser(userCredential.user!.uid, userInfoMap)
            .then((value) {

        });

        // Naviguer vers la page suivante
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewsScreen(
              userInfo: {
                "email": mailController.text,
                "name": usernameController.text,
                "imgUrl": null,
              },
            ),
          ),
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "Password Provided is too Weak",
                style: TextStyle(fontSize: 18.0),
              )));
        } else if (e.code == "email-already-in-use") {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "Account Already exists",
                style: TextStyle(fontSize: 18.0),
              )));
        }
      }
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
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            height: MediaQuery.of(context).size.height - 50,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    const SizedBox(height: 60.0),
                    const Text(
                      "Sign Up",
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: secondaryColor),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Create your account",
                      style: TextStyle(fontSize: 15, color: uiProvider.isDark ? Colors.white: Colors.grey[700]),
                    )
                  ],
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: usernameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter username';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            hintText: "Username",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none),
                            fillColor: uiProvider.isDark ?  Colors.grey.withOpacity(0.4):Colors.grey.withOpacity(0.1),
                            filled: true,
                            prefixIcon: const Icon(Icons.person)),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: mailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter email';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            hintText: "Email",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none),
                            fillColor: uiProvider.isDark ?  Colors.grey.withOpacity(0.4):Colors.grey.withOpacity(0.1),
                            filled: true,
                            prefixIcon: const Icon(Icons.email)),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: passwordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter Password';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "Password",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none),
                          fillColor: uiProvider.isDark ?  Colors.grey.withOpacity(0.4):Colors.grey.withOpacity(0.1),
                          filled: true,
                          prefixIcon: const Icon(Icons.fingerprint),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter Password again';
                          }
                          if (value != passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "Confirm Password",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none),
                          fillColor: uiProvider.isDark ?  Colors.grey.withOpacity(0.4):Colors.grey.withOpacity(0.1),
                          filled: true,
                          prefixIcon: const Icon(Icons.fingerprint),
                        ),
                        obscureText: true,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 3, left: 3),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          email = mailController.text;
                          name = usernameController.text;
                          password = passwordController.text;
                        });
                        registration();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: primaryColor,
                    ),
                    child: const Text(
                      "Sign up",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
                Center(child: Text("Or",style: TextStyle(color: uiProvider.isDark ?  Colors.white: Colors.grey.withOpacity(0.2),),)),
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
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: TextButton(
                    onPressed: () {},
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Already have an account?",style: TextStyle(color: uiProvider.isDark ?  Colors.white:Colors.grey.withOpacity(0.2),),),
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>  LoginPage()),
                          );
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(color: primaryColor),
                        ))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
*/

import 'package:adminfejem/constants.dart';
import 'package:adminfejem/interface/user/login.dart';
import 'package:adminfejem/theme_Provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Home.dart';
import '../../service/auth.dart';
import '../../service/database.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  String email = "", password = "", name = "";
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController mailController = TextEditingController();
  bool _obscureText = true;

  final _formKey = GlobalKey<FormState>();

  registration() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
            email: mailController.text, password: passwordController.text);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "Registered Successfully",
            style: TextStyle(fontSize: 20.0),
          ),
        ));

        Map<String, dynamic> userInfoMap = {
          "email": userCredential.user!.email,
          "imgUrl": userCredential.user!.photoURL,
          "name": usernameController.text,
          "isLeader": false,
          "id": userCredential.user!.uid
        };

        // Ajouter l'utilisateur à Firestore
        await DatabaseMethods()
            .addUser(userCredential.user!.uid, userInfoMap)
            .then((value) {});

        // Naviguer vers la page suivante
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewsScreen(
              userInfo: {
                "email": mailController.text,
                "name": usernameController.text,
                "imgUrl": null,
              },
            ),
          ),
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "Password Provided is too Weak",
                style: TextStyle(fontSize: 18.0),
              )));
        } else if (e.code == "email-already-in-use") {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "Account Already exists",
                style: TextStyle(fontSize: 18.0),
              )));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final uiProvider = Provider.of<UiProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor:
        uiProvider.isDark ? uiProvider.darkTheme.primaryColorDark : Colors.white,
        body: OrientationBuilder(
          builder: (context, orientation) {
            return SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                height: MediaQuery.of(context).size.height - 50,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        const SizedBox(height: 60.0),
                        const Text(
                          "Sign Up",
                          style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: secondaryColor),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Create your account",
                          style: TextStyle(
                              fontSize: 15,
                              color: uiProvider.isDark
                                  ? Colors.white
                                  : Colors.grey[700]),
                        )
                      ],
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            controller: usernameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please Enter username';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                hintText: "Username",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide.none),
                                fillColor: uiProvider.isDark
                                    ? Colors.grey.withOpacity(0.4)
                                    : Colors.grey.withOpacity(0.1),
                                filled: true,
                                prefixIcon: const Icon(Icons.person)),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: mailController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please Enter email';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                hintText: "Email",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide.none),
                                fillColor: uiProvider.isDark
                                    ? Colors.grey.withOpacity(0.4)
                                    : Colors.grey.withOpacity(0.1),
                                filled: true,
                                prefixIcon: const Icon(Icons.email)),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: passwordController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please Enter Password';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: "Password",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: BorderSide.none),
                              fillColor: uiProvider.isDark
                                  ? Colors.grey.withOpacity(0.4)
                                  : Colors.grey.withOpacity(0.1),
                              filled: true,
                              prefixIcon: const Icon(Icons.fingerprint),
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
                          TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please Enter Password again';
                              }
                              if (value != passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: "Confirm Password",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: BorderSide.none),
                              fillColor: uiProvider.isDark
                                  ? Colors.grey.withOpacity(0.4)
                                  : Colors.grey.withOpacity(0.1),
                              filled: true,
                              prefixIcon: const Icon(Icons.fingerprint),
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
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 3, left: 3),
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              email = mailController.text;
                              name = usernameController.text;
                              password = passwordController.text;
                            });
                            registration();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: primaryColor,
                        ),
                        child: const Text(
                          "Sign up",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        "Or",
                        style: TextStyle(
                          color: uiProvider.isDark
                              ? Colors.white
                              : Colors.grey.withOpacity(0.2),
                        ),
                      ),
                    ),
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
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: TextButton(
                          onPressed: () {
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Already have an account?",
                          style: TextStyle(
                            color: uiProvider.isDark
                                ? Colors.white
                                : Colors.grey.withOpacity(0.4),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginPage()),
                            );
                          },
                          child: const Text(
                            "Login",
                            style: TextStyle(color: primaryColor),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
