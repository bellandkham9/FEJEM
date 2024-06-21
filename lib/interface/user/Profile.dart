/*
import 'dart:io';
import 'package:adminfejem/theme_Provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../service/auth.dart';

class Profile extends StatefulWidget {
  final Map<String, dynamic> userInfo;
  const Profile({super.key, required this.userInfo});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;
  File? _imageFile;


  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        print("Affiche image picked: $_imageFile");
      });
    }
  }


  @override
  void initState() {
    super.initState();
    _nameController.text = widget.userInfo['name'] ?? '';
    _emailController.text = widget.userInfo['email'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    String? imgUrl = widget.userInfo['imgUrl'];
    String email = widget.userInfo['email'] ?? "";
    String displayName = widget.userInfo['name']?.toString() ?? "User";
    String initialLetter = email.isNotEmpty ? email[0].toUpperCase() : "";

    final uiProvider = Provider.of<UiProvider>(context);

    return Scaffold(
      backgroundColor: uiProvider.isDark ? uiProvider.darkTheme.primaryColorDark:Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text("Edit Profile",style: TextStyle(color: Colors.white),),
        elevation: 5,
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.dark_mode),
                  title: const Text("Dark mode"),
                  trailing: Switch(
                    value: uiProvider.isDark,
                    onChanged: (value) => uiProvider.changeTheme(value),
                  ),
                ),
                const SizedBox(
                  height: 30.0,
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              backgroundColor: secondaryColor,
                              radius: 35,
                              backgroundImage: _imageFile != null
                                  ? FileImage(_imageFile!)
                                  : imgUrl != null && imgUrl.isNotEmpty
                                  ? NetworkImage(imgUrl)
                                  : null,
                              child: _imageFile == null &&
                                  (imgUrl == null || imgUrl.isEmpty)
                                  ? Text(
                                initialLetter,
                                style: const TextStyle(
                                  fontSize: 22,
                                  color: Colors.white,
                                ),
                              )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: IconButton(
                                icon: const Icon(Icons.edit, color: Colors.white),
                                onPressed: () {
                                  _pickImage(ImageSource.gallery);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.5,
                        padding: const EdgeInsetsDirectional.all(8.0),
                        child: Column(
                          children: [
                            Text(
                              displayName,
                              style:  TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold, color: uiProvider.isDark ? Colors.grey: Colors.grey.withOpacity(0.3)),
                            ),
                            Text(email,style: TextStyle(color: uiProvider.isDark ? Colors.grey: Colors.grey.withOpacity(0.3)),)
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter your Name';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            hintText: "Name",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none),
                            fillColor: uiProvider.isDark ? Colors.grey.withOpacity(0.5):Colors.grey.withOpacity(0.3),
                            filled: true,
                            prefixIcon: const Icon(Icons.account_circle)),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter your mail';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            hintText: "mail",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none),
                            fillColor: uiProvider.isDark ? Colors.grey.withOpacity(0.5):Colors.grey.withOpacity(0.3),
                            filled: true,
                            prefixIcon: const Icon(Icons.mail)),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                // Get updated user information
                                 var updatedUserInfo = {
                                  'name': _nameController.text,
                                  'email': _emailController.text,
                                };

                                // Update user information in Firestore
                                if (_imageFile != null) {
                                  String imageUrl = await AuthMethods().uploadImageToStorage(auth.currentUser!.uid, _imageFile!);
                                  if (imageUrl.isNotEmpty) {
                                    updatedUserInfo['imgUrl'] = imageUrl;
                                    print("L'url  image upload: $imageUrl");
                                  }
                                }

                                try {
                                  await AuthMethods().updateUser(auth.currentUser!.uid, updatedUserInfo);
                                  setState(() {
                                    widget.userInfo['name'] = _nameController.text;
                                    widget.userInfo['email'] = _emailController.text;
                                    if (_imageFile != null) {
                                      widget.userInfo['imgUrl'] = updatedUserInfo['imgUrl'];
                                    }
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Profile updated')),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('Error updating profile: $e')),
                                  );
                                }
                              }
                            },
                            child: const Text(
                              'Save Update',
                              style: TextStyle(fontSize: 18, color: primaryColor),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Cancel',
                              style: TextStyle(fontSize: 18, color: secondaryColor),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
*/


