import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_app/pages/structure/Competition.dart';

class AppTeam {
  late String email;
  late String teamName;
  late int teamNumber;
  late String uid;

  final _auth = FirebaseAuth.instance;
  late User _user = _auth.currentUser;

  AppTeam() {
    FirebaseAuth auth = FirebaseAuth.instance;
    this.uid = auth.currentUser.uid.toString();
  }

  void logInTeam(BuildContext context, String email, String password) async {
    try {
      final user = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (user != null) {
        Navigator.pushNamed(context, 'event');
      }
    } catch (e) {
      print(e);
    }
  }

  String getTeamName() {
    return teamName;
  }

  int getTeamNumber() {
    return teamNumber;
  }

  Future resetEmail(String emailReplacement) async {
    try {
      User user = await _auth.currentUser;
      user.updateEmail(email);
    } catch (e) {
      print(e);
    }
  }

  Future resetPassword(String passwordReplacement) async {
    try {
      User user = await _auth.currentUser;
      user.updatePassword(passwordReplacement);
    } catch (e) {
      print(e);
    }
  }

  void updateJoinedCompetitions(Competition competition) {}

  void updatedListOfHiddenRequests() {}
}
