import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tetris/block.dart';
import 'package:tetris/data.dart';
import 'package:tetris/sub_block.dart';

enum Collision { LANDED, LANDED_BLOCK, HIT_WALL, HIT_BLOCK, NONE }

const BLOCK_X = 10;
const BLOCK_Y = 20;
const GAME_AREA_BORDER_WIDTH = 2.0;
const SUB_BLOCK_EDGE_WIDTH = 2.0;
const REFRESH_RATE = 200;

class Game extends StatefulWidget {
  const Game({Key key}) : super(key: key);

  @override
  GameState createState() => GameState();
}

class GameState extends State<Game> {
  ///实际子块的宽度
  double subBlockWidth;

  GlobalKey _keyGameArea = GlobalKey();

  Block block;

  Timer timer;
  Duration duration = Duration(milliseconds: REFRESH_RATE);

  List<SubBlock> oldSubBlocks;

  BlockMovement action;

  bool isGameOver;

  Block getNewBlock() {
    int blockType = Random().nextInt(7);
    int orientationIndex = Random().nextInt(4);

    switch (blockType) {
      case 0:
        return IBlock(orientationIndex);
      case 1:
        return JBlock(orientationIndex);
      case 2:
        return LBlock(orientationIndex);
      case 3:
        return OBlock(orientationIndex);
      case 4:
        return TBlock(orientationIndex);
      case 5:
        return SBlock(orientationIndex);
      case 6:
        return ZBlock(orientationIndex);
      default:
        return null;
    }
  }

  void endGame() {
    context.read<Data>().setIsPlaying(false);
    timer.cancel();
  }

  void startGame() {
    isGameOver = false;
    context.read<Data>().setIsPlaying(true);
    context.read<Data>().setScore(0);

    oldSubBlocks = [];
    RenderBox renderBox = _keyGameArea.currentContext.findRenderObject();
    subBlockWidth =
        (renderBox.size.width - GAME_AREA_BORDER_WIDTH * 2) / BLOCK_X;

    context.read<Data>().setNextBlock(getNewBlock());
    block = getNewBlock();

    timer = Timer.periodic(duration, onPlay);
  }

  void onPlay(Timer timer) {
    var status = Collision.NONE;
    setState(() {
      if (action != null) {
        if (!checkOnEdge(action)) {
          block.move(action);
        }
      }

      checkHitBlock(action);

      if (!checkAtBottom()) {
        if (!checkAboveBlock()) {
          block.move(BlockMovement.DOWN);
        } else {
          status = Collision.LANDED_BLOCK;
        }
      } else {
        status = Collision.LANDED;
      }

      if (status == Collision.LANDED_BLOCK && block.y < 0) {
        isGameOver = true;
        endGame();
      } else if (status == Collision.LANDED ||
          status == Collision.LANDED_BLOCK) {
        block.subBlocks.forEach((subBlock) {
          subBlock.x += block.x;
          subBlock.y += block.y;
          oldSubBlocks.add(subBlock);
        });
        block = context.read<Data>().getNextBlock;
        context.read<Data>().setNextBlock(getNewBlock());
      }
      action = null;
      updateScore();
    });
  }

  void updateScore() {
    var combo = 1;
    Map<int, int> rows = new Map();
    List<int> rowsToBeRemoved = [];

    oldSubBlocks?.forEach((subBlock) {
      rows.update(subBlock.y, (value) => ++value, ifAbsent: () => 1);
    });

    rows.forEach((rowNum, count) {
      if (count == BLOCK_X) {
        context.read<Data>().addScore(combo++);
        rowsToBeRemoved.add(rowNum);
      }
    });

    if (rowsToBeRemoved.length > 0) {
      removeRows(rowsToBeRemoved);
    }
  }

