import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tetris/score_bar.dart';

import 'data.dart';
import 'game.dart';
import 'next_block.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(ChangeNotifierProvider(
    create: (context) => Data(),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MaterialApp(
      home: Tetris(),
    );
  }
}

class Tetris extends StatefulWidget {
  const Tetris({Key key}) : super(key: key);

  @override
  _TetrisState createState() => _TetrisState();
}

class _TetrisState extends State<Tetris> {
  GlobalKey<GameState> _keyGame = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.indigo,
        appBar: AppBar(
          title: Text("TETRIS"),
          centerTitle: true,
          backgroundColor: Colors.indigoAccent,
        ),
        body: SafeArea(
            child: Column(
              children: [
                ScoreBar(),
                Expanded(
                    child: Center(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              child: Game(
                                key: _keyGame,
                              ),
                            ),
                            flex: 3,
                          ),
                          Flexible(
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  NextBlock(),
                                  SizedBox(
                                    height: 30,
                                  ),
                                  RaisedButton(
                                    onPressed: () {
                                      context
                                          .read<Data>()
                                          .getIsPlaying
                                          ? _keyGame.currentState.endGame()
                                          : _keyGame.currentState.startGame();
                                    },
                                    color: Colors.indigo[700],
                                    child: Text(
                                      Provider
                                          .of<Data>(context)
                                          .getIsPlaying
                                          ? "end"
                                          : "Start",
                                      style:
                                      TextStyle(
                                          color: Colors.white, fontSize: 18),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            flex: 1,
                          ),
                        ],
                      ),
                    ))
              ],
            )));
  }
}
