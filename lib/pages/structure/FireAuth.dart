import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_app/pages/structure/Competition.dart';

class FireAuth {
  Competition defaultComp = Competition("", "", "", false);

  Future<void> userSetup(String teamEmail, String teamName, String teamNumber,
      String teamRegion) async {
    CollectionReference users =
        FirebaseFirestore.instance.collection("UserData");
    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser.uid.toString();

    await users.doc(uid).set(
      {
        'uid': uid,
        'teamEmail': teamEmail,
        'teamName': teamName,
        'teamNumber': teamNumber,
        'teamRegion': teamRegion,
        'competitionsJoined': [],
      },
    );

    return;
  }

  Future<void> updateCompJoined(List<Competition> competitions) async {
    CollectionReference users =
        await FirebaseFirestore.instance.collection("UserData");
    FirebaseAuth auth = await FirebaseAuth.instance;
    String uid = await auth.currentUser.uid.toString();

    List<String> competitionsToString = [];
    for (Competition comp in competitions) {
      competitionsToString.add(comp.name);
    }

    var snapshot = await users.doc(uid).get();
    var data = snapshot.data();

    print(
        "Old Comp Joined Data: $data\nNew Comp Joined Data: ${competitionsToString}");

    await users.doc(uid).update({'competitionsJoined': competitions});

    print("Data updated");
    return;
  }

  Future<void> updateCompetitionsJoined(
      Competition competition, bool join) async {
    CollectionReference users =
        FirebaseFirestore.instance.collection("UserData");
    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser.uid.toString();

    List<String> competitionsJoined = [];

    var data = await users.doc(uid).get().then(
      (DocumentSnapshot snapshot) {
        print('Current User Data: ${snapshot.data()}');
        print(
            'Competition User Data: ${snapshot.data()['competitionsJoined']}');
      },
    );

    competitionsJoined = data['competitionsJoined'];

    print('UID: $uid');

    competitionsJoined = [competition.name];

    print("Competitions Joined Data FR: $competitionsJoined");

    await users
        .doc(uid)
        .update({'competitionsJoined': competitionsJoined}).then(
      (_) {
        print("Competitions Joined Data: $competitionsJoined");
      },
    );
  }

  Future<List<String>> getJoinedCompetitions() async {
    CollectionReference users =
        FirebaseFirestore.instance.collection('UserData');
    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser.uid.toString();

    List<String> competitionsJoined = [];

    var data = await users.doc(uid).get().then(
      (DocumentSnapshot snapshot) {
        print('Current User Data: ${snapshot.data()}');
        print(
            'Competition User Data: ${snapshot.data()['competitionsJoined']}');
        return snapshot.data();
      },
    );

    competitionsJoined = data['competitionsJoined'];
    return competitionsJoined;
  }

  Future<Competition> getCompToView() async {
    CollectionReference users =
        FirebaseFirestore.instance.collection("UserData");
    late CollectionReference competitions;
    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser.uid.toString();

    late Competition newComp;

    var data = await users.doc(uid).get().then(
      (DocumentSnapshot snapshot) {
        print('Current User Data: ${snapshot.data()}');
        print(
            'Competition User Data: ${snapshot.data()['competitionsJoined']}');
      },
    );

    var compData = data['competitionsJoined'] as List<dynamic>;

    competitions = FirebaseFirestore.instance.collection(compData[0]);
    var compSpecificData = await competitions.doc('data').get();
    newComp = new Competition(compSpecificData['name'],
        compSpecificData['date'], compSpecificData['location'], true);

    return newComp;
  }
}
