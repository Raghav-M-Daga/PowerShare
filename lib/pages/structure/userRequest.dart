import 'package:share_app/pages/structure/FirestoreData.dart';

class Request {
  String requestName = "";
  String teamRequesting = "";
  String teamFulfilling = "";
  String time = DateTime.now().toString();
  bool isAccepted = false;

  FirestoreData firestoreData = new FirestoreData();

  Request(String teamRequesting, String requestName) {
    this.teamRequesting = teamRequesting;
    this.requestName = requestName;
  }

  String getName() {
    return (requestName);
  }

  String getRequestingTeam() {
    return (teamRequesting);
  }
}
