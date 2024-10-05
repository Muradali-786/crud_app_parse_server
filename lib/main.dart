
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import 'home/home.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await connectToParseServer();
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dummy task',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Home(),
    );
  }
}

Future<void> connectToParseServer() async {
  const keyApplicationId = 'i1CjHDN9xXcCUFohEeHVvfJ7VTGGTUacBU3apYGN';
  const keyClientKey = 'lukGN4hdu9SLle4XVNeSB8v9pBbJmdfwuyjrmxjr';
  const keyParseServerUrl = 'https://parseapi.back4app.com';

  await Parse().initialize(
    keyApplicationId,
    keyParseServerUrl,
    clientKey: keyClientKey,
    debug: false,
  );
}