import 'dart:io';
import 'package:adminfejem/theme_Provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../service/auth.dart';

class Profile extends StatefulWidget {
  final Map<String, dynamic> userInfo;
  const Profile({super.key, required this.userInfo});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.userInfo['name'] ?? '';
    _emailController.text = widget.userInfo['email'] ?? '';
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        print("Affiche image picked: $_imageFile");
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      var updatedUserInfo = {
        'name': _nameController.text,
        'email': _emailController.text,
      };

      if (_imageFile != null) {
        String imageUrl = await AuthMethods().uploadImageToStorage(auth.currentUser!.uid, _imageFile!);
        if (imageUrl.isNotEmpty) {
          updatedUserInfo['imgUrl'] = imageUrl;
        }
      }

      try {
        await AuthMethods().updateUser(auth.currentUser!.uid, updatedUserInfo);
        setState(() {
          widget.userInfo['name'] = _nameController.text;
          widget.userInfo['email'] = _emailController.text;
          if (_imageFile != null) {
            widget.userInfo['imgUrl'] = updatedUserInfo['imgUrl'];
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String? imgUrl = widget.userInfo['imgUrl'];
    String email = widget.userInfo['email'] ?? "";
    String displayName = widget.userInfo['name']?.toString() ?? "User";
    String initialLetter = email.isNotEmpty ? email[0].toUpperCase() : "";

    final uiProvider = Provider.of<UiProvider>(context);

    return Scaffold(
      backgroundColor: uiProvider.isDark ? uiProvider.darkTheme.primaryColorDark : Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.white),
        ),
        elevation: 5,
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.dark_mode),
                    title: const Text("Dark mode"),
                    trailing: Switch(
                      value: uiProvider.isDark,
                      onChanged: (value) => uiProvider.changeTheme(value),
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Center(
                          child: Stack(
                            children: [
                              CircleAvatar(
                                backgroundColor: secondaryColor,
                                radius: 35,
                                backgroundImage: _imageFile != null
                                    ? FileImage(_imageFile!)
                                    : imgUrl != null && imgUrl.isNotEmpty
                                    ? NetworkImage(imgUrl) as ImageProvider
                                    : null,
                                child: _imageFile == null &&
                                    (imgUrl == null || imgUrl.isEmpty)
                                    ? Text(
                                  initialLetter,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    color: Colors.white,
                                  ),
                                )
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.white),
                                  onPressed: () {
                                    _pickImage(ImageSource.gallery);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          padding: const EdgeInsetsDirectional.all(8.0),
                          child: Column(
                            children: [
                              Text(
                                displayName,
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: uiProvider.isDark
                                      ? Colors.grey
                                      : Colors.grey.withOpacity(0.3),
                                ),
                              ),
                              Text(
                                email,
                                style: TextStyle(
                                  color: uiProvider.isDark
                                      ? Colors.grey
                                      : Colors.grey.withOpacity(0.3),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _nameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter your Name';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: "Name",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                            fillColor: uiProvider.isDark
                                ? Colors.grey.withOpacity(0.5)
                                : Colors.grey.withOpacity(0.3),
                            filled: true,
                            prefixIcon: const Icon(Icons.account_circle),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _emailController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter your mail';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: "mail",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                            fillColor: uiProvider.isDark
                                ? Colors.grey.withOpacity(0.5)
                                : Colors.grey.withOpacity(0.3),
                            filled: true,
                            prefixIcon: const Icon(Icons.mail),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton(
                              onPressed: _updateProfile,
                              child: const Text(
                                'Save Update',
                                style: TextStyle(fontSize: 18, color: primaryColor),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Cancel',
                                style: TextStyle(fontSize: 18, color: secondaryColor),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
