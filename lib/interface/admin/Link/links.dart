/*

import 'package:adminfejem/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart'; // Ajout de l'importation pour UUID

import '../../../theme_Provider.dart';
import 'Link_Provider.dart'; // Assurez-vous que ce fichier existe et contient la classe LinkProvider avec la méthode AddLink

class AdminlinkScreen extends StatefulWidget {
  @override
  _AdminlinkScreenState createState() => _AdminlinkScreenState();
}

class _AdminlinkScreenState extends State<AdminlinkScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController urlController = TextEditingController();

  String title = '';
  String description = '';
  String imageUrl = '';
  late String linkId;
  late Map<String, dynamic> linkInfo = {};

  Future<void> fetchAndSetMetadata() async {
    if (urlController.text.isNotEmpty) {
      try {
        var metadata = await fetchLinkMetadata(urlController.text);
        setState(() {
          title = metadata['title']!;
          description = metadata['description']!;
          imageUrl = metadata['image']!;
        });
      } catch (e) {
        print('Failed to fetch metadata: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final uiProvider = Provider.of<UiProvider>(context);
    return Scaffold(
      backgroundColor: uiProvider.isDark ? uiProvider.darkTheme.primaryColorDark:Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.only(top: 50),
            child: Column(
              children: [
                TextFormField(
                  controller: urlController,
                  decoration: InputDecoration(
                    hintText: "URL",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none),
                    fillColor: uiProvider.isDark ?  Colors.grey.withOpacity(0.4):Colors.grey.withOpacity(0.1),
                    filled: true,
                    prefixIcon: const Icon(Icons.link),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a URL';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: fetchAndSetMetadata,
                  child: const Text('Fetch Metadata', style: TextStyle(color: secondaryColor),),
                ),
                const SizedBox(height: 20),
                if (title.isNotEmpty) Text('Title: $title'),
                if (description.isNotEmpty) Text('Description: $description'),
                if (imageUrl.isNotEmpty)
                  Image.network(imageUrl),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Générer un ID unique pour le lien
                      linkId = const Uuid().v4();

                      var linkInfo = {
                        'titre': title,
                        'description': description,
                        'imgLink': imageUrl,
                        'lien':urlController.text,
                      };

                      try {
                        await LinkProvider().addLink(linkId, linkInfo);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Link saved')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error when saved link: $e')),
                        );
                      }
                    }
                  },
                  child: const Text("Save Link", style: TextStyle(color: primaryColor),),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<Map<String, String>> fetchLinkMetadata(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var document = html.parse(response.body);
      String title = document.querySelector('title')?.text ?? 'No title';
      String description = document
          .querySelector('meta[name="description"]')
          ?.attributes['content'] ??
          'No description';
      String imageUrl = document
          .querySelector('meta[property="og:image"]')
          ?.attributes['content'] ??
          'No image';

      return {
        'title': title,
        'description': description,
        'image': imageUrl,
      };
    } else {
      throw Exception('Failed to load metadata');
    }
  }
}*/


import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../constants.dart';
import '../../../theme_Provider.dart';
import 'Link_Provider.dart';

class AdminlinkScreen extends StatefulWidget {
  @override
  _AdminlinkScreenState createState() => _AdminlinkScreenState();
}

class _AdminlinkScreenState extends State<AdminlinkScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController urlController = TextEditingController();

  String title = '';
  String description = '';
  String imageUrl = '';
  late String linkId;
  late Map<String, dynamic> linkInfo = {};

  Future<void> fetchAndSetMetadata() async {
    if (urlController.text.isNotEmpty) {
      try {
        var metadata = await fetchLinkMetadata(urlController.text);
        setState(() {
          title = metadata['title']!;
          description = metadata['description']!;
          imageUrl = metadata['image']!;
        });
      } catch (e) {
        print('Failed to fetch metadata: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch metadata')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final uiProvider = Provider.of<UiProvider>(context);
    return Scaffold(
      backgroundColor:
      uiProvider.isDark ? uiProvider.darkTheme.primaryColorDark : Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.only(top: 50),
            child: Column(
              children: [
                TextFormField(
                  controller: urlController,
                  decoration: InputDecoration(
                    hintText: "URL",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    fillColor: uiProvider.isDark
                        ? Colors.grey.withOpacity(0.4)
                        : Colors.grey.withOpacity(0.1),
                    filled: true,
                    prefixIcon: const Icon(Icons.link),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a URL';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: fetchAndSetMetadata,
                  child: const Text(
                    'Fetch Metadata',
                    style: TextStyle(color: secondaryColor),
                  ),
                ),
                const SizedBox(height: 20),
                if (title.isNotEmpty) Text('Title: $title'),
                if (description.isNotEmpty) Text('Description: $description'),
                if (imageUrl.isNotEmpty) Image.network(imageUrl),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      linkId = const Uuid().v4(); // Generate unique link ID

                      linkInfo = {
                        'titre': title,
                        'description': description,
                        'imgLink': imageUrl,
                        'lien': urlController.text,
                      };

                      try {
                        await LinkProvider().addLink(linkId, linkInfo);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Link saved')),
                        );
                      } catch (e) {
                        print('Error saving link: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Error saving link')),
                        );
                      }
                    }
                  },
                  child: const Text(
                    "Save Link",
                    style: TextStyle(color: primaryColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<Map<String, String>> fetchLinkMetadata(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var document = html.parse(response.body);
      String title = document.querySelector('title')?.text ?? 'No title';
      String description = document
          .querySelector('meta[name="description"]')
          ?.attributes['content'] ??
          'No description';
      String imageUrl = document
          .querySelector('meta[property="og:image"]')
          ?.attributes['content'] ??
          'No image';

      return {
        'title': title,
        'description': description,
        'image': imageUrl,
      };
    } else {
      throw Exception('Failed to load metadata');
    }
  }
}
