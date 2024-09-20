import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FireAuthEventViewer {
  CollectionReference users = FirebaseFirestore.instance.collection("UserData");

  Future<dynamic> getJoinedCompetitions() async {
    CollectionReference users = FirebaseFirestore.instance.collection("UserData");
    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser.uid.toString();

    var snapshot = await users.doc(uid).get();
    var data = snapshot.data();

    print("Current auth data: ${data["competitionsJoined"]}");

    return data["competitionsJoined"];
  }

  Future<void> updateJoinedCompetitions(List<String> competitions) async {
    CollectionReference users = FirebaseFirestore.instance.collection("UserData");
    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser.uid.toString();

    print("USER UID: $uid");

    await users.doc(uid).update(
      {'competitionsJoined': competitions}
    );

    print("Data Updated to: ${getJoinedCompetitions()}");
  }

  Future<void> updateCurrentViewingComp(String competitionName) async {
    CollectionReference users = FirebaseFirestore.instance.collection("UserData");
    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser.uid.toString();

    await users.doc(uid).update(
      {'currentCompetitionViewing': competitionName}
    );

    return;
  }

  Future<dynamic> getCurrentViewingComp() async {
    CollectionReference users = FirebaseFirestore.instance.collection("UserData");
    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser.uid.toString();

    var snapshot = await users.doc(uid).get();
    var data = snapshot.data();

    print("currentCompetitionViewing: ${data["currentCompetitionViewing"]}");

    return data["currentCompetitionViewing"];
  }
}
