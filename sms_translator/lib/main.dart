import 'package:flutter/material.dart';
import 'package:sms/sms.dart';

void main() => runApp(MyApp());
final ThemeData androidTheme = new ThemeData(
  primarySwatch: Colors.pink,
  accentColor: Colors.white
);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext ctx){
    return new MaterialApp(
      title:'SMS viewer',
      theme: androidTheme,
      home: new Scaffold(
        appBar: new AppBar(
          title: Text("SMS")
        ),
        body: SmsList(),
      )
    );
  }
}

class SmsList extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => new SmsListState();
}

class SmsListState extends State<SmsList> {
  List<SmsMessage> messages = <SmsMessage>[];
  final _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  void initState() {
    super.initState();
    _getSmsMessages(new SmsQuery());
  }
  _getSmsMessages(query) async{
    messages =  await query.getAllSms;
    print(messages);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold (
      appBar: AppBar(
        title: Text('List'),
      ),
      body: _getListView(),
    );
  }
  Widget _getListView() {
    return new ListView.builder(
      padding: const EdgeInsets.all(10.0),
      itemBuilder: (context, i) {
        return _buildRow(messages[i]);
      },
    );
  }
  Widget _buildRow(SmsMessage message) {
    return new ListTile(
      title: new Text(message.body, style: _biggerFont),
    );
  }

}