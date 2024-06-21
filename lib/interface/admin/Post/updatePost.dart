import 'dart:convert';
import 'dart:io';
import 'package:adminfejem/interface/admin/Post/post_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import '../../../theme_Provider.dart';

class UpdatePostScreen extends StatefulWidget {
  final String postId;
  final Map<String, dynamic> initialData;

  const UpdatePostScreen({
    Key? key,
    required this.postId,
    required this.initialData,
  }) : super(key: key);

  @override
  _UpdatePostScreenState createState() => _UpdatePostScreenState();
}

class _UpdatePostScreenState extends State<UpdatePostScreen> {
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  late QuillController _descriptionController;

  final FirebaseStorage storage = FirebaseStorage.instanceFor(bucket: "gs://fejemproject.appspot.com");
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.initialData['title'] ?? '';
    _subtitleController.text = widget.initialData['subtitle'] ?? '';

    _descriptionController =
        QuillController(document: Document.fromJson(widget.initialData['description']),// "\n" is mandatory
          selection: const TextSelection.collapsed(offset: 0),
        );

    /*if (widget.initialData['description'] is String) {
      try {

        final descriptionJson = jsonDecode(widget.initialData['description']);
        _descriptionController = QuillController(
          document: Document.fromJson(descriptionJson),
          selection: const TextSelection.collapsed(offset: 0),
        );
        print("le update lààà vraiment"+descriptionJson);
      } catch (e) {
        _descriptionController = QuillController(
          document: Document(),
          selection: const TextSelection.collapsed(offset: 0),
        );
      }
    } else {
      _descriptionController = QuillController(
        document: Document(),
        selection: const TextSelection.collapsed(offset: 0),
      );
    }*/

    _getInitialImageUrl();
  }

  Future<void> _getInitialImageUrl() async {
    if (widget.initialData['imgPost'] != null) {
      String imgUrl = widget.initialData['imgPost'];
      setState(() {
        _imageFile = File(imgUrl);
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
  Widget build(BuildContext context) {
    final uiProvider = Provider.of<UiProvider>(context);
    String? imgUrl = widget.initialData['imgPost'];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update a Post'),
      ),
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
                          ? NetworkImage(imgUrl!) as ImageProvider
                          : null,
                      child: _imageFile == null &&
                          (imgUrl == null || imgUrl.isEmpty)
                          ? const Text(
                        "P",
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
                decoration: const InputDecoration(labelText: 'Titre'),
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
                decoration: const InputDecoration(labelText: 'Sous-titre'),
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
                    sharedConfigurations: const QuillSharedConfigurations(locale: Locale('de')),
                  )),
              const SizedBox(height: 16.0),
              QuillEditor.basic(
                  configurations: QuillEditorConfigurations(
                    placeholder: "Details here",
                    controller: _descriptionController,
                    checkBoxReadOnly: false,
                    sharedConfigurations: const QuillSharedConfigurations(locale: Locale('de')),
                  )),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    var postInfo = {
                      'title': _titleController.text,
                      'subtitle': _subtitleController.text,
                      'description': _descriptionController.document.toDelta().toJson(),
                    };

                    if (_imageFile != null) {
                      String imageUrl = await uploadImageToStorage(widget.postId, _imageFile!);
                      print("voici l'image imageUrl: "+imageUrl);
                      if (imageUrl.isNotEmpty) {
                        postInfo['imgPost'] = imageUrl;
                      }
                      else{
                        postInfo['imgPost']=widget.initialData['imgPost'];
                      }
                    }

                    try {
                      await PostProvider().updatePost(widget.postId, postInfo);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Post updated successfully')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error updating post: $e')),
                      );
                    }
                  }
                },
                child: Text(
                  'Update Post',
                  style: TextStyle(
                    fontSize: 18,
                    color: uiProvider.isDark ? Colors.grey : Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        print("Affiche image picked: $_imageFile");
      });
    }
  }
}
