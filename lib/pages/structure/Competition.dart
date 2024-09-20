import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Competition {
  String name = "";
  String date = "";
  String location = "";
  late List<User> usersList;

  bool isJoined = false;
  late Widget joinedStatusWidget;
  Map<bool, Widget> possibleJoinStatus = {
    false: SizedBox(),
    true: Icon(
      Icons.check_circle_outline_sharp,
      color: Colors.redAccent,
      size: 50.0,
    )
  };

  Map<int, List<String>> requests = {};
  Stream<QuerySnapshot> usersStream =
      FirebaseFirestore.instance.collection('Sacramento').snapshots();
  CollectionReference competitionStream =
      FirebaseFirestore.instance.collection('Sacramento');

  Competition(String name, String date, String location, bool isJoined) {
    this.name = name;
    this.date = date;
    this.location = location;
    this.isJoined = isJoined;
    this.usersStream = FirebaseFirestore.instance.collection(name).snapshots();
    this.competitionStream = FirebaseFirestore.instance.collection(name);
    this.joinedStatusWidget = possibleJoinStatus[isJoined]!;
  }

  String getName() => name;

  String getDate() => date;

  String getLocation() => location;

  bool getIsJoined() => isJoined;

  void switchJoinedStatusWidget() {
    isJoined = !isJoined;
    joinedStatusWidget = possibleJoinStatus[isJoined]!;
  }

  void switchJoinedStatusWidgetWithBool(bool isJoined) {
    joinedStatusWidget = possibleJoinStatus[isJoined]!;
  }

  Map<int, List<String>> getAllRequests() => requests;

  List<String> getRequestData(
    AsyncSnapshot<QuerySnapshot> snapshot,
    int reqIndex,
  ) {
    dynamic data = snapshot.data!.docs
        .map((DocumentSnapshot document) => document.data())
        .toList();

    return data[0]['requestsV2'][reqIndex]['data'];
  }

  dynamic getAllRequestData(AsyncSnapshot<QuerySnapshot> snapshot) {
    dynamic data = snapshot.data!.docs
        .map((DocumentSnapshot document) => document.data())
        .toList();

    return data[0]['requestsV2'];
  }

  dynamic getAllData(AsyncSnapshot<QuerySnapshot> snapshot) {
    dynamic data = snapshot.data!.docs
        .map((DocumentSnapshot document) => document.data())
        .toList();

    return data[0];
  }

  void updateRequest(String value, int dataIndex, int reqIndex,
      AsyncSnapshot<QuerySnapshot> snapshot) {
    final firestoreInstance = FirebaseFirestore.instance;

    var fullData = getAllRequestData(snapshot);
    fullData[reqIndex]['data'][dataIndex] = value;

    firestoreInstance
        .collection(this.name)
        .doc('Comp')
        .update({'requestsV2': fullData}).then(
      (_) {
        print(fullData);
      },
    );
  }

  void addRequest(List<String> reqData, snapshot) {
    final firestoreInstance = FirebaseFirestore.instance;

    List<dynamic> fullData = getAllRequestData(snapshot);
    Map<String, dynamic> newReq = {'data': reqData};
    fullData.add(newReq);

    firestoreInstance
        .collection(this.name)
        .doc('Comp')
        .update({'requestsV2': fullData}).then(
      (_) {
        print(fullData);
      },
    );
  }

  Future<DocumentSnapshot> getDataSnapshot() async {
    return this.competitionStream.doc(this.name).get();
  }
}
