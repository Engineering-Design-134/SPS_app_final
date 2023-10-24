
import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((value) {
    runApp(MyApp());
  });
}


bool tutorialShown = false;

class currentSettings {
  final String vibrationStrength;
  final String flexSensitivity;
  final String vibrationDuration;

  const currentSettings({
    required this.vibrationStrength,
    required this.flexSensitivity,
    required this.vibrationDuration,
  });

  factory currentSettings.fromJson(Map<String, dynamic> json) {
    return currentSettings(
      vibrationStrength: json['vibration_strength'],
      flexSensitivity: json['flex_sensitivity'],
      vibrationDuration: json['vibration_duration'],
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

Future<void> changeSettings(vibrationStrength, flexSensitivity, vibrationDuration) async {
  final url = Uri.parse('https://sps-api-ce9301a647f2.herokuapp.com/settings');
  final headers = {"Content-type": "application/json"};
  final Map<String, String> data = {
    "device_id": "1",
    "vibration_strength": "${vibrationStrength.toString()}",
    "flex_sensitivity": "${flexSensitivity.toString()}",
    "vibration_duration": "${vibrationDuration.toString()}",
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
  double _currentSliderValue = 0;
  List<bool> isSelected2 = [false, true, false];

  void initialSetting (settings) {
    if (settings.vibrationStrength == "0") {
      isSelected0 = [true, false, false];
    }
    else if (settings.vibrationStrength == "1") {
      isSelected0 = [false, true, false];
    }
    else if (settings.vibrationStrength == "2") {
      isSelected0 = [false, false, true];
    }

    _currentSliderValue = (double.parse(settings.flexSensitivity) - 800)/4;

    if (settings.vibrationDuration == "500") {
      isSelected2 = [true, false, false];
    }
    else if (settings.vibrationDuration == "1000") {
      isSelected2 = [false, true, false];
    }
    else if (settings.vibrationDuration == "2000") {
      isSelected2 = [false, false, true];
    }
    notifyListeners();
  }

  var vibrationStrength = "";
  var flexSensitivity = "";
  var vibrationDuration = "";
  var deviceID = 1;


  void calibrateSPS (selected0,_currentSliderValue,selected2) {
    if (selected0[0] == true){
      vibrationStrength = "0";}
    else if (selected0[1]== true){
      vibrationStrength = "1";}
    else if (selected0[2]== true){
      vibrationStrength = "2";}

    flexSensitivity = (_currentSliderValue*4 + 800).toString();

    if (selected2[0] == true){
      vibrationDuration = "500";}
    else if (selected2[1]== true){
      vibrationDuration = "1000";}
    else if (selected2[2]== true){
      vibrationDuration = "2000";}

    changeSettings(vibrationStrength,flexSensitivity,vibrationDuration);
  }



  var badPostureCountToday = 20;
  var badPostureCountWeek = 50;
  var badPostureCountMonth = 180;
  var badPostureCountTodayColor = "green";


  void setPostureCounts () {
    badPostureCountToday = Random().nextInt(20)+5;
    badPostureCountWeek = (5 * badPostureCountToday) + Random().nextInt(35)+10;
    badPostureCountMonth = (2* badPostureCountWeek) + Random().nextInt(250)+50;

    if (badPostureCountToday<10){
      badPostureCountTodayColor = "green";}
    else if (badPostureCountToday>=10 && badPostureCountToday<20){
      badPostureCountTodayColor = "orange";}
    else if (badPostureCountToday>=20){
      badPostureCountTodayColor = "red";}
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
        context.read<MyAppState>().setPostureCounts ();
      }
    });
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
            label: 'Personalization',
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
    var colorToday = appState.badPostureCountTodayColor;

    Map<String, Color> colorMap = {
      'red': Colors.red,
      'orange': Colors.orange,
      'green': Colors.green,
    };

    String selectedColor = colorToday;

    void showTutorial(){
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Welcome to the Smart Posture Strips App"),
              content: SingleChildScrollView(
                child: Text(
                  "The app consists of 3 pages. You can switch between them by using the buttons on the bottom of your screen. The page you see upon opening is just the landing page, there is nothing to do there but you can quickly see how many times the device had to correct you that day.\n\n"
                      "The second page you can visit it the personalization page. Here you can adjust the settings of the device, these settings are:\n\n"
                      "Vibration intensity: this setting will determine the power of the vibration motor in the device.\n\n"
                      "Bending sensitivity: this setting will determine the sensitivity of the bending sensor of the device. \n\n"
                      "Vibration duration: this setting will determine how long the device will vibrate when bad posture is detected.\n\n"
                      "To ensure the best user experience we highly encourage playing around with the settings to see what is best for your neck!\n\n"
                      "Last but not least is the statistics page, here you can see some data of how you performed over a period of time, these stats will update automatically every time when you open the app so you don't have to worry about it.\n\n"
                      "We hope our device will help you correct your posture and we wish you can one day get rid of the device and do it all on your own!",
                  style: TextStyle(fontSize: 20),),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Got it"),
                ),
              ],
            );
          });
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.topRight, // Align to the top-left corner
            child: ElevatedButton(
              onPressed: () {
                showTutorial();
              },
              child: Icon(
                Icons.help,
                size: 60,
              ),
            ),
          ),
          SizedBox(height: 35),
          Image.asset('assets/images/Logo.png'),
          SizedBox(height: 25),
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Bad posture count today:",
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
          SizedBox(height: 10),
          Container(
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorMap[selectedColor] ?? Colors.white,
            ),
            child: Center(
              child: Text(
                "$today",
                style: TextStyle(fontSize: 30),
              ),
            ),
          ),
        ],
      ),
    );
  }}

