import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FireAuthQ {
  Future<void> userSetup(String teamEmail, String teamName, String teamNumber,
      String teamRegion) async {
    CollectionReference users =
        FirebaseFirestore.instance.collection("UserData");
    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser.uid.toString();

    print("USER UID: $uid");

    await users.doc(uid).set(
      {
        'uid': uid,
        'teamEmail': teamEmail,
        'teamName': teamName,
        'teamNumber': teamNumber,
        'teamRegion': teamRegion,
        'competitionsJoined': ['Join a competition to begin'],
        'currentCompetitionViewing': 'Join a competition to begin'
      },
    );

    return;
  }
}
