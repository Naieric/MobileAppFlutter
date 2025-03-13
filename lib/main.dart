import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Artists App',
      theme: ThemeData(
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Color(0xFFF5F5DC),
        appBarTheme: AppBarTheme(
          color: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.brown,
        ),
      ),
      home: ArtistsScreen(),
    );
  }
}

class ArtistsScreen extends StatefulWidget {
  @override
  _ArtistsScreenState createState() => _ArtistsScreenState();
}

class _ArtistsScreenState extends State<ArtistsScreen> {
  final CollectionReference artistsCollection =
      FirebaseFirestore.instance.collection('Artists');

  void _addArtist() {
    TextEditingController nameController = TextEditingController();
    TextEditingController nationalityController = TextEditingController();
    TextEditingController worksController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title:
              Text('Add Artist', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Name')),
                TextField(
                    controller: nationalityController,
                    decoration: InputDecoration(labelText: 'Nationality')),
                TextField(
                    controller: worksController,
                    decoration: InputDecoration(labelText: 'Notable Works')),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                artistsCollection.add({
                  'name': nameController.text,
                  'nationality': nationalityController.text,
                  'works': worksController.text,
                });
                Navigator.pop(context);
              },
              child: Text('Add', style: TextStyle(color: Colors.brown)),
            ),
          ],
        );
      },
    );
  }

  void _editArtist(DocumentSnapshot artist) {
    TextEditingController nameController =
        TextEditingController(text: artist['name']);
    TextEditingController nationalityController =
        TextEditingController(text: artist['nationality']);
    TextEditingController worksController =
        TextEditingController(text: artist['works']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text('Edit Artist',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Name')),
                TextField(
                    controller: nationalityController,
                    decoration: InputDecoration(labelText: 'Nationality')),
                TextField(
                    controller: worksController,
                    decoration: InputDecoration(labelText: 'Notable Works')),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                artistsCollection.doc(artist.id).update({
                  'name': nameController.text,
                  'nationality': nationalityController.text,
                  'works': worksController.text,
                });
                Navigator.pop(context);
              },
              child: Text('Save', style: TextStyle(color: Colors.brown)),
            ),
          ],
        );
      },
    );
  }

  void _deleteArtist(String id) {
    artistsCollection.doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: Text('Artists')),
      body: StreamBuilder(
        stream: artistsCollection.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());
          return ListView(
            padding: EdgeInsets.all(10),
            children: snapshot.data!.docs.map((artist) {
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  title: Text('[Artist] ${artist['name']}',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Nationality : ${artist['nationality']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          icon: Icon(Icons.edit, color: Colors.brown),
                          onPressed: () => _editArtist(artist)),
                      IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteArtist(artist.id)),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addArtist,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
