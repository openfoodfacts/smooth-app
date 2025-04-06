import 'package:flutter/material.dart';
import 'dart:math';

class SugarGuessingGame extends StatefulWidget {
  const SugarGuessingGame({super.key});

  @override
  _SugarGuessingGameState createState() => _SugarGuessingGameState();
}

class _SugarGuessingGameState extends State<SugarGuessingGame> {
  int guess = 0;
  int actualSugar = 0;
  List<String> items = ["Chocolate Bar", "Cake", "Candy", "Ice Cream"];
  String currentItem = "";

  @override
  void initState() {
    super.initState();
    actualSugar = Random().nextInt(10) + 1; // 1-10 random
    currentItem = items[Random().nextInt(items.length)]; // Random item
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("How Much Sugar?")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Guess sugar cubes for: $currentItem"),
            SizedBox(height: 20),
            TextField(
              onChanged: (value) {
                setState(() => guess = int.tryParse(value) ?? 0);
              },
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Your Guess"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Result"),
                    content: Text("You guessed: $guess\nActual: $actualSugar cubes"),
                    actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("OK"))],
                  ),
                );
              },
              child: Text("Submit Guess"),
            ),
          ],
        ),
      ),
    );
  }
}