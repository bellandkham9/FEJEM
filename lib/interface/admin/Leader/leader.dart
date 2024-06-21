import 'package:adminfejem/constants.dart';
import 'package:adminfejem/interface/admin/Leader/addLeader.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme_Provider.dart';

class Leader {
  // Obtenir tous les leaders
  Future<List<Map<String, dynamic>>> getAllLeaders() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('User')
        .where('isLeader', isEqualTo: true)
        .get();

    List<Map<String, dynamic>> leaders = [];
    for (var doc in snapshot.docs) {
      leaders.add(doc.data() as Map<String, dynamic>);
    }
    return leaders;
  }

  // Supprimer un leader
  Future<void> deleteLeader(String leaderId) async {
    await FirebaseFirestore.instance.collection('User').doc(leaderId).delete();
  }
}

class leader extends StatefulWidget {
  const leader({super.key});

  @override
  State<leader> createState() => _leaderState();
}

class _leaderState extends State<leader> {
  late Future<List<Map<String, dynamic>>> _leadersFuture;

  @override
  void initState() {
    super.initState();
    _leadersFuture = Leader().getAllLeaders();
  }

  Future<void> _deleteLeader(String leaderId) async {
    try {
      await Leader().deleteLeader(leaderId);
      setState(() {
        _leadersFuture = Leader().getAllLeaders();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Leader successful deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting a leader: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final uiProvider = Provider.of<UiProvider>(context);

    return Scaffold(
      backgroundColor: uiProvider.isDark ? uiProvider.darkTheme.primaryColorDark:Colors.white,
      body: Padding(
        padding: const EdgeInsetsDirectional.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _leadersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erreur: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Aucun leader trouvé.'));
                  } else {
                    return ListView.separated(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (BuildContext context, int index) {
                        var leader = snapshot.data![index];
                        return Container(
                          decoration: BoxDecoration(
                            color: uiProvider.isDark ? Colors.grey.withOpacity(0.6):Colors.grey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(7.0),
                          ),
                          child: ListTile(
                            title: Text(
                              leader['name'] ?? 'Sans nom',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(leader['email'] ?? 'Sans email'),
                            tileColor: Colors.white10,
                            onTap: () {},
                            leading: uiProvider.isDark
                                ? const Icon(Icons.person,
                                size: 36, color: Colors.black)
                                : const Icon(Icons.person,
                                size: 36, color: Colors.grey),
                            trailing: IconButton(
                              onPressed: () {
                                _deleteLeader(leader['id']);
                              },
                              icon: uiProvider.isDark
                                  ? const Icon(Icons.delete,
                                  size: 36, color: Colors.black)
                                  : const Icon(Icons.delete,
                                  size: 36, color: Colors.grey),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                      const Divider(
                        color: Colors.white,
                      ),
                    );
                  }
                },
              ),
            ),
            FloatingActionButton(
              backgroundColor: primaryColor,
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddLeader()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
