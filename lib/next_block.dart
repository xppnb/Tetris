import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tetris/data.dart';

class NextBlock extends StatefulWidget {
  const NextBlock({Key key}) : super(key: key);

  @override
  _NextBlockState createState() => _NextBlockState();
}

class _NextBlockState extends State<NextBlock> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5), color: Colors.white),
      width: double.infinity,
      padding: EdgeInsets.all(5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Next",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 5,
          ),
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              color: Colors.indigo[600],
              child: context.read<Data>().getNextBlockWidget(),
            ),
          )
        ],
      ),
    );
  }
}
