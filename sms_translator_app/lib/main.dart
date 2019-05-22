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
  SmsReceiver receiver = new SmsReceiver();
  List<SmsMessage> smsList = new List<SmsMessage>();
//  List<SmsMessage> origSMSList = new List<SmsMessage>();
//  AnimatedList animatedList = new AnimatedList();
  ListView smsListView;
  List<Card> cardList = new List<Card>();

  @override
  void initState() {
    super.initState();
    receiver.onSmsReceived.listen((smsMessage) => getSms());
    getSms();
  }

  Future<void> getSms() async {
    //Navigator.pop(context);
    try {
      query = new SmsQuery();
      List<SmsMessage> messages = await query.getAllSms;
      createListView(messages);
    } catch (e) {
      print('failed: ${e.toString()}');
    }
  }

  void createListView(List<SmsMessage> messages) {
    GoogleTranslator _translator = new GoogleTranslator();
    if (messages != null && messages.length > 0) {
      messages.forEach((smsMessage) {
        Card tempCard = new Card(
            child: ListTile(
          title: Text(smsMessage.address),
          subtitle: Text(smsMessage.body),
          onTap: () {
            _translator.translate(smsMessage.body).then((translatedText) {
              infoDialog(context, new SmsMessage(smsMessage.address, translatedText));
            });
          },
        ));
        cardList.add(tempCard);
      });
      setState(() {
        this.cardList = cardList;
      });

      this.smsListView = new ListView(
        children: this.cardList,
      );

      setState(() {
        this.smsListView = smsListView;
      });

      /*setState(() {
        this.animatedList = tempAnimatedList;
      });*/
    }
  }
  infoDialog(context, smsMessage){
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(smsMessage.address),
          content:Text(smsMessage.body),
          actions: <Widget>[
            FlatButton(
              child: Text('Okay'),
              onPressed: () =>  Navigator.of(context).pop(),
            )
          ],
        );
      }
    );
  }

  /*createListView(messages) {
    GoogleTranslator _translator = new GoogleTranslator();
    ListView tempListViewBuilder = new ListView.builder(
        padding: const EdgeInsets.all(10.0),
        itemCount: messages.length,
        itemBuilder: (context, i) {
          Card tempCard = new Card(
            child: ListTile(
              title: Text(messages[i].address),
              subtitle: Text(messages[i].body),
              onTap: () {
                _translator.translate(messages[i].body).then((translatedText){
                  _updateSingleItem(translatedText, i, messages[i].address, messages[i].body).then((updatedListView){
                    setState(() {
                      this.listViewBuilder = updatedListView;
                    });
                  });
                });
              },
            ),
          );
          cards.add(tempCard);
          return tempCard;
        });

    setState(() {
      listViewBuilder = tempListViewBuilder;
    });
    setState(() {
      smsList = messages;
    });
  }
  Future<ListView> _updateSingleItem(translatedText, index, address, originalSmsText) async{
    print("_updateSingleItem");
    Card newCard = Card(
      child: Column(
        children: <Widget>[
          ListTile(
              title: Text(address),
              subtitle: Text(originalSmsText)),
          Container(
              color: Colors.grey[200],
              child: ListTile(
                  leading: Icon(
                    Icons.check_circle,
                    color: Colors.green[800],
                  ),
                  title: Text(translatedText)))
        ],
      ),
    );
    this.cards.removeAt(index);
    this.cards.insert(index, newCard);
    ListView tempListView = ListView(
      children: this.cards,
    );
    return tempListView;
  }*/

  void onSyncSMS() {
    getSms();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
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
