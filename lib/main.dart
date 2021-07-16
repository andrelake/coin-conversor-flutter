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
  double dolar = 0;
  double euro = 0;

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  _realOnChange(String text) {
    if(text.isEmpty) {
      clearAllFields();
      return;
    }

    double real = double.parse(text);

    dolarController.text = (real/dolar).toStringAsFixed(2);
    euroController.text = (real/euro).toStringAsFixed(2);

    print(text);
  }

  _dolarOnChange(String text) {
    if(text.isEmpty) {
      clearAllFields();
      return;
    }

    double dolarTipped = double.parse(text);

    realController.text = (dolarTipped * this.dolar).toStringAsFixed(2);
    euroController.text = (dolarTipped * this.dolar / euro).toStringAsFixed(2);

  }

  _euroOnChange(String text) {
    if(text.isEmpty) {
      clearAllFields();
      return;
    }

    double euroTipped = double.parse(text);

    realController.text = (euroTipped * this.euro).toStringAsFixed(2);
    dolarController.text = (euroTipped * this.euro / dolar).toStringAsFixed(2);
  }

  clearAllFields() {
    realController.text = '';
    dolarController.text = '';
    euroController.text = '';
  }

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
                  dolar = snapshot.data!['results']["currencies"]["USD"]['buy'];
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
                        textFieldBuilder('Reais', 'R\$ ', realController, _realOnChange),
                        SizedBox(height: 20,),
                        textFieldBuilder('Dolar', ' \$ ', dolarController, _dolarOnChange),
                        SizedBox(height: 20,),
                        textFieldBuilder('Euro', ' € ', euroController, _euroOnChange),
                      ],
                    ),
                  );
                }
            }
          },
        )));
  }
}

Widget textFieldBuilder(String label, String prefix, TextEditingController controller, Function(String)? function) {
  return TextField(
    decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        prefixText: prefix
    ),
    controller: controller,
    onChanged: function,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
  );
}
