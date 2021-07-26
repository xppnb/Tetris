import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tetris/data.dart';

class ScoreBar extends StatefulWidget {
  final score;

  const ScoreBar({Key key, this.score}) : super(key: key);

  @override
  _ScoreBarState createState() => _ScoreBarState();
}

class _ScoreBarState extends State<ScoreBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Text(
        "Score:${context.read<Data>().getScore}",
        style: TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          gradient:
              LinearGradient(colors: [Colors.indigo[800], Colors.indigo[300]])),
    );
  }
}
