class OtherRequest {
  String teamRequesting = "";
  String time = DateTime.now().toString();

  bool isAccepted = false;
  String teamAccepting = "";

  OtherRequest({required this.teamRequesting, required this.time});

  void reverseAcceptedStatus() {
    isAccepted = !isAccepted;
  }
}