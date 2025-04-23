import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:snapscore/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");
  runApp(const Snapscore());
}

class Snapscore extends StatelessWidget {
  const Snapscore({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snapscore',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const Text('Hello World!'),
    );
  }
}
