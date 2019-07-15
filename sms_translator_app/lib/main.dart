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
Map<String, String> languagesMap = new Map.fromIterables([
  "en",
  "de",
  "hi",
  "af",
  "ar",
  "bn",
  "zh-CN",
  "tl",
  "fr",
  "el",
  "it",
  "ja",
  "ko",
  "ru",
  "ta",
  "te",
  "th",
  "vi"
], [
  "English",
  "German",
  "Hindi",
  "Afrikaans",
  "Arabic",
  "Bengali",
  "Chinese-Simplified",
  "Filipino",
  "French",
  "Greek",
  "Italian",
  "Japanese",
  "Korean",
  "Russian",
  "Tamil",
  "Telegu",
  "Thai",
  "Vietnamese"
]);

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
                  String detectedSourceLanguage =
                      translatedMap["detectedSourceLanguage"];
                  Map<String, String> smsDisplayObject = new Map.fromIterables([
                    "originalMsg",
                    "translatedMessage",
                    "detectedSourceLanguage",
                    "address"
                  ], [
                    messages[i].body,
                    translatedText,
                    detectedSourceLanguage,
                    messages[i].address
                  ]);
                  infoDialog(context, smsDisplayObject);
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

  Future<Map> translateText(String smsText) async {
    Uri translationUri =
        Uri.https("translation.googleapis.com", "/language/translate/v2", {
      "target": dropdownValue,
      "key": "test",
      "q": smsText
    });
    var res =
        await http.get(translationUri, headers: {"Accept": "application/json"});
    var responseBody = json.decode(res.body);
    Map translatedTextMap = responseBody["data"]["translations"][0];
    return translatedTextMap;
  }

  void infoDialog(context, smsDisplayObject) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: RichText(
                  text: TextSpan(
                      style: TextStyle(
                          color: Colors.black.withOpacity(0.8),
                          fontSize: 18.0,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.black,
                          decorationStyle: TextDecorationStyle.solid),
                      text: "Translated message")),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(32.0))),
              contentPadding: EdgeInsets.only(top: 10.0),
              content: Container(
                width: 300,
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      ListTile(
                          title: Text(smsDisplayObject["address"]),
                          subtitle: Text(smsDisplayObject["originalMsg"])),
                      SizedBox(
                        height: 5.0,
                      ),
                      Divider(
                        color: Colors.grey,
                        height: 4.0,
                      ),
                      Container(
                          color: Colors.amberAccent[100],
                          child: ListTile(
                              title:
                                  Text(smsDisplayObject["translatedMessage"]))),
                      Padding(
                        padding: EdgeInsets.only(left: 30.0, right: 30.0),
                        child: TextField(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                          ),
                          maxLines: 8,
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                            width: 300,
                            padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                            decoration: BoxDecoration(
                              color: Colors.indigo,
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(32.0),
                                  bottomRight: Radius.circular(32.0)),
                            ),
                            child: Text(
                              "Okay",
                              style: TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            )),
                      )
                    ]),
              ));
        });
  }

  void onSyncSMS() {
    getSms();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          backgroundColor: Colors.amber[100],
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                RichText(
                    text: TextSpan(
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22.0,
                          height: 1.20,
                          backgroundColor: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                        ),
                        text: " Translate to ")),
                Padding(
                  padding: EdgeInsets.only(right: 10.0),
                ),
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
                      child: Text(languagesMap[value]),
                    );
                  }).toList(),
                )
              ],
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
                    label: Text("Sync SMS")),
                width: 130.0,
                height: 60.0,
              )
            ]));
  }
}
