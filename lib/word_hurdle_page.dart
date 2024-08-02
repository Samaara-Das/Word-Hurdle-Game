import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:word_hurdle/audio.dart';
import 'package:word_hurdle/helper_functions.dart';
import 'package:word_hurdle/hurdle_provider.dart';
import 'package:word_hurdle/keyboard_view.dart';
import 'package:word_hurdle/wordle_view.dart';

class WordHurdlePage extends StatefulWidget {
  const WordHurdlePage({super.key});

  @override
  State<WordHurdlePage> createState() => _WordHurdlePageState();
}

class _WordHurdlePageState extends State<WordHurdlePage> {
  @override
  void didChangeDependencies() {
    Provider.of<HurdleProvider>(context, listen: false).init();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Word Hurdle'),
      ),
      body: Center(
          child: Column(
            children: [
              Expanded(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.70, // Gridview will take up 70% of the screen
                  child: Consumer<HurdleProvider>(
                    builder: (context, provider, child) =>
                        GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, mainAxisSpacing: 4, crossAxisSpacing: 4),
                          itemCount: provider.hurdleBoard.length,
                          itemBuilder: (context, index) {
                            final wordle = provider.hurdleBoard[index];
                            return WordleView(wordle: wordle);
                          },
                        ),
                  ),
                ),
              ),

              Consumer<HurdleProvider>(
                builder: (context, provider, child) =>
                  KeyboardView(
                    excludedLetters: provider.excludedLetters,
                    onPressed: (value) {
                      provider.inputLetter(value);
                    },
                  )
              ),

              Padding(
                padding: EdgeInsets.all(16),
                child: Consumer<HurdleProvider>(
                  builder: (context, provider, child) =>
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              provider.deleteLetter();
                            },
                            child: const Text('Delete'),
                          ),
                          submitButton(provider, context)
                        ],
                      ),
                ),
              )
            ],
          )),
    );
  }

  ElevatedButton submitButton(HurdleProvider provider, BuildContext context) {
    return ElevatedButton(
      onPressed: provider.count < 5 ? null: () {
        if (!provider.isAValidWord) { // Scenario 1
          showMsg(context, 'Invalid word');
          return;
        }

        if (provider.shouldCheckForAnswer) { // Scenario 2
          provider.checkAnswer();
        }

        if (provider.wins) { // Scenario 3
          print('Player won');
          Player.play('win-sound.wav');

          showResult(
            context: context,
            title: 'You win!',
            body: 'The word was ${provider.targetWord}',
            onPlayAgain: () {
              Navigator.pop(context);
              provider.reset();
            },
            onCancel: () {
              Navigator.pop(context);
            }
          );
        }

        else if(provider.noAttemptsLeft) { // Scenario 4
          showResult(
            context: context,
            title: 'You lost!',
            body: 'The word was ${provider.targetWord}',
            onPlayAgain: () {
              Navigator.pop(context);
              provider.reset();
            },
            onCancel: () {
              Navigator.pop(context);
            }
          );
        }
      },
      child: const Text('Submit'),
    );
  }
}
