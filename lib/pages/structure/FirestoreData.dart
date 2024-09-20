import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:share_app/pages/structure/userRequest.dart';

class FirestoreData {
  List<String> competitionsList = [];
  CollectionReference competitions =
      FirebaseFirestore.instance.collection('CompetitionsList');

  Future<List<String>> getCompDataFull(
      AsyncSnapshot<QuerySnapshot> snapshot) async {
    dynamic data = await snapshot.data!.docs
        .map((DocumentSnapshot document) => document.data())
        .toList();

    return [data[0]["date"], data[0]["location"]];
  }

  Future<DocumentSnapshot> getDataSnapshot() async {
    return await this.competitions.doc('CompetitionsList').get();
  }

  Future<dynamic> getReqDataFull(AsyncSnapshot<QuerySnapshot> snapshot) async {
    dynamic data = await snapshot.data!.docs
        .map((DocumentSnapshot document) => document.data())
        .toList();

    return data[0]['requestsV2'];
  }

  Future<List<List<Request>>> updateRequests(
      AsyncSnapshot<QuerySnapshot> snapshot, String teamName) async {
    // update your request
    // get list of objects and snapshots, loop through objects, add to a list
    // return list with updated request objects

    dynamic data = await getReqDataFull(snapshot);

    List<Request> yourRequests = [];
    List<Request> otherRequests = [];

    var firestoreReqData = data as List;
    for (var req in firestoreReqData) {
      var currentData = req['data'];

      // must update
      print('Updating data with new object');
      Request newRequestObj = new Request(currentData[0], currentData[1]);
      if ((currentData[2] as String) != "") {
        newRequestObj.teamFulfilling = currentData[2];
        newRequestObj.isAccepted = true;
      }

      if (newRequestObj.teamRequesting != teamName) {
        // is an other request
        otherRequests.add(newRequestObj);
      } else {
        yourRequests.add(newRequestObj);
      }

      print('Updated specific request data with: ${currentData} from firebase');
    }

    return [yourRequests, otherRequests];
  }

  // format because data: actual data with index
  Future<void> deleteRequest(AsyncSnapshot<QuerySnapshot> snapshot,
      Request userRequest, String competitionName) async {
    final firestoreInstance = await FirebaseFirestore.instance;

    // get full data
    print(
        "userRequest: {${userRequest.teamRequesting}, ${userRequest.getName()}, ${userRequest.teamFulfilling}");
    var fullData = await getReqDataFull(snapshot);

    // loop through data, see if request object data is present
    print("fullData: ${fullData.toString()}");
    for (var reqMap in fullData as List) {
      List<dynamic> req = reqMap['data'];
      print("${req.toString()} vs \n${[
        userRequest.teamRequesting,
        userRequest.requestName,
        userRequest.teamFulfilling
      ]}");
      if (req[0] == userRequest.teamRequesting &&
          req[1] == userRequest.getName() &&
          req[2] == userRequest.teamFulfilling) {
        // request object data is present
        print("Found data to delete");

        // if so, remove data from list
        print("reqMap: $reqMap");
        fullData.remove(reqMap);
        break;
      }
    }

    // update full data on firebase --> request is deleted
    print("Updated fullData: $fullData}");
    await firestoreInstance
        .collection(competitionName)
        .doc('Comp')
        .update({'requestsV2': fullData}).then(
      (_) {
        print("All requests data: ${fullData}");
      },
    );

    print(
        "Request Deleted: ${userRequest.teamRequesting}, ${userRequest.requestName}, ${userRequest.teamFulfilling}");
  }

  Future<void> makeNewUserRequestFirebase(Request request,
      AsyncSnapshot<QuerySnapshot> snapshot, String compName) async {
    final firestoreInstance = await FirebaseFirestore.instance;
    var fullData = await getReqDataFull(snapshot);

    Map<String, dynamic> newReq = {
      'data': [
        request.teamRequesting,
        request.requestName,
        request.teamFulfilling
      ]
    };
    fullData.add(newReq);

    await firestoreInstance
        .collection(compName)
        .doc('Comp')
        .update({'requestsV2': fullData}).then(
      (_) {
        print(fullData);
      },
    );
  }

  Future<Request> fullfilRequest(Request requestToFulfill, String teamName,
      String compName, AsyncSnapshot<QuerySnapshot> snapshot) async {
    // update request object
    requestToFulfill.teamFulfilling = teamName;
    requestToFulfill.isAccepted = true;

    List<String> requestWithoutFulfill = [
      requestToFulfill.teamRequesting,
      requestToFulfill.requestName,
      ""
    ];
    List<String> requestWithFulfill = [
      requestToFulfill.teamRequesting,
      requestToFulfill.requestName,
      teamName
    ];

    // update data into firebase with full data
    final firestoreInstance = await FirebaseFirestore.instance;

    var fullData = await getReqDataFull(snapshot);

    int index = -1;
    for (var dataMap in fullData) {
      List<dynamic> data = dataMap['data'];
      print("data: $data");
      if (data[0].toString() == requestWithoutFulfill[0].toString() &&
          data[1].toString() == requestWithoutFulfill[1].toString()) {
        print("Request without fulfill: ${requestWithFulfill[2]}");
        // Update request with team fulfilling
        data = requestWithFulfill;

        index = (fullData as List<dynamic>).indexOf(dataMap);
      }
    }

    print("index: $index");
    fullData[index] = {'data': requestWithFulfill};
    print("Before break, fullData: $fullData");

    await firestoreInstance
        .collection(compName)
        .doc('Comp')
        .update({'requestsV2': fullData}).then(
      (_) {
        print(fullData);
      },
    );

    // return updated request object
    return requestToFulfill;
  }
}
