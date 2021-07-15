import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final request = 'https://api.hgbrasil.com/finance?key=${dotenv.env['API_KEY']}';

void main() async {
  await dotenv.load(fileName: ".env");

  runApp(MyApp());
}

Future<Map> getData() async {
  http.Response response = await http.get(Uri.parse(request));
  return json.decode(response.body);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primarySwatch: Colors.blueGrey,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double dollar = 0;
  double euro = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Coin Conversion'),
        ),
        body: Center(
            child: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: Text(
                    'Loading...',
                    style: TextStyle(fontSize: 25),
                    textAlign: TextAlign.center,
                  ),
                );
              default:
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error!!!',
                      style: TextStyle(fontSize: 25),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else {
                  dollar =
                      snapshot.data!['results']["currencies"]["USD"]['buy'];
                  euro = snapshot.data!['results']["currencies"]["EUR"]['buy'];
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          Icons.monetization_on_rounded,
                          size: 160,
                        ),
                        TextFieldBuilder('Reais', 'R\$ '),
                        SizedBox(height: 20,),
                        TextFieldBuilder('Dollar', ' \$ '),
                        SizedBox(height: 20,),
                        TextFieldBuilder('Euro', ' € '),
                      ],
                    ),
                  );
                }
            }
          },
        )));
  }
}

Widget TextFieldBuilder(String label, String prefix) {
  return TextField(
    decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        prefixText: prefix
    ),
  );
}
