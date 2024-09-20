import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_app/pages/structure/userRequest.dart';
import 'package:share_app/pages/structure/FirestoreData.dart';

class RequestTOScrollableWidget extends StatefulWidget {
  List<Request> requestsList = [];

  RequestTOScrollableWidget(List<Request> requestsList) {
    this.requestsList = requestsList;
  }

  Future<RequestTOScrollableWidget> updateSelf(String currentRequestString, AsyncSnapshot<QuerySnapshot> snapshot, String compName, String teamName) async {
    FirestoreData firestoreData = new FirestoreData();
    Request newRequest = new Request(teamName, currentRequestString);

    // Send new Request to Firebase
    await firestoreData.makeNewUserRequestFirebase(newRequest, snapshot, compName);

    // Pull all own requests
    var data = await firestoreData.updateRequests(snapshot, "Ink and Metal");
    if (data.length != 0) {
      requestsList = data[0];
      print("data: ${data}");
      print("data[0]: ${requestsList}");
    }

    return RequestTOScrollableWidget(requestsList);
  }

  @override
  _RequestTOScrollableWidgetState createState() => _RequestTOScrollableWidgetState();
}

class _RequestTOScrollableWidgetState extends State<RequestTOScrollableWidget> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}