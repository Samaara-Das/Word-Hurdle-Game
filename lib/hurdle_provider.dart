import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:english_words/english_words.dart' as words;
import 'wordle.dart';

class HurdleProvider extends ChangeNotifier {
  final random = Random.secure();
  List<String> totalWords = [];
  List<String> rowInputs = [];
  List<String> excludedLetters = [];
  List<Wordle> hurdleBoard = [];
  String targetWord = '';
  int count = 0;
  int index = 0;
  final lettersPerRow = 5;
  final totalAttempts = 6;
  int attempts = 0;
  bool wins = false;

  bool get shouldCheckForAnswer => rowInputs.length == lettersPerRow;

  bool get noAttemptsLeft => attempts == totalAttempts;

  init() {
    totalWords = words.all.where((element) => element.length == 5).toList();
    generateBoard();
    generateRandomWord();
  }

  generateBoard() {
    hurdleBoard = List.generate(30, (index) => Wordle(letter: ''));
  }

  generateRandomWord() {
    targetWord = totalWords[random.nextInt(totalWords.length)].toUpperCase();
    print(targetWord);
  }

  bool get isAValidWord => totalWords.contains(rowInputs.join('').toLowerCase());

  inputLetter(String letter) {
    if(count < lettersPerRow) {
      count++;
      hurdleBoard[index] = Wordle(letter: letter);
      index++;
      rowInputs.add(letter);
      notifyListeners();
    }
  }

  void deleteLetter() {
    if(rowInputs.isNotEmpty) {
      rowInputs.removeAt(rowInputs.length - 1);
    }

    if(count > 0) {
      hurdleBoard[index - 1] = Wordle(letter: '');
      count--;
      index--;
    }

    notifyListeners();
  }

  void checkAnswer() {
    final input = rowInputs.join('');
    if(targetWord == input) {
      wins = true;
    } else {
      _markLetterOnBoard();
      if(attempts < totalAttempts) {
        _goToNextRow();
      }
    }
  }

  void _markLetterOnBoard() {
    for(int i = 0; i < hurdleBoard.length; i++) {
      final letter = hurdleBoard[i].letter;

      if(letter.isNotEmpty && targetWord.contains(letter)) {
        hurdleBoard[i].existsInTarget = true;
      } else if(letter.isNotEmpty && !targetWord.contains(letter)) {
        hurdleBoard[i].doesNotExistInTarget = true;
        excludedLetters.add(letter);
      }
      notifyListeners();
    }
  }

  void _goToNextRow() {
    attempts++;
    count = 0;
    rowInputs.clear();
  }

  reset() {
    count = 0;
    index = 0;
    rowInputs.clear();
    hurdleBoard.clear();
    excludedLetters.clear();
    attempts = 0;
    wins = false;
    targetWord = '';
    generateBoard();
    generateRandomWord();
    notifyListeners();
  }
}