class CalibrationPage extends StatefulWidget {
  @override
  State<CalibrationPage> createState() => _CalibrationPageState();
}

class _CalibrationPageState extends State<CalibrationPage> {

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var isSelected0 = appState.isSelected0;
    var _currentSliderValue = appState._currentSliderValue;
    var isSelected2 = appState.isSelected2;


    void startCalibrationTimer() {
      appState.calibrateSPS(isSelected0,_currentSliderValue,isSelected2);

      showDialog(
        context: context,
        barrierDismissible: false, // Prevent the user from dismissing the dialog
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Saving'),
            content: Text('Please wait while the settings are saved...',
              style: TextStyle(fontSize:20),),
          );
        },
      );
      Timer(Duration(seconds: 2), () {
        Navigator.of(context).pop();
      });
    }


    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState){
          return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        WidgetSpan(
                          child: Icon(Icons.vibration, size: 20),
                        ),
                        TextSpan(
                          text: "Vibration intensity",
                          style: TextStyle(fontSize: 20, color: Colors.black,),
                        ),
                      ],
                    ),
                  ),),),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                    color: Colors.red[100]),
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
                  fillColor: Colors.green[100],
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
              SizedBox(height: 50),
              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        WidgetSpan(
                          child: Icon(Icons.sensors, size: 20),
                        ),
                        TextSpan(
                          text: "Bending sensitivity",
                          style: TextStyle(fontSize: 20, color: Colors.black,),
                        ),
                      ],
                    ),
                  ),),),
              SizedBox(height: 10),
              Slider(
                value: _currentSliderValue,
                min: 0,
                max: 100,
                label: _currentSliderValue.round().toString(),
                onChanged: (double value) {
                  setState(() {
                    _currentSliderValue = value;});}),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Min",
                              style: TextStyle(fontSize: 20, color: Colors.black,),
                            ),
                          ],
                        ),
                      ),),),
                  SizedBox(width: 250), // Adjust the width to control spacing
                  Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                    child: RichText(
                      text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Max",
                          style: TextStyle(fontSize: 20, color: Colors.black,),
                      ),
                    ],
                  ),
                ),),),
              ]),
              SizedBox(height: 50),
              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        WidgetSpan(
                          child: Icon(Icons.timer, size: 20),
                        ),
                        TextSpan(
                          text: "Vibration duration (seconds)",
                          style: TextStyle(fontSize: 20, color: Colors.black,),
                        ),
                      ],
                    ),
                  ),),),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                    color: Colors.red[100]),
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
                  fillColor: Colors.green[100], // Background color when selected
                  borderColor: Colors.white, // Border color when selected
                  children: const <Widget>[
                    Text("0.5",
                      style: TextStyle(fontSize: 20),),
                    Text("1",
                      style: TextStyle(fontSize: 20),),
                    Text("2",
                      style: TextStyle(fontSize: 20),),
                  ],
                ),
              ),
              SizedBox(height: 100),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      startCalibrationTimer();
                    },

                    child: Text('Save current settings',
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }
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
          SizedBox(height: 10),
          Container(
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Center(
              child: Text(
                "$today",
                style: TextStyle(fontSize: 30),
              ),
            ),
          ),
          SizedBox(height: 30),
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Bad posture count this week:",
                style: TextStyle(fontSize: 20),
              ),),),
          SizedBox(height: 10),
          Container(
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Center(
              child: Text(
                "$week",
                style: TextStyle(fontSize: 30),
              ),
            ),
          ),
          SizedBox(height: 30),
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Bad posture count this month:",
                style: TextStyle(fontSize: 20),
              ),),),
          SizedBox(height: 10),
          Container(
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Center(
              child: Text(
                "$month",
                style: TextStyle(fontSize: 30),
              ),
            ),
          ),
          SizedBox(height: 100),
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                message,
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),),),
        ],
      ),
    );
  }
}