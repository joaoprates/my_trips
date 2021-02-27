import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'Map.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final _controller = StreamController<QuerySnapshot>.broadcast();
  Firestore _db = Firestore.instance;

  _openMap(String tripId) {
    Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => Maps( tripId: tripId ))
    );
  }

  _deleteTrip( tripId ) {
    _db.collection("trips").document( tripId ).delete();
  }

  _addPlace () {

    Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => Maps())
    );

  }

  _addListenerTrips() async {
    final stream = _db.collection("trips").snapshots();

    stream.listen((data){
      _controller.add( data);
      });
  }

  @override
  void initState() {
    _addListenerTrips();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("myTrips")),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Color(0xff0066cc),
        onPressed: () {
          _addPlace();
        },
      ),
      body: StreamBuilder<QuerySnapshot>(

        stream: _controller.stream,
        // ignore: missing_return
        builder: (context, snapshot) {
          switch( snapshot.connectionState ) {
            case ConnectionState.none:
            case ConnectionState.waiting:
            case ConnectionState.active:
            case ConnectionState.done:

              QuerySnapshot querySnapshot = snapshot.data;
              List<DocumentSnapshot> trips = querySnapshot.documents.toList();

              return Column(
                children: [
                  Expanded(child: ListView.builder(
                    itemCount: trips.length,
                      itemBuilder: (context, index) {

                      DocumentSnapshot item = trips[index];
                      String title = item["title"];
                      String tripId = item.documentID;


                    return GestureDetector(
                      onTap: () {
                        _openMap( tripId );
                      },
                      child: Card(
                        child: ListTile(
                          title: Text(title),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  _deleteTrip( tripId );
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Icon(Icons.remove_circle, color: Colors.red),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  }))
                ],
              );
              break;
          }
        },
      )
    );
  }
}
