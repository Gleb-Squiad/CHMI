import 'package:chmi/card.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return (MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFFe5e5e7),
        body: SafeArea(
          child: Column(
            children: [
              Flexible(
                flex: 40,
                child: Container(
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(30),
                      ),
                      color: Colors.white),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Flexible(
                          flex: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(
                                226,
                                174,
                                187,
                                1,
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Container(),
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  'Теплица',
                                  style: TextStyle(
                                    fontSize: 23,
                                  ),
                                ),
                                Icon(Icons.edit),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFe5e5e7),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(30),
                    ),
                  ),
                ),
              ),
              Flexible(
                flex: 40,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SensorsCard(
                        key: key,
                        name: 'Температура',
                        avgValue: '250 K',
                        values: const ['200 K', '300 K'],
                        errors: const [false, false],
                      ),
                      SensorsCard(
                        key: key,
                        name: 'Влажность воздуха',
                        avgValue: '32%',
                        values: const ['30%', '34%'],
                        errors: const [true, false],
                      ),
                      SensorsCard(
                        key: key,
                        name: 'Влажность почвы',
                        avgValue: '7%',
                        values: const ['12%', '2%'],
                        errors: const [false, true],
                      ),
                      SensorsCard(
                        key: key,
                        name: 'Уровень воды',
                        avgValue: '15 см%',
                        values: const ['15 см', '15 см'],
                        errors: const [false, true],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    ));
  }
}
