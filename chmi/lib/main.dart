import 'dart:developer';

import 'package:chmi/card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:socket_io_client/socket_io_client.dart';

void main() {
  runApp(const MaterialApp(home: App()));
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late Socket socket;
  late List humidityAir;
  late List temperature;
  late List humiditySoil;
  late List servos;
  late List hudSensors;
  late List waterLevel;
  final url = Uri.parse('https://hmiapi.vercel.app/');
  void connect() {
    try {
      socket = io(url, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      });

      socket.connect();

      socket.on('data', (data) {
        humidityAir = [
          data.airHumidities[0].value,
          data.airHumidities[1].value,
        ];
        temperature = [
          data.temperatures[0].value,
          data.temperatures[1].value,
        ];
        humiditySoil = [
          data.groundHumidities[0].value,
          data.groundHumidities[1].value,
        ];
        waterLevel = [
          !data.waterLevel[0].isLow,
          '',
        ];
        servos = [
          data.servos[0].value,
          data.servos[1].value,
        ];
        hudSensors = [
          data.pump.value,
          data.humidifier.value,
        ];
      });
      socket.on('new_data', (data) {});
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  void initState() {
    connect();
  }

  @override
  Widget build(BuildContext context) {
    void showSettingsChange(String type) {
      late int value;
      showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              content: Container(
                height: 230,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(children: [
                  const Text(
                    'Назначьте новое значение',
                    style: TextStyle(fontSize: 25),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    onChanged: (e) {
                      value = int.parse(e);
                    },
                    decoration:
                        const InputDecoration(labelText: "Введите значение"),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: InkWell(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade700,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(15),
                          child: Text(
                            'Сохранить',
                            style: TextStyle(color: Colors.white, fontSize: 25),
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(_);
                        socket.emit('change_settings', [value.toString(),type.toString()]);
                      },
                    ),
                  )
                ]),
              ),
            );
          });
    }

    void showSettings() {
      showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              content: Container(
                height: 450,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Center(
                    child: Column(
                      children: [
                        const Text(
                          'Изменение параметров',
                          style: TextStyle(fontSize: 25),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pop(_);
                            showSettingsChange('airHum');
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade700,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Уровень влажности воздуха',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 25),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pop(_);
                            showSettingsChange('soilHum');
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade700,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Уровень влажности воды',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 25),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pop(_);
                            showSettingsChange('temp');
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade700,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Уровень температуры воздуха',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 25),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
    }

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
                            child: const Center(
                              child: Image(
                                image: AssetImage('assets/images/screen.png'),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Теплица',
                                  style: TextStyle(
                                    fontSize: 23,
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                InkWell(
                                  child: const Icon(Icons.settings),
                                  onTap: () {
                                    showSettings();
                                  },
                                ),
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
                        key: widget.key,
                        name: 'Температура',
                        avgValue: '${(temperature[0] + temperature[1]) / 2} °C',
                        values: [
                          '${temperature[0]} °C',
                          '${temperature[1]} °C'
                        ],
                        errors: const [false, false],
                      ),
                      SensorsCard(
                        key: widget.key,
                        name: 'Влажность воздуха',
                        avgValue: '${(humidityAir[0] + humidityAir[1]) / 2}%',
                        values: ['${humidityAir[0]}%', '${humidityAir[1]}%'],
                        errors: const [true, false],
                      ),
                      SensorsCard(
                        key: widget.key,
                        name: 'Влажность почвы',
                        avgValue: '${(humiditySoil[0] + humiditySoil[1]) / 2}%',
                        values: ['${humiditySoil[0]}%', '${humiditySoil[1]}%'],
                        errors: const [false, true],
                      ),
                      SensorsCard(
                        key: widget.key,
                        name: 'Уровень воды',
                        avgValue:
                            waterLevel[0] == false ? 'Ниже нормы' : 'Норма',
                        values: [
                          waterLevel[0] == false ? 'Ниже нормы' : 'Норма',
                          ''
                        ],
                        errors: const [false, true],
                      ),
                      SensorsCard(
                          key: widget.key,
                          name: 'Контроллеры температуры',
                          avgValue: servos[0] && servos[1]
                              ? 'Исправны'
                              : 'Есть проблема',
                          values: [
                            servos[0] == true ? 'Исправен' : 'Есть проблема',
                            servos[1] == true ? 'Исправен' : 'Есть проблема',
                          ],
                          errors: [
                            !servos[0],
                            !servos[1]
                          ]),
                      SensorsCard(
                          key: widget.key,
                          name: 'Контроллеры влажности',
                          avgValue: hudSensors[0] && hudSensors[1]
                              ? 'Исправны'
                              : 'Есть проблема',
                          values: [
                            hudSensors[0] == true
                                ? 'Помпа исправна'
                                : 'Проблема с помпой',
                            hudSensors[1] == true
                                ? 'Увлажнитель исправен'
                                : 'Проблема с увлажнителем',
                          ],
                          errors: [
                            !hudSensors[0],
                            !hudSensors[1]
                          ])
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
