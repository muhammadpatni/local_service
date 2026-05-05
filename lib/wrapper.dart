// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:local_service/login_screen.dart';
// import 'package:local_service/home_page.dart';

// class Wrapper extends StatefulWidget {
//   const Wrapper({super.key});

//   @override
//   State<Wrapper> createState() => _WrapperState();
// }

// class _WrapperState extends State<Wrapper> {
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         if (snapshot.hasData) {
//           return MyHomePage();
//         } else {
//           return LoginScreen();
//         }
//       },
//     );
//   }
// }

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

// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:flutter/material.dart';
// // import 'package:local_service/login_screen.dart';
// // import 'package:local_service/home_page.dart';
// // import 'package:local_service/provider_home_screen.dart';
// // import 'package:local_service/selection_screen.dart';

// // class Wrapper extends StatefulWidget {
// //   const Wrapper({super.key});

// //   @override
// //   State<Wrapper> createState() => _WrapperState();
// // }

// // class _WrapperState extends State<Wrapper> {
// //   final Color primaryBlue = const Color(0xFF0E6BBB);

// //   @override
// //   Widget build(BuildContext context) {
// //     return StreamBuilder<User?>(
// //       stream: FirebaseAuth.instance.authStateChanges(),
// //       builder: (context, snapshot) {
// //         if (snapshot.connectionState == ConnectionState.waiting) {
// //           return Scaffold(
// //             body: Center(child: CircularProgressIndicator(color: primaryBlue)),
// //           );
// //         }

// //         if (snapshot.hasData && snapshot.data != null) {
// //           User user = snapshot.data!;

// //           return FutureBuilder<DocumentSnapshot>(
// //             future: FirebaseFirestore.instance
// //                 .collection('users')
// //                 .doc(user.uid)
// //                 .get(),
// //             builder: (context, fsSnapshot) {
// //               if (fsSnapshot.connectionState == ConnectionState.waiting) {
// //                 return Scaffold(
// //                   body: Center(
// //                     child: CircularProgressIndicator(color: primaryBlue),
// //                   ),
// //                 );
// //               }

// //               if (fsSnapshot.hasData && fsSnapshot.data!.exists) {
// //                 var userData = fsSnapshot.data!.data() as Map<String, dynamic>;

// //                 // Last session check: agar last time provider mode mein tha
// //                 String? lastMode = userData['lastMode'];

// //                 if (lastMode == 'provider') {
// //                   // Provider data bhi check karo
// //                   return FutureBuilder<DocumentSnapshot>(
// //                     future: FirebaseFirestore.instance
// //                         .collection('providers')
// //                         .doc(user.uid)
// //                         .get(),
// //                     builder: (context, providerSnapshot) {
// //                       if (providerSnapshot.connectionState ==
// //                           ConnectionState.waiting) {
// //                         return Scaffold(
// //                           body: Center(
// //                             child: CircularProgressIndicator(
// //                               color: primaryBlue,
// //                             ),
// //                           ),
// //                         );
// //                       }
// //                       if (providerSnapshot.hasData &&
// //                           providerSnapshot.data!.exists) {
// //                         return const ProviderHomeScreen();
// //                       }
// //                       return const MyHomePage();
// //                     },
// //                   );
// //                 }

// //                 return const MyHomePage();
// //               } else {
// //                 return SelectionScreen(
// //                   emailcontact: user.email ?? user.phoneNumber ?? '',
// //                 );
// //               }
// //             },
// //           );
// //         } else {
// //           return const LoginScreen();
// //         }
// //       },
// //     );
// //   }
// // }

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
        // Auth state load ho raha hai
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator(color: primaryBlue)),
          );
        }

        // User logged in hai
        if (snapshot.hasData && snapshot.data != null) {
          final User user = snapshot.data!;

          // Firestore se user ka data fetch karo
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

              // User ka Firestore document exist karta hai
              if (fsSnapshot.hasData && fsSnapshot.data!.exists) {
                final userData =
                    fsSnapshot.data!.data() as Map<String, dynamic>;
                final String? lastMode = userData['lastMode'];

                // Agar last session provider mode mein tha
                if (lastMode == 'provider') {
                  // Providers collection bhi verify karo
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

                      // Provider verified hai aur data exist karta hai
                      if (providerSnapshot.hasData &&
                          providerSnapshot.data!.exists) {
                        final pData =
                            providerSnapshot.data!.data()
                                as Map<String, dynamic>;

                        // Sirf tab ProviderHomeScreen dikhao jab setup complete ho
                        if (pData['setupStep'] == 'complete' &&
                            pData['isVerified'] == true) {
                          return const ProviderHomeScreen();
                        }
                      }

                      // Provider data nahi / incomplete — normal home par bhejo
                      return const MyHomePage();
                    },
                  );
                }

                // lastMode 'user' ya kuch aur hai — normal home
                return const MyHomePage();
              } else {
                // Pehli baar login — Selection Screen dikhao
                return SelectionScreen(
                  emailcontact: user.email ?? user.phoneNumber ?? '',
                );
              }
            },
          );
        }

        // User logged out hai
        return const LoginScreen();
      },
    );
  }
}
