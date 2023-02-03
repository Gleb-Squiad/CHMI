import 'package:flutter/material.dart';

class SensorsCard extends StatefulWidget {
  final String name;
  final String avgValue;
  final List<String> values;
  final List<bool> errors;

  const SensorsCard(
      {required super.key,
      required this.name,
      required this.avgValue,
      required this.values,
      required this.errors});

  @override
  State<SensorsCard> createState() => _SensorsCardState();
}

class _SensorsCardState extends State<SensorsCard> {
  bool isOpen = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: (Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          style: const TextStyle(),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          widget.avgValue,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    IconButton(
                        onPressed: () {
                          setState(() {
                            isOpen = !isOpen;
                          });
                        },
                        icon: Icon(isOpen
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded))
                  ],
                ),
                isOpen
                    ? Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  widget.errors[0] == true
                                      ? const Icon(
                                          Icons.error_outline,
                                          size: 20,
                                          color: Colors.red,
                                        )
                                      : Container(),
                                  const Text('Датчик №1')
                                ],
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFf2f2f2),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 3,
                                    ),
                                    child: Text(
                                      widget.values[0],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  widget.errors[1] == true
                                      ? const Icon(
                                          Icons.error_outline,
                                          size: 20,
                                          color: Colors.red,
                                        )
                                      : Container(),
                                  const Text('Датчик №2')
                                ],
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFf2f2f2),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 3,
                                    ),
                                    child: Text(
                                      widget.values[1],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      )
                    : Container()
              ],
            ),
          )),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
