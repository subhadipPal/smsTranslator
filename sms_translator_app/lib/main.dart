import 'package:flutter/material.dart';
import 'package:sms/sms.dart';
import 'dart:core';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());
final ThemeData androidTheme =
    new ThemeData(primarySwatch: Colors.indigo, accentColor: Colors.white);
String dropdownValue = 'en';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) {
    return new MaterialApp(
        title: 'SMS Translator',
        theme: androidTheme,
        home: new Scaffold(
          appBar: new AppBar(title: Text("SMS Translator")),
          body: SmsList(),
        ));
  }
}

class SmsList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new SmsListState();
}

class SmsListState extends State<SmsList> {
  SmsQuery query;
  SmsReceiver receiver = new SmsReceiver();
  List<SmsMessage> smsList = new List<SmsMessage>();
  ListView smsListView = new ListView();

  @override
  void initState() {
    super.initState();
    receiver.onSmsReceived.listen((smsMessage) => getSms());
    getSms();
  }

  Future<void> getSms() async {
    try {
      query = new SmsQuery();
      List<SmsMessage> messages = await query.getAllSms;
      createListView(messages);
    } catch (e) {
      print('failed: ${e.toString()}');
    }
  }

  void createListView(List<SmsMessage> messages) {
    ListView tempListViewBuilder = new ListView.builder(
        padding: const EdgeInsets.all(10.0),
        itemCount: messages.length,
        itemBuilder: (context, i) => ListTile(
              title: Text(messages[i].address),
              subtitle: Text(messages[i].body),
              onTap: () {
                translateText(messages[i].body).then((translatedMap) {
                  String translatedText = translatedMap["translatedText"];
                  String detectedSourceLanguage = translatedMap["detectedSourceLanguage"];
                  print("detectedSourceLanguage: "+detectedSourceLanguage);
                  infoDialog(context,
                      new SmsMessage(messages[i].address, translatedText));
                });
              },
            ));
    setState(() {
      smsListView = tempListViewBuilder;
    });
    setState(() {
      smsList = messages;
    });
  }

  Future<Map<String, String>> translateText(String smsText) async{
    Uri translationUri = Uri.https("https://translation.googleapis.com", "/language/translate/v2",{
      "target":dropdownValue,
      "key":"AIzaSyDGNd8nxLsmEKitdXx4kLRLSqHEtlRDbjQ",
      "q":smsText
    });
    var res = await http.get(translationUri, headers: {"Accept": "application/json"});
    var responseBody = json.decode(res.body);
    return responseBody["data"]["translations"][0];
  }

  infoDialog(context, smsMessage) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(smsMessage.address),
            content: Text(smsMessage.body),
            actions: <Widget>[
              FlatButton(
                child: Text('Okay'),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          );
        });
  }

  void onSyncSMS() {
    getSms();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          actions: <Widget>[
            DropdownButton<String>(
              value: dropdownValue,
              onChanged: (String newValue) {
                setState(() {
                  dropdownValue = newValue;
                });
              },
              items: <String>['en', 'de', 'hi']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            )
          ],
        ),
        body: smsListView,
        floatingActionButton: new Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              new Container(
                margin: const EdgeInsets.only(top: 20.0),
                child: FloatingActionButton.extended(
                    icon: Icon(Icons.autorenew, size: 30.0),
                    onPressed: onSyncSMS,
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    label: Text("Sync")),
                width: 160.0,
                height: 60.0,
              )
            ]));
  }
}
