
import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

//TODO: change isSelected on app startup based on get function
//TODO: have feedback on patch to see if it worked

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((value)=>runApp(MyApp()));
  runApp(MyApp());
}

class currentSettings{
  final String vibrationStrength;
  final String flexSensitivity;
  final int waitTime;

  const currentSettings({
    required this.vibrationStrength,
    required this.flexSensitivity,
    required this.waitTime,
  });

  factory currentSettings.fromJson(Map<String, dynamic> json) {
    return currentSettings(
      vibrationStrength: json['vibration_strength'],
      flexSensitivity: json['flex_sensitivity'],
      waitTime: json['vibration_duration'] != null ? int.tryParse(json['vibration_duration'].toString()) ?? 0 : 0,
    );
  }}
Future<currentSettings?> fetchSettings() async {
  final response = await http.get(Uri.parse('https://sps-api-ce9301a647f2.herokuapp.com/settings?device_id=1'));

  if (response.statusCode == 200) {
    return currentSettings.fromJson(jsonDecode(response.body));
  } else {
    print('Failed to load settings, request failed with status: ${response.statusCode}');
    return null; // Return null in case of an error.
  }
}

Future<void> changeSettings(vibrationStrength, flexSensitivity, waitTime) async {
  final url = Uri.parse('https://sps-api-ce9301a647f2.herokuapp.com/settings');
  final headers = {"Content-type": "application/json"};
  final Map<String, String> data = {
    "device_id": "1",
    "vibration_strength": "${vibrationStrength.toString()}",
    "flex_sensitivity": "${flexSensitivity.toString()}",
    "vibration_duration": "${waitTime.toString()}",
  };

  print(jsonEncode(data));

  final response = await http.patch(url, headers: headers, body: jsonEncode(data));

  if (response.statusCode == 200) {
    print('Request successful');
  } else if (response.statusCode == 204) {
    print('Request successful');
  } else {
    print('Request failed with status: ${response.statusCode}');
    print('Response body: ${response.body}');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'SPS',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
          scaffoldBackgroundColor:  Colors.brown[100],
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  List<bool> isSelected0 = [false, true, false];
  List<bool> isSelected1 = [false, true, false];
  List<bool> isSelected2 = [false, true, false];

  void initialSetting (settings) {
    print(Text("here"));
    if (settings.vibrationStrength == "0") {
      isSelected0 = [true, false, false];
    }
    else if (settings.vibrationStrength == "50") {
      isSelected0 = [false, true, false];
    }
    else if (settings.vibrationStrength == "100") {
      isSelected0 = [false, false, true];
    }

    if (settings.flexSensitivity == "0") {
      isSelected1 = [true, false, false];
    }
    else if (settings.flexSensitivity == "50") {
      isSelected1 = [false, true, false];
    }
    else if (settings.flexSensitivity == "100") {
      isSelected1 = [false, false, true];
    }

    if (settings.waitTime == 5) {
      isSelected2 = [true, false, false];
    }
    else if (settings.waitTime == 10) {
      isSelected2 = [false, true, false];
    }
    else if (settings.waitTime == 15) {
      isSelected2 = [false, false, true];
    }
    notifyListeners();
  }

  var vibrationStrength = 0;
  var flexSensitivity = 0;
  var waitTime = 10;
  var deviceID = 1;


  void calibrateSPS (selected0,selected1,selected2) {
    if (selected0[0] == true){
        vibrationStrength = 0;}
      else if (selected0[1]== true){
        vibrationStrength = 50;}
      else if (selected0[2]== true){
        vibrationStrength = 100;}

    if (selected1[0] == true){
        flexSensitivity = 0;}
      else if (selected1[1]== true){
        flexSensitivity = 50;}
      else if (selected1[2]== true){
        flexSensitivity = 100;}

    if (selected2[0] == true){
        waitTime = 5;}
      else if (selected2[1]== true){
        waitTime = 10;}
      else if (selected2[2]== true){
        waitTime = 15;}

    changeSettings(vibrationStrength,flexSensitivity,waitTime);
  }



  var badPostureCountToday = 20;
  var badPostureCountWeek = 50;
  var badPostureCountMonth = 180;


  void setPostureCounts () {
    print( Text('setting bad posture counts'));
    badPostureCountToday = Random().nextInt(20)+5;0;
    badPostureCountMonth = Random().nextInt(100)+80;
    badPostureCountWeek = Random().nextInt(50)+2;
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  late Future<currentSettings?> futurecurrentSettings;

  @override
  void initState() {
    super.initState();
    futurecurrentSettings = fetchSettings();
    futurecurrentSettings.then((settings) {
      if (settings != null) {
        context.read<MyAppState>().initialSetting(settings);

         }});
  }
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {


    Widget page;
    switch (selectedIndex) {
      case 0:
        page = WelcomePage();
        break;
      case 1:
        page = CalibrationPage();
        break;
      case 2:
        page = StatisticsPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return Scaffold(
      body: page,
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Calibration',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Statistics',
          ),
        ],
        currentIndex: selectedIndex,
        onTap: (int index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
    );
  }
}

class WelcomePage extends StatefulWidget {
  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var today = appState.badPostureCountToday;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/Logo.png'),
          SizedBox(height: 25),
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
                child: Text(
                "Bad posture count today:",
                  style: TextStyle(fontSize: 20),
                ),),),
          SizedBox(height: 10),
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                  "$today",
                style: TextStyle(fontSize: 30),
              ),),),],),);}}

