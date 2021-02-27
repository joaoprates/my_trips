import 'package:flutter/material.dart';
import 'Map.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _listTrips = [];

  _openMap() {}

  _deleteTrip() {}

  _addPlace () {

    Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => Map())
    );

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
      body: Column(
        children: [
          Expanded(child: ListView.builder(itemBuilder: (context, index) {
            String title = _listTrips[index];
            return GestureDetector(
              onTap: () {
                _openMap();
              },
              child: Card(
                child: ListTile(
                  title: Text(title),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _deleteTrip();
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
      ),
    );
  }
}
