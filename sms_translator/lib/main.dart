import 'package:flutter/material.dart';
import 'package:sms/sms.dart';
import 'package:translator/translator.dart';

void main() => runApp(MyApp());
final ThemeData androidTheme =
    new ThemeData(primarySwatch: Colors.indigo, accentColor: Colors.white);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) {
    return new MaterialApp(
        title: 'SMS viewer',
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
  List<SmsMessage> smsList = new List<SmsMessage>();
  List<SmsMessage> translatedSmsList = new List<SmsMessage>();
  ListView listViewBuilder = new ListView();
  Map<String, String> smsBodyAddressMap = new Map<String, String>();

  @override
  void initState() {
    super.initState();
    getSms();
  }

  Future<void> getSms() async {
    try {
      query = new SmsQuery();
      List messages = await query.getAllSms;
      createListView(messages);
    } catch (e) {
      print('failed: ${e.toString()}');
    }
  }

  createListView(messages) {
    ListView tempListViewBuilder = new ListView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: messages.length,
      itemBuilder: (context, i) => ListTile(
          title: Text(messages[i].address), subtitle: Text(messages[i].body)),
    );
    setState(() {
      listViewBuilder = tempListViewBuilder;
    });
    setState(() {
      smsList = messages;
    });
  }

  void onTranslateText()  {
    GoogleTranslator _translator = new GoogleTranslator();
    List<Future> translatePromises = new List<Future>();
    this.smsList.forEach((smsMessage) {
      translatePromises.add(_translator.translate(smsMessage.body));
    });
    Future.wait(translatePromises).then((translatedTexts){
      List<SmsMessage> translatedMessages = new List<SmsMessage>();
      int i=0;
      translatedTexts.forEach((text) {
        translatedMessages.add(new SmsMessage(this.smsList[i].address, text));
        i++;
      });
      createListView(translatedMessages);
    });

  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: listViewBuilder,
        floatingActionButton: new Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              new Container(
                margin: const EdgeInsets.only(top: 20.0),
                child: FloatingActionButton.extended(
                    icon: Icon(Icons.language, size: 30.0),
                    onPressed: onTranslateText,
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    label: Text("Translate")),
                width: 160.0,
                height: 60.0,
              )
            ]));
  }
}
