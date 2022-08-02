import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:radio_app/pages/SignupPage.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:radio_app/utils/ai_util.dart';
import 'package:radio_app/model/radio.dart';
import 'package:radio_app/Service/Auth_Service.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<MyRadio> radios;
  late MyRadio _selectedRadio;
  late Color _selectedColor;
  bool _isPlaying = false;

  AudioPlayer _audioPlayer = AudioPlayer();
  AuthClass authClass = AuthClass();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchRadios();
    _audioPlayer.onPlayerStateChanged.listen((event) {
      if(event == PlayerState.PLAYING){
        _isPlaying=true;
      }
      else{
        _isPlaying=false;
      }
      setState(() {});
    });
  }

  fetchRadios() async{
    final radioJson = await rootBundle.loadString("assets/radio.json");
    radios = MyRadioList.fromJson(radioJson).radios;
    _selectedRadio = radios[0];
    print(radios);
    setState((){});
  }

  _playMusic(String url){
    _audioPlayer.play(url);
    _selectedRadio = radios.firstWhere((element) => element.url ==url);
    print(_selectedRadio.name);
    setState((){});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
          child: Container(
              color: AIColors.primaryColor2,
              child: radios != null
              ? [
              100.heightBox,
              "All Channels".text.xl.white.semiBold.make().px16(),
              20.heightBox,
              ListView(
                padding: Vx.m0,
                shrinkWrap: true,
                children: radios
                    .map((e) => ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(e.icon),
                  ),
                  title: "${e.name} FM".text.white.make(),
                  subtitle: e.tagline.text.white.make(),
                ))
                    .toList(),
              ).expand()
              ].vStack(crossAlignment: CrossAxisAlignment.start)
              : const Offstage(),
    ),
      ),
      body: Stack(
        children: [
          VxAnimatedBox().size(context.screenWidth, context.screenHeight).withGradient(
            LinearGradient(colors:[
              AIColors.primaryColor1,
              AIColors.primaryColor2,
            ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ).make(),
          AppBar(
            title: "AI Radio".text.xl4.bold.white.make().shimmer(
              primaryColor: Vx.purple300, secondaryColor: Colors.white,
            ),
           actions: [
             IconButton(
                 icon: Icon(Icons.logout),
                 onPressed: () async {
                   await authClass.logout();
                   Navigator.pushAndRemoveUntil(
                       context,
                       MaterialPageRoute(builder: (builder) => SignUpPage()),
                           (route) => false);
                 }),
           ],
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            centerTitle: true,
          ).h(100).p16(),
          radios!=null ? VxSwiper.builder(itemCount: radios.length,aspectRatio: 1.0,
            enlargeCenterPage: true,onPageChanged: (index){
              _selectedRadio = radios[index];
            }, itemBuilder: (context,index){
              final rad = radios[index];
              return VxBox(
                  child: ZStack([
                    Positioned(top:0.0 ,right: 0.0,child: VxBox(
                        child: rad.category.text.uppercase.white.make().px16()
                    ).height(40).black.alignCenter.withRounded(value: 10.0).make(),),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: VStack([
                        rad.name.text.xl3.white.bold.make(),
                        5.heightBox,
                        rad.tagline.text.sm.white.semiBold.make(),
                      ]),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: [Icon(CupertinoIcons.play_circle, color: Colors.white,),
                        10.heightBox,
                        'Double Tap To Play'.text.gray300.make()].vStack(),
                    )
                  ],
                  )
              ).clip(Clip.antiAlias).bgImage(DecorationImage(image: NetworkImage(rad.image),fit: BoxFit.cover,colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken)),
              ).border(color: Colors.black,width: 5.0).withRounded(value: 60.0).make().onInkDoubleTap(() {
                _playMusic(rad.url);
              }).p16();
            },
          ).centered():Center(child: CircularProgressIndicator(
            backgroundColor: Colors.white,
          ),),
          Align(alignment: Alignment.bottomCenter,child:[
            if(_isPlaying)
              "Playing Now - ${_selectedRadio.name} FM".text.white.makeCentered(),
            Icon(
              _isPlaying ? CupertinoIcons.stop_circle: CupertinoIcons.play_circle,
              color: Colors.white,
              size: 50.0,
            ).onInkTap(() {
              if(_isPlaying){
                _audioPlayer.stop();
              }else{
                _playMusic(_selectedRadio.url);
              }
            })].vStack(),).pOnly(bottom: context.percentHeight*12)
        ],
        fit: StackFit.expand,
      ),
    );
  }
}
