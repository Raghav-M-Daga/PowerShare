import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_app/pages/requestTO_widget.dart';
import 'package:share_app/pages/structure/Competition.dart';
import 'package:share_app/pages/structure/FirestoreData.dart';
import 'package:share_app/pages/structure/NotificationsHandlerV2.dart';
import 'package:share_app/pages/structure/userRequest.dart';
import 'package:url_launcher/url_launcher.dart';

class YourRequests extends StatefulWidget {
  // Fetch name, date, location, teamsList
  String competitionName = "";
  String competitionDate = "";
  String competitionLocation = "";

  List<Request> othersRequestsList = [];
  List<Request> acceptedByYou = [];

  YourRequests(Competition competition) {
    this.competitionName = competition.getName();
    this.competitionDate = competition.getDate();
    this.competitionLocation = competition.getLocation();

    print(
        "EVENT PAGE DATA: ${this.competitionName}\n${this.competitionDate}\n${this.competitionLocation}");
  }

  @override
  _YourRequestState createState() => _YourRequestState();
}

class _YourRequestState extends State<YourRequests> {
  Color color = Colors.black;
  RequestTOScrollableWidget ownRequestsWidget =
  new RequestTOScrollableWidget([]);
  FirestoreData firestoreData = new FirestoreData();

  String teamEmail = "";
  String teamName = "";
  String teamNumber = "";
  String teamRegion = "";
  String uid = "";
  Request currentRequest = new Request("", "");
  int acceptedCount = 0;
  int tempAccepted = 0;

  Future<String> updateUserInfo() async {
    CollectionReference users =
    FirebaseFirestore.instance.collection("UserData");
    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser.uid.toString();

    var snapshot = await users.doc(uid).get();
    var data = snapshot.data();

    this.teamEmail = data['teamEmail'];
    this.teamName = data['teamName'];
    this.teamNumber = data['teamNumber'];
    this.teamRegion = data['teamRegion'];
    this.uid = uid;

    this.currentRequest = new Request(this.teamNumber, "");

    return this.teamNumber ?? "";
  }

