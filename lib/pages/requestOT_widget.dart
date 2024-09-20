import 'package:flutter/material.dart';

class RequestOTScrollableWidget extends StatelessWidget {
  late List<List<String>> othersRequests;
  Color color = Colors.black;

  RequestOTScrollableWidget(List<List<String>> othersRequests) {
    this.othersRequests = othersRequests;
  }

  Widget _confirmAcceptance(BuildContext context, String team) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            child: Text(
              "$team notified!",
              style: TextStyle(
                    fontSize: 20,
                    color: color
                  )
            ),
          ),
        ],
      ),
      backgroundColor: Colors.orangeAccent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
