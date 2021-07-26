import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tetris/block.dart';

class Data extends ChangeNotifier {
  int score = 0;
  bool isPlaying = false;
  Block nextBlock;

  void setScore(int score) {
    this.score = score;
    notifyListeners();
  }

  void addScore(int score) {
    this.score += score;
    notifyListeners();
  }

  void setIsPlaying(bool isPlaying) {
    this.isPlaying = isPlaying;
    notifyListeners();
  }

  bool get getIsPlaying {
    return this.isPlaying;
  }

  int get getScore {
    return this.score;
  }

  void setNextBlock(Block nextBlock) {
    this.nextBlock = nextBlock;
    notifyListeners();
  }

  Block get getNextBlock{
    return this.nextBlock;
  }

  Widget getNextBlockWidget() {
    if (!isPlaying) {
      return Container();
    }
    var width = nextBlock.width;
    var height = nextBlock.height;
    var color;

    List<Row> columns = [];
    for (int y = 0; y < height; ++y) {
      List<Container> rows = [];
      for (int x = 0; x < width; ++x) {
        if (nextBlock.subBlocks
                .where((subBlock) => subBlock.x == x && subBlock.y == y)
                .length >
            0) {
          color = nextBlock.color;
        } else {
          color = Colors.transparent;
        }
        rows.add(Container(
          width: 12,
          height: 12,
          color: color,
        ));
      }
      columns.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: rows,
      ));
    }

    return Column(
      children: columns,
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }
}