  dynamic getRequestData(AsyncSnapshot<QuerySnapshot> snapshot) {
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

  void updateRequest(String value, int index, int requestIndex,
      AsyncSnapshot<QuerySnapshot> snapshot) {
    var fullData = getReqDataFull(snapshot);
    fullData[requestIndex]['data'][index] = value;
  }

  void addRequest(List<String> reqData, snapshot) {
    List<dynamic> fullData = getReqDataFull(snapshot);
    Map<String, dynamic> newReq = {'data': reqData};
    fullData.add(newReq);
  }

  int _selectedIndex = 1;

  List<String> notifications = <String>[];

  Widget _createNotification(String content) {
    return PopupMenuItem(
      child: Text(
        content,
        style: TextStyle(
          fontSize: 12.0,
        ),
      ),
    );
  }

  Widget makeRequest(BuildContext context,
      AsyncSnapshot<QuerySnapshot> snapshot, double width, double height) {
    return new AlertDialog(
      content: SizedBox(
        width: width * 0.7,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(width * 0.025, 0, 0, 0),
              child: Text(
                "Create A New Request",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  width * 0.025, height * 0.01, width * 0.025, height * 0.025),
              child: SizedBox(
                width: width * 0.6,
                height: height * 0.05,
                child: TextField(
                  textCapitalization: TextCapitalization.words,
                  style: TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                      hintText: "Enter your name",
                      contentPadding: EdgeInsets.zero),
                  onChanged: (value) {
                    // currentRequest = new Request(this.teamNumber, value);
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  width * 0.025, height * 0.01, width * 0.025, height * 0.025),
              child: SizedBox(
                width: width * 0.6,
                height: height * 0.05,
                child: TextField(
                  textCapitalization: TextCapitalization.words,
                  style: TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                      hintText: "Enter part", contentPadding: EdgeInsets.zero),
                  onChanged: (value) {
                    currentRequest = new Request(this.teamNumber, value);
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  width * 0.025, height * 0.01, width * 0.025, height * 0.025),
              child: SizedBox(
                width: width * 0.6,
                height: height * 0.05,
                child: TextField(
                  textCapitalization: TextCapitalization.words,
                  style: TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                      hintText: "Part URL", contentPadding: EdgeInsets.zero),
                  onChanged: (value) {
                    // currentRequest = new Request(this.teamNumber, value);
                  },
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, width * 0.02, 0),
                  child: GestureDetector(
                    child: Container(
                      height: height * 0.04375,
                      width: width * 0.2,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(width * 0.02,
                            height * 0.01, width * 0.02, height * 0.01),
                        child: Text(
                          "Cancel",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(color: Colors.black),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                GestureDetector(
                  child: Container(
                    height: height * 0.04375,
                    width: width * 0.2,
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(width * 0.02, height * 0.01,
                          width * 0.02, height * 0.01),
                      child: Text("Confirm",
                          style: TextStyle(color: Colors.white)),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onTap: () async {
                    await firestoreData.makeNewUserRequestFirebase(
                        currentRequest, snapshot, widget.competitionName);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    );
  }

  void navigateToPage(int index) {
    setState(
          () {
        _selectedIndex = index;
      },
    );
    if (index == 1) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => YourRequests(new Competition("November 12th Qualifying Tournament", "12/10/22", "NorCal", true)),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
  }

  Widget generateRequestsWidget(
      AsyncSnapshot<QuerySnapshot> snapshot, double width, double height) {
    List<Request> ownRequests = [];
    dynamic data = snapshot.data!.docs
        .map((DocumentSnapshot document) => document.data())
        .toList()[0]['requestsV2'];

    for (var req in data) {
      var currentData = req['data'];

      Request newRequestObj = new Request(currentData[0], currentData[1]);
      if (newRequestObj.teamRequesting == this.teamNumber) {
        if ((currentData[2] as String) == "") ownRequests.add(newRequestObj);
      }
      if ((currentData[2] as String) != "") {
        newRequestObj.teamFulfilling = currentData[2];
        newRequestObj.isAccepted = true;
        if (newRequestObj.teamRequesting == this.teamNumber) {
          tempAccepted++;
        }
      }
    }
    if (tempAccepted > acceptedCount) {
      LocalNoticeService()
          .addNotification("Your Request has been Accepted", "", "");
      acceptedCount = tempAccepted;
    }
    if (ownRequests.length > 0) {
      return Container(
        child: SingleChildScrollView(
          child: Container(
            alignment: Alignment.centerLeft,
            height: height * 0.19,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: ownRequests.length + 1,
              itemBuilder: (BuildContext context, int i) {
                if ((i - 1) > -1) {
                  String request = ownRequests[i - 1].requestName;
                  return Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, width * 0.04, 0),
                    child: Container(
                      width: width * 0.32,
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.fromLTRB(0.0, 0.0, 0, 0),
                            child: GestureDetector(
                              child: Container(
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(
                                      width * 0.01, width * 0.01, 0, 0),
                                  child: Icon(
                                    Icons.close,
                                    size: width * 0.075,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      _confirmRequestDeletion(
                                          ownRequests[i - 1],
                                          snapshot,
                                          ownRequests[i - 1].teamFulfilling,
                                          width,
                                          height),
                                );
                              },
                            ),
                          ),
                          Container(
                            child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection(widget.competitionName)
                                  .snapshots(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<QuerySnapshot> snapshot) {
                                late List<Color?> colors = [
                                  Colors.grey[200],
                                  Color(0xff520000),
                                  Color(0xff135200),
                                ];
                                late Color? acceptedColor = colors[1];
                                late Color? pendingColor = colors[1];
                                late IconData currentIcon = Icons.close;

                                String fulfillingTeam = "";

                                dynamic allRequests = snapshot.data!.docs
                                    .map((DocumentSnapshot document) =>
                                    document.data())
                                    .toList()[0]['requestsV2'] as List;

                                for (var req in allRequests) {
                                  var request = req['data'];
                                  String requestName = request[1];
                                  String teamFulfilling = request[2];
                                  if (requestName ==
                                      ownRequests[i - 1].getName()) {
                                    fulfillingTeam = teamFulfilling;
                                    acceptedColor = colors[2];
                                    pendingColor = colors[0];
                                    currentIcon = Icons.check;

                                    break;
                                  }
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                      child: Container(
                                        height: height * 0.04,
                                        child: Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              width * 0.015,
                                              0,
                                              width * 0.015,
                                              0),
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              "$request",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 22,
                                                  color: Colors.white),
                                              textWidthBasis:
                                              TextWidthBasis.parent,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: height * 0.02,
                                      child: Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            width * 0.015,
                                            0,
                                            width * 0.015,
                                            0),
                                        child: InkWell(
                                          child: Text(
                                            "Part Link",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                decoration: TextDecoration.underline,
                                                fontSize: 14,
                                                color: Colors.white),
                                            textWidthBasis:
                                            TextWidthBasis.parent,
                                            textAlign: TextAlign.center,
                                          ),
                                          onTap: () => launch('https://www.youtube.com/watch?v=dQw4w9WgXcQ'),
                                        ),
                                      ),
                                    ),
                                    generateAcceptedTeamWidget(
                                        fulfillingTeam, height),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      decoration: BoxDecoration(
                          color: Color(0xffB43D2D),
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black,
                            )
                          ]
                      ),
                    ),
                  );
                } else {
                  return Padding(
                    padding:
                    EdgeInsets.fromLTRB(width * 0.04, 0, height * 0.02, 0),
                    child: Material(
                      elevation: 0.0,
                      borderRadius: BorderRadius.circular(10.0),
                      child: GestureDetector(
                        child: Container(
                          height: height * 0.19,
                          width: width * 0.33,
                          child: Padding(
                            padding: EdgeInsets.all(width * 0.02),
                            child: Icon(
                              Icons.add,
                              size: width * 0.2,
                              color: Color(0xff9D1F00),
                            ),
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xffFFCCCC),
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              color: Color(0xffB43D2D),
                              width: width * 0.01,
                            ),
                          ),
                        ),
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) => makeRequest(
                                  context, snapshot, width, height));
                        },
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ),
      );
    } else {
      return Row(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(width * 0.04, 0, width * 0.02, 0),
            child: Material(
              elevation: 0.0,
              borderRadius: BorderRadius.circular(10.0),
              child: GestureDetector(
                child: Container(
                  height: height * 0.19,
                  width: width * 0.33,
                  child: Padding(
                    padding: EdgeInsets.all(width * 0.02),
                    child: Icon(
                      Icons.add,
                      size: width * 0.2,
                      color: Color(0xff9D1F00),
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xffFFCCCC),
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: Color(0xffB43D2D),
                      width: width * 0.01,
                    ),
                  ),
                ),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) =>
                          makeRequest(context, snapshot, width, height));
                },
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(width * 0.02),
            child: Container(
              child: Padding(
                padding: EdgeInsets.fromLTRB(width * 0.005, height * 0.0025,
                    width * 0.005, height * 0.0025),
                child: Container(
                  width: width * 0.4,
                  height: height * 0.1,
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(width * 0.01, height * 0.01,
                        width * 0.01, height * 0.01),
                    child: Text(
                      "You have no outgoing requests",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  padding: EdgeInsets.all(width * 0.02),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    color: Color(0xff9D1F00),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget generateAcceptedTeamWidget(String fulfillingTeam, double height) {
    if (fulfillingTeam != "") {
      return Padding(
        padding: EdgeInsets.all(height * 0.0),
        child: Container(
          height: height * 0.07,
          alignment: Alignment.center,
          child: Padding(
            padding: EdgeInsets.all(height * 0.0),
            child: Text(
              "$fulfillingTeam has accepted!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
          decoration: BoxDecoration(
            color: Color(0xff3E5CA2),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      );
    } else {
      return Padding(
        padding: EdgeInsets.all(height * 0.01),
        child: Container(
          height: height * 0.04,
          alignment: Alignment.center,
          child: Padding(
            padding: EdgeInsets.all(height * 0.0),
            child: Text(
              "Pending",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                // fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      );
    }
  }



  Widget generateAcceptedStatusWidget(
      Request request,
      AsyncSnapshot<QuerySnapshot> snapshot,
      String teamRequesting,
      double width,
      double height) {
    if (request.teamFulfilling == "") {
      return Container(
        height: height * 0.05625,
        alignment: Alignment.center,
        child: GestureDetector(
          child: Container(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  width * 0.02, height * 0.01, width * 0.02, height * 0.01),
              child:
              Text("Accept Request", style: TextStyle(color: Colors.white)),
            ),
            decoration: BoxDecoration(
              color: Color(0xff9D1F00),
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
          onTap: () async {
            await firestoreData.fullfilRequest(
                request, this.teamNumber, widget.competitionName, snapshot);
            showDialog(
              context: context,
              builder: (BuildContext context) =>
                  _confirmRequestAcceptance(context, teamRequesting),
            );
          },
        ),
      );
    } else {
      return Container(
        height: height * 0.05625,
        alignment: Alignment.center,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
              width * 0.02, height * 0.01, width * 0.02, height * 0.01),
          child: Text(
            "Request Accepted",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
        ),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(5.0),
        ),
      );
    }
  }

  Widget _confirmRequestAcceptance(BuildContext context, String team) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            child: Text(
              "Team $team notified!",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            decoration: BoxDecoration(color: Color(0xffFFCCCC)),
          ),
        ],
      ),
      backgroundColor: Color(0xffFFCCCC),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    );
  }

  Widget _confirmRequestDeletion(
      Request request,
      AsyncSnapshot<QuerySnapshot> snapshot,
      teamFulfilling,
      double width,
      double height) {
    return AlertDialog(
      content: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                  width * 0.01, height * 0.005, width * 0.01, height * 0.005),
              child: Text(
                "Are you sure that you want to delete your request for:",
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  width * 0.01, height * 0.005, width * 0.01, height * 0.025),
              child: Text(
                "${request.getName()}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: height * 0.03125,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                GestureDetector(
                  child: Container(
                    height: height * 0.04375,
                    width: width * 0.175,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(width * 0.02, height * 0.01,
                          width * 0.02, height * 0.01),
                      child: Text(
                        "Cancel",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(5.0),
                      border: Border.all(color: Colors.grey),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                SizedBox(
                  width: width * 0.0375,
                ),
                GestureDetector(
                  child: Container(
                    height: height * 0.04375,
                    width: width * 0.175,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(width * 0.02, height * 0.01,
                          width * 0.02, height * 0.01),
                      child: Text(
                        "Yes",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onTap: () async {
                    //
                    await firestoreData.deleteRequest(
                        snapshot, request, widget.competitionName);
                    Navigator.pop(context);
                    if (teamFulfilling != "") {
                      acceptedCount--;
                      tempAccepted = acceptedCount;
                    }
                    ;
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    );
  }

//todo: fix formatting from here
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double width = constraints.maxWidth;
        double height = constraints.maxHeight;
        return Container(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection(widget.competitionName)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong');
              }

              return FutureBuilder(
                future: updateUserInfo(),
                builder: (BuildContext context,
                    AsyncSnapshot<String> teamNameSnapshot) {
                  return Scaffold(
                    body: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image:
                          AssetImage("assets/largerShareAppBackground.jpg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Column(
                        children: <Widget>[
                          // Padding(
                          //   padding:
                          //       EdgeInsets.fromLTRB(0, height * 0.025, 0, 0),
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.end,
                          //     children: [
                          //       IconButton(
                          //         icon: const Icon(Icons.exit_to_app_rounded),
                          //         color: Colors.black,
                          //         iconSize: width * 0.075,
                          //         onPressed: () {
                          //           FirebaseAuth.instance.signOut();
                          //           Navigator.pushReplacement(
                          //             context,
                          //             PageRouteBuilder(
                          //               pageBuilder:
                          //                   (context, animation1, animation2) =>
                          //                       LoginScreen(),
                          //               transitionDuration: Duration.zero,
                          //               reverseTransitionDuration:
                          //                   Duration.zero,
                          //             ),
                          //           );
                          //         },
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(width * 0.01, 0.0,
                                width * 0.01, height * 0.00025),
                            child: Text(
                              widget.competitionName,
                              style: TextStyle(
                                fontSize: width * 0.075,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(width * 0.01),
                            child: Text(
                              "${widget.competitionDate}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: width * 0.04,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(width * 0.01,
                                height * 0.01, width * 0.01, height * 0.00025),
                            child: Text(
                              "Your Requests",
                              style: TextStyle(
                                fontSize: width * 0.045,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(width * 0.002),
                            child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection(widget.competitionName)
                                  .snapshots(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (snapshot.hasError) {
                                  return Text('Something went wrong');
                                }
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Text("Loading");
                                }
                                return generateRequestsWidget(
                                    snapshot,
                                    constraints.maxWidth,
                                    constraints.maxHeight);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    bottomNavigationBar: BottomNavigationBar(
                      items: const <BottomNavigationBarItem>[
                        BottomNavigationBarItem(
                            icon: Icon(Icons.pageview_rounded), label: "All Requests"),
                        BottomNavigationBarItem(
                            icon: Icon(Icons.home), label: "Your Requests"),
                        BottomNavigationBarItem(icon: Icon(Icons.heart_broken_outlined), label: "Third"),
                      ],
                      currentIndex: _selectedIndex,
                      selectedItemColor: Color(0xffA72B0C),
                      onTap: navigateToPage,
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
