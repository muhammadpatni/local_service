import 'package:flutter/material.dart';
import 'package:local_service/user_drawer.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: UserDrawer(), // Aapka Drawer widget yahan use hona chahiye
      appBar: AppBar(title: const Text("Home Page")),
      body: Center(child: Text("Welcome to the Home Page!")),
    );
  }
}
