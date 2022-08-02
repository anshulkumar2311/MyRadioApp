import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:radio_app/Service/Auth_Service.dart';
import 'package:radio_app/pages/Phonepage.dart';
import 'package:radio_app/pages/SignInPage.dart';
import 'package:radio_app/pages/SignupPage.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomePage(),
  ));
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  firebase_auth.FirebaseAuth firebaseAuth = firebase_auth.FirebaseAuth.instance;
  Widget currentPage = SignUpPage();
  AuthClass authClass = AuthClass();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLogin();
  }
  void checkLogin() async{
    String? token =await authClass.getTocken();
    if(token != null){
      currentPage = HomePage();
    }
  }
  @override
  Widget build(BuildContext context) {
    return currentPage;
  }
}