  void removeRows(List<int> rowsToBeRemoved) {
    rowsToBeRemoved.forEach((rowNum) {
      oldSubBlocks.removeWhere((subBlock) => subBlock.y == rowNum);
      oldSubBlocks.forEach((subBlock) {
        if (subBlock.y < rowNum) {
          ++subBlock.y;
        }
      });
    });
  }

  ///判断是否到底部了
  bool checkAtBottom() {
    return block.y + block.height == BLOCK_Y;
  }

  ///判断是否在某个块上面
  bool checkAboveBlock() {
    for (var oldSubBlock in oldSubBlocks) {
      for (var subBlock in block.subBlocks) {
        var x = block.x + subBlock.x;
        var y = block.y + subBlock.y;

        if (x == oldSubBlock.x && y + 1 == oldSubBlock.y) {
          return true;
        }
      }
    }
    return false;
  }

  ///让两个块之间不能撞击然后进入另外一个块中，这是一个bug
  void checkHitBlock(BlockMovement action) {
    for (var oldSubBlock in oldSubBlocks) {
      for (var subBlock in block.subBlocks) {
        var x = block.x + subBlock.x;
        var y = block.y + subBlock.y;
        if (x == oldSubBlock.x && y == oldSubBlock.y) {
          switch (action) {
            case BlockMovement.RIGHT:
              block.move(BlockMovement.LEFT);
              break;
            case BlockMovement.LEFT:
              block.move(BlockMovement.RIGHT);
              break;
            case BlockMovement.ROTATE_CLOCKWISE:
              block.move(BlockMovement.ROTATE_COUNTER_CLOCKWISE);
              break;
            default:
              break;
          }
        }
      }
    }
  }

  bool checkOnEdge(BlockMovement action) {
    return (action == BlockMovement.LEFT && block.x <= 0) ||
        (action == BlockMovement.RIGHT && block.x + block.width >= BLOCK_X);
  }

  Widget getPositionSquareContainer(Color color, int x, int y) {
    return Positioned(
      child: Container(
        width: subBlockWidth - SUB_BLOCK_EDGE_WIDTH,
        height: subBlockWidth - SUB_BLOCK_EDGE_WIDTH,
        decoration: BoxDecoration(
            color: color,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(3)),
      ),
      left: x * subBlockWidth,
      top: y * subBlockWidth,
    );
  }

  Widget drawBlock() {
    if (block == null) return null;
    List<Positioned> subBlocks = new List();

    block.subBlocks.forEach((subBlock) {
      subBlocks.add(getPositionSquareContainer(
          subBlock.color, subBlock.x + block.x, subBlock.y + block.y));
    });

    oldSubBlocks?.forEach((subBlock) {
      subBlocks.add(
          getPositionSquareContainer(subBlock.color, subBlock.x, subBlock.y));
    });

    if (isGameOver) {
      subBlocks.add(getGameOverRect());
    }

    return Stack(
      children: subBlocks,
    );
  }

  Widget getGameOverRect() {
    return Positioned(
        child: Container(
          width: subBlockWidth * 8.0,
          height: subBlockWidth * 3.0,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Colors.red, borderRadius: BorderRadius.circular(10)),
          child: Text(
            'Game Over',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        left: subBlockWidth * 1.0,
        top: subBlockWidth * 8);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx > 0) {
          action = BlockMovement.RIGHT;
        } else {
          action = BlockMovement.LEFT;
        }
      },
      onVerticalDragUpdate: (details) {
        // print(details.delta.dy);
      },
      onTap: () {
        action = BlockMovement.ROTATE_CLOCKWISE;
      },
      child: AspectRatio(
        aspectRatio: BLOCK_X / BLOCK_Y,
        child: Container(
          key: _keyGameArea,
          decoration: BoxDecoration(
            color: Colors.indigo[800],
            border: Border.all(
                width: GAME_AREA_BORDER_WIDTH, color: Colors.indigoAccent),
            borderRadius: BorderRadius.circular(10),
          ),
          child: drawBlock(),
        ),
      ),
    );
  }
}
