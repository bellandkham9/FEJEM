
import 'dart:io';
import 'package:adminfejem/interface/admin/Post/post_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';  // Used to generate unique IDs
import '../../../constants.dart';
import '../../../theme_Provider.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _descriptionController = QuillController.basic();
  final FirebaseStorage storage =
  FirebaseStorage.instanceFor(bucket: "gs://fejemproject.appspot.com");
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  final _formKey = GlobalKey<FormState>();

  late String postId;
  late Map<String, dynamic> postInfo = {};

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        print("Selected image: $_imageFile");
      });
    }
  }

  Future<String> uploadImageToStorage(String postId, File imageFile) async {
    try {
      Reference ref = storage.ref().child('postImages').child(postId);
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }


  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);
    final uiProvider = Provider.of<UiProvider>(context);
    String? imgUrl = postInfo['imgUrl'];

    return Scaffold(
      backgroundColor:
      uiProvider.isDark ? uiProvider.darkTheme.primaryColorDark : Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      backgroundColor: secondaryColor,
                      radius: 50,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : imgUrl != null && imgUrl.isNotEmpty
                          ? NetworkImage(imgUrl) as ImageProvider
                          : null,
                      child: _imageFile == null &&
                          (imgUrl == null || imgUrl.isEmpty)
                          ? const Text(
                        'P',
                        style: TextStyle(
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
                        icon: const Icon(Icons.camera_alt, color: Colors.black),
                        onPressed: () {
                          _pickImage(ImageSource.gallery);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: "Title",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  fillColor: Colors.grey.withOpacity(0.1),
                  filled: true,
                  prefixIcon: const Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _subtitleController,
                decoration: InputDecoration(
                  hintText: "Subtitle",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  fillColor: Colors.grey.withOpacity(0.1),
                  filled: true,
                  prefixIcon: const Icon(Icons.subtitles),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a subtitle';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              QuillToolbar.simple(
                  configurations: QuillSimpleToolbarConfigurations(
                      controller: _descriptionController,
                      headerStyleType: HeaderStyleType.buttons,
                      sharedConfigurations:
                      const QuillSharedConfigurations(
                          locale: Locale('de')))),
              const SizedBox(height: 16.0),
              QuillEditor.basic(
                  configurations: QuillEditorConfigurations(
                      placeholder: "Details here",
                      controller: _descriptionController,
                      checkBoxReadOnly: false,
                      sharedConfigurations:
                      const QuillSharedConfigurations(locale: Locale('de')))),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (_imageFile == null) {
                      // Show alert dialog if no image is selected
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Missing Image"),
                          content: const Text("Please select an image before saving the post."),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("OK"),
                            ),
                          ],
                        ),
                      );
                      return;
                    }
                    postId = const Uuid().v4(); // Generate unique post ID

                    postInfo = {
                      'title': _titleController.text,
                      'subtitle': _subtitleController.text,
                     // 'description': _descriptionController.document.toPlainText(),
                      'description':_descriptionController.document.toDelta().toJson(), // Save as JSON
                    };

                    if (_imageFile != null) {
                      String imageUrl =
                      await uploadImageToStorage(postId, _imageFile!);
                      if (imageUrl.isNotEmpty) {
                        postInfo['imgUrl'] = imageUrl;
                        print("Uploaded image URL: $imageUrl");
                      }
                    }

                    try {
                      await postProvider.createPost(postId, postInfo);
                      setState(() {
                        postInfo['title'] = _titleController.text;
                        postInfo['subtitle'] = _subtitleController.text;
                        //postInfo['description'] = _descriptionController.document.toPlainText();
                        postInfo['description']=_descriptionController.document.toDelta().toJson();
                        if (_imageFile != null) {
                          postInfo['imgUrl'] = postInfo['imgUrl']!;
                        }
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Post published successfully')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error saving post: $e')),
                      );
                    }
                  }
                },
                child: const Text(
                  'Add new Post',
                  style: TextStyle(fontSize: 18, color: primaryColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
