import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart' as line;
import 'package:flutter_social_button/flutter_social_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SignInDemo extends StatefulWidget {
  const SignInDemo({Key? key}) : super(key: key);

  @override
  State<SignInDemo> createState() => _SignInDemoState();
}

class _SignInDemoState extends State<SignInDemo> {
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
                FlutterSocialButton(
                  onTap: () async {
                    if (Platform.isAndroid) {
                      await _signInWithAppleServer();
                    } else {
                      final user = await signInWithApple();
                      setState(() {
                        _social = "Google";
                        _userName = user.user?.displayName ?? "";
                        _email = user.user?.email ?? "";
                        _image = user.user?.photoURL ?? "";
                      });
                    }
                  },
                  buttonType: ButtonType.apple,
                ),
                FlutterSocialButton(
                  onTap: () async {
                    final user = await signInWithGoogle();
                    dev.log(
                        'DODODOODODO sign in google ${user.user?.toString()}');
                    setState(() {
                      _social = "Google";
                      _userName = user.user?.displayName ?? "";
                      _email = user.user?.email ?? "";
                      _image = user.user?.photoURL ?? "";
                    });
                  },
                  buttonType: ButtonType.google,
                ),
                FlutterSocialButton(
                  onTap: () async {
                    final user = await signInWithFacebook();
                    if (user != null) {
                      dev.log(
                          'DODODOODODO sign in fb ${user.user?.toString()}');
                      setState(() {
                        _social = "Facebook";
                        _userName = user.user?.displayName ?? "";
                        _email = user.user?.email ?? "";
                        _image = user.user?.photoURL ?? "";
                      });
                    }
                  },
                  buttonType: ButtonType.facebook,
                ),
                Container(
                  padding: const EdgeInsets.all(20.0),
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
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
                    icon: const Icon(
                      FontAwesomeIcons.line,
                      color: Color(0xff26c34d),
                    ),
                    label: const Text(
                      'Login With Line',
                      style: TextStyle(
                        color: Color(0xff26c34d),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        // <-- Radius
                      ),
                      side: const BorderSide(
                        color: Color(0xff26c34d),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    dev.log('sign out');
                    if (_social == 'google') {
                      GoogleSignIn().signOut();
                    } else if (_social == 'facebook') {
                      await FacebookAuth.instance.logOut();
                    } else if (_social == 'Apple') {}
                    _clear();
                  },
                  child: Container(
                    height: 60,
                    width: MediaQuery.of(context).size.width - 56,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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
        Text(
          "$_social Login Success",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Token: ",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Flexible(child: Text(token)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Text(
              'Name: ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(_userName),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Text(
              '$_social account: ',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(_email),
          ],
        ),
        const SizedBox(height: 10),
        if (_image != '')
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Image: ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
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

  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<UserCredential> signInWithApple() async {
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    // Request credential for the currently signed in Apple account.
    final appleCredential = await SignInWithApple.getAppleIDCredential(
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
      nonce: nonce,
    );

    // Create an `OAuthCredential` from the credential returned by Apple.
    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    setState(() {
      token = appleCredential.identityToken ?? '';
    });

    // Sign in the user with Firebase. If the nonce we generated earlier does
    // not match the nonce in `appleCredential.identityToken`, sign in will fail.
    return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
  }

  Future<void> _signInWithAppleServer() async {
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
    dev.log('DODODODOODO ${decodedToken.toString()}');
    setState(() {
      _social = 'Apple';
      token = credential.identityToken ?? '';
      _email = decodedToken['email'].toString();
    });
  }
}
