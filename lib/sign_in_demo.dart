import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
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
                    log('DODODOODODO ding in fbfbfbfbf');
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
                  onTap: () {
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
    });
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    log('DODODOODODO ${googleUser.toString()}');

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

  // Future<UserCredential> signInWithFacebook() async {
  //   // Trigger the sign-in flow
  //   final LoginResult loginResult = await FacebookAuth.instance.login();
  //   log('DODODOODODO result fb ${loginResult.accessToken?.toJson()}');
  //
  //   setState(() {
  //     token = loginResult.accessToken?.token ?? '';
  //   });
  //
  //   // Create a credential from the access token
  //   final OAuthCredential facebookAuthCredential =
  //       FacebookAuthProvider.credential(loginResult.accessToken?.token ?? '');
  //
  //   // Once signed in, return the UserCredential
  //   return FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
  // }

  Future<UserCredential?> signInWithFacebook() async {
    final LoginResult loginResult = await FacebookAuth.instance.login(
      permissions: const ["public_profile", "email"],
    );

    if (loginResult.status == LoginStatus.success) {
      log('DODODOODODO fb 1');
      final AccessToken accessToken = loginResult.accessToken!;
      final OAuthCredential credential =
          FacebookAuthProvider.credential(accessToken.token);
      try {
        log('DODODOODODO fb 2 ${credential.accessToken}');
        return await FirebaseAuth.instance.signInWithCredential(credential);
      } on FirebaseAuthException catch (e) {
        log('DODODOODODO fb 3 $e');
        // manage Firebase authentication exceptions
        return null;
      } catch (e) {
        log('DODODOODODO fb 4 $e');
        // manage other exceptions
        return null;
      }
    } else {
      log('DODODOODODO fb 5 e');
      // login was not successful, for example user cancelled the process
      return null;
    }
  }

  void _setText(String data) {
    setState(() {
      text = data;
    });
  }
}
