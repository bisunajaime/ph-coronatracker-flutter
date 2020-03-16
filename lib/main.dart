import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:ph_corona_tracker/models/models.dart';
import 'package:ph_corona_tracker/models/models.dart';
import 'package:ph_corona_tracker/models/models.dart';
import 'package:intl/intl.dart';

void main() => runApp(MyApp());

final Color red = Color(0xffe53e3e);
final Color bg = Color(0xfff7f7f7);
final Color green = Color(0xff48bb78);
final Color blue = Color(0xff2c5282);
final String poppinsBlack = 'Poppins-Black';
final String poppinsBold = 'Poppins-Bold';
final String poppinsRegular = 'Poppins-Regular';

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      title: 'PH Corona Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String text = 'Data';
  List<List<dynamic>> data;
  List<PhilippineData> phData = [];
  bool loading = false;
  String totalConfirmed = '';
  String totalRecovered = '';
  String totalDeaths = '';
  Color healthColor = blue;
  DateTime date;
  List<String> residents;
  String tappedString = '';

  Future getGrades() async {
    setState(() {
      phData.clear();
      loading = true;
    });
    http.Client client = http.Client();
    http.Response response = await client.get('https://covid19ph.com/');
    var body = response.body;
    var phmainlist = parse(response.body);
    List<dom.Element> elements =
        phmainlist.getElementsByTagName('phmainlist-comp');
    var data = elements.length;

    print('pass here');

    List<dom.Element> totalCases = phmainlist.querySelectorAll(
        'body .container .grid .col-span-6 .rounded .px-10 p');
    List<dom.Element> results =
        phmainlist.querySelectorAll('.py-3:nth-child(1)');
    //print(results);
    setState(() {
      totalConfirmed = totalCases[0].innerHtml;
      totalDeaths = totalCases[1].innerHtml;
      totalRecovered = totalCases[2].innerHtml;
    });
    var jsonData = jsonEncode(elements[0]
        .attributes
        .toString()
        .replaceFirst("{:phcases:", '')
        .replaceRange(
            elements[0]
                    .attributes
                    .toString()
                    .replaceFirst("{:phcases:", '')
                    .length -
                1,
            elements[0]
                .attributes
                .toString()
                .replaceFirst("{:phcases:", '')
                .length,
            ''));

    var newJson = jsonDecode(jsonDecode(jsonData));

    PhilippineData p = PhilippineData.fromJson(newJson[1]);

    for (int i = 0; i < newJson.length; i++) {
      if (newJson[i]['nationality'] != '?' &&
          newJson[i]['nationality'].trim().length != 0) {
        setState(() {
          phData.add(PhilippineData.fromJson(newJson[i]));
        });
      }
    }

    List<String> res = [];

    phData.forEach((f) {
      res.add(f.residentOf);
    });

    setState(() {
      text = newJson.toString();
      loading = false;
      residents = res.toSet().toList();
      date = DateTime.now();
      tappedString = '';
    });

    print('oasse');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getGrades();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff272727),
      floatingActionButton: loading
          ? null
          : FloatingActionButton(
              onPressed: getGrades,
              child: Icon(
                Icons.refresh,
                color: Colors.white,
              ),
              backgroundColor: red,
            ),
      appBar: AppBar(
        title: Column(
          children: <Widget>[
            Text(
              'PH Corona Info',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: poppinsBlack,
                fontSize: 15,
              ),
            ),
            Text(
              '${phData.length == 0 ? 'Loading' : phData.length} ${phData.length == 0 ? '' : ' Total Cases'}',
              style: TextStyle(
                color: Color(0xffFFD057),
                fontFamily: poppinsBold,
                fontSize: 15.0,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 5,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Results as of',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.0,
                          fontFamily: poppinsRegular,
                        ),
                      ),
                      Text(
                        '${DateFormat('yMMMMd').add_jm().format(date)}',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: poppinsRegular,
                          fontSize: 20.0,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    child: ListView(
                      physics: BouncingScrollPhysics(),
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical: 5.0,
                          ),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.black,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 5.0,
                                color: Colors.black26,
                              )
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                '$totalConfirmed',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xffDA8CFF),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30,
                                  fontFamily: poppinsBlack,
                                ),
                              ),
                              Text(
                                'Confirmed',
                                style: TextStyle(
                                  fontFamily: poppinsBold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(
                                  left: 10,
                                  top: 5,
                                  right: 5,
                                  bottom: 5,
                                ),
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.black,
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 5.0,
                                      color: Colors.black26,
                                    )
                                  ],
                                ),
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      '$totalDeaths',
                                      style: TextStyle(
                                        fontFamily: poppinsBlack,
                                        fontSize: 30.0,
                                        color: red,
                                      ),
                                    ),
                                    Text(
                                      'Deaths',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: poppinsBold,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(
                                  left: 5,
                                  top: 5,
                                  right: 10,
                                  bottom: 5,
                                ),
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.black,
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 10.0,
                                      color: Colors.black26,
                                    )
                                  ],
                                ),
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      '$totalRecovered',
                                      style: TextStyle(
                                        fontFamily: poppinsBlack,
                                        fontSize: 30.0,
                                        color: green,
                                      ),
                                    ),
                                    Text(
                                      'Recovered',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: poppinsBold,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical: 5,
                          ),
                          child: Text(
                            'Residents Of',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: poppinsRegular,
                            ),
                          ),
                        ),
                        Container(
                          height: 50,
                          width: double.infinity,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: residents.length,
                            itemBuilder: (context, i) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    tappedString = residents[i];
                                  });
                                  print(tappedString);
                                },
                                child: Container(
                                  margin: EdgeInsets.all(5),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.0,
                                    vertical: 2.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: blue,
                                    borderRadius: BorderRadius.circular(50),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 5.0,
                                      )
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${residents[i]}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: poppinsBold,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            tappedString.length == 0
                                ? Container()
                                : Container(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0,
                                        vertical: 5.0,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text(
                                                'Showing results for : ',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: poppinsRegular,
                                                  fontSize: 15.0,
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    tappedString = '';
                                                  });
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 10.0,
                                                    vertical: 5.0,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                    color: Colors.white70,
                                                  ),
                                                  child: Text('Clear'),
                                                ),
                                              )
                                            ],
                                          ),
                                          Text(
                                            '$tappedString',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: poppinsRegular,
                                              fontSize: 20.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: List.generate(
                                phData.length,
                                (i) {
                                  if (tappedString == phData[i].residentOf) {
                                    print(true);
                                    return DataWidget(
                                      phData: phData[i],
                                    );
                                  }
                                  if (tappedString.length == 0) {
                                    return DataWidget(
                                      phData: phData[i],
                                    );
                                  }
                                  return Container();
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class DataWidget extends StatelessWidget {
  final PhilippineData phData;

  DataWidget({this.phData});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 5.0,
      ),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Color(0xff000000),
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            blurRadius: 5.0,
            color: Colors.black26,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                '#${phData.caseNo} ${phData.nationality == null ? 'NOT SPECIFIED' : phData.nationality}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25.0,
                  fontFamily: poppinsBold,
                  color: Color(0xffE4E4E4),
                ),
              ),
              Text(
                '${phData.age} yrs',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                  fontFamily: poppinsBold,
                  color: Color(0xffFFF9C0),
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              DataContent(
                type: 'Sex',
                typeColor: blue,
                typeSize: 12,
                data: phData.sex,
                dataSize: 15,
                dataColor: Color(0xffFF5C00),
              ),
              DataContent(
                type: 'Transpo',
                typeColor: blue,
                typeSize: 12,
                data: phData.transType,
                dataSize: 15,
                dataColor: Color(0xffC9C0FF),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              DataContent(
                type: 'Currently At',
                typeColor: blue,
                typeSize: 12,
                data: phData.currentlyAt.trim() == ""
                    ? 'Not Specified'
                    : phData.currentlyAt,
                dataSize: 15,
                dataColor: Colors.white,
              ),
            ],
          ),
          Row(
            children: <Widget>[
              DataContent(
                type: 'Health Status',
                typeColor: blue,
                typeSize: 12,
                data: phData.healthStatus == "" ? 'NONE' : phData.healthStatus,
                dataSize: 15,
                dataColor: Color(0xffC0FFC7),
              ),
              DataContent(
                type: 'Case Status',
                typeColor: blue,
                typeSize: 12,
                data: phData.caseStatus,
                dataSize: 15,
                dataColor: phData.caseStatus == 'Deceased'
                    ? Color(0xffFFC0C0)
                    : Color(0xff90E4FF),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              DataContent(
                type: 'Date',
                typeColor: blue,
                typeSize: 12,
                data: phData.dtStamp,
                dataSize: 15,
                dataColor: Colors.amber,
              ),
              DataContent(
                type: 'Resident Of',
                typeColor: blue,
                typeSize: 12,
                data: phData.residentOf,
                dataSize: 15,
                dataColor: Colors.white,
              ),
            ],
          )
          // Text('Symptoms: ${phData[i].symptoms}'),
        ],
      ),
    );
    ;
  }
}

class DataContent extends StatelessWidget {
  final String data;
  final String type;
  final double dataSize;
  final double typeSize;
  final Color dataColor;
  final Color typeColor;

  DataContent({
    this.data,
    this.type,
    this.dataSize,
    this.typeSize,
    this.dataColor,
    this.typeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: 5,
          horizontal: 5,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 10.0,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Color(0xff1D1D1D),
          boxShadow: [
            BoxShadow(
              blurRadius: 5.0,
              color: Colors.black54,
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              type,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: poppinsRegular,
                color: Colors.white70,
                fontSize: typeSize,
              ),
            ),
            Text(
              data,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: poppinsBold,
                color: dataColor,
                fontSize: dataSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
