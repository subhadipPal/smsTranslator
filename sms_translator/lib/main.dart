import 'package:flutter/material.dart';
import 'package:sms/sms.dart';

void main() => runApp(MyApp());
final ThemeData androidTheme =
    new ThemeData(primarySwatch: Colors.pink, accentColor: Colors.white);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) {
    return new MaterialApp(
        title: 'SMS viewer',
        theme: androidTheme,
        home: new Scaffold(
          appBar: new AppBar(title: Text("SMS")),
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
  List<String> smsList = new List(10);
  ListView listViewBuilder = new ListView();
  void onButtonPressed() {
    print("Pressed");
    getSms();
  }

  Future<void> getSms() async {
    try {
      query = new SmsQuery();
      List messages = await query.getAllSms;
      print(messages);
      createListView(messages);
    } catch (e) {
      print('failed: ${e.toString()}');
    }
  }

  createListView(messages) {
    //List<String> smsBodyList = messages.forEach((msg) => msg.body);
    ListView tempListViewBuilder = new ListView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: messages.length,
      itemBuilder: (context, i) => ListTile(title: Text(messages[i].body)),
    );
    setState(() {
      listViewBuilder = tempListViewBuilder;
    });
  }

  void onTranslateText() {
    print("translate before");
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: Text('SMS List'),
        ),
        body: listViewBuilder,
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.refresh),
          onPressed: getSms,
          backgroundColor: Colors.red,
          foregroundColor: Colors.black,
        )
    );
  }
}
