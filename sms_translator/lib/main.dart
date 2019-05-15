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

  void onTranslateText() {
    print("translate before");
    int i=0;
    smsList.forEach((smsMessage){
      _translateSMS(smsMessage, i, smsList.length);
      i++;
    });
    
  }

  _translateSMS(smsMessage, index, noOfSms) async {
    String textToBeTranslated = smsMessage.body;
    GoogleTranslator _translator = new GoogleTranslator();
    _translator.translate(textToBeTranslated).then((translatedText) {
      print(translatedText);
      smsMessage.body = translatedText;
      List<SmsMessage> translatedMessages = this.translatedSmsList;
      translatedMessages.add(smsMessage);
      setState(() {
        this.translatedSmsList = translatedMessages;
      });
      if(index == noOfSms){
        createListView(translatedMessages);
      }
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
