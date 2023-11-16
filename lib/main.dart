import 'dart:async';

import 'package:alpha/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
// import 'package:http/http.dart' as http;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
// Needed because we can't import `dart:html` into a mobile app,
// while on the flip-side access to `dart:io` throws at runtime (hence the `kIsWeb` check below)
// import 'html_shim.dart' if (dart.library.html) 'dart:html' show window;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await runZonedGuarded(
    () async {
      runApp(const MyApp());
    },
    (e, st) => print('ERROR'),
    zoneSpecification: ZoneSpecification(
        print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
      //save to a file or do whatever you want
    }),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String text = "";
  String token = "";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: ((settings) {
        // This is also invoked for incoming deep links

        // ignore: avoid_print
        print('onGenerateRoute: $settings');

        return null;
      }),
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Kokoromil Health: Sign in with Apple',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          backgroundColor: Colors.black,
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Center(
              child: Column(
                children: [
                  SignInWithAppleButton(
                    onPressed: () async {
                      _setText("");
                      final AuthorizationCredentialAppleID credential =
                          await SignInWithApple.getAppleIDCredential(
                        scopes: [
                          AppleIDAuthorizationScopes.email,
                          AppleIDAuthorizationScopes.fullName,
                        ],
                        webAuthenticationOptions: WebAuthenticationOptions(
                          // TODO: Set the `clientId` and `redirectUri` arguments to the values you entered in the Apple Developer portal during the setup
                          clientId: 'com.linhndq.alpha.service',

                          redirectUri:
                              // For web your redirect URI needs to be the host of the "current page",
                              // while for Android you will be using the API server that redirects back into your app via a deep link
                              Uri.parse(
                            'https://broad-golden-tempo.glitch.me/callbacks/sign_in_with_apple',
                          ),
                        ),
                        nonce: 'example-nonce',
                        state: 'example-state',
                      );
                      Map<String, dynamic> decodedToken =
                          JwtDecoder.decode(credential.identityToken ?? '');
                      token = credential.identityToken ?? '';
                      _setText(decodedToken['email'].toString());
                    },
                  ),
                  if (text.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Text("Login Success"),
                        SizedBox(
                          height: 10,
                        ),
                        Text("Token"),
                        SizedBox(
                          height: 10,
                        ),
                        Text(token),
                        SizedBox(
                          height: 10,
                        ),
                        Text("Infomation"),
                        SizedBox(
                          height: 10,
                        ),
                        Text(text),
                      ],
                    )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _setText(String data) {
    setState(() {
      text = data;
    });
  }
}
