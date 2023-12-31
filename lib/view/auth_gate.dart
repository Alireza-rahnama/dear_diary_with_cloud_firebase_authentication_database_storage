import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart'hide EmailAuthProvider;
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

import 'diary_entry_view.dart';
import 'diary_list_view..dart';
import 'diary_list_view2.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(snapshot.error.toString()),
            ),
          );
        }
        if (!snapshot.hasData) {
          return SignInScreen(
            headerBuilder: (context, constraints, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.all(35),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset('assets/1.png'),
                ),
              );
            },
            // subtitleBuilder: (context, action) {
            //   return Padding(
            //     padding: const EdgeInsets.symmetric(vertical: 8.0),
            //     child: action == AuthAction.signIn
            //         ? const Text('Welcome to Dear Diary, please sign in!')
            //         : const Text('Welcome to Dear Diary, please sign up!'),
            //   );
            // },
            footerBuilder: (context, action) {
              return const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  'By signing in, you agree to our terms and conditions.',
                  style: TextStyle(color: Colors.deepPurple),
                ),
              );
            },
            providers: [
              EmailAuthProvider(), // new
              GoogleProvider(clientId: "1075040481167-nr1bg35jvthus95pl1skk617tfas6vme.apps.googleusercontent.com"),  // new
            ],
          );
        } else {
          return Center(child:
          // DiaryLogView()
          DiaryLogView2()
          );
        }
      },
    );
  }
}
