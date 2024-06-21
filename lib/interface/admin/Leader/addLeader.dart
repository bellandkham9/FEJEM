
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../service/database.dart';
import '../../../theme_Provider.dart';

class AddLeader extends StatefulWidget {
  const AddLeader({super.key});

  @override
  State<AddLeader> createState() => _AddLeaderState();
}

class _AddLeaderState extends State<AddLeader> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController mailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _obscureText = true;


  final _formKey = GlobalKey<FormState>();

  Future<void> registrationLeader() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: mailController.text,
          password: passwordController.text,
        );

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
          "isLeader": true,
          "id": userCredential.user!.uid,
        };

        // Ajouter l'utilisateur à Firestore
        await DatabaseMethods().addUser(userCredential.user!.uid, userInfoMap);

      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "Password Provided is too Weak",
              style: TextStyle(fontSize: 18.0),
            ),
          ));
        } else if (e.code == "email-already-in-use") {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "Account Already exists",
              style: TextStyle(fontSize: 18.0),
            ),
          ));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final uiProvider = Provider.of<UiProvider>(context);
    return SafeArea(
      child: Scaffold(
         backgroundColor: uiProvider.isDark ? uiProvider.darkTheme.primaryColorDark:Colors.white,
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: const Text("Add Leader",style: TextStyle(color: Colors.white),),
          elevation: 5,
        ),
        body:SingleChildScrollView(child: Center(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30,),
                SizedBox(
                  width: 80,
                  height: 80,
                  child: uiProvider.isDark ?Image.asset("assets/images/leader_gris.png"): Image.asset("assets/images/leader.png"),
                ),
                const SizedBox(height: 50),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        child: TextFormField(
                          controller: usernameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter something';
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
                                prefixIcon: const Icon(Icons.account_circle))
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        child: TextFormField(
                          controller: mailController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter something';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                              hintText: "Mail",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: BorderSide.none),
                              fillColor: uiProvider.isDark ?  Colors.grey.withOpacity(0.4):Colors.grey.withOpacity(0.1),
                              filled: true,
                              prefixIcon: const Icon(Icons.mail)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        child: TextFormField(
                          controller: passwordController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter something';
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
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        child: TextFormField(
                          controller: confirmPasswordController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter password again';
                            }
                            if (value != passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                              hintText: "Password again",
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
                            ),),
                          obscureText: _obscureText,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.all(20),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                registrationLeader();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                            ),
                            child: const Text(
                              "Save Leader",
                              style: TextStyle(fontSize:18,color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}