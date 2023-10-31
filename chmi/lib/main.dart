import 'dart:async';
import 'dart:developer';

import 'package:chmi/card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  late int tempLimit = 30;
  late int humAirLimit = 50;
  late int humSoilLimit = 0;
  late List humidityAir = [0, 0];
  late List temperature = [0, 0];
  late List humiditySoil = [0, 0];
  late List<bool> groundErrors = [false, false];
  late List<bool> tempErrors = [false, false];
  late List<bool> airErrors = [false, false];
  late List<bool> servos = [false, false];
  late List<bool> hudSensors = [true, true];
  late List<bool> waterLevel = [true, true];
  Timer scheduleTimeout([int milliseconds = 10000]) =>
      Timer(Duration(milliseconds: milliseconds), handleTimeout);
//Соединение с сервером
  void handleTimeout() {
    connect();
  }

  void connect() {
    try {
      socket = io(
          'Ссылка на сервер',
          OptionBuilder().setTransports(['websocket']).setExtraHeaders(
              {'authorization': 'Token'}).build());

      log('321');
      
      socket.onConnect((_) {
        log('connect');
        socket.emit('msg', 'test');
      });
      socket.onDisconnect((_) => log('disconnect'));
      socket.on('THLevelUpdate', (data) {
        log(data.toString());
      });
      socket.on('WLevelUpdate', (data) {
        log(data.toString());
      });
      socket.on('Data', (data) {
        log(data.toString());
        humidityAir = [
          data['airHumidities'][0]['value'],
          data['airHumidities'][1]['value'],
        ];
        setState(() {});
        temperature = [
          data['temperatures'][0]['value'],
          data['temperatures'][1]['value'],
        ];
        setState(() {});
        waterLevel = [data['waterLevel'], true];
        setState(() {});
        humiditySoil = [
          data['groundHumidities'][0]['value'],
          data['groundHumidities'][1]['value'],
        ];
        setState(() {});
        groundErrors = [
          !data['sensors'][0]['isWorking'],
          !data['sensors'][5]['isWorking'],
        ];
        setState(() {});
        servos = [
          !data['sensors'][9]['isWorking'],
          !data['sensors'][9]['isWorking'],
        ];
        setState(() {});
        tempErrors = [
          !data['sensors'][1]['isWorking'],
          !data['sensors'][3]['isWorking'],
        ];
        setState(() {});
        airErrors = [
          !data['sensors'][2]['isWorking'],
          !data['sensors'][4]['isWorking'],
        ];
        setState(() {});
        hudSensors = [
          data['sensors'][7]['isWorking'],
          data['sensors'][8]['isWorking'],
        ];
        
      });
      socket.connect();
    } catch (e) {
      log(e.toString());
    }
  }
//Конец соединения с севрером
//ДОставание инфы из кеша
  Future<void> getLimits() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    tempLimit = prefs.getInt('tempLimit') ?? 0;
    humAirLimit = prefs.getInt('humAirLimit') ?? 0;
    humSoilLimit = prefs.getInt('humSoilLimit') ?? 0;
  }

  @override
  void initState() {
    getLimits();
    connect();
    super.initState();
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
                      onTap: () async {
                        Navigator.pop(_);
                        final SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        if (type == 'airHum') {
                          humAirLimit = value;

                          prefs.setInt('humAirLimit', tempLimit);
                        }
                        if (type == 'soilHum') {
                          humSoilLimit = value;
                          prefs.setInt('humSoilLimit', humSoilLimit);
                        }
                        if (type == 'temp') {
                          tempLimit = value;
                          prefs.setInt('tempLimit', tempLimit);
                        }
                        setState(() {});
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
                                'Уровень влажности почвы',
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
                  child: temperature[0] == 0
                      ? const CircularProgressIndicator()
                      : Column(
                          children: [
                            SensorsCard(
                              isRed: (temperature[0] + temperature[1]) / 2 >
                                  tempLimit,
                              key: widget.key,
                              name: 'Температура',
                              avgValue:
                                  '${(temperature[0] + temperature[1]) / 2} °C',
                              values: [
                                '${temperature[0]} °C',
                                '${temperature[1]} °C'
                              ],
                              errors: airErrors,
                            ),
                            SensorsCard(
                              isRed: (humidityAir[0] + humidityAir[1]) / 2 <
                                  humAirLimit,
                              key: widget.key,
                              name: 'Влажность воздуха',
                              avgValue:
                                  '${(humidityAir[0] + humidityAir[1]) / 2}%',
                              values: [
                                '${humidityAir[0]}%',
                                '${humidityAir[1]}%'
                              ],
                              errors: airErrors,
                            ),
                            SensorsCard(
                              isRed: (humiditySoil[0] + humiditySoil[1]) / 2 <
                                  humSoilLimit,
                              key: widget.key,
                              name: 'Влажность почвы',
                              avgValue:
                                  '${(humiditySoil[0] + humiditySoil[1]) / 2}%',
                              values: [
                                '${humiditySoil[0]}%',
                                '${humiditySoil[1]}%'
                              ],
                              errors: groundErrors,
                            ),
                            SensorsCard(
                              isRed: !waterLevel[0],
                              key: widget.key,
                              name: 'Уровень воды',
                              avgValue: waterLevel[0] == false
                                  ? 'Ниже нормы'
                                  : 'Норма',
                              values: [
                                waterLevel[0] == false ? 'Ниже нормы' : 'Норма',
                                ''
                              ],
                              errors: const [false, true],
                            ),
                            SensorsCard(
                                isRed: tempErrors[0] && tempErrors[1],
                                key: widget.key,
                                name: 'Контроллеры температуры',
                                avgValue: !tempErrors[0] && !tempErrors[1]
                                    ? 'Исправны'
                                    : 'Есть проблема',
                                values: [
                                  !tempErrors[0] == true
                                      ? 'Исправен'
                                      : 'Есть проблема',
                                  !tempErrors[1] == true
                                      ? 'Исправен'
                                      : 'Есть проблема',
                                ],
                                errors: tempErrors),
                            SensorsCard(
                                isRed: !hudSensors[0] && hudSensors[1],
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
