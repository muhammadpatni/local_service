// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:flutter/material.dart';
// // import 'package:local_service/login_screen.dart';
// // import 'package:local_service/home_page.dart';

// // class Wrapper extends StatefulWidget {
// //   const Wrapper({super.key});

// //   @override
// //   State<Wrapper> createState() => _WrapperState();
// // }

// // class _WrapperState extends State<Wrapper> {
// //   @override
// //   Widget build(BuildContext context) {
// //     return StreamBuilder(
// //       stream: FirebaseAuth.instance.authStateChanges(),
// //       builder: (context, snapshot) {
// //         if (snapshot.hasData) {
// //           return MyHomePage();
// //         } else {
// //           return LoginScreen();
// //         }
// //       },
// //     );
// //   }
// // }

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:local_service/login_screen.dart';
// import 'package:local_service/home_page.dart';
// import 'package:local_service/selection_screen.dart';

// class Wrapper extends StatefulWidget {
//   const Wrapper({super.key});

//   @override
//   State<Wrapper> createState() => _WrapperState();
// }

// class _WrapperState extends State<Wrapper> {
//   final Color primaryBlue = const Color(0xFF0E6BBB);

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         // Checking authentication state
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Scaffold(
//             body: Center(child: CircularProgressIndicator(color: primaryBlue)),
//           );
//         }

//         if (snapshot.hasData && snapshot.data != null) {
//           User user = snapshot.data!;

//           // Agar user auth mein hai, toh Firestore check karo
//           return FutureBuilder<DocumentSnapshot>(
//             future: FirebaseFirestore.instance
//                 .collection('users')
//                 .doc(user.uid)
//                 .get(),
//             builder: (context, fsSnapshot) {
//               if (fsSnapshot.connectionState == ConnectionState.waiting) {
//                 return Scaffold(
//                   body: Center(
//                     child: CircularProgressIndicator(color: primaryBlue),
//                   ),
//                 );
//               }

//               // Agar Firestore mein data exist karta hai -> Home Page
//               if (fsSnapshot.hasData && fsSnapshot.data!.exists) {
//                 return const MyHomePage();
//               } else {
//                 // Agar data nahi hai -> Selection Screen
//                 return SelectionScreen(
//                   emailcontact: user.email ?? user.phoneNumber ?? '',
//                 );
//               }
//             },
//           );
//         } else {
//           // Agar user logged in nahi hai -> Login Screen
//           return const LoginScreen();
//         }
//       },
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:local_service/login_screen.dart';
import 'package:local_service/home_page.dart';
import 'package:local_service/provider_home_screen.dart';
import 'package:local_service/selection_screen.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  final Color primaryBlue = const Color(0xFF0E6BBB);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator(color: primaryBlue)),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          User user = snapshot.data!;

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get(),
            builder: (context, fsSnapshot) {
              if (fsSnapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(color: primaryBlue),
                  ),
                );
              }

              if (fsSnapshot.hasData && fsSnapshot.data!.exists) {
                var userData = fsSnapshot.data!.data() as Map<String, dynamic>;

                // Last session check: agar last time provider mode mein tha
                String? lastMode = userData['lastMode'];

                if (lastMode == 'provider') {
                  // Provider data bhi check karo
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('providers')
                        .doc(user.uid)
                        .get(),
                    builder: (context, providerSnapshot) {
                      if (providerSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Scaffold(
                          body: Center(
                            child: CircularProgressIndicator(
                              color: primaryBlue,
                            ),
                          ),
                        );
                      }
                      if (providerSnapshot.hasData &&
                          providerSnapshot.data!.exists) {
                        return const ProviderHomeScreen();
                      }
                      return const MyHomePage();
                    },
                  );
                }

                return const MyHomePage();
              } else {
                return SelectionScreen(
                  emailcontact: user.email ?? user.phoneNumber ?? '',
                );
              }
            },
          );
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
