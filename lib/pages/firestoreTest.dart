import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserInformation extends StatefulWidget {
  @override
  _UserInformationState createState() => _UserInformationState();
}

class _UserInformationState extends State<UserInformation> {
  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('Sacramento').snapshots();
  final Map<String, int> requestRequirements = {'Team Requesting':0, 'Request':1, 'Team Fulfilling':2, };

  dynamic getReqData(AsyncSnapshot<QuerySnapshot> snapshot) {
    dynamic data = snapshot.data!.docs
        .map((DocumentSnapshot document) => document.data())
        .toList();

    return data[0]['requestsV2'][0]['data'];
  }

  dynamic getReqDataFull(AsyncSnapshot<QuerySnapshot> snapshot) {
    dynamic data = snapshot.data!.docs
        .map((DocumentSnapshot document) => document.data())
        .toList();

    return data[0]['requestsV2'];
  }

  void updateRequest(String value, int index, int reqIndex, AsyncSnapshot<QuerySnapshot> snapshot) {
    final firestoreInstance = FirebaseFirestore.instance;

    var fullData = getReqDataFull(snapshot);
    fullData[reqIndex]['data'][index] = value;

    firestoreInstance
        .collection("Sacramento")
        .doc('Comp')
        .update({'requestsV2': fullData}).then((_) {
      print(fullData);
    });
  }

  void addRequest(List<String> reqData, snapshot) {
    final firestoreInstance = FirebaseFirestore.instance;

    List<dynamic> fullData = getReqDataFull(snapshot);
    Map<String, dynamic> newReq = {'data': reqData};
    fullData.add(newReq);

    firestoreInstance
        .collection("Sacramento")
        .doc('Comp')
        .update({'requestsV2': fullData}).then((_) {
      print(fullData);
    });
  }

  Widget formatText(text) => Text(
        text,
        style: TextStyle(color: Colors.black, fontSize: 16.0),
      );

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _usersStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          print(snapshot.connectionState.toString());
          return Text("Loading");
        }

        var data = getReqData(snapshot);
        print(data.runtimeType);

        // print('Data From Firebase: ${data}');
        print('Team Requesting: ${data[0]}');
        print('Request Item: ${data[1]}');
        print('Team Fulfilling: ${data[2]}');

        return Scaffold(
          appBar: AppBar(
            title: Text(
              "Firestore Test",
            ),
          ),
          body: Column(
            children: <Widget>[
              formatText('Team Requesting: ${data[0]}'),
              formatText('Request Item: ${data[1]}'),
              formatText('Team Fulfilling: ${data[2]}'),
            ],
          ),
        );
      },
    );
  }
}
