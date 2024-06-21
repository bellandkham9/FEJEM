
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../Home/DetailsNews.dart';
import '../../../theme_Provider.dart';
import '../Link/Link_Provider.dart';

class AllLinks extends StatefulWidget {
  final bool isLeader;
  const AllLinks({super.key, required this.isLeader});

  @override
  _AllLinksState createState() => _AllLinksState();
}

class _AllLinksState extends State<AllLinks> {
  final auth = FirebaseAuth.instance;
  User? loggedInUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> getCurrentUser() async {
    final user = auth.currentUser;
    if (user != null) {
      setState(() {
        loggedInUser = user;
      });
    }
  }

  Future<void> shareLink(String title, String link, String? imageUrl, BuildContext context) async {
    try {
      // Create a list of files to share (including text and image if available)
      List<XFile> filesToShare = [XFile('dummy')]; // Initialize with a dummy XFile

      if (imageUrl != null) {
        // Get the temporary directory
        Directory tempDir = await getTemporaryDirectory();
        String tempImagePath = '${tempDir.path}/temp_image.jpg';

        // Download the image from the URL
        final response = await http.get(Uri.parse(imageUrl));
        File imageFile = File(tempImagePath);
        await imageFile.writeAsBytes(response.bodyBytes);

        // Create an XFile object for the image file
        XFile xImageFile = XFile(tempImagePath);

        // Replace the dummy entry with the actual image file
        filesToShare[0] = xImageFile;
      }

      // Combine title and link into one string
      String textToShare = '$title\n$link';

      // Share the files using Share.shareXFiles
      await Share.shareXFiles(
        filesToShare,
        text: textToShare,
      );
    } catch (e) {
      print('Error sharing post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to share the Link. Please try again.'),
        ),
      );
    }
  }

  Future<void> _openLink(String? url) async {
    if (url != null) {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        print('Could not launch $url');
      }
    }
  }

  Future<void> deleteLink(String linkId) async {
    await _firestore.collection('Links').doc(linkId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link delete successfuly!'),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    final uiProvider = Provider.of<UiProvider>(context);
    return Center(
      child: FutureBuilder(
        future: getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (loggedInUser == null) {
            return const Center(child: Text("No user logged in"));
          }
          return Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: LinkProvider().getLink(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    final linkDocs = snapshot.data!.docs;
                    print("la taille des données: " + linkDocs.length.toString());
                    return ListView.builder(
                      itemCount: linkDocs.length,
                      itemBuilder: (context, index) {
                        final linkData = linkDocs[index].data() as Map<String, dynamic>;
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              /*Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>  DetailsNews(postId: linkDocs[index].id,),
                                ),
                              );*/
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: uiProvider.isDark ? Colors.grey.withOpacity(0.3): Colors.white70,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(15.0),
                                ),
                                border: const Border(
                                  bottom: BorderSide(color: Colors.black12),
                                ),
                              ),
                              child: ListTile(
                                onTap: () {
                                  final String? link = linkData['lien'];
                                  if (link != null) {
                                    _openLink(link);
                                  } else {
                                    // Afficher un message d'erreur ou faire autre chose si le lien est null
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('No link available')),
                                    );
                                  }
                                },
                                title: Text(
                                  linkData['titre'] ?? "No Title",
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  linkData['description'] ?? "No Description",
                                  style: const TextStyle(color: Colors.grey),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                leading: linkData['imgLink'] != null
                                    ? Image.network(linkData['imgLink'])
                                    : const Image(
                                  image: AssetImage("assets/images/link_image.jpg"),
                                ),
                                 trailing: widget.isLeader
                                     ?IconButton(
                                   onPressed: () {
                                     deleteLink(
                                         linkDocs[index].id);
                                   },
                                   icon: const Icon(Icons.delete,
                                       color: Colors.grey),
                                 ):
                                     IconButton(
                                       onPressed: () {
                                         if (linkData['imgLink'] != null) {
                                           shareLink(linkData['titre'] ?? "Check out this post",linkData['lien'], linkData['imgLink'],context);
                                         } else {
                                           Share.share(linkData['titre'] ?? "Check out this post");
                                         }
                                       },
                                       icon: uiProvider.isDark ? const Icon(Icons.share,color: Colors.black,):const Icon(Icons.share,color: Colors.grey,),
                                     ),
                                 )
                              ),
                            ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}