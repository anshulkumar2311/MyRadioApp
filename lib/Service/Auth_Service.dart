import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:radio_app/pages/HomePage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
class AuthClass{
  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );
   FirebaseAuth auth = FirebaseAuth.instance;
   final storage = new FlutterSecureStorage();

  Future<void> googleSignIn(BuildContext context) async{
    try{
      GoogleSignInAccount? googleSignInAccount =await _googleSignIn.signIn();
      if(googleSignInAccount!=null){
        GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
        AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken,
        );
        try{
          UserCredential userCredential = await auth.signInWithCredential(credential);
          storageToken(userCredential);
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (builder) => HomePage()), (route) => false);
        }
        catch(e){
          final snackbar = SnackBar(content: Text(e.toString()));
          ScaffoldMessenger.of(context).showSnackBar(snackbar);
        }
      }
      else{
        final snackbar = SnackBar(content: Text("Not able to sign in"));
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      }
    }
    catch(e){
      print(e);
      final snackbar = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  Future<void> storageToken(UserCredential userCredential) async{
    await storage.write(key: "token", value: userCredential.credential?.token.toString());
    await storage.write(key: "userCredential", value: userCredential.toString());
  }

  Future<String?> getTocken() async{
    return await storage.read(key: "token");
  }

  Future<void> logout() async{
    try{
      await _googleSignIn.signOut();
      await auth.signOut();
      await storage.delete(key: "token");
    }
    catch(e){
      print(e);
    }
  }

  Future<void> verifyPhoneNumber(String phoneNumber, BuildContext context, Function setData ) async{
    PhoneVerificationCompleted verificationCompleted = (PhoneAuthCredential phoneAuthCredential) async{
      showSnackBar(context, "Verification Complete");
    };
    PhoneVerificationFailed verificationFailed = (FirebaseAuthException exception){
      showSnackBar(context, exception.toString());
    };

    PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationID) {
          showSnackBar(context, "Time Out");
        };

    try{
      await auth.verifyPhoneNumber(verificationCompleted: verificationCompleted,
          verificationFailed: verificationFailed,
          phoneNumber: phoneNumber,
          codeSent: (String? verificationId,int? resendToken){
            showSnackBar(context, "Verification Code sent on the phone number");
            setData(verificationId);
          },
          codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
    }
    catch(e){
      showSnackBar(context, e.toString());
    }
}

Future<void> SignInWithPhoneNumber(String verificationId,String smsCode, BuildContext context) async{
    try{
      AuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId,
          smsCode: smsCode);
    UserCredential userCredential = await auth.signInWithCredential(credential);
    storageToken(userCredential);
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (builder)=> HomePage()), (route) => false);
    showSnackBar(context, "Logged In");
    }
    catch(e){
showSnackBar(context, e.toString());
    }
}

void showSnackBar(BuildContext context,text){
    final snackBar = SnackBar(content: Text(text));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
}