import 'package:enhanced_ctf/utils/helpers/calculate_page_height.dart';
import 'package:enhanced_ctf/utils/helpers/navigation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:enhanced_ctf/pages/select_name_and_team_screen.dart';
import '../utils/services/my_game_state.dart';
import '../utils/helpers/regex.dart';
import '../utils/helpers/design_constants.dart';
import '../widgets/text_with_outline.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: JoinGameScreen());
  }
}

class JoinGameScreen extends StatefulWidget {
  const JoinGameScreen({Key? key}) : super(key: key);

  @override
  _JoinGameScreenState createState() => _JoinGameScreenState();
}

class _JoinGameScreenState extends State<JoinGameScreen> {
  final textEditController = TextEditingController();
  final GameState _gameState = GameState();
  final _formKey = GlobalKey<FormState>();
  void _attemptSetGameId() {
    //there should be verification in here.
    String currentTextField = textEditController.text;
    String? extractedGameID =
        isValidGameId(currentTextField); //checks if it's valid
    if (extractedGameID != null) {
      //first we load the new gameID into our gamestate.
      _gameState.attemptGameID = extractedGameID;
      //then we switch the navigator
      _gameState.createdGame = false;
      newPageReversible(context, const SelectNameAndTeamScreen());
    } else {
      debugPrint(
          "Invalid game ID! we should never get here because the form is validated before we are here");
    }
  }

  @override
  void dispose() {
    textEditController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstants.bannerColor,
        centerTitle: true,
        title: AppConstants.topOfAppBarText,
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints:
              BoxConstraints(minHeight: calculateMaxPageHeight(context)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                // padding: const EdgeInsets.only(
                //     top: 200.0, right: 40.0, left: 40.0, bottom: 200.0),
                padding: const EdgeInsets.all(30.0),
                child: Form(
                  key: _formKey,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const TextWithOutline(
                          fontSize: 30,
                          strokeColor: Colors.black,
                          strokeWidth: 5,
                          text: "Game ID:",
                          textColor: Colors.white),
                      Expanded(
                        child: TextFormField(
                          validator: (text) {
                            if (text == null || isValidGameId(text) == null) {
                              return "Please enter a valid Game ID (6 letters A-Z)";
                            } else {
                              return null;
                            }
                          },
                          controller: textEditController,
                          keyboardType: TextInputType.name,
                          autofocus: false,
                          decoration: InputDecoration(
                            hintText: "Enter 6 letter Game ID",
                            errorMaxLines: 3,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 10),
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                width: 10, // Doesn't work for some reason
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    //if the form is valid
                    _attemptSetGameId(); //should only push new page if successful.
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.white),
                ),
                child: const Text(
                  'Join Game',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