class CalibrationPage extends StatefulWidget {
  @override
  State<CalibrationPage> createState() => _CalibrationPageState();
}

class _CalibrationPageState extends State<CalibrationPage> {

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var isSelected0 = appState.isSelected0;
    var isSelected1 = appState.isSelected1;
    var isSelected2 = appState.isSelected2;

    void startCalibrationTimer() {
      appState.calibrateSPS(isSelected0,isSelected1,isSelected2);

      showDialog(
        context: context,
        barrierDismissible: false, // Prevent the user from dismissing the dialog
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Calibrating'),
            content: Text('Please sit still in the correct posture for 5 seconds...',
            style: TextStyle(fontSize:20),),
          );
        },
      );
      Timer(Duration(seconds: 5), () {
        Navigator.of(context).pop();
      });
    }


    return Center(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Vibration intensity:",
                style: TextStyle(fontSize: 20),
              ),),),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: Colors.white),
            child: ToggleButtons(
              isSelected: isSelected0,
              onPressed: (int index) {
                setState(() {
                  for (int buttonIndex = 0; buttonIndex < isSelected0.length; buttonIndex++) {
                    if (buttonIndex == index) {
                      isSelected0[buttonIndex] = true;
                    } else {
                      isSelected0[buttonIndex] = false;
                    }}});},
              color: Colors.black,
              fillColor: Colors.grey[300],
              borderColor: Colors.white,
              children: const <Widget>[
                Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Text("Light",
                    style: TextStyle(fontSize: 20),),
                ),
                Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Text("Medium",
                    style: TextStyle(fontSize: 20),),
                ),
                Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Text("Heavy",
                    style: TextStyle(fontSize: 20),),
                ),
              ],),),
          SizedBox(height: 20),
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Flex sensitivity:",
                style: TextStyle(fontSize: 20),
              ),),),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
                color: Colors.white),
            child: ToggleButtons(
              isSelected: isSelected1,
              onPressed: (int index) {
                setState(() {
                  for (int buttonIndex = 0; buttonIndex < isSelected1.length; buttonIndex++) {
                    if (buttonIndex == index) {
                      isSelected1[buttonIndex] = true;
                    } else {
                      isSelected1[buttonIndex] = false;
                    }}});},
              color: Colors.black,
              fillColor: Colors.grey[300],
              borderColor: Colors.white,
              children: const <Widget>[
                Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Text("Low",
                    style: TextStyle(fontSize: 20),),
                ),
                Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Text("Medium",
                    style: TextStyle(fontSize: 20),),
                ),
                Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Text("High",
                    style: TextStyle(fontSize: 20),),
                ),
              ],),),
          SizedBox(height: 20),
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Wait time before vibration occurs:",
                style: TextStyle(fontSize: 20),
              ),),),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
            color: Colors.white),
            child: ToggleButtons(
              isSelected: isSelected2,
              onPressed: (int index) {
                setState(() {
                  for (int buttonIndex = 0; buttonIndex < isSelected2.length; buttonIndex++) {
                    if (buttonIndex == index) {
                      isSelected2[buttonIndex] = true;
                    } else {
                      isSelected2[buttonIndex] = false;
                    }}});},
              color: Colors.black, // Set the background color of all buttons to white
              fillColor: Colors.grey[300], // Background color when selected
              borderColor: Colors.white, // Border color when selected
              children: const <Widget>[
                Text("5",
                    style: TextStyle(fontSize: 20),),
                Text("10",
                    style: TextStyle(fontSize: 20),),
                Text("15",
                  style: TextStyle(fontSize: 20),),
              ],
            ),
          ),
          SizedBox(height: 20),
          Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                startCalibrationTimer();
              },

              child: Text('calibrate sensors and save current settings'),
            ),
          ],
        ),
        ],
        ),
    );
  }
}

class StatisticsPage extends StatefulWidget {
  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var today = appState.badPostureCountToday;
    var week = appState.badPostureCountWeek;
    var month = appState.badPostureCountMonth;
    var message = "";
    if (today<10){
        message = "You're doing great today!";}
      else if (today>=10 && today<20){
        message = "There's still room for improvement, keep trying!";}
      else if (today>=20){
        message = "Be careful with that neck!";}


    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                  "Bad posture count today:",
                  style: TextStyle(fontSize: 20),
              ),),),
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                  "$today",
                style: TextStyle(fontSize: 20),
              ),),),
          SizedBox(height: 15),
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                  "Bad posture count this week:",
                style: TextStyle(fontSize: 20),
              ),),),
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                  "$week",
                  style: TextStyle(fontSize: 20),
              ),),),
          SizedBox(height: 15),
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                  "Bad posture count this month:",
                style: TextStyle(fontSize: 20),
              ),),),
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                  "$month",
                style: TextStyle(fontSize: 20),
              ),),),
          SizedBox(height: 60),
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                message,
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),),),
          SizedBox(height: 60),
          ElevatedButton(
            onPressed: () {
              appState.setPostureCounts();
              },
           child: Text('Update to latest data'),
          ),
        ],
      ),
    );
  }
}


