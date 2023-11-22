import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart' as line;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SignInDemo extends StatefulWidget {
  const SignInDemo({Key? key}) : super(key: key);

  @override
  State<SignInDemo> createState() => _SignInDemoState();
}

class _SignInDemoState extends State<SignInDemo> {
  String text = "";
  String token = "";
  String _social = "";
  String _userName = "";
  String _email = "";
  String _image = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                          // 'https://broad-golden-tempo.glitch.me/callbacks/sign_in_with_apple',
                          'https://alpha-92f76.firebaseapp.com/__/auth/handler',
                        ),
                      ),
                      nonce: 'example-nonce',
                      state: 'example-state',
                    );
                    final oauthCredential =
                        OAuthProvider("apple.com").credential(
                      idToken: credential.identityToken,
                    );
                    final authResult = await FirebaseAuth.instance
                        .signInWithCredential(oauthCredential);
                    log('DODODOODODO ${authResult.toString()}');
                    Map<String, dynamic> decodedToken =
                        JwtDecoder.decode(credential.identityToken ?? '');
                    token = credential.identityToken ?? '';
                    _setText(decodedToken['email'].toString());
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final user = await signInWithGoogle();
                    log('DODODOODODO sign in google ${user.user?.toString()}');
                    setState(() {
                      _social = "Google";
                      _userName = user.user?.displayName ?? "";
                      _email = user.user?.email ?? "";
                      _image = user.user?.photoURL ?? "";
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.grey,
                    child: const Text('Goggle',
                        style: TextStyle(color: Colors.black)),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final user = await signInWithFacebook();
                    if (user != null) {
                      log('DODODOODODO sign in fb ${user.user?.toString()}');
                      setState(() {
                        _social = "Facebook";
                        _userName = user.user?.displayName ?? "";
                        _email = user.user?.email ?? "";
                        _image = user.user?.photoURL ?? "";
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.grey,
                    child: const Text('Facebook',
                        style: TextStyle(color: Colors.black)),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final result = await line.LineSDK.instance
                        .login(scopes: ["profile", "openid", "email"]);
                    // user email, if user set it in LINE and granted your request.
                    setState(() {
                      _social = "Line";
                      token = result.accessToken.data.toString() ?? '';
                      _userName = result.userProfile?.displayName ?? '';
                      _email = result.accessToken.email ?? '';
                      _image = result.userProfile?.pictureUrl ?? "";
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.grey,
                    child: const Text('Facebook',
                        style: TextStyle(color: Colors.black)),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    log('sign out');
                    GoogleSignIn().signOut();
                    _clear();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.grey,
                    child: const Text('Logout',
                        style: TextStyle(color: Colors.black)),
                  ),
                ),
                if (text.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      const Text("Login Success"),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text("Token"),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(token),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text("Infomation"),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(text),
                    ],
                  ),
                if (token.isNotEmpty) _infoWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text("$_social Login Success"),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Token: "),
            Flexible(child: Text(token)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Text('Name: '),
            Text(_userName),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Text('$_social: '),
            Text(_email),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Text('image: '),
            Image.network(
              _image,
              width: 120,
            ),
          ],
        ),
      ],
    );
  }

  void _clear() {
    setState(() {
      _social = "";
      _userName = "";
      _email = "";
      _image = "";
      token = "";
    });
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    token = googleAuth?.accessToken ?? '';

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<UserCredential?> signInWithFacebook() async {
    final LoginResult result = await FacebookAuth.instance
        .login(permissions: ['public_profile', 'email']);
    if (result.status == LoginStatus.success) {
      // Create a credential from the access token
      final OAuthCredential credential =
          FacebookAuthProvider.credential(result.accessToken!.token);
      // Once signed in, return the UserCredential
      setState(() {
        token = result.accessToken!.token;
      });
      try {
        return await FirebaseAuth.instance.signInWithCredential(credential);
      } on FirebaseAuthException catch (e) {
        // manage Firebase authentication exceptions
        return null;
      } catch (e) {
        // manage other exceptions
        return null;
      }
    }
    return null;
  }

  void _setText(String data) {
    setState(() {
      text = data;
    });
  }
}
