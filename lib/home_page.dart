// import 'package:flutter/material.dart';
// import 'package:local_service/user_drawer.dart';

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key});

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       drawer: UserDrawer(), // Aapka Drawer widget yahan use hona chahiye
//       appBar: AppBar(title: const Text("Home Page")),
//       body: Center(child: Text("Welcome to the Home Page!")),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:local_service/user_drawer.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    // Is screen par aate hi lastMode = user save karo
    _saveLastMode();
  }

  Future<void> _saveLastMode() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'lastMode': 'user'});
      }
    } catch (e) {
      debugPrint("lastMode save error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const UserDrawer(),
      appBar: AppBar(title: const Text("Home Page")),
      body: const Center(child: Text("Welcome to the Home Page!")),
    );
  }
}
