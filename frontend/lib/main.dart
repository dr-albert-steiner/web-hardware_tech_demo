import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(DemoApp());
}

class DemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Демо',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Тех демо'),
    );
  }
}

class SensorData{
  final double data;

  SensorData({this.data});

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      data: json['temperature'],
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}



class _MyHomePageState extends State<MyHomePage> {
  bool _useRealData = false;

  Stream<SensorData> _temperatureUpdater() async* {
    while(true) {
      await Future.delayed(Duration(milliseconds: 1000));
      final response = await http.get('http://127.0.0.1:8000/api/sensors/');

      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        yield SensorData.fromJson(jsonDecode(response.body));
      }
    }
  }

  @override
  void initState(){
    super.initState();
  }

  void _onUseRealDataChanged(bool newValue){
    setState(() {
      _useRealData = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.all(15.0),
              padding: const EdgeInsets.all(3.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Использовать данные с микроконтроллера',
                  ),
                  Switch(
                    value: _useRealData,
                    onChanged: _onUseRealDataChanged,
                  ),
                ],
              ),
            ),
            Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: Container(
                        child: Column(
                          children: [
                            Container(
                              child: Container(
                                child: Text("Segnetics"),
                              ),
                              padding: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 20.0),
                            ),
                            IntrinsicWidth(
                              child: Row(
                                children: [
                                  Text("Температура: "),
                                  StreamBuilder<SensorData>(
                                    stream: _temperatureUpdater(),
                                    builder: (context, snapshot) {
                                      if(_useRealData){
                                        if (snapshot.connectionState == ConnectionState.active)
                                          return Text(snapshot.data.data.toString());

                                        return CircularProgressIndicator();
                                      }
                                      return Text("20.00");
                                    },
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    fit: FlexFit.loose,
                    child: Container(
                      padding: const EdgeInsets.all(5.0),
                      margin: const EdgeInsets.all(2.0),
                      child: Text("Arduino"),
                    )
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
