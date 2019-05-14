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

  void onButtonPressed() {
    print("Pressed");
    getSms();
  }

  Future<void> getSms() async{
    SmsQuery query = new SmsQuery();
    List messages = await query.getAllSms;
    print(messages);
  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Text('SMS List'),
      ),
      body: new Column(
        children: <Widget>[
          RaisedButton(
            onPressed: onButtonPressed,
            child:Text('Test')
          )
        ],
      )
    );
  }

}