// import 'package:donation_nature/API/domain/ultra_srt_ncst.dart';
// import 'package:donation_nature/API/repository/ultra_srt_ncst_repository.dart';
// import 'package:donation_nature/API/repository/wthr_wrn_liist_repository.dart';
// import 'package:donation_nature/action/action.dart';
// import 'package:donation_nature/permission/permission_request.dart';
// import 'package:donation_nature/screen/alarm_screen.dart';
// import 'package:flutter/material.dart';

// class InfoScreen extends StatelessWidget {
//   const InfoScreen({Key? key}) : super(key: key);

//   void _callAPI() async {
//     PermissionRequest.determinePosition();

//     UltraSrtNcstRepository ultraSrtNcstRepository = UltraSrtNcstRepository();
//     UltraSrtNcst? ultraSrtNcst =
//         await ultraSrtNcstRepository.loadUltraSrtNcst();

//     print(
//         "기온 : ${ultraSrtNcst?.T1H}, 1시간 강수량 : ${ultraSrtNcst?.RN1}, 습도 : ${ultraSrtNcst?.REH}, 강수형태 : ${ultraSrtNcst?.PTY}");

//     WthrWrnListRepository wthrWrnListRepository = WthrWrnListRepository();
//     var wthrWrnList = await wthrWrnListRepository.loadWthrWrnList();

//     print(
//         "폭염 예비특보: ${wthrWrnList?[0].FHWA}\n호우 예비특보: ${wthrWrnList?[0].FHRA}\n태풍 예비특보: ${wthrWrnList?[0].FTYA}\n강풍 예비특보: ${wthrWrnList?[0].FSWA}\n풍랑 예비특보: ${wthrWrnList?[0].FSTA}");

//     print(
//         "폭염주의보: ${wthrWrnList?[0].HWA}\n폭염경보: ${wthrWrnList?[0].HWW}\n호우주의보: ${wthrWrnList?[0].HRA}\n호우경보: ${wthrWrnList?[0].HRW}\n태풍주의보: ${wthrWrnList?[0].TYA}\n강풍주의보: ${wthrWrnList?[0].SWA}\n풍랑주의보: ${wthrWrnList?[0].STA}");
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('재난 정보',
//             style: TextStyle(
//               color: Colors.black,
//             )),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: _callAPI,
//           child: const Text('Call API'),
//         ),
//       ),
//     );
//   }
// }

import 'package:donation_nature/screen/api_info.dart';
import 'package:donation_nature/screen/login_screen.dart';
import 'package:donation_nature/screen/weather_disaster_api.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:svg_path_parser/svg_path_parser.dart';

class InfoScreen extends StatefulWidget {
  @override
  _InfoScreenState createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> with TickerProviderStateMixin {
  // TickerProviderStateMixin allows the fade out/fade in animation when changing the active button

  // this will control the button clicks and tab changing
  late TabController _controller;

  // this will control the animation when a button changes from an off state to an on state
  late AnimationController _animationControllerOn;

  // this will control the animation when a button changes from an on state to an off state
  late AnimationController _animationControllerOff;

  // this will give the background color values of a button when it changes to an on state
  late Animation _colorTweenBackgroundOn;
  late Animation _colorTweenBackgroundOff;

  // this will give the foreground color values of a button when it changes to an on state
  late Animation _colorTweenForegroundOn;
  late Animation _colorTweenForegroundOff;

  // when swiping, the _controller.index value only changes after the animation, therefore, we need this to trigger the animations and save the current index
  int _currentIndex = 0;

  // saves the previous active tab
  int _prevControllerIndex = 0;

  // saves the value of the tab animation. For example, if one is between the 1st and the 2nd tab, this value will be 0.5
  double _aniValue = 0.0;

  // saves the previous value of the tab animation. It's used to figure the direction of the animation
  double _prevAniValue = 0.0;

  // these will be our tab icons. You can use whatever you like for the content of your buttons
  List _icons = [
    FontAwesomeIcons.fire,
    FontAwesomeIcons.cloudShowersHeavy,
    FontAwesomeIcons.hurricane,
    FontAwesomeIcons.wind,
    FontAwesomeIcons.houseTsunami,
  ];

  List _labels = [' 폭염', ' 호우', ' 태풍', ' 강풍', ' 풍랑'];

  // active button's foreground color
  Color _foregroundOn = Colors.white;
  Color _foregroundOff = Colors.grey;

  // active button's background color
  Color _backgroundOn = Color(0xff416E5C);
  Color _backgroundOff = Colors.grey.withOpacity(0.5);

  // scroll controller for the TabBar
  ScrollController _scrollController = new ScrollController();

  // this will save the keys for each Tab in the Tab Bar, so we can retrieve their position and size for the scroll controller
  List _keys = [];

  // regist if the the button was tapped
  bool _buttonTap = false;

  @override
  void initState() {
    super.initState();

    for (int index = 0; index < _icons.length; index++) {
      // create a GlobalKey for each Tab
      _keys.add(new GlobalKey());
    }

    // this creates the controller with 6 tabs (in our case)
    _controller = TabController(vsync: this, length: _icons.length);
    // this will execute the function every time there's a swipe animation
    _controller.animation!.addListener(_handleTabAnimation);
    // this will execute the function every time the _controller.index value changes
    _controller.addListener(_handleTabChange);

    _animationControllerOff =
        AnimationController(vsync: this, duration: Duration(milliseconds: 75));
    // so the inactive buttons start in their "final" state (color)
    _animationControllerOff.value = 1.0;
    _colorTweenBackgroundOff =
        ColorTween(begin: _backgroundOn, end: _backgroundOff)
            .animate(_animationControllerOff);
    _colorTweenForegroundOff =
        ColorTween(begin: _foregroundOn, end: _foregroundOff)
            .animate(_animationControllerOff);

    _animationControllerOn =
        AnimationController(vsync: this, duration: Duration(milliseconds: 150));
    // so the inactive buttons start in their "final" state (color)
    _animationControllerOn.value = 1.0;
    _colorTweenBackgroundOn =
        ColorTween(begin: _backgroundOff, end: _backgroundOn)
            .animate(_animationControllerOn);
    _colorTweenForegroundOn =
        ColorTween(begin: _foregroundOff, end: _foregroundOn)
            .animate(_animationControllerOn);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('재난 상황 정보'),
        ),
        backgroundColor: Colors.white,
        body: Column(children: <Widget>[
          SizedBox(height: 5),
          // this is the TabBar
          Container(
              height: 49.0,
              // this generates our tabs buttons
              child: ListView.builder(
                  // this gives the TabBar a bounce effect when scrolling farther than it's size
                  physics: BouncingScrollPhysics(),
                  controller: _scrollController,
                  // make the list horizontal
                  scrollDirection: Axis.horizontal,

                  // number of tabs
                  itemCount: _icons.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                        // each button's key
                        key: _keys[index],
                        // padding for the buttons
                        padding: EdgeInsets.all(6.0),
                        child: ButtonTheme(
                            child: AnimatedBuilder(
                          animation: _colorTweenBackgroundOn,
                          builder: (context, child) => FlatButton(
                              // get the color of the button's background (dependent of its state)
                              color: _getBackgroundColor(index),
                              // make the button a rectangle with round corners
                              shape: RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(7.0)),
                              onPressed: () {
                                setState(() {
                                  _buttonTap = true;
                                  // trigger the controller to change between Tab Views
                                  _controller.animateTo(index);
                                  // set the current index
                                  _setCurrentIndex(index);
                                  // scroll to the tapped button (needed if we tap the active button and it's not on its position)
                                  _scrollTo(index);
                                });
                              },
                              child: Row(
                                children: [
                                  Icon(
                                      // get the icon
                                      _icons[index],
                                      // get the color of the icon (dependent of its state)
                                      color: _getForegroundColor(index)),
                                  Text(_labels[index],
                                      style: TextStyle(
                                          color: _getForegroundColor(index))),
                                ],
                              )),
                        )));
                  })),

          Flexible(
              // this will host our Tab Views
              child: TabBarView(
            // and it is controlled by the controller
            controller: _controller,
            children: <Widget>[
              // our Tab ViewsP
              drawMap(0),
              drawMap(1),
              drawMap(2),
              drawMap(3),
              drawMap(4),
            ],
          )),
        ]));
  }

  // runs during the switching tabs animation
  _handleTabAnimation() {
    // gets the value of the animation. For example, if one is between the 1st and the 2nd tab, this value will be 0.5
    _aniValue = _controller.animation!.value;

    // if the button wasn't pressed, which means the user is swiping, and the amount swipped is less than 1 (this means that we're swiping through neighbor Tab Views)
    if (!_buttonTap && ((_aniValue - _prevAniValue).abs() < 1)) {
      // set the current tab index
      _setCurrentIndex(_aniValue.round());
    }

    // save the previous Animation Value
    _prevAniValue = _aniValue;
  }

  // runs when the displayed tab changes
  _handleTabChange() {
    // if a button was tapped, change the current index
    if (_buttonTap) _setCurrentIndex(_controller.index);

    // this resets the button tap
    if ((_controller.index == _prevControllerIndex) ||
        (_controller.index == _aniValue.round())) _buttonTap = false;

    // save the previous controller index
    _prevControllerIndex = _controller.index;
  }

  _setCurrentIndex(int index) {
    // if we're actually changing the index
    if (index != _currentIndex) {
      setState(() {
        // change the index
        _currentIndex = index;
      });

      // trigger the button animation
      _triggerAnimation();
      // scroll the TabBar to the correct position (if we have a scrollable bar)
      _scrollTo(index);
    }
  }

  _triggerAnimation() {
    // reset the animations so they're ready to go
    _animationControllerOn.reset();
    _animationControllerOff.reset();

    // run the animations!
    _animationControllerOn.forward();
    _animationControllerOff.forward();
  }

  _scrollTo(int index) {
    // get the screen width. This is used to check if we have an element off screen
    double screenWidth = MediaQuery.of(context).size.width;

    // get the button we want to scroll to
    RenderBox renderBox = _keys[index].currentContext.findRenderObject();
    // get its size
    double size = renderBox.size.width;
    // and position
    double position = renderBox.localToGlobal(Offset.zero).dx;

    // this is how much the button is away from the center of the screen and how much we must scroll to get it into place
    double offset = (position + size / 2) - screenWidth / 2;

    // if the button is to the left of the middle
    if (offset < 0) {
      // get the first button
      renderBox = _keys[0].currentContext.findRenderObject();
      // get the position of the first button of the TabBar
      position = renderBox.localToGlobal(Offset.zero).dx;

      // if the offset pulls the first button away from the left side, we limit that movement so the first button is stuck to the left side
      if (position > offset) offset = position;
    } else {
      // if the button is to the right of the middle

      // get the last button
      renderBox = _keys[_icons.length - 1].currentContext.findRenderObject();
      // get its position
      position = renderBox.localToGlobal(Offset.zero).dx;
      // and size
      size = renderBox.size.width;

      // if the last button doesn't reach the right side, use it's right side as the limit of the screen for the TabBar
      if (position + size < screenWidth) screenWidth = position + size;

      // if the offset pulls the last button away from the right side limit, we reduce that movement so the last button is stuck to the right side limit
      if (position + size - offset < screenWidth) {
        offset = position + size - screenWidth;
      }
    }

    // scroll the calculated ammount
    _scrollController.animateTo(offset + _scrollController.offset,
        duration: new Duration(milliseconds: 150), curve: Curves.easeInOut);
  }

  _getBackgroundColor(int index) {
    if (index == _currentIndex) {
      // if it's active button
      return _colorTweenBackgroundOn.value;
    } else if (index == _prevControllerIndex) {
      // if it's the previous active button
      return _colorTweenBackgroundOff.value;
    } else {
      // if the button is inactive
      return _backgroundOff;
    }
  }

  _getForegroundColor(int index) {
    // the same as the above
    if (index == _currentIndex) {
      return _colorTweenForegroundOn.value;
    } else if (index == _prevControllerIndex) {
      return _colorTweenForegroundOff.value;
    } else {
      return _foregroundOff;
    }
  }

// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'weather_disaster_api.dart';
// import 'package:svg_path_parser/svg_path_parser.dart';
// import 'package:donation_nature/screen/alarm_screen.dart';

// class InfoScreen extends StatefulWidget {
//   const InfoScreen({Key? key}) : super(key: key);

//   @override
//   State<InfoScreen> createState() => InfoScreenState();
// }

// class InfoScreenState extends State<InfoScreen> {
//   String? temp = '';
//   List<String>? reportList = ['', '', '', '', ''];
//   List<Color>? areaColor = [];
//   bool loading = false;

//   WthrReport wthrReport = WthrReport();

//   @override
//   void initState() {
//     super.initState();
//     getWeatherData();
//   }

//   getWeatherData() async {
//     setState(() {
//       loading = true;
//     });

//     wthrReport.getWeatherReport().then((List<String> value) {
//       setState(() {
//         reportList = value;
//       });
//     });

//     setState(() {
//       loading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: Text('재난 정보',
//               style: TextStyle(
//                 color: Colors.black,
//               )),
//           actions: [
//             IconButton(
//               onPressed: () {
//                 Navigator.push(context,
//                     MaterialPageRoute(builder: (context) => AlarmScreen()));
//               },
//               icon: Icon(Icons.notifications),
//             ),
//           ],
//         ),
//         body: loading
//             ? CircularProgressIndicator()
//             : SingleChildScrollView(
//                 child: Column(children: [
//                 Container(
//                     margin: EdgeInsets.all(50),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(
//                           color: Colors.black,
//                           width: 1.0,
//                           style: BorderStyle.solid),
//                     ),
//                     child: Stack(children: [
//                       // Container(
//                       //     decoration: BoxDecoration(
//                       //         image: DecorationImage(
//                       //       fit: BoxFit.cover,
//                       //       image: AssetImage('assets/images/background.jpg'),
//                       //     )),
//                       //     child: BackdropFilter(
//                       //       filter: ImageFilter.blur(
//                       //         sigmaX: 50,
//                       //         sigmaY: 50,
//                       //       ),
//                       //       child: Container(
//                       //         color: Colors.black.withOpacity(0.2),
//                       //       ),
//                       //     )),

//                       disasterButton(),
//                       drawMap(),
//                     ])),
//                 disasterInfo(),
//               ])));
//   }

  // Widget disasterInfo(int index) {
  //   print(Static.reportList![index]);
  //   return Container(
  //     child: Column(children: [
  //       Text('현재 상황'),
  //       if (Static.reportList![index].contains('null')) ...[
  //         Text('현재 발효중인 폭염특보는 없습니다'),
  //       ] else ...[
  //         Text(Static.reportList![index])
  //       ],
  //       Text(
  //           '폭염내용\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng\ng')
  //     ]),
  //   );
  // }

//   Widget disasterButton() {
//     return Container(
//       margin: EdgeInsets.only(top: 30, right: 30),
//       // height: double.infinity,
//       // width: double.infinity,
//       // decoration: BoxDec  //   color: Color.fromARGB(173, 170, 170, 170).withOpacity(0.1),
//       //   borderRadius: BorderRadius.all(
//       //     Radius.circular(10),
//       //   ),

//       // ),
//       alignment: Alignment.bottomCenter,
//       child: Row(
//         children: [
//           _WthrReportButton('폭염', Icon(Icons.local_fire_department), 0),
//           _WthrReportButton('호우', Icon(Icons.flood), 1),
//           _WthrReportButton('태풍', Icon(Icons.air), 2),
//           _WthrReportButton('강풍', Icon(Icons.tornado), 3),
//           _WthrReportButton('풍랑', Icon(Icons.air), 4),
//         ],
//       ),
//     );
//   }

//   Widget _WthrReportButton(String str, Icon icon, int index) {
//     return ElevatedButton.icon(
//         //Handle button press event
//         icon: icon, //Button icon
//         label: Text(str),
//         onPressed: () {
//           if (this.mounted) {
//             setState(() {
//               areaColor = wthrReport.classifyLocation(reportList![index]);
//               for (int i = 0; i < paths.length; i++) {
//                 paths[i][1] = areaColor![i];
//               }
//             });
//           }
//         },
//         style: ElevatedButton.styleFrom(
//           //Change font size
//           textStyle: const TextStyle(
//             fontSize: 10,
//           ),
//           //Set the background color
//           primary: Color(0xff416E5C),
//           // primary: Color(0xff90B1A4),
//           onPrimary: Colors.grey,
//           // onPrimary: Color(0xff416E5C),

//           padding: const EdgeInsets.all(10.0),
//         ));
//   }

// 서울, 부산, 대구, 인천, 광주, 대전, 울산, 경기도, 강원도, 충청북도, 충청남도, 전라북도, 전라남도, 경상북도, 경상남도, 제주도, 세종
  final paths = [
    [
      'm 133.25429,127.63884 0.58,0.33 0,0 3.8,3.83 -0.1,1.78 0.55,0.52 0.32,3.1 0.57,0.53 0.56,-0.1 2.41,-1.25 2.57,5.7 0.53,0.13 1.81,-0.73 1.21,0.5 2.39,-0.1 4.17,-2.31 3.08,-0.29 0,1.71 0.68,1.22 3.65,-2.08 2.99,-0.26 1.68,-1.58 -0.45,-0.56 0.43,-0.59 0.63,0.16 0.63,-0.46 1.28,-1.72 0,-0.59 -1.18,-0.49 0.4,-2.51 0.99,-0.99 1.76,-0.62 0.45,-0.53 -0.66,-2.41 -0.79,-1.15 -1.15,0.82 -2.47,0.6 -1.18,0.76 -1.18,0.16 -0.37,-0.59 -0.03,-1.19 1.45,-4.16 -1.11,-1.71 -0.07,-1.85 -0.9,-1.16 -0.1,-4.52 -0.92,-1.09 -1.18,-0.2 -2.63,0.33 -2.33,-0.53 -0.92,0.99 -1.26,0.53 -0.56,0.53 0.03,1.19 -1.1,1.06 -0.08,3 -1.1,0.79 -5.15,0.4 -0.84,1.05 -0.16,3.11 -0.63,0.36 -3.62,1.61 -2.42,-1.15 -1.39,-1.72 -1.26,-0.32 -1.02,2.47 -1.16,0.99 z',
      Color(0xff416E5C).withOpacity(0.0)
    ],
    [
      'm 362.20429,382.50884 0.04,0.76 3.97,0 1.34,1.34 0,0 1,1.68 -0.17,1.51 -0.9,0.32 -0.6,0.77 -0.37,1.02 0.26,1.67 -0.73,2.34 -0.87,-0.06 -0.1,0.93 -0.89,0.13 0.58,0.55 1.02,-0.35 0.31,1.63 -1.42,3.04 -0.63,-0.03 -0.34,-0.48 -0.6,1.41 0.79,1.38 -0.08,0.48 -0.45,0 -0.03,1.25 -0.5,0.26 -0.31,-0.45 -0.53,0.74 -1,0.13 -0.58,2.21 -0.76,0.16 -0.37,0.54 -1.65,-0.61 -0.6,0.1 -0.68,0.83 -1.65,-1.09 0.11,0.8 -1.63,0.22 -0.23,0.54 0.29,0.86 -0.66,0.67 1.02,0.16 0.52,1.5 -0.13,2.62 -1.18,-0.64 -0.71,0 -0.29,0.51 -0.92,-0.19 -0.1,-1.02 -0.21,0.64 -1.94,-0.26 0.21,-1.98 -0.71,-0.45 -0.58,0.8 -1.21,0.51 -0.31,0.57 0.24,0.38 -1.63,1.73 -0.21,1.79 -0.81,0.1 0.68,1.44 -0.71,1.15 -0.92,-2.04 -0.18,-1.53 -1.08,0.19 0.92,3.86 -0.34,0.54 -0.6,-0.13 -0.16,-1.47 -0.97,-0.35 -0.29,0.67 0.63,0.16 -0.13,0.83 -1.16,-0.13 0.69,0.93 -0.45,0 -0.73,0.83 0.1,-1.76 -0.73,-0.38 -0.81,-3.32 0.55,-3.03 -0.58,-0.06 -0.34,1.73 -1.15,0.77 -0.13,-1.18 0.47,-1.6 -0.42,-0.1 -0.68,2.01 -1.26,0.74 -0.03,0.86 -1.65,0 0.5,-3.8 0.53,-0.73 -1.05,-0.38 -0.97,4.92 -1.5,-0.51 -2.94,0 -1.5,-1.63 -0.24,0.7 -1.55,0.16 -1.15,1.31 -0.52,-0.06 -0.24,-0.83 0.76,-1.05 0.87,0.16 0.21,-0.64 -1.26,0.19 0.32,-2.32 0,0 0.2,-0.47 2.43,-1 4.3,-1.15 0.43,-5.01 2.29,-0.29 3.87,-2.43 4.15,-0.14 1.43,-1.57 0.86,-2 0.79,-0.2 0.98,-1.16 3.95,-2.48 1.84,0.32 1.03,-1.34 0.86,-2.72 1.72,-2.58 4.87,-0.57 0.57,-1.86 2.95,-2.71 0,0 0.24,0.27 z m -14.5,30.88 1.86,1.6 -0.29,1.63 1.94,1.63 -0.5,1.09 -0.89,0 -0.47,-1.18 -0.63,0.26 -0.5,-0.48 -0.08,-0.8 -1.31,-0.42 -1.81,-1.88 0.03,-0.48 0.81,-0.51 1.84,-0.46 z',
      Color.fromARGB(255, 223, 223, 223).withOpacity(0.0)
    ],
    [
      'm 298.06429,351.13884 -0.78,1 -0.8,3.59 -1.08,0.6 -2.42,-0.89 0,0 -1.53,0.37 0,0 -3.49,2.5 -2.41,0.06 0,0 -0.73,-3.43 -4.06,-4.99 0.31,-2.81 1.87,0.62 1.56,1.25 2.19,0 0.62,-2.49 -3.12,-3.44 1.25,-3.12 1.25,-2.81 5.3,-0.93 -0.31,-1.87 -2.81,-2.19 -4.68,-0.31 0.31,-3.12 1.25,-2.81 2.19,-3.12 2.18,-0.62 1.87,-1.25 0.63,5.61 2.49,0 0.94,-3.12 2.5,-4.99 5.92,-1.25 2.81,-3.12 3.43,-0.93 3.12,0.31 3.75,3.12 0,4.37 0.62,3.12 1.88,4.05 -0.94,2.19 -3.43,1.25 -1.56,3.43 0,3.12 -2.5,0.31 0,1.87 1.25,1.56 0,4.06 -3.43,1.25 -1.57,1.87 -2.8,-0.31 -0.63,-2.81 -3.12,0 -2.18,1.25 -1.56,2.5 z',
      Color.fromARGB(255, 223, 223, 223).withOpacity(0.0)
    ],
    [
      "m 113.77429,124.42884 2.46,-1.99 1.69,-0.73 0.62,-1.58 1.5,-1.27 2.08,0.19 7.46,6.03 0,0 3.83,1.29 -0.13,1.25 0.58,0.33 0,0 -3.54,4.55 0,0 0.13,4.02 3.31,2.9 0,0 0.03,1.19 -0.71,0.79 -0.02,0.66 0,0 0.26,1.15 -0.94,0.82 0,0 -0.55,0.43 -0.29,1.08 0,0 -0.55,-0.16 -0.13,-0.2 -1.31,-0.23 0.47,-1.81 -0.68,-0.53 -0.26,0.07 0.6,0.49 -0.13,0.76 -0.6,0.36 -0.29,-2.2 -0.31,-0.13 0.05,2.27 0.42,0.23 -0.03,0.49 -1.97,2.27 -3.57,-0.49 -3.68,4.64 -3.2,0.03 -0.13,0 -1.26,0.1 -0.34,1.09 -1,-0.03 0.84,-0.26 0.53,-1.84 2.18,0 -0.45,0.82 2.84,0 3.6,-4.51 -1.34,-0.43 -2.7,-2.73 -0.94,-4.28 -0.5,2.31 -1.47,-0.1 0.37,-0.82 -0.5,-0.72 0.68,-0.1 -0.47,-0.39 0.11,-0.56 -0.81,1.29 -0.97,-0.1 -0.24,-0.39 0.37,-1.38 -0.21,-0.89 0.6,-0.03 -0.34,-0.82 0.79,-1.52 2.99,-1.19 1.23,0.4 -0.76,-0.54 -0.16,-1.14 -1.05,0.99 -1.36,0.13 0.05,-1.32 -0.73,-0.39 -0.29,-0.69 0.97,0.1 -0.16,-1.25 -0.58,0 -0.05,-0.82 -0.53,0 -0.08,-0.43 0.68,-0.3 0.05,-1.42 -2.62,1.02 -0.16,0.63 -0.39,-0.4 -0.6,0.23 -2.31,2.02 2.21,-2.08 3.91,-1.62 -0.84,-1.06 -0.74,-0.13 -0.52,-1.42 z m -26.000004,1.62 1.76,0.89 0.08,0.36 0.87,-0.26 0.53,1.55 0.89,0.46 2.97,-0.43 -0.26,1.45 -2.05,-0.43 -1.86,0.63 -0.05,-0.56 -0.34,0 -1.02,0.96 0.37,-2.11 -1.94,-1.91 0.05,-0.6 z m 19.640004,3.16 0.76,0.73 -0.03,0.46 3.57,0.99 0.55,0.92 0.84,0.4 0.42,1.85 -2.26,1.42 -1.39,-0.07 -0.6,-0.59 -1,1.25 -2.13,0.96 -1.73,2.24 -4.02,2.93 -1.550004,-0.2 -1.31,0.76 -0.05,-0.53 0.58,-0.33 -0.18,-1.12 -0.94,-0.66 -1.23,0.82 0.89,-0.92 -0.47,-0.72 -0.74,0.23 0,0.79 -0.63,-0.53 -0.24,0.76 -0.52,-0.72 -1.1,-0.1 0.87,-0.62 -0.47,-0.16 0.13,-0.95 -0.55,0.07 -0.66,-0.72 -0.18,-0.69 0.42,-0.69 1.65,-0.03 3.94,-2.8 5.570004,-0.26 1.34,-0.96 0.68,-2.7 1.77,-0.51 z m -9.850004,14.66 0.11,0.82 0.79,0.26 0.79,1.28 1.100004,0.53 -0.08,0.59 -0.630004,-0.07 0.580004,0.43 -0.710004,0.49 0,0.69 -1.57,0.43 -0.95,-0.92 0.37,-1.25 -0.26,-0.69 -1.18,-0.3 0.81,-1.45 0.08,-0.99 0.75,0.15 z",
      Color.fromARGB(255, 223, 223, 223).withOpacity(0.0)
    ],
    [
      'm 151.37429,399.96884 -1.95,-2.34 -1.82,-0.87 -2.44,-0.09 -2.44,0.96 -2,1.04 -2.01,2.09 -1.48,0.09 -2.09,-0.7 -1.48,-1.39 -0.61,-2.18 -2.18,-0.08 -2.09,5.31 -2.35,-0.09 -1.74,2.09 -1.13,4.79 0.43,4.09 7.23,1.05 1.83,2.26 1.92,3.84 3.74,0 3.4,-2.01 3.83,0 1.48,-1.04 3.14,0.61 3.39,-2.35 1.4,-1.83 0.78,-1.66 0.09,-2.61 0.87,-1.83 0,-1.39 -2.09,-0.96 -2.61,-0.26',
      Color.fromARGB(255, 223, 223, 223).withOpacity(0.0)
    ],
    [
      'm 192.76429,261.00884 0.31,0.17 0,0 0.48,-0.09 0.98,-2.28 0,0 0.61,-0.64 0,0 1.39,0.18 -0.32,1.3 0,0 -0.07,0.64 0,0 0,0.26 2.86,-2.66 0,0 2.5,2.5 0,0 0.24,2.62 0.65,0.75 1.78,0.41 -0.32,1.63 0.77,0.21 1.25,2.18 -1.25,0.31 -1.56,1.56 0,0 -0.94,5.62 0,0 -1.25,6.24 1.17,3.75 0,0 -3.35,2.18 -2.18,2.81 -3.75,-2.19 -2.18,-3.74 0,-1.87 -0.63,-1.56 -1.56,0 0.32,3.12 -0.63,4.99 -0.93,2.19 -1.25,0 -0.94,-3.13 -2.5,-0.93 -1.56,-2.19 -0.31,-3.43 -2.18,-1.87 -0.31,-4.06 2.18,-2.49 -0.31,-8.74 0,0 2.52,-0.58 0,0 0.91,-0.04 3.43,-1.56 0.94,-2.81 0.33,-3.29 -0.31,-0.04 0,0 -0.23,-0.31 3.95,-0.42 z',
      Color.fromARGB(255, 223, 223, 223).withOpacity(0.0)
    ],
    [
      'm 361.40429,346.70884 1.8,1.47 2.01,0.31 0.98,0.59 0.23,0.82 0,0 -0.42,2.85 0,0 0.28,0.77 0.74,0.33 0,0 1.97,0.66 0,0 1.43,-0.25 2.82,-1.84 1.12,-0.31 0,0 1.48,-0.01 0,0 4.89,1.74 0,0 1.76,0.42 0,0 2.9,0.41 0.7,1.45 -0.03,1.38 -0.74,0.2 -0.39,0.58 0.53,3.14 -0.61,1.06 -0.05,1.35 -0.11,0.36 -1.02,0.16 0.03,0.48 0.73,-0.39 -0.18,1.58 -1.21,0.51 0.03,0.29 0.84,-0.16 0.13,0.61 -1.26,0.61 0.18,0.45 0.95,-0.39 0.36,0.65 -0.47,-0.07 -0.55,1.25 -1,-0.41 0.08,0.35 -1,0.13 0.05,0.51 -0.52,0.48 -0.42,-0.19 -0.24,-1.48 0.4,-0.99 -0.63,-0.84 -0.53,-0.06 0.19,-1.38 -0.82,-1.57 -1.94,-2.13 -1.5,-0.48 0,0.68 1.39,0.48 0.92,1.19 -0.08,1.12 0.97,0.26 -0.07,0.83 0.42,0.62 -0.32,0.44 -0.52,-0.22 -1.03,0.35 -0.5,-0.45 0.53,0.71 0.97,-0.26 0.89,1.58 -0.63,0.45 -0.13,1.15 -0.65,0.23 -1.19,1.41 -0.68,-0.03 -0.5,-1.13 -1.05,-0.54 0.68,0.8 0.08,2.21 0.29,0.26 0.87,-0.32 -0.5,0.99 1.36,-0.73 -0.41,0.73 0.41,0.87 -0.31,0.39 -1.02,0.06 -0.24,0.77 0.39,1.15 0.71,0 0.03,0.58 -0.5,0.16 -0.29,1.41 -0.81,0.36 -0.21,0.99 0.1,0.74 0.97,0.29 0.71,1.47 -1.49,0.87 -0.56,-0.55 -0.63,0.06 -0.5,1.13 -0.6,-0.03 -0.1,0.67 -0.5,0.22 -0.32,1.09 -1.07,0.07 -0.27,1.18 -1.15,-0.13 -0.29,-0.8 -0.55,0.26 0.17,-1.51 -1,-1.68 0,0 -1.34,-1.34 -3.98,0 -0.04,-0.76 0,0 -1.54,-1.88 0,0 -3.09,-0.21 0,0 -2.23,-1.89 -3.43,-3.98 0,0 -3.26,-3.36 -2.4,-0.2 0,0 -2.75,0 -2.23,-1.05 -0.34,-4.83 2.23,-1.89 0,0 1.2,-1.05 0,-1.46 -1.47,-2.43 0,0 3.92,-3.09 0,0 1.66,-0.17 0,0 0.68,0.13 0.65,-0.87 -1.35,-2.48 -0.22,-1.06 0.59,-0.5 4.16,-2.57 3.11,-1.02 1.63,0.29 2.59,-0.65 z',
      Color.fromARGB(255, 223, 223, 223).withOpacity(0.0)
    ],
    [
      'm 79.574286,102.98884 -1.73,-1.49 -0.08,-0.6 0.84,-0.5 0.68,-1.160003 -0.16,-1.19 0.37,-1.09 1.58,-1.49 0.84,0.3 1.81,-0.3 3.05,1.75 1.55,0 0.84,-0.66 1.08,1.19 -1.71,2.780003 -1.97,1.19 -2.62,-0.33 -0.79,0.53 -1.44,0.07 -1.05,1.42 -1.09,-0.42 z m 10.61,58.28 -0.37,0.53 -0.34,-0.26 -0.21,0.43 -1.39,-0.89 -0.45,0.2 -1.52,-0.49 -0.08,-0.59 -0.81,0.17 0.21,0.76 -0.47,0.33 1.26,1.22 0.11,-0.43 0.5,0.49 0.89,-0.13 0.21,0.79 0.18,-0.43 0.42,0.03 0.42,0.56 2.07,-0.52 0.74,-1.22 -0.84,-0.53 -0.53,0 z m -7.77,-43.87 -0.05,-0.99 0.5,-0.89 -0.26,-0.5 -1.53,0.07 -0.68,-0.4 -0.92,0.23 -0.08,0.6 1.39,1.49 1.87,1.02 0.55,0.76 0.34,-0.56 -0.47,-0.5 -0.66,-0.33 z m -11.47,45.78 -0.24,-0.56 -0.92,0.63 -0.08,-1.35 -0.39,-0.03 -0.29,-1.48 -0.6,-0.43 -0.5,0.26 0.18,0.46 -1.18,2.5 0.08,2.17 -0.6,0.89 1.26,-0.2 -0.21,-0.46 0.39,-0.33 0.39,1.28 1.16,-0.36 0.13,0.72 -0.66,0.33 0.37,0.39 1.76,-0.33 0.6,0.23 0.13,-0.52 0.89,0.1 0.05,-0.56 1.55,-1.31 -0.29,-0.3 -2.98,-1.74 z m 6.14,-52.22 -0.37,-0.13 -1.26,1.52 -1.05,-0.36 -1.34,0.4 0.11,0.5 1.18,0.73 1.16,-0.5 0.94,0.69 -0.08,0.79 0.47,-0.2 1.39,0.53 -0.29,-0.76 0.58,-0.69 -1.08,-1.06 -0.36,-1.46 z m 83.090004,-69.870003 -5.57,4.26 -1,1.83 -3.9,3.98 -2.81,0 -4.68,-1.87 -2.5,1.56 -2.81,1.87 -2.81,2.81 -3.43,4.99 1.87,0.94 1.87,3.75 6.31,0.29 3.37,1.9 0.62,3.12 -1.25,0.94 -0.31,1.87 -2.18,-0.62 -2.81,0 -0.31,3.75 -1.56,0.94 0.31,2.5 1.87,0.94 -0.31,6.55 -2.18,1.25 -1.56,-2.5 -1.56,-1.25 1.25,-4.37 -1.96,-2.47 -2.4,0.07 -0.32,2.71 -1.87,1.87 -3.47,-3.34 -0.74,0.11 -0.28,0.84 1.17,4.06 -0.49,1.87 3.49,0.83 1.25,0.94 3.43,4.99 -6.55,1.87 -2.83,0 -0.96,4.55 -3,0.18 -1.12,0.530003 -1.96,1.94 -3.56,-0.53 -2.02,-1.610003 -0.6,1.170003 -1.08,0.1 -0.68,0.69 1.1,1.75 -0.87,4.23 1.08,1.79 0.08,1.49 -0.58,1.62 1.16,0.53 -0.05,1.26 -0.71,0.46 1.68,3.04 0.97,3.3 2.37,3.1 0,0 2.46,-1.99 1.69,-0.73 0.62,-1.58 1.5,-1.27 2.08,0.19 7.46,6.03 0,0 3.82,1.29 0,0 1.16,-0.99 1.02,-2.47 1.26,0.33 1.39,1.72 2.42,1.15 3.63,-1.61 0.63,-0.36 0.16,-3.1 0.84,-1.06 5.15,-0.4 1.1,-0.79 0.08,-3 1.1,-1.06 -0.03,-1.19 0.55,-0.53 1.26,-0.53 0.92,-0.99 2.34,0.53 2.63,-0.33 1.18,0.2 0.92,1.09 0.11,4.53 0.89,1.16 0.08,1.85 1.1,1.72 -1.44,4.16 0.03,1.19 0.37,0.59 1.18,-0.16 1.18,-0.76 2.47,-0.59 1.16,-0.82 0.79,1.15 0.66,2.41 -0.44,0.53 -1.76,0.63 -1,0.99 -0.39,2.5 1.18,0.49 0,0.59 -1.29,1.71 -0.63,0.46 -0.63,-0.16 -0.42,0.59 0.45,0.56 -1.68,1.58 -2.99,0.26 -3.65,2.08 -0.68,-1.22 0,-1.71 -3.07,0.3 -4.18,2.31 -2.39,0.1 -1.21,-0.49 -1.81,0.72 -0.52,-0.13 -2.57,-5.7 -2.41,1.25 -0.55,0.1 -0.58,-0.53 -0.31,-3.1 -0.55,-0.53 0.1,-1.78 -3.81,-3.82 0,0 -3.54,4.55 0,0 0.13,4.02 3.31,2.9 0,0 0.03,1.19 -0.71,0.79 -0.02,0.66 0,0 0.26,1.15 -0.94,0.82 0,0 -0.55,0.43 -0.29,1.08 0,0 0.81,0 0.42,0.59 -3.96,-0.76 -0.89,1.05 0.81,0.63 -0.39,1.51 -1.97,1.65 -0.76,-0.07 -0.47,0.69 -1.5,0.36 -0.26,0.95 0.53,0.13 0.03,0.43 -7.6,2.52 -2.94,2.24 -0.92,-0.26 0.47,0.99 -1.29,1.38 -0.58,-0.03 -0.03,-0.66 -2.28,-0.69 2.13,2.2 0.32,1.48 0.45,0.36 -0.34,2.07 -0.47,0.43 -1.1,-0.03 -0.24,0.72 0.11,0.66 1.1,0.07 0.24,0.76 -1.21,0 0.29,0.85 -0.6,0.16 -0.47,0.92 0.39,0.26 0.55,-0.89 0.71,-0.06 1.02,1.58 0.71,-0.75 -0.21,-0.62 0.63,-1.35 0.71,-0.66 0.87,0.69 0.58,-0.06 0.5,0.85 0.37,-0.49 0.71,0.56 -0.21,-1.25 1,-2.07 0.26,1.64 2,1.25 -0.5,0.69 -0.03,1.02 0.58,0.62 0.37,-0.85 -0.18,-0.72 0.6,-0.75 -0.34,-1.64 -2.63,-1.35 -0.24,-1.44 -0.52,-0.43 0.13,-0.82 -0.94,-0.46 -1.26,0.07 -0.97,-1.35 -1.16,-0.66 1.1,-1.15 -0.08,-0.66 3.2,-2.23 6.49,-2.24 1,-0.07 3.52,2.79 4.86,1.81 3.1,-0.39 1.16,2.1 1.05,0.43 0.55,0.76 1.26,-0.43 -0.87,0.82 -0.13,0.95 -1.58,-2 -0.47,0.36 -1.44,-0.85 0.16,-0.92 -0.89,0.33 -0.34,0.79 0.76,0.56 0.18,0.72 -1.1,-0.56 -0.81,0.46 0.74,1.74 -0.92,0.85 0.66,0.2 -0.71,0.2 0.32,0.49 -1.84,2.66 -0.34,-0.59 -0.97,-0.29 0.58,-0.69 -0.47,-0.66 -0.13,-2.37 -2.65,0.85 -0.34,-1.08 -0.89,0.13 -2.68,-0.89 -0.89,1.12 0.16,0.72 -1.71,0.36 0.39,1.74 0.53,-0.2 0.4,0.79 -0.92,0.79 -0.03,0.95 0.97,1.54 -1.42,0.03 -1.16,1.48 1.18,2.59 -1.08,0.95 1,-0.03 0.5,-0.59 0.26,0.4 1.29,-0.39 0.11,0.66 0.79,-0.16 -1.34,1.84 -0.89,0.3 0.32,0.39 0.58,-0.16 0.39,0.59 0.34,1.25 -0.52,0.52 0.84,0.79 0.4,-1.61 0.89,-0.26 0.47,-0.92 0.55,-0.03 0.08,0.33 1.37,-1.02 2.07,-3.41 2.55,0.23 0.37,-0.59 0.45,0.03 0.58,-1.57 -0.03,1.21 0.68,0.2 -0.21,0.72 0.5,0.26 -2.15,1.31 4.67,0.07 0.05,0.36 -2.13,0.23 0.95,0.56 -0.03,0.46 -0.81,-0.36 -0.34,0.82 -1.02,0.49 -1.05,-0.72 -2.02,1.94 -0.18,0.92 0.71,1.8 -0.47,4.36 -0.37,0.46 -0.24,0.03 -0.95,1.44 -0.03,0.82 0.37,0.79 3.49,-0.03 0.81,0.36 0.29,2.1 -0.5,-0.2 -0.84,0.62 0.05,0.82 0.55,0.52 1.81,-0.2 1.55,0.49 1.5,2.59 0.29,1.01 -0.66,-0.36 0.5,0.92 1.92,0.79 0.45,1.87 1.94,-0.33 1.42,0.92 0.87,4.56 0,0 0.99,-0.06 0.83,-1.21 1.64,-0.81 7.55,1.76 0.83,-0.61 0.94,0.01 3.17,-1.16 3.01,-2.07 2.58,-0.08 2.99,1.43 1.34,1.8 1.95,1.59 5.1,0.7 0,0 2.77,-0.23 0,0 1.52,-0.91 0,0 1.56,-0.35 0,0 0.7,-0.44 0,0 1.71,-1.24 2.21,0.14 0.91,-1.35 0.89,-0.39 0.17,-2.11 -0.3,-1.08 0,0 2,-1.59 0,0 3.09,-1.41 -0.18,-0.45 0.93,-1.14 0.05,-1.04 2.34,-2.57 0.8,1.19 1.48,-0.02 -0.27,2.07 1.6,-3.22 4.3,0.78 4.06,-3.74 2.5,-0.31 0.63,-7.8 1.56,0 1.56,1.87 1.87,0 2.66,-6.65 2.65,-0.58 0,0 0.62,-7.44 -0.62,-3.43 1.56,-1.25 -0.31,-7.49 3.43,-8.11 0.31,-4.06 -1.95,-0.71 -0.79,-2.38 2.77,-3.14 0.37,-0.89 2.06,-0.7 0.79,-2.18 -1.27,-1.55 -0.38,-1.35 -2.24,0.17 -0.85,-0.79 -2.28,-0.62 -3.59,-0.12 -4.31,-3.69 -2.69,-0.32 -1.82,-1.46 -2.3,-1.02 -3.64,1.4 -1.28,-0.91 -1.36,-1.93 1.75,-3.51 0.31,-4.39 -1.56,0.55 -0.75,-0.14 -0.66,0.64 -0.63,-0.15 0.12,-2.02 2.16,-1.85 0.54,-1.23 -1.32,-3.5 0.01,-0.92 0.82,-1.04 -0.2,-1.75 -0.65,-1.200003 0.59,-1.52 2.26,-0.75 1.8,-2.06 2.62,-0.57 0.69,-0.5 1,-3.97 -0.82,-4.03 -1.44,-1.59 -2.01,-0.39 -2.19,-1.03 -0.08,-2.7 -0.88,-0.6 -3.22,0.34 -3.09,-1.53 -1.25,-1.59 -0.3,-1.43 -0.4,-7.52 -1.42,-1.97 -0.73,-0.09 -1.22,1.14 -0.7,-0.96 -1.4,-0.59 -1.49,0.2 -2.37,0.81 -1.22,1.41 -0.52,-0.29 -1.92,-2.18 -1.36,-0.21 -1.19,-1.19 -0.31,-1.97 0.55,-1.12 0.25,-2.23 1.09,-0.92 -1.97,-0.88 -0.57,0.04 -1.41,1.31 -1.68,2.4 -2.44,0.16 -1.64,-0.83 -0.51,-0.94 0.12,-2.25 -0.99,0.31 -0.18,-1.08 0.63,-1.87 -1.56,-1.25 -0.94,-5.3 -4.68,0 0,-1.87 1.25,-0.94 -4.74,-4.42 -1.48,0.39 z m -65.840004,70.330003 -1.08,-0.79 0.03,-0.5 -2.49,-0.36 -2.1,-1.65 -0.03,-2.31 1.02,-2.08 -0.92,-0.56 -3.23,1.32 -0.08,3.41 -0.24,0.4 -1.02,-0.23 -0.26,0.4 1.86,1.72 2.73,1.45 1.02,1.45 -0.26,2.08 1.26,0.63 -0.18,0.43 0.74,0 -0.21,-0.76 3.05,-1.98 0.39,-2.07 z m 13.580004,3.6 0.21,-0.56 0.76,-0.2 -0.03,-0.46 -1.13,-0.46 -0.34,-0.89 0.79,-3.17 -0.87,-0.76 -0.29,-0.96 0.13,-1.22 0.97,-1.42 0.13,-1.09 -1.37,-1.69 0.16,-1.02 -0.5,-1.260003 -4.52,-2.94 -2.150004,-2.78 -1,-0.23 -0.58,0.79 -2.36,0.17 -0.84,2.02 -3.49,1.89 0.6,3.440003 -0.42,2.68 0.34,3.97 2.99,0.79 0.39,0.56 -0.23,0.79 1.37,1.32 0.45,1.92 -0.16,1.49 -0.71,0.89 -3.18,0.59 0.81,0.53 0.34,1.55 -0.71,0.46 0.13,0.33 0.42,-0.07 1.26,1.19 1.26,0.2 0.34,0.63 5.360004,0.36 0.03,-1.02 0.89,0.43 0.58,-0.92 2.21,0.99 0.95,-0.07 0.81,-1.65 1.37,-0.4 0.05,-0.56 -1.22,-4.18 z m -3.08,43.89 -0.92,0.13 -0.6,-0.76 -1.55,0.56 -0.39,-0.13 -0.34,0.59 0.16,0.69 -1.550004,-0.13 -0.16,1.25 -0.55,0.26 0.45,0.3 0.37,1.68 -0.5,0.16 0.16,1.71 1.890004,-0.03 0.32,0.39 -0.26,0.53 0.63,-0.06 0.45,-0.72 0.89,-0.39 -0.26,-0.85 1.52,-0.1 0,-0.49 -0.52,0.13 0.03,-0.53 -0.66,-0.43 0.74,-0.29 0.53,0.26 -0.21,-0.76 1,0.72 0.42,-0.43 0.26,-1.54 -0.47,-0.89 -0.88,-0.83 z',
      Color.fromARGB(255, 223, 223, 223).withOpacity(0.0)
    ],
    [
      'm 281.58429,0.358837 1.42,2.81 2.15,2.75 0.58,-0.17 0.78,1.74 -0.02,0.73 -0.53,0.54 0.69,0.8 -0.08,0.54 1.15,1 -0.58,1.3 0.37,0.8 0.79,0.21 -0.16,1.46 1,0.77 -0.18,0.84 0.68,0.37 2.2,2.9 -0.44,0.57 -0.16,-0.3 -0.53,0.23 -0.05,1.71 3.78,5.8 1.74,1.8 -0.63,0.44 0.26,1.66 1.6,2.24 -0.03,1.46 2.32,2 -0.24,1.7 1,1.87 0.07,2.06 3.42,5 0.58,0.2 -0.74,0.4 -0.08,0.73 2.03,2.73 -0.92,0.99 0.5,1.87 -0.16,0.93 0.58,1.26 0.91,1.3 0.69,0.26 0.97,2.13 1.42,1.73 1.6,1.16 0.71,3.03 4.04,4.31 1.1,0.1 -0.5,1.89 3.76,6.17 1.68,1.2 -0.08,1.06 3.28,3.35 0.82,0.39 0.39,0.86 -0.47,1.63 1.86,2.65 2.52,2.38 0.24,1.46 9.51,10.030003 3.7,5.02 3.75,3.44 -0.29,2.47 -0.55,0.17 -0.52,1.06 0.16,0.95 2.38,3.24 4.5,3.69 0.36,1.82 -0.94,1.94 1.26,2.25 -0.32,0.69 1.39,1.98 -0.39,0.26 1.76,1.38 3.41,3.92 1.11,5.04 4.83,3.75 0.08,2.24 0.91,1.15 0.71,3.49 1.84,1.61 1.03,-0.1 0.47,2.53 0.63,-0.26 1.02,0.33 -0.05,0.66 0.87,0.42 -0.27,1.81 2.13,1.94 0.05,1.05 0.63,0.43 -1.47,1.11 0.71,1.78 -0.84,2.39 0.55,2.59 1.21,1.22 0.95,2.46 0.58,0.26 -0.32,1.18 0.81,0.84 0,0 -4.27,0.71 0,0 -1.87,2.19 -2.5,0.93 -2.81,2.5 0,0 -1.56,2.18 0,1.25 0,0 1.56,2.81 -6.54,0.16 0,0 -2.65,-2.27 -2.95,-1.03 -2.62,-0.4 -2.54,2.52 -1.01,-0.2 -3.07,-1.74 -3.35,-0.68 -1.17,-0.03 -2.18,0.75 -0.68,-1.33 -1.72,-0.68 0,0 -0.93,0.59 -1.98,3.72 0,0 -0.93,1.24 -4.06,0 -3.43,-2.8 -2.81,-1.56 -2.02,0.18 -0.65,2.32 0.11,2.4 -0.37,0.75 -0.75,0.37 -1.45,-0.96 -1.61,-0.42 -1.92,0.26 -3.09,-2.1 -1.17,-0.24 0,0 -1.73,-1.35 0,0 -0.64,-0.79 0,0 -2.14,0.26 0,0 -1.35,-0.05 -3.96,-1.27 0,0 -1.62,-0.72 -1.97,-2.2 -1.66,-0.52 -0.35,0.43 0,0 -0.94,0.43 0,0 -3.29,0.58 -0.82,-0.25 -0.31,0.59 -0.76,0.12 -0.82,-1.39 0,0 -0.18,-0.83 0,0 -1.15,-0.53 0,0 -0.46,-0.29 0,0 0.01,-1.95 0,0 0.09,-0.67 0,0 -0.96,-0.81 -1.46,0.33 -2.42,-0.19 0,0 -0.86,0.05 -1.19,1.25 0,0 -1.47,0.14 -0.5,0.52 0,0 -0.7,0.47 -2.31,-1.77 0,0 -0.66,-1.69 1.52,-1.27 0,0 1.74,-0.76 0,0 2.36,-2.73 0.1,-1.36 -0.58,-0.53 -0.97,0 -1.37,0.83 0,0 -1.05,0.27 0,0 -1.71,-0.24 -1.48,-1.73 -2.12,-0.43 -1.98,-1.51 -2.46,0.59 -1.12,0.93 -0.67,1.51 -0.68,0.1 -2.97,-1.01 -1.59,1.78 -2.09,1.3 0,0 -2.13,0.37 0,0 -2.04,0.82 0,0 -0.9,-0.33 0,0 -0.34,-0.47 0.06,-3.37 0,0 -1.77,-3.31 0,0 -2.05,-0.52 0,0 -2.22,0.08 -1.5,0.94 0,0 -2.38,1.69 -0.46,1 0.28,2.7 0.71,1.99 -0.42,1.8 -2.04,0.79 -0.44,0.95 -0.67,0.36 -2.33,-1.15 -3.03,0.09 -1.45,1.88 -2.19,0.93 -4.05,-3.12 -0.62,-3.48 0,0 0.62,-7.44 -0.63,-3.43 1.56,-1.25 -0.31,-7.49 3.43,-8.11 0.32,-4.06 -1.96,-0.71 -0.78,-2.38 2.77,-3.14 0.36,-0.89 2.07,-0.7 0.79,-2.19 -1.27,-1.55 -0.38,-1.35 -2.24,0.17 -0.86,-0.79 -2.28,-0.62 -3.59,-0.12 -4.31,-3.7 -2.69,-0.32 -1.81,-1.46 -2.3,-1.02 -3.64,1.4 -1.28,-0.91 -1.36,-1.94 1.75,-3.51 0.31,-4.39 -1.56,0.56 -0.74,-0.14 -0.66,0.64 -0.63,-0.15 0.12,-2.03 2.16,-1.85 0.54,-1.23 -1.32,-3.5 0.01,-0.92 0.81,-1.04 -0.2,-1.75 -0.64,-1.200003 0.58,-1.52 2.27,-0.76 1.8,-2.06 2.61,-0.57 0.7,-0.5 1,-3.97 -0.82,-4.03 -1.45,-1.59 -2.01,-0.39 -2.19,-1.03 -0.08,-2.71 -0.88,-0.6 -3.22,0.34 -3.1,-1.53 -1.25,-1.59 -0.3,-1.43 -0.41,-7.51 -1.42,-1.98 -0.74,-0.09 -1.22,1.14 -0.7,-0.96 -1.39,-0.59 -1.49,0.19 -2.37,0.81 -1.21,1.41 -0.53,-0.28 -1.91,-2.18 -1.36,-0.22 -1.19,-1.19 -0.32,-1.97 0.55,-1.12 0.25,-2.23 1.09,-0.92 -1.97,-0.88 -0.57,0.04 -1.41,1.31 -1.68,2.39 -2.44,0.17 -1.64,-0.84 -0.51,-0.93 0.12,-2.26 -1,0.31 -0.18,-1.07 0.63,-1.87 -1.56,-1.25 -0.94,-5.31 -4.68,0 0,-1.87 1.25,-0.94 -4.74,-4.41 0,0 0.99,-1.18 3.05,-2.08 1.11,-0.23 2.26,0.62 3.7,-1.29 2.99,-1.77 3.41,0.52 1.61,1.19 1.5,-0.4 1.69,0.29 1.14,-0.95 2.09,0.01 1.88,-1.02 2.04,-0.11 1.97,0.83 1.25,1.07 1.57,-0.16 2.22,0.84 2.22,1.42 5.31,-3.21 2.93,-1.03 1.45,0.32 1.16,1.12 1.5,0.09 2.28,-0.5 2.67,0.67 1.95,-1.31 5.79,0.29 2.54,-1.4 0.62,0.36 0.71,1.79 2.34,2.45 2.13,-0.92 1.79,-0.19 0.82,-0.45 1.3,-1.79 6.29,1.84 1.78,-0.43 6.45,1.44 2.96,-0.46 2.98,-2.44 2.64,0.1 0.7,-0.38 2.93,-2.96 3.87,-2.45 1.29,-2.11 1.76,-1.15 3.77,-3.69 2.16,-4.61 -0.23,-1.44 1.05,-3.15 -0.53,-9.08 0.56,-0.74 z',
      Color.fromARGB(255, 223, 223, 223).withOpacity(0.0)
    ],
    [
      'm 214.60429,306.87884 -0.93,-2.8 -1.56,-3.12 -2.19,-1.88 -0.31,-2.8 0,0 1.25,-2.81 -0.31,-3.12 -1.87,-3.12 0,0 -2.8,0.26 -1.03,-0.84 -2.93,-1.08 -1.05,-3.65 1.25,-6.24 0,0 0.94,-5.62 0,0 1.56,-1.56 1.25,-0.31 -1.25,-2.18 -0.77,-0.21 0.32,-1.63 -1.78,-0.41 -0.65,-0.75 -0.24,-2.62 0,0 -2.5,-2.5 0,0 -2.86,2.66 0,-0.26 0,0 0.07,-0.64 0,0 0.32,-1.3 -1.39,-0.18 0,0 -0.61,0.64 0,0 -0.98,2.28 -0.48,0.09 0,0 -0.31,-0.17 0,0 -1.25,-5.3 -3.95,0.42 -0.39,-0.55 -0.71,-0.14 -0.4,0.33 0,0 -0.57,0.78 0,0 1.86,-6.1 -1.08,-1.14 0.83,-1.83 0.09,-1.45 -3.34,-0.2 -0.45,-1.35 0,0 0,-2.81 -2.81,-3.43 2.19,-0.63 0.31,-2.81 0,0 -1.56,-2.18 4.99,-7.8 3.75,0.31 1.56,-1.87 -1.25,-3.75 -3.12,-2.18 -2.88,0 0,0 -1.08,-0.48 0.16,-1.99 0,0 -0.06,-0.42 -0.53,-0.07 0,0 -1.48,-0.71 0,0 -0.23,-2.66 -2.84,-1.92 -0.91,-2.42 2.76,-0.23 0,0 1.52,-0.91 0,0 1.56,-0.35 0,0 0.7,-0.44 0,0 1.71,-1.24 2.21,0.14 0.9,-1.36 0.89,-0.39 0.17,-2.11 -0.3,-1.08 0,0 1.99,-1.6 0,0 3.09,-1.41 -0.17,-0.45 0.92,-1.15 0.05,-1.03 2.34,-2.57 0.81,1.19 1.48,-0.02 -0.27,2.07 1.59,-3.23 4.31,0.78 4.05,-3.74 2.5,-0.31 0.62,-7.8 1.57,0 1.56,1.87 1.87,0 2.66,-6.65 2.65,-0.58 0.62,3.48 4.05,3.12 2.19,-0.93 1.44,-1.88 3.04,-0.09 1.92,1.08 1.08,-0.29 0.44,-0.95 2.04,-0.79 0.42,-1.8 -0.72,-1.99 -0.27,-2.7 0.46,-1 2.38,-1.69 0,0 1.5,-0.94 2.22,-0.08 0,0 2.05,0.52 0,0 1.77,3.31 0,0 -0.06,3.37 0.34,0.47 0,0 0.9,0.33 0,0 2.04,-0.82 0,0 2.13,-0.37 0,0 2.09,-1.3 1.59,-1.78 2.97,1.01 0.68,-0.09 0.67,-1.52 1.12,-0.93 2.46,-0.59 1.98,1.51 2.12,0.43 1.48,1.73 1.71,0.24 0,0 1.05,-0.27 0,0 1.37,-0.83 0.97,0 0.58,0.53 -0.1,1.36 -2.36,2.73 0,0 -1.74,0.76 0,0 -1.52,1.27 0.66,1.69 0,0 2.31,1.77 0.7,-0.47 0,0 0.5,-0.52 1.47,-0.14 0,0 1.19,-1.25 0.86,-0.05 0,0 2.42,0.19 1.46,-0.33 0.96,0.81 0,0 -0.09,0.67 0,0 -0.01,1.95 0,0 0.46,0.29 0,0 1.15,0.53 0,0 0.18,0.83 0,0 0.82,1.4 0.76,-0.13 0.31,-0.59 0.82,0.25 3.29,-0.58 0,0 0.94,-0.43 0,0 0.35,-0.43 1.66,0.52 1.97,2.2 1.62,0.72 0,0 3.96,1.27 1.35,0.05 0,0 2.14,-0.26 0,0 0.64,0.79 0,0 1.73,1.35 -1.27,1.28 0,0 -0.93,0.88 -0.47,-0.23 0,0 -0.92,-0.33 0,0 -0.75,0.31 0,0 -1.45,2.14 -0.83,0.48 0,0 -0.62,0.28 0,0 -3.29,3.25 -2.8,0.8 0,0 -0.79,1.25 0,0 -0.46,1 -3.08,1.75 -0.09,0.88 -1.49,1.47 -1.58,3.31 0,0 -0.83,1.57 0,0 -0.06,1.33 1.32,0.61 0,0 0.53,0.82 0,0 0.26,2.1 -2.84,3.89 0,0 -1.43,0.3 0,0 -2.11,0.15 0,0 -0.46,0.33 0,0 -0.92,1.04 -2.44,-0.06 0,0 -1.65,0.44 -0.55,-0.26 0,0 -1.03,-2.79 -1.46,-2.13 -3.24,-1.85 -1.18,-1.97 0,0 -1.08,1.28 -0.28,1.02 0,0 -0.31,0.75 -1.13,0.34 -0.24,2.59 0,0 -0.2,0.64 0,0 -0.37,0.57 -5.21,-1.29 -0.49,-0.45 0,0 -0.42,-0.63 0,0 -1.07,-0.37 -0.61,0.62 0,0 -1.38,1.15 0,0 -1.15,1.94 0,0 -1.38,0.19 0,0 -1.64,-1.74 -0.51,0.3 -2.71,6.34 0,0 -0.15,0.35 0,0 3.24,4.45 0.15,0.8 -1.19,0.1 -3.41,-1.02 0,0 -1.18,-0.66 -1.21,0.59 0,0 -2.19,-1.02 0,0 -1.12,-0.61 0,0 -1.17,2.33 -1.71,1.4 -1.6,1.04 -2,0.13 0,0 -0.65,0.25 0,0 -1.68,2.38 0.48,2.22 0,0 -0.45,0.7 0,0 -2.2,1.91 0,0 -0.58,0.73 0,0 -0.95,1.5 -0.81,0.05 0,0 -1.56,0.35 0,0 -0.82,1 -0.17,0.91 0.72,1.1 5.37,1.13 1.22,1.22 -0.14,0.93 0,0 0.38,1.56 0.58,0.41 0,0 1.64,0.68 0.37,0.68 -0.42,1.71 0,0 -0.13,0.56 0,0 -1.89,0.33 0,0 -0.43,1.34 0,0 0.3,3.59 -0.68,2.7 0.6,1.18 0,1.29 -1.29,2.02 1.32,3.25 0,0 0.5,0.31 0,0 -1,2.56 -2.67,2.31 0,0 -0.07,4.28 0.37,0.79 1.79,0.99 0,0 1.84,-1.07 1.17,-1.51 0.4,0.02 0.47,1.45 2.24,0.79 0.26,0.69 0,0 0.09,0.5 0,0 0.98,0.32 0,0 0.78,0.75 0,0 0.33,0.49 0.84,-0.09 0,0 1.99,-0.84 0,0 2.23,-0.79 2.02,0.7 0,0 0.62,1.07 0,0 -0.35,1.06 0.5,2.11 0,0 0.57,1.3 0.69,0.57 0,0 -0.09,0.79 -1.15,0.56 -2.47,-1.48 -2.41,1.43 -0.66,0.86 -0.52,0.88 0.08,1.19 1.09,1.77 -0.51,1.41 0.1,2.16 -1.75,1.46 0.18,0.92 -1,1.68 -0.22,2.04 -1.84,2.6 -0.76,0.33 -0.88,-0.66 -1.24,0.23 -3.82,3.64 -2,-2.22 -0.9,-0.06 0,0 -1.37,0.45 0,0 -2.73,1.62 0,0 -0.89,0.33 0,0 -0.36,0.91 0,0 -2.6,0 -0.15,-0.92 0,0 -1.71,-1.04 0,0 -1.17,-0.29 0,0 -2.26,-0.56 0,0 -0.67,-0.57 0,0 -1.05,-2.27 z',
      Color.fromARGB(255, 223, 223, 223).withOpacity(0.0)
    ],
    [
      'm 92.784286,270.55884 -0.1,0.91 -1.31,-0.62 -0.47,0.68 -0.24,-1.39 1.08,-0.75 0.03,-1.33 0,0 0.66,0 0.21,1.69 0.95,0.71 -0.81,0.1 z m 7.280004,-4.78 -0.730004,0.78 1.160004,0.58 1.58,0.16 -0.16,0.94 -1.42,-0.13 -0.18,-0.62 -1.650004,-0.45 -1.63,0.03 -0.39,-0.58 -1.21,0.42 -0.66,-0.26 -0.03,-1.07 0.74,-0.55 1.44,0.49 1.08,0.91 -0.52,-1.43 0.95,-0.46 0,0 1.02,0.1 0.16,1.04 0.450004,0.1 z m -5.750004,-16.7 0.26,0.33 1.16,-0.03 0.81,0.94 0.21,1.11 -0.53,0.36 -0.02,0.55 1.1,-0.32 -0.16,1.82 0.87,1.43 -1,1.43 0.79,0.2 0.71,1.43 0.87,0.13 -0.21,0.98 0.47,1.17 -1.29,1.01 0.58,1.36 -0.84,0.13 0.21,-0.46 -0.34,-0.45 -0.5,0.29 -0.16,-1.17 -1.21,0 0.37,-0.75 -1.92,-0.03 -0.05,0.58 -0.92,0.52 -0.5,-0.62 -0.42,0.07 -0.13,-1.01 -0.68,0.03 0.55,-1.88 -2,0.2 -0.45,-0.58 0.24,-0.65 -0.37,-0.98 0.76,-1.72 -1.37,0.39 0.11,-0.49 0.68,-0.29 0.29,-2.11 -0.05,-0.65 -0.6,-0.29 0.29,-0.91 -0.52,-0.19 0.32,-5.21 -1.44,-1.85 -0.21,-1.53 0.89,-0.85 0.05,-0.81 2.78,-2.12 0,0 0.42,-0.16 0.92,0.78 -0.05,1.14 0.79,0.62 -0.18,0.75 0.42,0.1 -0.05,1.14 -1.36,0.46 -0.16,0.52 1.47,0.68 0.34,1.76 -0.24,1.5 1.02,1.37 -0.1,0.59 -0.72,0.24 z m 6.770004,-61.83 -2.810004,0.3 0.29,-0.98 -0.6,-1.08 0.26,-0.72 0,0 2.360004,0.39 0.53,0.82 -0.03,1.27 z m 4.52,-2.55 2.02,0.72 0,0 1.55,2.26 2.21,0.36 6.8,4.06 1.6,0.39 4.75,-0.16 0.37,0.79 7.51,2.03 0.29,0.43 -0.37,0.95 1.58,2.68 -0.31,0.43 0.42,0.79 0.37,0.56 0.29,-0.33 0.47,0.16 0.53,3.37 0.95,1.08 0.03,0.56 3.57,0.65 1.71,-0.78 2.78,-0.28 0.99,-0.06 0.83,-1.21 1.64,-0.81 7.55,1.76 0.83,-0.61 0.94,0.01 3.17,-1.16 3.01,-2.07 2.58,-0.08 2.99,1.43 1.34,1.8 1.95,1.59 5.1,0.7 0.91,2.42 2.84,1.92 0.23,2.66 1.48,0.71 0.53,0.07 0.06,0.42 -0.16,2 1.08,0.48 2.88,0 3.12,2.18 1.25,3.75 -1.56,1.87 -3.74,-0.31 -4.99,7.8 -2.44,0.2 -2.56,-0.94 -2.7,-1.62 -1.48,-1.62 -2.56,-0.81 -2.7,1.08 -0.4,1.75 1.08,2.02 0.54,2.02 0.27,3.1 -0.67,2.43 0.27,3.37 0.14,3.51 0,3.1 -1.08,2.43 0.14,2.02 1.89,2.56 2.7,1.48 1.35,3.91 0.27,2.83 -0.13,4.04 1.21,3.1 1.75,1.35 1.71,2.06 0.31,4.06 2.18,1.87 0.31,3.43 1.56,2.19 2.5,0.94 0.94,3.12 1.25,0 0.94,-2.18 0.63,-4.99 -0.31,-3.12 1.56,0 0.62,1.56 0,1.87 2.18,3.74 3.75,2.19 2.18,-2.81 3.35,-2.18 2.8,0.98 1.03,0.85 2.8,-0.27 1.87,3.12 0.31,3.12 -1.25,2.81 0.31,2.81 2.18,1.87 1.56,3.12 0.93,2.8 -0.31,0.33 0,2.49 -2.81,2.81 -1.56,-1.25 -2.6,-1.28 -1.89,1 -1.03,0.18 -0.16,2.21 -0.94,1.87 -3.12,0.62 -3.43,-0.31 -0.62,-2.81 -0.07,-2.18 -0.61,-0.16 -3.06,1.72 -1.25,0 -1.87,-4.37 -0.35,-2.77 -2.96,-5.1 -1.13,-1.63 -2.42,2.02 -4.37,-0.31 0.63,2.5 -5.3,0.31 -1.73,-1.73 -1.12,-0.16 -1.9,1.15 -2.3,0.23 -1.48,0.72 -2.55,-0.18 -0.51,-0.81 -0.02,-1.21 -2.43,-0.19 -0.31,-3.74 -2.19,-2.01 -1.27,0.38 -3.76,-2.27 -3.68,-0.67 -2.68,2.01 -2.01,0.67 0,8.44 -7.18,3.43 -4.37,1.56 -1.48,-1.36 -1.31,0.56 -0.68,-0.33 -0.31,1.03 -1.08,1.13 -4.28,-1.07 -1.13,0.61 -0.73,-0.74 0.42,-1.07 -0.47,-1.07 0.68,-0.06 0.08,-0.42 -2.26,-2.59 -1.05,0.1 -0.29,-2.81 -1.05,0.19 0.68,-1.03 0.73,0.42 1.1,-0.81 -0.08,-0.52 -1.18,0.32 0.03,-0.84 -1.05,-0.49 -0.81,0.71 -1.34,-2.94 -2.55,-2.2 -1.39,1.39 -0.13,-0.91 -0.79,-0.94 -2.63,-0.94 -1.18,0.32 -0.29,2.4 -1.08,-0.97 0.03,-2.75 0.81,0.45 1.55,-0.23 0.76,-0.97 -0.18,-2.23 1.1,-1.59 0.39,-0.03 -0.89,-4.5 0.66,-0.78 0.32,-1.75 0.71,-0.13 0.05,-0.49 -0.58,-0.97 -0.73,-0.29 0.5,-0.32 -1.18,-2.24 -0.92,0.13 -0.42,-1.62 -1.23,-1.59 0.45,-0.52 0.84,0.42 0.63,-0.81 2.23,-0.78 0.29,-0.68 0.92,-0.55 2.6,0.23 -3.26,-0.68 -4.73,-3.28 -1.78,-0.03 0.42,-3.21 0.92,-1.92 1,-0.23 1.39,-1.43 1.26,0 0.66,-1.2 0.68,0.1 0.18,-0.39 1.5,0.1 0.68,-2.76 1.26,0.72 1.44,-0.26 1,-1.24 -2.23,0.78 -1.44,-0.91 -0.5,0.49 -0.5,-0.59 -0.1,0.75 -2.1,1.37 -0.31,1.17 -0.79,0.06 -0.31,1.4 -2.62,1.33 0.26,-1.2 -1.23,-1.3 0.11,-1.79 -0.66,-1.01 0.24,-3.41 0.71,-0.26 0.26,-0.98 1.05,-0.88 2.15,0.81 1.29,1.53 0.76,-0.1 -1.65,-1.56 -1.76,-0.68 -0.73,-0.75 -1.5,1.27 -0.23,-1.01 -2.13,-1.89 0.66,-1.69 -0.73,-3.03 -1,-1.2 -3.460004,-1.4 -0.55,-0.94 -3.62,-0.59 -0.68,-0.65 -2.34,1.4 -1.58,1.53 -0.58,1.56 -0.6,-0.59 -1.58,1.86 -0.21,-0.91 -0.81,-0.81 0.66,-1.04 -0.1,-1.89 1.05,-0.75 -0.13,-3.16 -1.08,-2.31 -0.55,-0.42 -0.8,0.33 -0.92,-0.23 -0.08,-0.75 0.4,-0.36 -0.53,-0.33 -0.1,-0.72 0.11,-0.69 1.02,-0.68 -0.21,-1.44 0.29,-0.78 0.47,0.13 0.34,-0.42 -0.39,-0.75 -0.87,0.07 -1,1.47 -2.1,-0.1 -0.18,0.98 0.6,0.49 -0.1,0.36 -0.76,0.23 0.13,0.59 -2.31,0.23 0.13,0.65 -0.94,0.23 0.18,0.46 -0.45,0.98 -0.79,0.26 -0.31,-0.75 -0.89,0.39 -1.92,-0.29 -0.6,-2.02 0.34,-0.29 -0.56,-0.57 0.26,-0.42 1.18,-0.29 -0.29,-0.39 0.95,-0.78 1.29,0.36 1.47,1.11 0.81,0.07 0.97,-0.72 0.58,-1.21 -0.89,-0.65 -1.05,0.65 0.05,-0.65 1.21,-1.69 -1.23,0.59 -1.92,-1.08 1.02,-1.34 -0.87,0.2 -0.31,-0.42 -1.5,-0.06 -0.87,0.55 -1.55,-0.85 0.13,0.91 0.87,0.75 0.16,2.02 -2.68,2.68 -0.42,0 0.13,-0.78 0.53,-0.29 -0.34,-1.17 1.13,-1.63 -0.39,-0.62 0.31,-0.42 -0.16,-0.29 -0.71,0.29 -0.34,-0.56 0.24,-0.68 -0.39,-0.06 0.18,-0.49 -0.81,-0.46 -0.08,-0.56 1.81,-0.36 -0.03,-1.27 0.42,0.52 1.05,-0.85 0.42,-1.57 -0.5,0 -0.24,-0.65 0.68,-0.39 -0.03,-0.56 0.66,-0.06 0.18,-1.18 -1.29,-1.21 0.92,-0.03 -0.58,-1.04 0.63,0.29 0.47,-0.75 0.08,1.08 1.02,0.06 -0.5,1.31 0.63,0.59 -0.18,1.83 0.24,0.2 0.45,-0.72 1.29,3.33 0.63,0.36 -0.53,-2.64 -0.84,-0.49 -0.26,-1.21 1.1,-0.1 -1.42,-1.57 1.13,-0.78 0.95,-1.96 -1,0.07 0.05,-1.21 -0.66,0 -0.08,-0.49 0.89,-0.69 -0.52,-0.69 -0.92,-0.16 0.1,-0.36 1,-0.29 0.45,0.52 0.42,-0.1 0.29,-0.56 -0.29,-0.33 0.68,-0.39 -0.18,-0.98 0.92,0.79 0.55,-0.82 1.55,-0.39 0.26,-0.69 0.5,0.26 0.97,-0.36 -0.45,0.69 2.68,1.31 1.02,-0.23 -0.37,-1.08 0.84,-1.31 -0.29,-3.7 -0.76,-1.44 0.42,-0.72 0.87,0 0.53,-0.98 0.53,-0.1 0.26,0.75 -0.45,0.82 -1.02,0.26 0.81,1.05 0.63,-0.36 0.37,0.26 -0.95,1.31 0,3.24 0.66,0.46 0.13,0.75 0.87,0.26 0.18,1.6 0.97,0 -0.13,0.56 -1.23,0.03 -0.39,0.36 -0.03,0.82 -0.97,1.21 -0.03,1.01 -0.62,0.62 -0.08,1.18 2.1,0.46 -0.16,0.69 -1.92,0.95 -1.13,-0.03 -0.23,0.75 0.68,0.42 -0.21,1.31 0.5,0.62 0.53,-0.52 -0.13,-0.59 0.37,-0.26 0.26,0.52 0.32,-0.2 -0.31,-0.62 0.34,-0.42 0.76,0.43 0.87,-0.88 0.53,0.59 0.6,-0.03 0.08,-0.39 -0.94,-0.75 -0.1,-0.75 0.39,-0.42 -0.97,-0.75 1.13,-2.68 0.76,0.46 0.84,-0.16 -0.42,1.7 1.26,1.73 0.81,0.1 -0.89,-1.86 1.44,-1.24 0.03,-1.34 -0.63,-0.88 1.23,-0.72 1.94,0.26 -0.16,-1.54 0.71,0.29 0.11,-0.75 0.97,0.39 0.29,-0.49 1.1,-0.06 0.13,-0.36 -0.45,-0.56 -1.71,-0.26 0.21,-0.78 -0.55,-0.36 -0.08,-0.29 0.87,0.2 0.53,-0.52 -0.03,-1.5 -0.92,-0.43 0.05,0.46 -0.97,0.1 -0.76,0.79 -0.63,-0.56 -0.24,-1.28 -1.18,-0.26 -0.94,0.92 -0.26,-0.26 0.45,-1.08 -0.92,-0.16 -0.18,-1.15 -1.44,0.16 0.21,-1.08 2.47,0 0.71,1.11 0.45,-0.98 1.1,0 0.11,-0.36 -0.13,-0.33 -0.87,0.16 0.1,-0.72 -0.55,-0.52 -0.81,0.49 -0.18,-0.49 -2.97,-0.23 -0.31,-1.83 0.71,0.36 1.65,-0.88 0.32,-0.79 0.81,0.52 1.76,-0.36 0.34,-0.69 0.37,0.49 3.6,-0.1 2.680004,1.34 1.26,-0.65 -1,-1.9 0.42,0.1 2.18,-2.52 -0.53,-0.56 0.71,-1.38 0.5,0 0.37,-0.74 z',
      Color.fromARGB(255, 223, 223, 223).withOpacity(0.0)
    ],
    [
      'm 129.12429,307.63884 1.31,-0.55 1.48,1.36 4.37,-1.56 7.18,-3.44 0,-8.44 2.01,-0.67 2.68,-2.01 3.69,0.67 3.76,2.27 1.27,-0.38 2.19,2.01 0.31,3.74 2.44,0.2 0.02,1.21 0.51,0.81 2.55,0.18 1.48,-0.72 2.3,-0.23 1.9,-1.15 1.12,0.16 1.73,1.73 5.3,-0.31 -0.62,-2.5 4.36,0.31 0,0 2.42,-2.01 1.14,1.62 0,0 2.96,5.11 0.35,2.77 1.87,4.37 1.25,0 0,0 3.06,-1.72 0,0 0.61,0.16 0,0 0.07,2.18 0,0 0.63,2.81 3.43,0.31 3.12,-0.62 0.94,-1.87 0,0 0.15,-2.21 1.03,-0.18 0,0 1.89,-1 2.54,1.2 1.56,1.25 2.81,-2.81 0,-2.48 0,0 0.31,-0.33 0.79,-0.3 1.05,2.27 0,0 0.67,0.57 0,0 2.26,0.56 0,0 1.17,0.29 0,0 1.71,1.04 0,0 0.15,0.92 2.6,0 0,0 0.36,-0.91 0,0 0.89,-0.33 0,0 2.73,-1.62 0,0 1.37,-0.45 0,0 0.9,0.06 2,2.22 2.74,-2.56 0,0 3.48,5.66 1.23,3.31 -0.27,2.77 -1.01,2.24 0,0 -2.33,1.52 -1.51,2.68 -0.53,1.94 -1.33,0.24 -1.78,1.64 -1.46,0.01 0,0 -1.83,1.15 0,0 -1.3,0.06 0,0 -0.71,-0.5 0,0 -0.45,-0.16 -0.2,0.63 0,0 -0.19,0.59 0,0 -0.66,1.2 0,0 -0.81,2.29 -3.27,3.59 -1.67,1.15 -0.78,4.82 0,0 -0.16,1.92 -0.89,0.79 0,0 -0.94,1.45 -1.91,4.95 0,0 -0.78,4.73 0,0 -1.59,3.28 0,0 0.17,2.32 0,0 2.07,0.67 0.7,0.7 0,0 -0.08,1.86 0.5,1.05 0,0 1.27,2.27 0,0 -0.68,3.34 0,0 0.69,1.93 0,0 1.63,0.43 0,0 0.1,0.54 0,0 -0.56,3.47 -3.7,3.56 -0.82,1.99 -0.33,1.16 0.55,2.87 -2.22,2.3 0,0 -0.23,0.21 0,0 -3.07,-2.65 -3.31,-1.81 0,0 -1.03,-0.92 -3.51,-1.16 0,0 -2,0.11 0,0 -1.75,0.98 -2.95,3.79 -0.63,0.45 -1.12,0.02 0,0 -3.2,-0.37 -2.38,0.7 0,0 -6.15,0.02 -1.13,-0.65 0,0 -1.44,-1.38 -1.93,1.12 0,0 -3.16,-1.35 -1.3,0.83 0,0 -0.96,0.9 0,0 -1.43,0.95 -1.61,0.14 0,0 -2.09,-0.54 0,0 -2.6,-1.97 0.42,-3.61 -1.01,-2.88 0,0 -1.59,0.01 -0.49,-0.68 -0.08,-0.93 1.15,-1.38 0,0 0.15,-2.51 -0.61,-1.91 -1.35,-1.03 -1.81,-0.4 -0.71,0.32 -0.98,1.78 -1,0.65 -0.53,2.08 0,0 -0.14,1.02 0,0 -1.02,0.69 -1.97,-0.57 0,0 -1.04,-0.89 0,0 -2.52,-4.77 -1.1,-1.13 -2.95,-1.86 -3.02,-0.61 -1.57,1.87 -1.08,-0.22 0,0 -1.53,-0.35 0,0 -2.27,0.98 -0.61,0.81 -0.18,1.18 0,0 0.15,3.09 -0.59,0.68 0,0 -1.45,0.95 -0.15,0.68 0,0 0.26,0.77 0,0 0.14,0.96 -0.76,2.01 -2.42,1.22 0,0 -3.14,0.97 -1.53,1.49 0,0 -2.07,0.71 -0.97,-0.43 0,0 -1.11,-0.24 -0.99,0.36 -1.45,1.54 -4.35,0.23 0,0 -0.37,-1.7 -1.72,0 -1.24,-4.06 -1.88,-2.18 -0.15,-2.96 -0.78,-2.66 -1.87,-1.56 0,0 -1.88,-0.62 0,0 -1.94,-0.18 0.02,-0.42 -0.44,-0.13 -0.740004,0.44 -0.73,-0.21 3.310004,-5.62 0.86,-2.57 0.63,-0.25 0.32,-1.39 0.31,-0.09 0.37,1.12 0.68,0.26 0.48,-0.45 -0.5,-0.16 0.26,-0.96 1.79,-1.16 0.99,-0.13 1.21,1.06 0.74,-1.19 1.49,-0.9 2.55,0.32 0.24,1.26 0.23,-1 0.84,-0.87 0.45,-1.7 0.55,0.16 -0.05,-1.22 0.5,0.35 0.94,-0.77 1.6,0.48 1.97,2 0.5,1.06 0.08,-0.71 -0.73,-1.67 0.34,-0.9 -0.97,-0.58 0.15,-0.67 0.45,0.38 0.55,-0.77 -1.39,0.03 0,-0.51 -0.68,-0.61 -0.69,0.09 -0.68,-0.67 -0.29,0.87 -0.71,0.19 -0.76,-0.42 -0.79,0.93 -0.68,-0.03 0.08,-0.48 -0.63,-0.45 -0.42,0.77 -1.76,-0.26 -2.34,0.55 -0.81,-0.32 -1.16,1.09 -0.91,-0.06 -0.35,-1 -0.57,1.06 -1.71,-0.74 -1.1,-2.02 -1.24,0.58 -0.73,-1.64 0.39,-1.39 0.66,-0.51 -0.11,-0.48 -0.73,-0.07 -0.42,-0.48 0.86,-0.32 0.03,-0.55 1.08,0.1 0.86,-1.1 1.47,-0.58 3.34,-3.57 1.84,-1.19 1.15,0.61 1.55,-1.67 0.95,-0.45 1.76,-2.9 1.31,-1.35 -0.13,-3.58 -0.58,-0.74 1.05,-1.61 1.86,0.93 4.63,-0.71 4.49,1.2 2.1,1.74 0.5,2.22 0.84,0.81 0.68,-0.65 -1.23,-0.35 0.02,-1.55 0.58,-0.74 -0.69,-2.9 -4.01,-2.13 -3.28,-2.58 -1.47,-0.29 1.44,-1.48 3.2,-1.23 3.63,0.65 0.55,-0.42 1.13,0 0.92,-1.13 -0.34,-0.97 0.42,-1.13 1.78,-0.55 1.13,-0.87 -0.24,-0.45 -1.39,0.52 -1.05,-0.26 -1.49,0.32 -1.66,1.65 -2.81,-0.29 -2.15,0.77 -3.26,-1 -1.36,1.23 -5.18,-0.29 -0.31,-3.78 0.5,-2.78 -2.08,-0.67 -2.47,0.19 -0.02,-1.1 -1.89,-1.48 0.73,-0.91 2.76,-0.16 0.66,0.39 1.49,-0.58 0.95,0.16 0.21,0.84 0.71,-0.84 0.6,0.32 5.12,-1.13 1.66,-1.23 2.88,1.13 1.11,-0.68 0.6,-1.19 0.32,-1.33 z',
      Color.fromARGB(255, 223, 223, 223).withOpacity(0.0)
    ],
    [
      'm 67.004286,506.88884 0.37,1.2 -0.6,-0.79 -1.23,-0.38 -0.68,1.2 -0.45,-0.41 0.24,-1.2 -0.42,0.35 -0.6,-0.28 0.47,1.04 -0.45,0.54 -0.47,-1.11 -0.47,0.22 -0.55,-0.47 -0.42,0.35 -1.02,-0.28 0.45,-0.57 -0.26,-0.54 -0.95,0.22 0.32,-0.85 0.34,-0.25 0.39,0.28 0.66,-0.76 -1.02,-0.31 0.16,-0.38 0.63,0.38 0.39,-0.38 -0.42,-0.38 0.87,-0.32 1.29,1.68 2.55,-0.38 0.79,-0.51 -0.21,1.58 0.71,1.11 -0.41,0.4 z m 27.52,-23.66 -0.74,-0.47 0.05,-0.41 0.84,-0.25 -0.47,-1.14 -0.87,-0.32 -0.76,-1.27 -0.79,-0.13 0.18,-0.54 -0.79,-0.6 -0.08,-0.63 -0.92,0.32 0.63,-1.11 -1.44,0.35 -0.16,0.67 -0.84,-0.22 -1.34,-1.52 0.76,-0.67 -0.73,-1.08 -1,-0.09 0,-0.51 -3.18,-1.24 -1.6,0.03 -0.29,0.48 0.55,0.35 -0.39,1.65 1,0.22 0,0.32 -1.5,2.92 -0.55,-0.03 -0.29,-0.63 -0.08,1.21 -0.63,-0.19 -0.6,0.6 1.1,1.21 -1.89,0.16 -0.37,1.05 0.74,0.83 -1.13,0.54 -0.5,-0.48 -0.03,-0.7 0.47,-0.89 -0.45,-0.22 -1.57,2.19 0.21,0.38 -0.37,0.79 -2.23,0.79 -0.52,0.76 -2.49,1.33 0.21,0.7 0.74,0.16 0,0.86 -0.66,-0.57 -1.13,0.44 -1.08,1.05 0.13,0.63 -0.79,1.43 2.7,4.56 0.89,0 0.39,-0.82 1.05,0.03 0.29,0.79 -1.02,0.44 0.39,0.6 -0.94,1.23 1.65,0 -0.13,-0.73 0.76,-0.22 0.92,1.62 1.31,-0.22 0.95,0.28 0.11,-0.51 2.55,-0.47 -0.66,-1.27 1.23,0.54 0.92,-0.89 0.6,0.67 0.89,-1.2 1.63,0.13 0.5,-0.6 -0.81,-0.32 0.45,-1.2 1.16,0.1 -0.02,0.7 0.37,0 1.58,-0.82 -0.81,-0.98 0.89,-0.38 0.1,0.6 0.71,0.1 -0.37,-1.2 1.16,0.86 -0.24,-1.81 1.39,1.74 -0.6,0.16 0.24,0.57 0.37,0.35 0.87,-0.32 -0.03,-1.68 1.18,-0.89 0.5,-1.39 1.13,-0.89 -0.71,-1.65 0.55,-0.82 0.6,-0.03 0.16,-0.82 -1.21,-0.35 0.03,-0.85 1.5,-0.41 0.58,0.86 0.32,-0.41 -0.52,-0.98 0.14,-0.31 z m -41.68,-26.17 0.21,-0.51 -1.02,-0.7 0.13,-0.35 0.92,0.19 -1.26,-1.91 0.05,-1.46 1.13,0.06 0.21,-0.48 2.89,0.22 0.18,-0.67 0.63,0.19 0.34,-1.34 1.16,-0.16 0.21,-1.46 -0.47,-1.37 -0.34,-0.09 -0.18,0.45 -0.63,-0.22 -0.05,0.48 -0.81,-0.29 -0.45,0.41 0.05,0.67 -0.68,0.29 0.11,0.54 -1.23,-0.25 0.21,0.64 -1.21,0.73 -1.21,0.26 -0.97,-0.16 -0.05,-0.57 -1.02,-0.13 -0.45,0.32 -0.29,-0.32 -0.16,0.96 0.58,0.25 -0.81,0.38 -0.13,-0.54 -0.39,0.76 0.58,0.7 -0.45,0.13 0,1.05 0.39,-0.16 -0.71,1.08 0.03,1.18 0.6,-0.16 -0.13,0.67 0.74,0.16 0.32,0.7 1.34,0.44 0.71,-0.19 1.38,-0.42 z m 77.730004,47.71 0.47,-0.1 0.47,-0.92 -0.63,-0.76 -1.44,0.03 -0.03,-1.01 -1.13,-1.46 0.03,-0.89 -0.68,-0.41 0.08,-2.82 -1.08,-1.2 -0.66,-0.09 -1,-1.2 -1.31,-0.1 -0.42,-0.44 -3.1,1.08 -0.97,0.89 -0.26,0.89 0.58,1.17 -0.37,0.41 0.37,2.03 -0.37,0.63 0.71,0.67 -0.5,0.89 1.97,0.41 0.53,0.92 0.66,0.1 0.45,0.79 -0.34,0.38 1.55,1.42 1.55,-0.6 2.5,1.27 -0.5,-1.77 0.32,-0.31 1.18,1.49 1.23,-0.1 0.76,0.63 0.79,-0.03 -0.47,-0.89 -0.76,-0.38 -0.18,-0.62 z m -70.790004,-45 -0.31,-0.6 -0.87,0.16 -1.47,-1.43 -1.26,-0.32 -0.47,-0.73 -0.05,-1.4 -0.45,-0.25 -0.16,1.81 -1.23,-0.06 0.26,1.4 -0.37,0.6 -0.97,-0.57 0.26,-0.6 -2.1,0.44 -0.21,2.96 0.6,1.65 0.74,-0.29 -0.08,-0.57 0.47,0.06 0.29,0.67 -0.34,0.44 0.84,0.51 0,-0.48 0.74,0.1 0.03,-0.67 0.53,0.03 0.29,0.45 -0.52,0.6 0.13,0.51 0.97,0.32 1.5,-0.67 0.03,-1.08 1.5,-1.02 0.16,-1.05 1.08,0.29 0.13,-1.21 0.31,0 z m 62.910004,59.64 0.55,-0.73 -1.63,-1.58 -1.73,-0.57 -0.66,1.55 -0.89,-0.09 0.79,0.35 -0.58,0.41 0.58,0.41 0.45,-0.47 0.58,1.36 -1.13,0.95 -0.47,1.26 -0.47,-0.1 -0.24,0.51 0.55,0.48 -0.37,0.63 0.66,0.51 0.05,1.14 1.05,-1.01 0.32,0.22 -0.13,1.61 1,0.47 0.89,-1.04 -0.37,-0.66 0.6,-0.57 -0.37,-1.39 0.29,-0.22 0.81,0.6 0.26,-1.07 -0.42,-0.28 -0.89,0.25 -0.05,-1.42 -1.15,-0.38 0.13,-0.85 1.99,-0.28 z m -5.96,-4.58 -0.79,-0.41 0.03,-0.6 -1.36,-0.35 -0.76,0.35 -0.63,-0.54 -0.52,0.73 -0.47,-1.39 -1.42,0.06 0.71,0.47 0.05,0.54 0.47,0.06 0,0.6 -0.89,0.1 -0.26,0.76 0.31,0.22 0.29,-0.54 0.37,0.32 -0.47,0.63 -0.66,0.03 0.55,0.32 -0.6,0.6 0.45,0.35 -0.92,0.41 1.6,0.41 -0.05,1.17 2.57,0.54 -1.34,-1.55 0.32,-0.38 1.68,-0.13 -0.1,0.92 1.63,0.19 0.26,-0.22 -0.24,-0.73 -1,-1.2 1.81,0 0.26,-0.63 -0.58,-0.28 -0.3,-0.83 z m -0.55,6.1 -0.37,-0.54 -2.31,-0.41 -0.66,0.44 0.05,0.57 -0.39,-0.25 -0.1,-0.85 -1.39,0.28 -0.03,-0.73 -1.52,-0.89 -1.6,1.3 -0.58,0.03 -0.03,0.57 -1.08,0.6 0.47,0.85 -0.55,0.73 0.53,0.28 -0.52,0.6 0.84,1.96 0.63,-0.44 0.76,0.51 3.31,-1.61 0.4,-1.04 0.97,-0.03 -0.24,-0.5 0.66,-0.41 -0.18,-0.63 0.79,0.16 0.34,-0.76 1.16,2.02 0.05,-1.67 1.23,1.39 0.71,-0.95 -0.24,-0.92 -1.11,0.34 z m -55.880004,-48.84 -0.45,0.54 0.1,0.73 0.6,0.51 -0.26,1.18 0.97,-0.13 -0.18,-0.86 0.58,0.1 0.16,-0.54 0.6,0.98 0.76,-0.57 0.6,0.54 -0.08,-0.35 0.53,-0.13 -0.18,-0.48 0.55,-0.7 -0.42,-1.11 -0.71,0.64 0.24,-2 -1.44,0.45 -0.31,-0.35 0.21,-0.6 -0.47,0.29 -0.26,-0.6 0.03,-0.92 0.66,-0.35 0.11,-0.86 -1.05,0.25 0.16,-0.79 -0.47,0.35 -0.95,-0.38 -0.45,0.48 0.6,1.43 -0.55,1.3 0.32,0.57 -0.29,0.67 0.82,-0.44 0.6,0.57 -0.26,0.7 -0.42,-0.12 z m 24.11,-31.35 -0.34,-1.02 -0.24,1.34 -0.52,0.48 -2.07,-0.38 -0.74,-0.51 -0.47,1.82 1.23,0.1 1.21,0.83 0.87,0.1 1.58,-1.88 1.34,0.06 0.34,0.41 1.47,-0.13 0.37,0.86 0.45,-0.6 0.84,0.03 0.63,0.73 -0.05,0.54 0.71,-0.29 0.1,0.92 -0.47,0.1 -0.24,0.77 -1,0.22 0.45,0.67 1.76,0.54 0.18,-0.95 0.32,0.41 1.18,-0.64 -0.45,-1.94 0.79,-0.16 -0.29,-1.59 -1.08,0.45 -0.42,-0.77 0.55,-0.19 -0.1,-0.32 -1.94,-0.1 -1.18,0.41 -0.97,-0.83 1.02,-0.48 -1.08,-0.73 0.37,-0.48 0.79,0.29 0.05,-1.24 0.68,0.54 0.37,-0.73 0.58,-0.16 0.58,0.86 0.21,-0.35 -0.03,-0.99 -1.05,-0.35 -0.39,-0.89 -1.23,-0.29 -0.29,0.54 -0.73,-0.06 -0.66,-1.4 -0.66,-0.26 -1.57,1.05 -0.13,0.32 1.31,0.99 0.89,1.66 -1.02,0.64 -0.66,-0.67 -0.52,0.06 -0.21,1.63 0.71,0.64 -0.29,0.57 -0.84,-0.2 z m -14.73,17.06 0.84,-1.34 1.42,-0.13 -0.32,0.73 0.82,0.41 0.13,1.88 0.76,-0.44 1.13,0.57 0.89,-0.7 -0.16,-1.21 0.45,-0.57 -0.63,-2.42 -1.26,-0.8 0.08,-0.86 -1.79,0.67 -1,-0.76 -0.71,-1.46 -1.73,0.54 -1.81,-0.92 0.05,0.89 -0.39,0.32 -0.47,0 0,-0.57 -0.81,0.28 -0.63,-0.25 0.26,0.41 1,0.16 0.45,1.43 -0.71,0.51 -0.39,1.34 0.24,0.29 1.05,-1.08 1,-0.13 0.1,1.02 0.66,-0.29 -0.37,1.88 1.18,-0.16 -0.13,0.41 0.8,0.35 z m 7.79,8.26 -1.52,0.54 -0.18,-0.7 0.5,-0.83 -0.6,-0.73 -0.63,0.13 0,-0.79 -1,-0.06 -0.21,-0.67 -0.6,-0.22 -0.97,0.32 -0.63,1.56 -0.79,-0.57 -0.31,0.95 -1.18,0.1 0.26,1.02 1,-0.64 0.58,0.73 -0.45,1.21 -0.6,0.41 0.45,0.6 -0.37,0.76 0.63,0.26 0.79,-0.64 1.26,0.06 -0.05,-0.67 0.53,-0.28 0.97,0 0.21,0.6 0.5,-0.03 0.63,-1.05 1.52,-0.16 0.37,-0.41 -0.11,-0.8 z m -3.28,-50.49 -0.47,1.88 0.58,-0.8 0.13,0.7 0.97,-0.29 -0.55,0.77 1.89,0.38 -0.03,-0.48 0.45,-0.13 0.84,1.05 1.79,-0.16 0.97,0.61 -0.42,1.66 0.92,0.19 0.87,1.6 0.84,0.35 0.58,-0.22 0.97,-1.91 -1.15,-0.73 -0.39,-2.43 -1.42,-0.99 -0.05,-1.21 0.55,-1.53 -0.52,-0.64 -1.39,0.9 -0.39,-1.05 -0.73,-0.22 -1.23,0.57 0.11,-0.67 -1.1,-0.58 -0.37,0.35 -0.68,-0.13 -0.32,0.7 -0.84,-0.16 -1.13,0.83 -0.08,1.09 0.8,0.7 z m -7.98,25.68 -0.63,0.96 -1.57,0.29 1.68,2.55 1.37,1.31 0.53,1.02 -0.16,1.05 2.21,-0.35 0.5,-1.4 -0.92,-1.65 0.68,-0.54 0.11,-0.6 1.13,0.51 1.6,-1.24 -1.02,-1.08 -0.71,-0.03 -0.03,-0.8 0.55,-0.32 1.29,0.38 0.6,-0.8 -0.39,-0.51 -0.45,0.22 -0.55,-1.53 -0.47,0.77 -0.68,-0.61 -0.71,0.13 -0.81,-0.41 -0.58,0.38 0.55,0.8 -0.55,0.45 0.16,0.54 0.89,0.73 -0.5,0.92 -2.13,-0.64 -0.34,-0.64 -0.65,0.14 z m 1.52,-16.26 0.71,0.51 1.44,-0.03 0.24,-0.48 0.95,-0.13 0.76,0.45 1.84,-0.03 0.71,-1.15 -0.52,-0.19 0.45,-0.54 -0.37,-0.41 -2.84,-0.99 -0.58,0.03 -0.24,0.99 -0.87,-0.06 -0.66,1.53 -0.55,-0.32 -0.47,0.82 z m -10.87,15.33 -0.52,0.38 0.6,0.19 0.45,-0.35 0.58,0.45 0.37,-0.51 0.97,0.8 0.47,-0.6 1.76,0.57 1.05,1.85 0.37,-0.38 -0.55,-1.4 0.76,-0.22 0.21,0.76 1.44,-0.45 -0.52,-0.57 0.18,-0.22 1.97,0.1 -0.6,-1.43 1.92,-0.92 0.05,-0.57 -1.02,-0.13 -0.47,-0.8 1.52,-1.4 -1.42,-0.22 -0.08,-0.41 0.66,-0.29 0.13,-0.51 -1.23,0.29 -0.31,-0.51 0.42,-0.8 -2.1,-0.86 0.39,2.17 -0.58,0.96 -1.02,0.19 -0.42,-1.11 -0.55,0.03 0.31,0.48 -0.42,0.7 -1.1,0.16 -0.71,-0.51 -0.05,0.96 -0.89,1.63 -0.53,0.35 -0.5,-0.22 0.29,0.77 -0.52,0.73 -1,-0.29 -1.13,0.32 -0.03,0.48 1.1,-0.32 0.3,0.68 z m 6.25,-22.23 0.87,-0.38 -0.05,0.9 0.66,0.13 -0.42,-1.37 1.58,-0.26 -0.26,1.15 0.26,0.45 0.81,0.06 0.11,0.38 0.81,-0.13 0.08,0.57 0.55,0.06 -0.05,-0.51 0.47,0 -0.39,-1.05 1.52,0.1 -0.68,-0.7 -0.13,-0.83 0.6,0.32 0.63,-0.54 -0.16,-0.48 -1.34,-0.51 -0.29,-0.77 0.32,-1.5 0.55,-0.38 0.63,0.35 -0.18,-1.47 0.5,-1.63 0.37,-0.54 1.73,-0.19 0.26,-0.64 1.47,-0.29 -1.29,-0.22 -2.78,0.74 -0.58,-0.29 0.24,0.54 -0.34,0.54 -2.81,2.97 -1.34,0.67 -1.86,-0.1 0.18,1.09 -0.87,1.18 1.58,0.93 -0.31,0.86 -1.68,-0.25 0,0.54 0.5,-0.16 0.53,0.66 z m -56.2399997,41.87 -0.84,0.38 -0.31,1.02 -0.69,0 -0.66,-0.73 1.29,-1.05 -2.49,0.13 -0.6,0.44 0.05,1.24 -1.08,1.02 -0.03,1.24 -0.97000002,0.67 0.24,0.73 0.84000002,0.28 -0.05,0.32 -1.19000002,0.28 0.95000002,1.65 1.58,0.57 -0.08,-1.68 0.6,-0.16 0.03,-0.44 1,-0.09 -0.55,-1.59 1.23,0 0.32,-0.29 0.34,-0.19 0.24,-2.06 0.97,-0.51 0.34,0.57 0.55,-0.7 -0.24,-0.76 -0.5,0.06 -0.29,-0.35 z m 138.5900037,58.06 -0.81,0.51 -0.39,-0.16 0.42,-0.35 0.08,-0.85 -0.79,-0.88 0.79,-0.44 -0.08,-0.76 -1.58,0.03 -0.31,-0.57 -0.68,0.06 -0.29,0.57 -0.89,0.22 -0.18,0.82 -1.18,0.31 0.47,0.44 -0.92,1.11 0.47,0.98 -0.79,-0.16 -0.21,0.51 0.34,0.7 0.45,-0.51 0.37,0.35 -1,0.89 0.58,0.19 -0.21,0.51 0.34,0.69 0.32,-1.29 0.87,-0.47 1.18,1.26 -0.08,0.6 1.79,-0.69 0.79,0.6 1.02,-0.91 0.6,-2.53 -0.49,-0.78 z m 80.08,-80.44 0.87,0.61 0.84,-0.03 -0.13,-3.44 -1.71,-1.69 -2.7,-0.06 0.26,-1.72 -0.79,-0.64 -1.44,1.56 -0.13,0.64 -1,0.38 0.05,2.01 5.36,1.21 0.5,0.7 0.16,-1.88 -0.45,-0.29 0,-0.54 0.95,-0.35 0.79,1.54 0.15,2.38 -1.26,-0.32 -0.32,-0.07 z m -0.23,34.13 0.5,0.64 1,-0.16 0.89,0.54 1.55,-0.6 0.16,-0.86 -1.86,-1.24 0.39,-0.41 -0.08,-1.75 0.84,-0.35 -0.18,-2.89 0.79,-0.29 -0.05,-0.44 -1.02,0.13 -0.18,-0.51 0.73,-0.22 -0.58,-0.06 -0.23,-0.63 -0.74,0.32 -0.79,-1.24 0.45,-0.7 -0.16,-1.18 -0.45,-0.16 -0.84,0.51 -0.66,-1.08 0.58,-0.76 0.84,0.67 0.45,-0.79 0.18,0.45 -0.47,0.64 0.81,-0.13 0.11,0.45 0.39,0 -0.24,-2 -4.04,-1.97 -0.47,0.03 -0.26,0.6 0.47,0.16 0.47,1.5 1.13,0.16 -0.42,1.78 0.24,0.76 1.44,0.7 -1.79,0.32 -0.52,0.73 0.03,0.73 -1.76,1.46 -0.52,0.03 -0.58,1.43 0.66,0.95 -1.34,1.52 0.89,0.95 1.66,0.22 -0.03,0.76 1.18,1.4 1.43,-0.12 z m -6.07,-14.9 -1.31,-1.11 -0.79,-0.16 0.34,-0.67 -0.97,-0.95 -0.79,-0.13 0.05,-0.73 -0.6,0.16 0.18,1.02 -0.79,0.38 -1.05,2.74 -0.42,-0.06 0.71,1.44 -1.55,-0.55 0,-0.83 -0.34,0.22 -0.08,1.08 -0.26,-0.26 -0.47,0.26 0.05,0.51 1.26,0.76 -0.42,1.02 0.71,0.48 0.68,-0.13 -0.71,0.54 -0.84,-0.19 0,0.32 0.71,0.35 0.6,1.88 -0.66,0.51 0.63,0.67 0.32,-0.35 0.37,0.19 -0.21,0.79 -1,0.67 1.02,0.03 0.42,1.14 -0.81,0.16 -0.24,-0.76 -0.95,0.32 0.18,-0.35 -1.15,-1.27 -2.42,-0.98 -1.21,0.38 0.71,2.19 -0.26,-0.03 -1.44,-2.73 -0.58,-0.57 -0.55,0.06 -0.21,-0.86 0.34,-0.54 0.63,-0.03 0.21,-0.6 -1.1,-0.35 0.05,-1.59 0.63,-0.06 -0.29,-0.29 0.53,-0.41 1.34,0.19 0.16,-0.32 -0.5,-0.29 -0.79,0.22 0,-0.83 -1.02,0.96 0.37,-1.53 -0.76,0.38 -0.05,-0.29 0.24,-0.73 1.23,-0.54 -0.24,-0.92 0.63,0.48 1.05,-0.57 -0.08,-0.7 0.55,-0.03 -0.13,-0.7 1.92,0.06 -1.1,-0.7 -0.71,0.1 0.63,-0.83 -0.68,-1.34 -0.34,0.89 -0.66,0.19 -0.03,-1.59 -1.29,-0.38 1.21,-0.25 0.16,-0.48 -0.39,0.03 -0.21,-0.92 -0.76,-0.54 -0.13,-1.3 -1.1,-0.35 -0.21,0.54 -0.6,-0.03 -1.21,-0.38 0.18,-1.62 1.16,-0.99 0.45,-1.18 -0.97,0.13 -0.68,-0.38 -0.79,-4.01 -1.24,0.61 -1.31,0.1 0.19,3.06 -0.6,0.77 -1.78,-0.54 -0.53,0.48 -1,0.1 -0.16,0.48 -0.66,-0.13 -0.05,-1.4 -0.42,0.03 -0.42,1.37 -3.36,1.34 -1.29,-1.34 -2.34,-0.1 -0.05,0.35 0.76,0.41 1.52,0.42 0.92,1.46 0.53,-0.29 1.65,0.51 0.92,-0.41 0.26,0.22 -1.5,1.31 -1.6,0.7 -0.71,1.08 -0.08,0.92 -1.94,-0.1 0.32,0.32 2.23,0.13 0.89,0.8 -0.39,1.24 -1.65,0.8 -0.73,1.08 1.55,3.4 0.79,0.64 0.39,-0.16 0.52,0.38 0,0.54 1.58,0.89 0.21,0.95 0.6,0.38 -0.45,0.7 0.84,-0.44 1,0.48 -0.24,1.37 1.21,-0.83 -0.05,0.83 0.95,0.1 -0.47,-1.08 1.47,-0.13 -0.03,0.86 -0.42,0.06 0.05,1.08 1.55,0.51 -0.03,0.89 -1.18,-0.67 -0.34,0.83 -0.55,-0.13 -0.37,-0.83 -0.47,0.44 0.84,0.92 2.78,0.6 -0.26,0.7 0.42,0.67 -0.18,0.51 0.87,1.14 -0.03,1.24 -1.71,1.43 -0.05,0.98 -0.55,-0.54 -0.47,-0.13 -0.37,0.57 -1.05,-0.7 0,-1.21 -0.39,-0.06 -0.05,0.89 -1.18,0.79 -1,-0.57 0,-0.73 -1.47,0.64 -0.37,-0.22 0.13,-0.48 -0.68,-0.22 -1.42,0.54 -2.55,0.03 0.05,0.67 2.36,-0.19 0.24,0.95 1.31,-0.79 -0.39,1.37 -0.63,0.57 -1.58,-0.19 -0.18,1.08 1.97,-0.57 1.08,0.45 1.18,-0.06 -0.63,0.57 1.37,-0.32 0.63,0.57 -0.6,0.76 0.42,0.95 -0.63,-0.28 -0.23,0.76 -0.39,-0.03 0.74,1.21 -0.29,0.28 0.18,0.7 -1.26,-0.82 -0.81,-0.06 -0.47,0.64 0.37,0.13 -0.24,0.92 -1.05,0 -0.37,-0.6 -1.05,0.73 1.13,1.43 -0.24,0.92 -0.29,-0.38 -0.47,0.35 -0.13,-0.44 -0.45,0.86 -0.39,-0.06 -0.21,-0.73 -1.13,-0.57 -0.47,1.62 -0.31,-0.06 0.18,-0.63 -0.5,0.03 -1.08,0.92 -0.58,-0.09 1.13,1.01 -0.37,0.44 -0.84,-0.73 -0.47,0.48 1.23,0.76 0,0.38 0.45,-0.19 0.26,1.01 -1.13,0.82 -1,-0.06 -0.68,-0.92 -0.52,0.13 0.03,-0.63 1.1,0.03 -0.71,-0.98 -0.39,0.44 -0.1,-0.67 -0.68,0.19 0.34,-0.86 -0.81,-0.03 -0.58,-0.76 -1.65,-0.44 0.45,-1.3 0.97,-0.63 -2.76,-2.63 -0.97,0.03 -0.03,0.73 -1.18,-0.38 0.21,-0.79 -1.15,-0.98 -0.66,-0.06 -0.58,-1.05 0.08,2.6 -0.89,-0.48 -0.39,-0.86 -1.13,0.06 -0.11,-0.44 -0.79,0.92 -0.05,0.83 -0.5,-0.67 -2.94,0.35 -1.47,-0.79 0.08,-1.24 -0.94,-0.63 0.47,-1.94 1.13,-1.11 0.58,0.03 -0.18,-0.63 1.1,-0.7 -0.24,-0.67 0.58,-1.21 0.21,0.79 0.74,0.28 1.23,-0.38 -0.37,-0.92 0.42,-0.25 0,-2.41 2.55,-2.54 2.68,-0.67 0.42,-2.48 1.1,-1.08 -0.71,-0.86 0.32,-0.8 1.16,-0.54 1.08,-1.43 0.68,0.54 0.42,-0.86 0.55,0.06 -0.08,2.26 0.5,0.03 0.08,0.48 -0.73,2.42 0.76,0.8 2.68,0.25 0.66,-1.14 -0.37,-0.83 0.94,-1.05 0.47,-1.91 1.13,-0.35 -0.1,-0.51 -1.05,-0.03 -0.63,-4.17 -1.26,-0.13 -0.79,0.38 -1.13,2.19 -0.45,-0.6 -1.52,-0.64 -0.76,1.15 -0.79,-0.76 -0.94,-2.55 -1.55,0.35 -1.73,2.16 -0.34,2.26 -0.79,1.37 -0.71,0.29 -0.68,1.18 -3.86,0.13 -0.68,-0.99 -0.63,-0.22 -1.37,1.24 -0.45,1.49 -1.13,0.92 -2.94,1.08 -0.42,0.48 0.16,0.7 -0.63,0.28 -0.89,1.49 -0.87,-0.06 -1.89,1.33 -3.33,-0.38 -2,0.32 0.84,0.54 0.66,-0.44 1.55,0.16 -0.03,0.95 1.39,0.76 -0.03,0.35 -1,0.1 0.13,0.76 -0.58,0.44 -0.21,1.37 -1.08,0.95 0.95,0.7 1.63,-0.32 -0.13,1.49 -0.26,0.29 -0.5,-0.89 -0.84,0.13 0.03,2.48 -1.55,-0.38 -1.15,1.3 0.24,0.73 1.42,1.3 -0.03,0.51 -0.92,0 -0.37,1.56 1.18,0.82 0.32,1.27 -0.73,0.28 -0.37,-0.32 -0.95,0.86 -1.39,-1.59 -0.58,0.83 0.37,1.59 0.6,0.73 -0.84,1.05 -1.05,-0.03 -0.6,-0.76 -4.73,-0.19 1.52,2.47 -0.16,1.46 -1.21,-1.81 -1.55,-0.51 -1.05,-1.08 -0.63,-0.19 -0.81,0.6 -1.1,-0.06 -1.29,-0.92 0.29,-1.4 -2.05,-0.06 0.08,-0.86 0.95,-0.38 -0.73,-3.14 0.26,-0.38 -0.47,-0.32 0.47,-1.59 -0.1,-1.59 0.68,-0.76 -0.53,0 -0.13,-0.51 -0.16,-0.89 0.58,-0.82 -0.87,-1.02 0.24,-1.17 -1.02,-0.92 0.37,-0.38 -0.37,-2.41 0.5,-1.59 0.66,-0.6 -0.31,-0.19 -0.68,1.97 -0.87,0.76 -0.6,9.43 0.55,0.64 -0.97,0.25 -0.08,0.41 0.26,2.22 0.42,0.41 -0.66,0.32 0.11,0.54 -0.68,-0.1 -1.31,0.79 0.79,1.55 -2.21,3.3 -0.55,-0.38 -0.84,0.79 -0.97,-0.13 -1.71,1.62 -0.63,-0.19 0.37,0.8 -0.45,0.15 -0.81,-0.82 -0.6,0.7 -0.76,-0.22 -0.52,1.49 -0.97,-0.25 -0.55,1.05 -0.55,-0.57 -0.6,0.79 0.5,0.57 -0.94,1.17 0.29,0.76 0.55,-0.03 -0.05,2.34 -1.71,1.08 0.6,0.51 -0.79,1.01 0.29,0.76 -0.21,1.11 0.45,0.51 -0.81,0.32 -1,-0.89 -2.47,-0.28 -1.5,2.21 -1.44,0.25 -0.34,1.01 -0.87,-0.31 0.26,-2.21 -0.66,-0.54 1.39,-1.68 -0.6,-1.14 0,-1.93 -1.44,-0.63 -0.55,0.73 -0.84,0 -1.13,1.14 -0.66,0.16 0,-0.63 -0.6,-0.44 -0.08,-0.54 0.39,-0.13 0.92,0.85 0.21,-0.35 -0.42,-0.66 0.97,0.09 -0.84,-0.66 0.37,-0.7 -0.74,-0.13 -0.05,-0.73 2.39,-0.41 -1.13,-1.58 0.29,-0.47 -0.24,-0.38 1.52,0.48 0.16,0.44 1.08,-1.65 -0.73,-1.27 0.5,-0.85 -0.47,-0.7 -1.13,0.92 -0.47,-0.38 -0.81,0.1 0,0.98 -0.71,-0.22 -0.66,-1.3 -1.26,-0.92 -0.1,-0.38 0.95,-0.47 0.6,0.76 0.53,-0.29 -0.76,-0.73 -0.05,-0.6 0.63,-0.35 -0.42,-0.7 -0.63,0.25 -0.74,-0.95 0.03,-0.57 0.97,-0.16 -0.92,-2.06 1.34,-0.82 -0.79,-1.36 -1.92,-0.16 0.13,-0.57 1.02,-0.19 1.05,-0.92 -0.31,-0.82 -0.97,0.19 -0.08,0.51 -1,-0.06 -0.03,-1.59 -2.280004,-0.79 0.21,1.21 -1.5,0.25 0.03,0.95 -1.44,0.7 -0.79,-0.79 0.92,-1.11 0,-1.24 -2.21,-0.09 -2.86,-1.43 -2,0.7 -0.94,-1.14 0.87,-1.02 -3.18,-1.18 0.53,-0.98 -0.45,-0.6 0.32,-1.02 -0.29,-0.35 1.23,-1.02 -0.42,-0.57 -0.45,0.64 -1.18,-0.29 -1.18,-1.14 -0.39,-2.8 0.39,-0.64 -0.45,-0.76 0.76,-0.7 -0.45,-1.08 0.29,-1.37 0.58,0.45 0.68,-1.11 0,-1.75 1.05,-3.4 1.31,-0.54 1.05,0.99 -0.32,0.73 1.26,-0.13 -0.29,0.76 0.92,0.51 0.37,1.97 0.84,0.25 0.92,1.15 0.03,0.64 -1.58,0.67 -0.24,1.94 0.4,0.83 -0.71,0.99 0.21,0.57 2.34,0.86 -0.1,2.89 1.31,0.64 0.26,1.84 0.42,-1.3 0.6,-0.19 2.02,1.37 0.71,-0.19 -0.13,0.67 4.150004,2.22 -0.18,-0.89 2.89,-1.46 0.45,-1.14 -0.08,-0.54 -0.79,0 -0.66,0.64 -0.55,-0.29 -0.81,0.64 -0.45,-2.89 -0.52,0 -0.66,1.18 -0.810004,-2.45 -1.05,0.25 0.5,-1.84 -0.74,-0.06 0.05,-0.83 -0.87,0.03 -0.31,1.24 -0.6,-0.19 -0.79,1.11 -1.08,-0.95 1.65,-1.97 -0.18,-1.87 -0.52,-0.54 0.6,0.1 0.53,0.83 0.47,-0.41 -0.18,-0.76 -0.58,-0.22 0.03,-0.79 -1.05,-0.19 0.05,-0.54 0.66,0.32 0.34,-0.73 1.55,2.13 -0.1,0.89 0.37,0.48 0.95,-1.08 0.58,-0.06 0.13,-0.76 0.500004,0.6 0.55,-0.95 1.13,0.67 -0.16,0.64 -1.31,0.89 -1.100004,2.07 1.130004,1.27 0.97,-0.38 -0.03,0.89 0.89,0.13 0.73,1.08 3.94,0.51 1.58,1.37 1,-1.33 -1.31,-0.38 -0.24,-1.24 0.37,-0.16 2.21,0.22 0.31,0.89 3.26,1.4 3.1,0.29 0.45,-0.44 -0.89,-0.76 -1.92,-0.09 -1.42,-1.4 -1.6,-0.83 -0.37,-1.37 0.6,-1.3 -1.26,-0.38 -1.13,0.25 -1.18,-2.92 -2.68,-3.18 -0.95,-0.38 -1.52,0.13 -0.73,0.19 -0.71,0.92 -0.5,-0.25 -0.24,-1.4 -1.260004,0.03 -0.45,0.51 -0.24,-0.67 -0.89,0.25 -0.45,-0.67 -0.66,0.38 -0.05,0.6 -1.1,-0.13 0.18,0.64 -0.79,0.35 -2.34,-0.86 -0.05,-0.48 1.68,-1.08 -0.26,-0.76 0.55,-0.48 -0.5,-0.32 1.16,-0.44 -0.08,-1.34 -1.99,0.13 -0.71,-2.17 0.87,-1.04 0,-0.8 0.47,-0.67 0.6,0.19 0.18,-0.92 0.34,-0.45 0.39,0.13 0.13,-0.7 0.79,-0.6 1.02,-0.1 -0.71,-0.54 -0.13,-1.98 -0.76,-0.38 0.63,-1.31 -0.73,-0.25 -0.55,-0.1 0.45,-1.24 -0.16,-0.73 0.42,0.26 0.42,-0.25 0.45,-1.27 -1.29,-1.21 -0.18,-0.67 0.66,-0.73 -0.79,-1.21 0.53,-2.23 -1.15,-0.77 -0.1,-1.91 -0.81,-1.34 -0.45,0.57 0.13,2.2 -0.87,0.7 0.08,0.77 0.79,-0.13 0.63,0.73 -0.89,1.44 0.76,0.51 -0.71,0.86 0.39,0.93 -0.24,0.41 -1.52,-0.13 -0.1,0.54 -0.63,0.22 -1.36,-0.16 -0.24,-1.62 -0.94,-0.22 -0.5,0.7 -0.47,-0.22 -0.18,-0.73 0.45,0.19 1.05,-1.24 -1.08,-0.48 -0.24,-0.89 -1.13,-1.15 0.21,-1.18 0.5,-0.1 0.21,-0.89 0.71,-0.38 -0.29,1.4 0.68,0.03 0.26,-0.7 0.81,1.69 1.89,-0.96 0.34,-0.89 0.63,-0.16 -0.03,-0.99 -1.86,-0.41 4.91,-3.16 -0.08,-1.5 -0.89,-1.12 -0.97,0.03 -1.65,0.8 -0.42,-1.02 0.42,-0.45 -0.26,-0.57 -1.65,-0.41 0.81,-0.26 0.45,-0.7 -1.15,-2.17 -1.34,-0.03 -0.13,0.73 -1.37,-0.96 1.21,2.24 -1.37,1.05 1.05,0.29 0.21,0.61 -1.29,1.21 -0.71,-1.72 -0.76,-0.35 -0.79,0.9 -1.29,0.1 0.08,-1.05 -0.68,-1.95 -1.02,-0.67 0.42,-1.28 1.65,-0.13 -2.21,-2.43 0.82,-1.92 0.39,0.48 0.37,-0.17 -0.47,-0.76 0.21,-0.54 1.47,-0.9 0.71,1.92 1,-0.22 -0.31,-0.51 0.37,-0.1 1.37,0.42 0.08,1.25 1.29,-0.06 0.92,-1.63 -0.68,-0.45 0.08,-0.32 0.37,-0.38 0.6,0.38 1.08,-1.28 0.05,2.56 -0.79,1.63 0.29,0.19 -0.18,0.51 -0.76,0.22 -0.18,0.9 0.53,0.38 0.05,0.83 -0.52,0.35 1.21,0.22 0.89,-1.02 -0.08,1.63 -0.68,0.45 0.05,0.57 0.37,0.26 0.24,-0.45 0.63,0.61 0.74,-0.57 0.21,1.95 0.42,-0.1 0.76,-2.11 1.05,-0.54 -0.66,2.27 0.47,0.16 0.66,-1.34 1,1.53 0.03,0.42 -1.58,1.85 0.97,-0.03 0.1,1.85 2.23,-0.06 -0.6,-0.99 0.03,-0.77 0.42,-0.61 1.680004,-0.8 1.44,-2.3 -2.070004,-0.96 2.100004,-0.67 0.66,-1.18 -1.71,-0.64 -2.360004,-0.1 -1.63,-3.16 -1.21,-0.51 -0.81,-1.41 0.03,-0.73 -0.92,-0.13 -0.6,-1.06 -0.66,-0.06 0.29,-1.34 -1,-0.48 1.63,-0.54 -0.18,-1.12 0.58,-0.29 0.29,-1.15 -1.79,0.9 -0.03,-0.42 -1,-0.22 -1.29,0.61 -0.39,-0.61 -1.18,-0.19 0.18,-0.77 -0.45,-0.96 -0.58,-0.54 -0.79,-0.06 0,-0.51 1.1,-2.08 0.66,1.54 0.66,0.55 0.03,0.77 0.63,-1.15 0.74,-0.22 -0.55,-0.99 1.6,-2.18 -0.29,-0.7 -1.29,0.45 -0.47,-0.42 0.74,-1.31 3.13,0.03 0.63,-2.37 0.11,-2.92 1.76,-4.45 1.47,0.58 0.68,-0.19 0.95,0.99 1.600004,0.19 -0.24,-0.67 -1.050004,0.19 -0.31,-0.74 -1.86,-1.15 -0.76,-2.4 0.74,-1.8 -0.29,-0.55 1.47,-1.41 2.230004,0.16 0.32,-0.58 1.94,0.18 0,0 1.87,0.62 0,0 1.87,1.56 0.78,2.66 0.16,2.96 1.87,2.19 1.25,4.06 1.71,0 0.38,1.7 0,0 4.35,-0.23 1.45,-1.54 0.99,-0.35 1.11,0.24 0,0 0.97,0.43 2.07,-0.71 0,0 1.53,-1.5 3.14,-0.96 0,0 2.41,-1.22 0.77,-2.01 -0.14,-0.96 0,0 -0.26,-0.77 0,0 0.15,-0.68 1.45,-0.95 0,0 0.59,-0.68 -0.15,-3.1 0,0 0.18,-1.18 0.61,-0.81 2.27,-0.98 0,0 1.53,0.35 0,0 1.08,0.22 1.57,-1.87 3.02,0.61 2.95,1.86 1.1,1.13 2.52,4.77 0,0 1.04,0.9 0,0 1.97,0.57 1.02,-0.69 0,0 0.14,-1.02 0,0 0.53,-2.08 1,-0.64 0.98,-1.79 0.71,-0.32 1.81,0.4 1.35,1.04 0.61,1.91 -0.16,2.51 0,0 -1.15,1.38 0.09,0.94 0.49,0.68 1.59,-0.01 0,0 1.01,2.88 -0.42,3.61 2.59,1.98 0,0 2.1,0.54 0,0 1.61,-0.15 1.42,-0.94 0,0 0.96,-0.9 0,0 1.3,-0.84 3.16,1.36 0,0 1.93,-1.12 1.44,1.37 0,0 1.13,0.66 6.15,-0.02 0,0 2.38,-0.7 3.19,0.36 0,0 1.13,-0.02 0.62,-0.44 2.95,-3.79 1.76,-0.98 0,0 2,-0.11 0,0 3.51,1.16 1.04,0.92 0,0 3.31,1.82 3.07,2.65 0,0 -0.78,0.7 -0.01,1.56 2.66,2.99 0.91,9.22 1.3,1.69 2.22,1.13 3.04,3.64 0.19,2.9 0,0 1.09,1.05 0,0 0.77,1.24 1.62,0.69 1.18,1.87 0,0 1.75,1.33 0,0 1.58,4.11 -0.04,2.93 0.7,0.32 0,0.87 -1.84,0.29 -0.95,-0.38 -1.36,-2.97 -0.58,-0.03 -0.63,1.15 -1.76,0.54 -0.05,-2.9 -1.42,-2.04 0.08,1.63 0.68,0.54 0.37,3.03 -1.55,1.18 -0.24,0.93 -0.63,-0.19 -0.68,0.89 -0.71,0.06 -0.18,0.48 0.47,0.96 -1.63,1.12 -1.57,0.41 0.21,0.48 -1.15,0.89 -0.95,-1.21 0.45,-0.57 -2.07,0.22 -0.47,-1.31 -1.05,-0.96 0.16,-2.45 -0.71,-0.67 0.29,1.21 -0.42,1.79 -1.15,0.19 -0.31,-0.29 -0.5,0.64 1.16,0.29 1.29,1.59 -0.5,0.8 0.61,1.02 -0.5,0.19 -0.5,-1.02 -0.73,0.7 -0.6,-0.54 -0.58,0.64 1.1,0.13 0.34,0.41 0.08,1.37 1.39,1.37 -0.26,0.42 0.37,0.6 0.37,0.22 0.42,-0.41 0.68,1.02 1.42,-0.16 -0.08,0.77 -0.81,0 -0.05,0.54 0.24,0.7 0.92,0.73 0.03,-1.11 0.84,0 1.47,0.8 1.21,-1.31 1.34,-0.48 0.92,-1.53 -0.55,-0.45 0.05,-0.76 0.6,0.92 0.1,-0.38 1.5,0.1 1.58,-0.67 -0.95,0.86 1.76,0.7 -0.13,-0.76 2.31,-0.83 1.34,1.34 -0.84,0.19 0.31,0.86 -0.71,2.32 0.66,0.19 -0.68,0.35 0.13,2.17 -0.89,-0.06 -0.29,1.53 -1.05,1.08 0.76,1.4 -0.34,1.18 0.53,0.38 -0.58,0.41 0.79,0.57 -0.18,0.6 -0.42,0.29 -1.58,-0.29 -0.26,1.11 -2.52,0.96 -0.66,-0.03 -0.12,-0.79 z m -64.24,-52.04 -2.61,-0.26 -1.02,-4.54 -1.94,-2.34 -1.83,-0.87 -2.44,-0.09 -2.44,0.96 -2,1.05 -2,2.09 -1.48,0.09 -2.09,-0.7 -1.48,-1.39 -0.61,-2.18 -2.18,-0.09 -2.09,5.31 -2.35,-0.09 -1.74,2.09 -1.13,4.79 0.44,4.09 7.23,1.04 1.83,2.27 1.92,3.83 3.75,0 3.4,-2 3.83,0 1.48,-1.04 3.14,0.61 3.4,-2.35 1.39,-1.83 0.78,-1.65 0.09,-2.61 0.87,-1.83 0,-1.39 -2.12,-0.97 z m 48.85,83.47 -1.6,-0.6 0.08,-0.41 -1.5,-1.87 -0.05,1.14 -0.42,0.19 -0.26,-0.6 -0.45,1.01 -0.92,-0.03 0.66,-0.82 -1.68,0.16 -0.52,-0.79 -0.92,-0.57 -0.31,0.19 0,1.93 0.39,0.63 -0.81,0.48 0.16,0.28 1.08,-0.76 0.53,0.25 0.45,-0.28 1,0.6 -0.21,0.63 -1.47,-0.6 -0.39,0.38 1.21,1.27 0.89,-0.51 0.21,0.51 0.58,0 0.21,0.82 -0.76,0.92 0.05,0.48 0.45,0.22 2.39,-1.2 0.32,-0.51 1,0.48 0.76,-0.95 -0.24,-0.7 0.09,-1.37 z m 24.69,-5.55 -0.55,0.03 0.03,-0.66 -2.47,-0.86 1.39,-0.06 0,-0.44 -0.13,-0.63 -1.71,-1.62 0.18,-0.57 -0.73,-1.59 -1.71,0.03 -2.55,1.75 -0.68,-0.32 -0.73,0.19 0.39,0.73 1.1,0.35 0.68,0.7 1.26,-0.41 -0.74,1.17 0.18,0.38 1.31,0.32 -0.74,0.54 0.13,0.35 0.66,0.22 1.18,-0.41 -0.03,0.64 1.65,0.28 -0.21,0.48 -0.66,0.1 0.81,0.38 1.89,0.13 0.13,-0.51 0.67,-0.69 z m -5.23,-45.27 -1.5,0.1 -0.94,-0.83 -1.76,0.67 -0.68,1.18 0.95,0.73 -0.47,0.45 1.79,0.1 0.47,0.48 0.92,-1.91 1.58,-0.38 -0.36,-0.59 z m -93.9,58.74 0.6,-0.44 2.15,0.13 -0.71,0.79 -0.6,1.81 1.39,0.82 -0.31,-0.51 0.47,-0.63 -0.13,-0.76 1.08,-1.46 1.02,-0.44 1.52,0.35 0.42,-0.54 -0.37,-0.44 0.5,-0.98 1.81,0.51 0.5,0.73 0.45,-0.41 1.1,0.32 0.08,-0.82 -0.71,0 0.24,-0.41 -0.39,-0.95 -0.81,0.13 0.47,-0.6 -0.26,-0.63 -1.1,0.82 -1.42,-1.01 1.79,-0.1 0.29,-0.98 -0.58,-0.57 -0.55,0.28 -0.08,-1.39 -3.04,1.39 -1.21,-0.16 -2.23,2.57 0.34,1.36 -0.79,0.38 -0.89,1.3 -0.04,0.54 z m 67.25,-11.34 -0.1,-0.57 0.81,-0.35 1.44,0.32 0.39,-0.7 0.13,0.7 0.45,0 1.13,-0.82 -1.39,-1.97 -2.89,-0.22 -0.24,-0.57 0.39,-0.22 1.21,0.38 -0.5,-1.14 -1.08,-0.19 0.05,-0.44 1.39,-0.09 0.45,-0.7 -0.47,-0.92 -1.52,-0.16 -0.45,0.29 -1.79,2.6 0.55,0.54 0.84,-0.16 0.66,0.67 -0.42,0.54 0.66,0.06 0,0.38 -1.68,1.05 0.81,0.76 0.13,0.79 1.04,0.14 z m 32.82,3.36 -0.6,-0.41 0.32,-1.01 -1.08,0.57 0.29,0.89 -1.15,2.22 1.5,-0.25 0.03,0.32 -1.13,0.25 -0.37,1.08 0.26,0.54 0.87,-0.48 0.11,0.82 0.71,0.03 -0.29,-0.63 0.5,-0.16 -0.18,-1.33 0.95,-2.91 -0.74,0.46 z m -76.57,12.54 -0.58,0.35 -0.79,-0.57 -1.42,0.22 -1.16,1.36 0.26,2.12 0.55,-0.38 0.26,0.95 0.55,0.32 0.39,-0.6 2.34,-0.89 0.21,-0.89 1.08,-0.22 -0.13,-0.92 -0.6,0.06 -0.96,-0.91 z m -13.57,3.39 1.1,-0.51 -0.39,-0.79 0.34,-0.16 0.79,0.95 -0.26,0.51 1.08,-0.03 0.32,-1.58 -0.55,-0.32 0,-0.44 0.66,-0.35 0.84,0.19 0.1,-1.52 -1.68,0.92 -0.71,-1.45 -1.44,0.41 -0.13,-0.66 -0.68,0.85 -0.55,-0.5 0.08,-0.41 -1.02,-0.7 -1.37,1.3 0.13,1.04 -1.23,0.51 -0.45,0.03 -1.15,-1.46 -1.39,1.27 -1.18,-0.41 -1,0.28 0.45,0.47 2.28,0.51 1.21,1.39 1.44,-1.39 1.87,0.13 0.5,0.44 0.13,0.89 0.42,0.1 -0.31,0.82 0.47,0.89 0.84,-0.25 0.44,-0.97 z m 21.48,-4.94 0.32,-0.57 -0.92,0 0.03,-0.48 -1,0.13 -0.6,0.85 -1.31,0.29 -0.24,-0.76 0.37,-0.16 -0.39,-0.51 0.32,-0.54 -0.55,-0.06 -1,-1.39 -0.21,0.89 -1.15,-0.51 -0.47,0.51 0.63,0.63 -0.18,0.32 -0.37,-0.47 -0.34,0.22 0.42,0.35 -0.42,0.79 -2.13,-0.32 2.13,1.24 0.71,-0.73 1.34,0.86 0.34,0.79 -1.42,0.32 0.81,0.16 0.34,0.51 0.45,0.03 0.37,-0.95 1.23,-0.03 0.13,0.73 -1.57,1.11 0.42,1.84 0.95,-1.87 0.5,0.16 0.21,-1.07 2.02,-0.51 -1.71,-0.28 0.55,-0.89 0.58,0.44 1.31,0.13 0.18,0.6 0.76,0.25 0.47,-0.28 -0.66,-0.63 -1.25,-1.14 z m -14.18,-4.34 -0.97,-0.47 -0.84,0.41 -0.6,-1.33 -0.66,0.6 -0.47,-0.7 0.13,0.82 -0.29,0.1 -1,-1.27 -0.05,0.54 -0.71,0.25 -0.37,-0.32 0.32,-0.57 -0.87,-0.41 -0.31,0.63 0.76,0.63 0.18,0.73 -0.79,2.38 0.68,0.57 1.34,-0.6 0.32,1.62 0.97,0.1 0.81,0.6 0.21,-0.66 0.79,0.38 0.63,-0.51 0.39,-1.17 0.89,0.51 0.92,-0.16 0.21,-0.79 -0.87,-1.17 0.29,-1.2 0.74,-0.92 -0.55,-1.11 -1.23,2.49 z m 30.8,15.89 -1.44,0.32 -0.03,1.17 -0.92,0.1 -0.71,2.78 0.37,-0.28 0.92,0.03 0.18,-0.41 0.37,0.47 1.31,0.38 -0.05,-0.89 -0.76,-0.32 1.1,-0.28 -0.29,-1.11 -0.05,-1.96 z m -2.21,-25.62 -0.29,-1.11 -1.55,-1.11 -1.39,0.86 -0.39,-0.03 -0.05,-0.48 -1.57,0.22 -1.58,1.27 -1.36,-0.13 -0.55,0.89 -0.58,-0.03 0.03,-0.7 -0.79,0.09 -0.42,-1.43 -0.47,0.44 -0.31,-0.38 -0.16,1.62 -0.68,0.13 -0.42,0.73 -0.55,-0.6 -0.34,0.41 1.26,1.74 -0.66,0.51 0.26,0.44 -0.26,0.44 0.87,0.1 0.03,-0.6 0.74,-0.13 -0.08,1.08 0.81,0.22 0.05,0.7 1.13,0.22 0.52,0.98 0.05,-0.82 0.53,-0.41 1.47,0.28 -0.16,-0.54 0.37,-0.22 2,0.57 2.05,0.06 0.84,-0.82 0.45,-2.12 1.15,-2.34 z m -17.98,1.78 -0.97,0.54 -1.1,0.03 0.21,0.51 0.89,0.16 0.34,3.2 0.81,0.79 0.6,-0.32 -0.26,-1.27 0.47,-0.22 0.58,0.48 -0.24,0.82 0.37,1.97 1.02,-1.68 -0.63,-0.51 0.81,-0.25 -0.03,-0.7 -0.92,-2.54 -0.97,-0.82 0.18,0.44 -0.58,0.32 -0.58,-0.95 z',
      Color.fromARGB(255, 223, 223, 223).withOpacity(0.0)
    ],
    [
      'm 522.63429,128.21884 0.94,0.28 -0.73,0.38 -0.32,1.08 0.96,1.76 -0.73,2.61 0.94,0.68 -0.99,0.36 -0.85,0.96 -0.47,-0.17 -1.23,0.72 -0.75,1.9 -0.57,-0.56 -1.79,-0.58 -0.88,0.18 -1.47,-1.14 -1.6,-0.36 -0.65,-1.06 0.24,-2.44 -1.04,-1.2 0.03,-1.08 0.75,0.48 4.06,-2.08 1.41,0.08 1.44,-0.94 1.63,0.24 0.77,-0.86 0.73,0.04 0.17,0.72 z m -223.29,222.72 0,0 0.69,1.28 -0.47,3.05 0,0 0.79,2.37 0.9,1.29 2.12,1.69 0,0 0.94,1.08 1.39,0.7 0,0 5.88,-1.1 0,0 3.44,0.77 4,1.97 0,0 1.92,0.57 1.57,-0.56 3.95,-3.27 1.01,0.3 0,0 1.14,-0.44 1.81,-2.29 0,0 2.02,-1.42 0,0 2.1,0.04 0,0 1.34,0.1 1.59,0.77 0,0 1.29,0.71 0,0 2.42,0.87 0,0 0.96,-0.35 0,0 0.77,-0.79 3.92,-3.09 1.66,-0.17 0,0 0.67,0.13 0.66,-0.86 -1.35,-2.48 -0.22,-1.06 0.6,-0.49 4.16,-2.58 3.11,-1.02 1.63,0.3 2.59,-0.65 1.09,0.42 1.8,1.47 2.01,0.31 0.97,0.59 0.24,0.83 0,0 -0.43,2.84 0,0 0.29,0.77 0.73,0.34 0,0 1.98,0.65 0,0 1.43,-0.24 2.82,-1.84 1.12,-0.31 0,0 1.49,-0.01 0,0 4.89,1.73 0,0 1.76,0.42 0,0 3.01,0.22 -0.81,-0.26 0,-0.55 -0.63,-0.58 -0.24,-2.32 0.76,-0.39 0.5,-1.99 1.05,-0.1 0,-1.61 0.52,0.06 0.63,-1.35 -0.45,-1.83 1.24,-2.8 -0.13,-1.48 0.97,-1 -0.34,-0.81 0.26,-1.26 0.37,-0.19 -0.63,-1.9 0.97,-0.77 -0.26,-0.58 0.89,-0.9 0.34,0.19 0.24,-1.35 -0.52,-0.77 1.13,-1.52 -0.18,-1.35 0.68,-0.55 0.05,-1.1 0.79,-1 -1.6,-0.32 0.21,-0.81 0.89,-0.26 -0.44,-1.32 0.87,-0.74 -1.47,-2.36 -0.05,-0.87 1.44,-0.77 0.68,-1.68 0.81,-0.19 -0.18,-0.52 0.79,-1.45 -0.37,-1.19 1.39,-1.23 -0.03,-0.87 1.71,-2.26 -0.68,-0.94 0.5,-0.42 0.05,-0.42 -0.55,-0.35 0.4,-0.16 0.24,-1.13 -1.31,-2.59 0.1,-1.16 -0.97,-0.29 -0.21,-0.78 -1.23,0.29 -0.03,0.94 -0.89,1.36 -3.07,3.33 -0.05,1.33 -4.17,2.49 -0.3,1.19 -0.82,0.26 -2.54,-1 -0.42,-0.77 0.71,-0.84 -0.55,-0.52 -2.34,0.61 0.19,-0.74 0.74,-0.35 0.45,-0.81 1.39,0.32 0.89,-0.1 -0.02,-0.42 -2.6,-0.94 -1.68,1.16 -1,-1.65 0.66,-2.33 1.31,0 0.5,-0.78 1.65,-0.58 -0.18,-1.45 1.21,-1.07 0.1,-0.58 0.08,-0.97 -3.02,-2.49 -0.47,-1.13 0.63,-1.68 -0.02,-1.23 -0.6,-1.98 -0.18,-0.39 -1.21,-0.23 -0.84,-1.59 0.21,-0.71 0.84,-0.23 0.34,-1.3 -0.44,-1.3 0.45,-1 -1.23,-1.46 0.29,-1.95 0.52,-0.55 -0.68,-1.59 0.45,-0.26 0.29,-3.67 -0.26,-1.23 0.89,-1.85 -0.08,-0.97 1.68,-2.89 0.21,-1.04 0.47,0 1.65,-2.4 0.58,-1.92 -0.29,-1.69 0.42,-2.76 -0.37,-1.85 1.08,-0.98 0.11,-1.79 0.6,-0.23 -0.47,-0.78 -0.39,0 -0.29,-4.62 -2.13,-2.41 -0.58,-1.24 -0.18,-1.79 0.6,-0.29 -0.39,-2.51 0.47,-1.86 1.08,-1.2 0.84,-2.61 1.18,-0.98 1.31,0.07 0.4,-1.76 0.87,-0.65 -0.55,-2.58 0.55,-0.52 -0.03,-0.91 -0.81,-1.53 -0.1,-1.3 1.05,-1.11 -1.44,-2.38 -0.58,-3.23 -0.89,-1.04 -0.1,-1.01 -1.68,-1.86 -0.84,-2.42 0.24,-0.62 -0.63,-1.27 -0.08,-0.75 0.55,-0.56 -0.52,-1.34 0.55,-4.25 -1.18,-3.96 1.05,-1.86 -0.05,-1.41 -0.92,-2.78 0.68,-0.52 -0.39,-1.28 0.21,-1.24 0.63,-0.43 0.55,0.36 0.42,-0.29 -0.6,-1.05 -2.86,-2.1 -0.1,-0.62 -1.68,-1.47 -0.18,-1.18 0.55,-0.84 0,0 -4.28,0.72 0,0 -1.87,2.19 -2.5,0.94 -2.81,2.5 0,0 -1.56,2.19 0,1.25 0,0 1.56,2.81 -6.53,0.16 0,0 -2.66,-2.27 -2.95,-1.03 -2.61,-0.4 -2.55,2.52 -1.01,-0.19 -3.07,-1.75 -3.35,-0.67 -1.17,-0.03 -2.18,0.74 -0.68,-1.32 -1.72,-0.68 0,0 -0.93,0.6 -1.98,3.71 0,0 -0.94,1.25 -4.06,0 -3.43,-2.81 -2.81,-1.56 -2.02,0.18 -0.65,2.32 0.11,2.4 -0.36,0.76 -0.75,0.36 -1.46,-0.95 -1.61,-0.42 -1.92,0.26 -3.08,-2.1 -1.17,-0.24 0,0 -1.27,1.28 0,0 -0.93,0.88 -0.47,-0.23 0,0 -0.93,-0.33 0,0 -0.75,0.31 0,0 -1.45,2.14 -0.83,0.47 0,0 -0.62,0.28 0,0 -3.29,3.25 -2.8,0.81 0,0 -0.79,1.24 0,0 -0.47,1 -3.08,1.75 -0.09,0.88 -1.48,1.47 -1.58,3.32 0,0 -0.83,1.57 0,0 -0.05,1.33 1.31,0.61 0,0 0.53,0.81 0,0 0.26,2.1 -2.84,3.9 0,0 -1.43,0.3 0,0 -2.11,0.15 0,0 -0.45,0.33 0,0 -0.92,1.03 -2.44,-0.05 0,0 -1.64,0.44 -0.55,-0.25 0,0 -1.04,-2.8 -1.46,-2.12 -3.24,-1.85 -1.18,-1.97 0,0 -1.08,1.28 -0.28,1.02 0,0 -0.31,0.75 -1.13,0.34 -0.24,2.59 0,0 -0.2,0.64 0,0 -0.37,0.57 -5.2,-1.3 -0.5,-0.44 0,0 -0.42,-0.63 0,0 -1.06,-0.38 -0.61,0.63 0,0 -1.38,1.15 0,0 -1.15,1.94 0,0 -1.38,0.19 0,0 -1.64,-1.75 -0.51,0.31 -2.71,6.34 0,0 -0.16,0.35 0,0 3.24,4.45 0.15,0.8 -1.19,0.11 -3.41,-1.01 0,0 -1.18,-0.67 -1.21,0.59 0,0 -2.19,-1.02 0,0 -1.12,-0.61 0,0 -1.17,2.34 -1.71,1.39 -1.6,1.05 -2,0.12 0,0 -0.64,0.25 0,0 -1.68,2.38 0.48,2.22 0,0 -0.45,0.7 0,0 -2.21,1.91 0,0 -0.58,0.73 0,0 -0.94,1.51 -0.81,0.05 0,0 -1.56,0.35 0,0 -0.82,1 -0.17,0.91 0.73,1.1 5.37,1.13 1.22,1.22 -0.14,0.93 0,0 0.39,1.56 0.58,0.41 0,0 1.64,0.68 0.37,0.68 -0.42,1.71 0,0 -0.12,0.56 0,0 -1.89,0.33 0,0 -0.43,1.34 0,0 0.3,3.6 -0.67,2.69 0.6,1.18 0,1.3 -1.28,2.02 1.32,3.25 0,0 0.5,0.31 0,0 -1,2.56 -2.66,2.31 0,0 -0.07,4.29 0.37,0.79 1.79,0.99 0,0 1.85,-1.07 1.16,-1.51 0.41,0.02 0.46,1.44 2.24,0.8 0.26,0.68 0,0 0.09,0.5 0,0 0.98,0.32 0,0 0.78,0.75 0,0 0.34,0.5 0.84,-0.1 0,0 1.99,-0.84 0,0 2.23,-0.79 2.02,0.7 0,0 0.62,1.07 0,0 -0.36,1.07 0.51,2.1 0,0 0.57,1.31 0.69,0.57 0,0 -0.09,0.8 -1.15,0.55 -2.47,-1.48 -2.41,1.43 -1.18,1.74 0.08,1.19 1.1,1.77 -0.51,1.41 0.1,2.16 -1.76,1.46 0.18,0.92 -0.99,1.68 -0.23,2.04 -1.84,2.6 -0.75,0.33 -0.88,-0.67 -1.24,0.24 -1.08,1.07 0,0 3.48,5.67 1.23,3.31 -0.27,2.77 -1.01,2.25 0,0 0.13,1.94 0.57,0.87 1.14,0.9 1.56,-0.01 0,0 0.71,0.37 0,0 0.31,2.61 0.94,0.56 0,0 2.14,0.33 0,0 1.78,0.22 0.58,1.13 1.15,0.64 0,0 4.44,0.78 0,0 2.55,-0.26 0,0 1.49,0.75 0,0 1.54,0.75 0.49,0.74 0.78,2.88 0,0 0.66,0.5 0,0 2.07,0.99 0.66,1.15 -0.23,0.61 2.52,1.49 0.94,1.79 -0.24,2.21 -1.82,3.97 0,0 -0.27,1.66 0.89,1.64 0,0 3.8,1.49 2.25,-0.3 0,0 1.19,-0.31 0,0 2.96,-1.09 2.2,1.09 2.29,0.27 0,0 2.24,2.18 0,0 1.71,1.25 0,0 -0.73,-3.43 -4.06,-4.99 0.31,-2.81 1.87,0.62 1.56,1.25 2.18,0 0.62,-2.5 -3.12,-3.43 1.25,-3.12 1.25,-2.81 5.31,-0.94 -0.31,-1.87 -2.81,-2.18 -4.68,-0.31 0.31,-3.12 1.25,-2.81 2.19,-3.12 2.18,-0.62 1.87,-1.25 0.62,5.62 2.5,0 0.94,-3.12 2.5,-4.99 5.93,-1.25 2.81,-3.12 3.43,-0.94 3.12,0.31 3.74,3.12 0,4.37 0.63,3.12 1.87,4.06 -0.94,2.19 -3.43,1.25 -1.56,3.43 0,3.12 -2.5,0.31 0,1.87 1.25,1.56 0,4.06 -3.43,1.25 -1.56,1.87 -2.81,-0.31 -0.62,-2.81 -3.12,0 -2.18,1.25 -1.56,2.5 0.45,1.51 0,0 0.3,-0.22 0.81,-0.18 z',
      Color.fromARGB(255, 223, 223, 223).withOpacity(0.0)
    ],
    [
      'm 240.12429,325.42884 1.14,0.9 1.56,-0.01 0,0 0.71,0.37 0,0 0.31,2.61 0.95,0.56 0,0 2.14,0.33 0,0 1.78,0.22 0.58,1.13 1.15,0.63 0,0 4.44,0.78 0,0 2.55,-0.26 0,0 1.49,0.75 0,0 1.54,0.75 0.49,0.74 0.78,2.88 0,0 0.66,0.5 0,0 2.07,0.99 0.66,1.15 -0.23,0.61 2.52,1.49 0.94,1.79 -0.24,2.21 -1.82,3.97 0,0 -0.27,1.66 0.89,1.64 0,0 3.8,1.49 2.25,-0.3 0,0 1.19,-0.31 0,0 2.96,-1.09 2.2,1.09 2.29,0.27 0,0 2.24,2.18 0,0 1.66,1.24 2.46,-0.05 3.49,-2.5 0,0 1.52,-0.38 0,0 2.42,0.89 1.08,-0.59 0.81,-3.59 0.78,-1 0.3,-0.22 0.98,0.01 0,0 0.69,1.28 -0.47,3.05 0,0 0.79,2.37 0.9,1.29 2.12,1.69 0,0 0.94,1.08 1.39,0.7 0,0 5.88,-1.1 0,0 3.44,0.77 4,1.97 0,0 1.92,0.57 1.57,-0.56 3.95,-3.27 1.01,0.3 0,0 1.14,-0.44 1.81,-2.29 0,0 2.02,-1.42 0,0 2.1,0.04 0,0 1.34,0.1 1.6,0.77 0,0 1.29,0.71 0,0 2.42,0.87 0,0 0.96,-0.35 0,0 0.77,-0.79 0,0 1.47,2.43 0,1.47 -1.2,1.05 0,0 -2.23,1.89 0.34,4.83 2.23,1.05 2.75,0 0,0 2.4,0.21 3.26,3.35 0,0 3.43,3.98 2.23,1.89 0,0 3.09,0.21 0,0 1.27,1.55 0,0 -2.95,2.71 -0.57,1.86 -4.87,0.57 -1.72,2.58 -0.86,2.72 -1.03,1.34 -1.84,-0.32 -3.95,2.48 -0.98,1.17 -0.79,0.2 -0.86,2 -1.43,1.58 -4.15,0.14 -3.86,2.43 -2.29,0.29 -0.43,5.01 -4.29,1.15 -2.43,1 -0.2,0.47 0,0 -1.81,2.23 -0.97,-0.73 0.16,1.25 -1.21,0.1 -1.05,-0.77 -0.66,1.05 -0.47,0 -0.37,-0.73 -0.87,0.19 -0.05,-0.93 -1.23,-0.03 0.11,0.51 -0.71,0.32 -0.71,-0.73 -0.21,-0.48 0.89,-0.41 0.82,-1.31 -0.66,-0.77 0.05,-1.06 -0.87,-0.29 0.21,-0.99 -1.68,0.8 0.52,1.76 -1.18,0.96 -0.34,-1.53 -1.78,-0.73 -0.16,-0.77 0.45,-0.58 -1.84,0.32 -0.42,1.73 -0.63,-0.83 -0.84,0.26 0.76,-1.09 -0.66,-1.02 0.19,-0.86 -0.55,0.23 -0.97,-1.31 -0.21,-3.23 1.63,-1.22 1.44,-0.16 0.87,-0.99 -1.23,0.74 -2.97,0.61 -2.21,2.59 0.47,1.25 0.92,0.35 -0.63,0.61 0.34,0.7 0.58,-0.32 0.55,0.45 0.95,2.11 -0.34,0.54 -1.02,0.29 -0.81,-0.29 -0.13,0.7 1.02,0.35 0.81,-0.51 0.68,0.1 -0.31,0.93 0.37,2.46 2.44,1.95 0.03,0.29 -2.28,0.35 0.79,0.96 1.37,-0.32 0.84,0.32 0.03,0.38 -2.81,1.15 -3.13,0.61 0.55,-0.89 0.87,-0.25 0.34,-1.05 -0.34,-0.06 -0.42,0.9 -0.31,-0.41 -1.65,0.22 0.58,1.37 -0.47,0.32 -0.74,-0.16 -1.29,-1.82 2.23,-0.16 -0.31,-1.21 0.97,-0.67 0.89,-0.06 0,-0.38 -3.78,-1.15 0.6,-0.73 -0.37,-0.35 -0.5,0.32 -0.08,-1.44 -1.02,1.82 -0.52,-0.16 -1.02,0.8 -0.63,0.03 -0.86,-0.93 -1.02,-0.29 0.1,0.83 -1.02,0.42 -1.42,-0.83 -0.87,-0.06 -0.21,1.06 2.97,1.72 0,0.39 -0.42,0.35 -0.66,-0.74 -0.42,0.96 -2.1,0.19 -1.31,1.95 -1.15,0 0.05,-0.83 -0.39,-0.06 -1.1,0.99 -1.55,0.38 -0.08,0.54 -0.76,-0.41 0.71,1.6 -0.84,0.67 -0.39,-0.19 0.13,0.89 -1.13,0.86 0.03,0.67 0.84,-0.73 1.89,-0.35 0.11,-1.76 1.5,-0.89 4.07,-1.02 -0.58,-0.99 0.39,-1.02 0.79,-0.19 0.39,0.83 0.89,-0.51 0.08,-0.93 1.26,1.31 -0.45,0.86 0.39,0.35 -0.26,0.9 -1.34,-0.35 -0.44,0.29 0.71,0.51 1.31,0.16 0.39,0.57 -0.42,0.83 1.87,0.9 0.11,0.61 -0.92,1.24 -0.37,-0.64 -0.47,0.1 0.13,1.18 -0.71,0.1 -0.03,0.67 -1.29,-0.51 0.34,0.89 -0.39,0.13 -2.18,-0.73 -3.02,-0.06 0.03,1.44 0.87,-0.51 1.08,0.1 1.21,0.38 0.24,1.05 -1,1.4 -0.94,0.54 0.58,0.26 0.08,1.09 -0.5,0.61 1,0.89 -0.66,0.45 0.08,1.31 -1.1,0.77 0.79,0.77 -0.6,0.77 0.39,1.53 -0.21,1.24 0.92,-0.67 0.26,-0.51 -0.34,-0.13 0.08,-0.51 1.44,-1.43 -0.13,-0.7 -0.63,-0.45 0.16,-0.32 1.23,-0.1 0.66,1.12 -0.08,0.57 0.45,0 0.08,0.83 0.81,-0.1 0.16,0.35 -0.76,2.29 -0.68,-0.22 -0.37,-1.11 -0.31,0.92 0.32,1.02 -0.87,-0.13 0.63,0.86 -0.13,1.4 -1.68,1.02 -0.81,-0.29 -1.44,0.64 2.76,0.64 0.24,0.92 -0.26,0.57 0.24,1.5 -0.89,-0.29 -0.1,0.45 0.81,0.86 -0.58,0.54 -1.31,-0.25 1.52,1.21 -1.02,1.34 -0.13,0.89 -1.68,-0.09 -0.24,-0.64 -0.58,0.35 -0.08,-1.69 -0.21,-0.19 -0.6,0.57 -0.21,-0.54 0.5,-0.64 -0.84,-1.21 -0.63,0.96 -0.18,-0.6 -0.94,-0.16 0.79,-0.89 0.71,-0.06 -0.37,-0.54 0.31,-0.73 -2.99,-1.21 -1.05,0.96 -0.58,-1.05 0,-0.64 0.34,0.35 0.58,-0.32 -0.24,-1.43 0.5,0.1 0.16,1.02 0.5,-0.29 -0.16,-0.73 0.6,-0.16 0.47,0.35 -0.13,0.57 0.74,0.51 0.63,-0.54 1.23,2.52 -0.18,-1.75 1,0.32 0.95,-0.76 -0.47,-0.29 -0.63,0.61 -0.24,-0.64 -0.55,0.06 0.42,-0.86 -1.31,0.1 0.31,-0.48 -0.68,-0.67 0.76,-0.1 0.97,-1.27 2.26,0.48 0.66,-0.35 -0.34,-0.6 -2.81,0 -0.5,-0.67 0.32,-1.02 -0.37,-0.67 -0.29,0.7 -0.79,-0.41 0.63,1.47 -0.34,0.42 -1.57,-0.32 -0.47,-1.69 -0.21,1.56 -0.66,-0.19 0,-0.83 -0.76,-0.1 0.37,0.61 -0.89,0.19 -0.03,-1.24 -1.08,0.8 -0.63,-1.47 -1.15,-0.86 0,-0.38 1.39,-0.7 2.49,0 0.79,0.48 0.79,-0.35 -0.31,-0.51 0.29,-0.67 -0.68,-0.06 -0.16,-0.25 0.37,-0.16 -0.6,-0.57 0.18,-0.86 -0.47,-1.53 -0.47,0.45 -0.55,-0.25 0.21,-1.08 -0.34,0.16 -0.97,-0.8 0.18,1.18 -0.34,0.13 0.45,0.7 -0.42,0.07 -0.18,0.6 -1.42,0.22 0.47,2.07 -1.42,1.02 -0.71,-0.73 0.03,1.4 -0.58,-0.03 -0.03,-0.67 -0.94,-0.22 0.24,-0.67 -0.63,-0.51 0.73,-1.37 -0.31,-0.67 -0.63,-0.1 -0.37,0.45 -0.66,-0.61 -0.29,0.7 -0.02,-0.86 -0.58,-0.19 -1.05,0.51 -0.58,-0.6 -0.42,0.83 -0.52,-0.41 -0.18,0.45 -0.31,-0.29 -1,0.45 0.79,1.27 -0.5,1.24 0.31,2.45 -1.89,-0.16 -0.66,-1.4 -0.21,1.21 -0.74,0 -0.68,-1.21 -1.6,0.57 -0.87,1.56 -1,-1.85 -1.05,0.26 -0.73,-1.02 0.6,-0.89 0.66,-0.16 0.18,0.54 0.24,-0.8 -4.15,-0.44 -0.1,0.38 -2.07,-0.7 -1.37,-1.24 -0.03,-0.7 -0.92,-1.34 1.81,-1.37 0.37,-0.96 -0.76,-0.38 -0.58,-1.69 1.02,-2.33 -0.42,-0.8 -0.73,0.64 -0.16,-0.51 0.6,-1.02 -0.26,-1.21 0.95,-3.22 1.16,-0.99 -0.63,-0.32 -2.02,1.53 0.21,0.61 -0.92,0.86 0.39,1.05 -0.32,1.53 -0.55,0.61 -1.08,-0.25 -0.34,-0.48 1.18,-0.64 -0.24,-0.7 -0.03,0.45 -0.71,0.42 -0.32,-0.61 -1.73,-0.32 -0.5,1.25 -0.39,0.1 -0.03,0.29 0.87,0 0.24,-0.8 0.84,0.16 -0.16,0.67 1.29,1.06 -0.13,1.09 1.13,0.26 -0.39,2.23 -0.71,-0.41 0.05,1.53 -0.44,-0.19 0.18,-0.51 -0.71,-0.89 -0.45,0.16 0.13,1.15 -0.42,-0.57 -0.42,0.19 0.55,0.73 -0.87,0.45 -1.13,-2.17 -0.79,0.19 -0.47,1.18 -0.45,-0.22 -0.47,0.32 0.5,0.86 -1.5,-0.54 0.37,-0.83 -0.6,0.22 -0.26,-0.64 0.32,-0.51 0.45,0.29 0.08,-1.24 -0.71,-0.19 -0.84,-1.25 -0.47,0.7 0.29,0.73 -0.63,1.4 0.21,0.99 -0.92,0 0.4,1.25 -1,0.13 -0.5,0.99 0.18,0.35 -0.73,0.57 -0.74,0 -0.37,0.77 -1.44,0.19 -0.45,-0.45 -1.05,0.45 -0.24,-1.53 -0.42,-0.25 -0.16,0.64 -0.55,-0.86 -0.42,2.1 -0.5,0.32 -0.47,-0.73 -0.75,0.16 -0.09,-0.45 -0.7,-0.32 0.04,-2.93 -1.58,-4.11 0,0 -1.74,-1.33 0,0 -1.18,-1.87 -1.62,-0.69 -0.77,-1.24 0,0 -1.09,-1.05 0,0 -0.19,-2.9 -3.04,-3.64 -2.22,-1.13 -1.3,-1.69 -0.91,-9.22 -2.66,-2.99 0.02,-1.56 0.79,-0.7 0,0 0.23,-0.2 0,0 2.22,-2.31 -0.55,-2.87 0.34,-1.16 0.82,-1.99 3.7,-3.57 0.56,-3.46 0,0 -0.1,-0.55 0,0 -1.63,-0.43 0,0 -0.69,-1.93 0,0 0.69,-3.34 0,0 -1.27,-2.27 0,0 -0.5,-1.05 0.08,-1.86 0,0 -0.69,-0.7 -2.08,-0.67 0,0 -0.17,-2.32 0,0 1.59,-3.28 0,0 0.79,-4.74 0,0 1.91,-4.94 0.94,-1.45 0,0 0.89,-0.8 0.16,-1.92 0,0 0.78,-4.82 1.67,-1.14 3.27,-3.59 0.81,-2.29 0,0 0.67,-1.21 0,0 0.18,-0.58 0,0 0.21,-0.64 0.44,0.17 0,0 0.71,0.49 0,0 1.31,-0.05 0,0 1.83,-1.15 0,0 1.46,-0.01 1.78,-1.65 1.32,-0.24 0.54,-1.94 1.51,-2.69 2.33,-1.51 0.13,1.94 0.3,0.77 z m 85.94,91.96 0.4,0.06 0.11,1.37 1.02,-0.29 0.47,1.76 -1.63,3.42 0.66,0.8 -0.58,1.44 -0.73,0.41 0.26,-0.6 -0.76,0 0,-0.77 -0.34,-0.19 0.13,-0.8 0.69,-0.41 -2.05,-0.89 -0.08,-0.38 0.66,0.06 0.37,-0.48 -0.76,-0.61 0.45,-0.19 -0.05,-0.67 -0.52,-0.7 -0.76,-0.13 -0.13,-0.7 0.87,-0.29 0.03,-0.38 1.58,-0.1 0.13,-0.67 0.56,-0.07 z m -14.31,3 0.73,0.29 0.45,0.86 0.76,-0.1 -0.05,-0.54 0.53,0.51 0.79,0 0.89,1.47 -0.87,1.66 -0.55,-0.45 -0.5,0.35 -0.1,0.38 0.52,0.19 0.08,0.48 -1.37,0.06 0.18,0.61 0.61,-0.09 -0.52,1.15 0.13,1.09 0.66,0 0.4,0.89 0.89,0.03 -0.18,0.83 0.37,0.77 0.66,0.19 0.13,1.15 -0.42,0.22 -0.44,-0.32 0.03,2.17 0.53,0.77 -0.37,0.51 -0.89,-0.29 0.63,1.31 -0.97,0.16 -0.34,0.7 -0.68,0.29 -0.05,1.05 1.45,0.29 -0.45,0.64 0.34,0.26 0.76,-1.47 1.1,-0.76 0.97,0.57 1.18,-1.05 -0.87,1.21 0.16,0.48 -0.58,0.1 0.45,1.24 -0.66,0.7 -0.94,-0.54 -0.26,0.26 1.16,2.39 -1.13,0.28 -0.58,-0.99 -1.6,1.05 0.03,0.89 0.63,0.54 0.87,-1.02 0.74,0.54 0.11,0.57 -0.71,0.51 2,3.37 0.03,0.77 -0.5,0.1 -0.5,-0.76 -1.89,-0.19 -0.02,-0.41 0.58,-0.38 -0.76,-1.37 -0.97,0.64 0.11,1.21 -0.29,0.06 -0.68,-0.19 0.34,-0.48 -0.13,-0.76 -2.07,-0.45 -0.24,2.29 0.71,0.86 -1.44,1.27 -1.18,-0.44 -0.73,1.78 1.39,2.39 1.97,-0.25 0.73,0.45 0.13,0.41 -0.63,0.13 0.03,0.86 -0.52,-0.83 -1.42,-0.51 -0.39,0.64 -1.18,-0.19 -0.92,0.57 -0.18,-0.7 -0.47,0.76 0.84,1.21 0.81,0.22 0.24,0.54 -0.39,0.38 -0.63,0.03 -0.58,-0.51 -1.5,1.46 -1.81,-0.92 -1.29,0.76 -0.16,-0.54 0.5,-0.98 0.74,-0.1 -0.29,-0.67 1.76,-0.48 0.32,-0.51 -0.58,-0.7 -1.36,0.06 -0.89,-0.48 0.03,-1.27 0.45,-0.51 -0.26,-0.67 2.05,-0.16 -0.05,-0.44 -0.81,-0.32 0.5,-0.86 -1.42,0.29 -0.71,-0.35 -1.24,1.4 -0.76,-0.19 -0.08,-0.89 1.42,-1.4 -1,-0.16 -1.39,1.56 0.24,-1.05 -0.66,-0.38 0.97,-0.16 0.24,-0.54 2,0.03 1.18,-0.51 0.03,-2.29 1.05,-0.86 -0.08,-0.76 -0.71,0.19 -0.18,-0.86 -0.66,-0.19 -0.16,-0.48 1.05,0.32 0.03,-0.7 -1.44,-0.83 -0.97,1.34 0.16,1.15 -2.34,-0.29 -0.21,0.7 -0.76,-0.45 -0.47,0.64 0.37,0.73 -0.76,-0.25 0.37,0.92 -0.66,0.77 -0.6,-0.03 -0.13,-0.99 -0.81,-0.7 0.68,-0.86 -1.21,-0.16 -1.26,-0.92 -0.37,-0.89 0.26,-0.35 -0.63,-0.38 0.37,-0.35 -0.52,-1.75 0.42,-1.27 0.76,-0.54 0.71,-1.34 0.82,-0.06 -0.39,-0.7 0.81,0.35 -0.47,-0.8 0.6,0.41 0.84,-0.22 -0.03,-0.64 0.95,-0.92 0.92,0.19 0.97,0.86 0.03,0.54 1.94,1.21 0.92,-0.16 0.05,-0.41 -0.6,-0.51 1.44,-0.77 0.53,0.83 0.53,-0.25 0.21,0.67 0.79,-0.38 0.68,1.43 1,0.32 0.05,-0.73 -0.89,-1.47 0.26,-0.64 -1,0.29 0.26,-1.05 -0.71,-0.1 -0.79,-1.88 -0.92,-0.29 0.34,-1.05 0.42,0.41 0.53,-0.57 -0.13,-1.37 0.74,-0.51 0.47,0.29 -0.5,1.09 1.13,-0.64 1.47,0.29 -0.03,-0.64 0.89,0.89 0.74,0.16 0.29,-0.32 -0.55,-0.22 0.11,-1.12 0.5,-0.89 0.58,-0.22 -0.5,-0.06 -0.05,-0.67 1.05,-0.26 -0.5,-0.8 0.74,0.35 0.34,-0.48 0.4,0.99 0.6,0.03 -0.73,-1.31 0.84,-0.16 -0.1,-0.57 -0.42,0.42 -0.89,-0.29 0.39,-1.66 0.4,-0.06 -0.03,-1.28 0.89,-0.13 -0.87,-0.57 0.13,-0.34 z m -2.81,2.17 0.47,1.25 -0.66,1.24 -0.05,0.42 0.58,0.16 -0.63,0.06 -0.05,1.72 -1.73,0.38 0.29,-0.41 -0.79,-0.29 -0.39,0.89 -0.76,0.19 0.21,-1.4 0.45,-0.22 0.18,0.32 0.74,-0.92 -0.08,-0.29 -0.92,0.03 0.11,-0.51 1.58,-0.03 -0.23,-1.12 0.63,-0.77 0.52,0.38 0.53,-1.08 z m -71.45,8.65 0.55,0.54 0.89,-0.03 0.08,0.45 0.47,-0.35 0.21,0.67 0.18,-0.8 0.63,0.29 -0.39,0.64 0.71,2.13 -0.47,1.56 0.16,1.24 -0.58,-0.03 -0.95,0.96 -0.71,-0.1 -0.34,1.5 1,2.23 0.63,0.45 -0.58,0.92 1.47,1.05 0.71,-0.29 1,0.67 0.16,2.13 0.92,0.45 0.79,-0.19 0.34,-0.32 -0.68,-0.54 1.81,-0.7 -0.1,-0.67 1.23,-0.7 2.68,0.19 0.05,-0.32 1,-0.16 0.39,0.83 1.08,0.57 0.24,-0.38 1.18,0.48 0.55,0.96 -0.47,0.92 0.39,0.45 -0.45,0.32 -0.73,-0.25 -0.13,0.64 0.6,0.32 -0.76,1.21 0.87,3.53 -0.26,0.7 -0.66,0.19 -1.24,1.31 -0.18,0.83 2.49,1.78 -0.66,-0.32 -0.03,0.45 -0.6,0.06 -0.39,0.61 -0.73,-0.13 0.13,-0.48 -0.87,-0.03 -0.24,0.79 -0.49,-0.15 0.66,-1.94 -0.94,-0.6 -0.79,0.29 0.31,0.7 -0.24,0.38 -0.47,0 -0.26,-0.51 -0.79,0.32 -0.34,-0.83 -0.47,0.29 0.39,0.7 -0.39,0.45 -1.1,-0.32 -1.47,0.26 -0.39,-0.86 0.47,-0.19 -0.05,-0.48 -0.66,-0.22 -0.6,-2.54 0.39,-2.1 0.66,-0.89 -0.42,-0.54 -2.1,0.19 -2.26,1.15 0.71,3.69 -0.5,0.73 -1.63,0.6 -2.99,-0.64 0.42,-0.73 -1.08,-0.41 0.53,-0.54 -0.34,-0.67 -1.5,-0.1 -0.16,-0.86 0.58,-0.13 0.21,-0.6 -0.26,-0.54 1.08,-0.25 -0.6,-2 -0.73,-0.26 -0.37,-0.7 0.24,-1.43 -0.84,-0.32 0.05,-0.73 -1.39,-1.85 -0.58,-2.83 0.97,-0.89 -0.21,-0.73 0.29,-0.35 0.97,-0.06 -0.18,-0.89 0.6,-0.92 -0.34,-0.32 1,-0.54 0.18,-0.86 0.39,0.61 1.65,-0.22 -0.97,-1.27 0,-0.86 0.53,0 -0.42,-0.7 1.08,-0.38 -0.08,-0.57 0.5,-0.67 2.15,-0.6 z m 12.95,2.77 0.24,0.7 -0.71,1.69 -0.89,0.83 -0.55,3.15 1.29,0.29 -0.13,-2.07 1.31,-1.75 1,0.13 0.21,1.59 0.6,-0.26 1.08,1.31 -0.13,1.4 -0.76,0.25 -0.34,0.8 0.76,-0.32 0.26,0.73 -0.39,0.45 1.45,0 0.03,0.7 0.89,0.26 0.16,0.99 -0.87,0 -0.5,-0.86 -0.73,0.6 -0.97,-0.95 -0.79,0.32 -2.28,-1.53 -0.31,1.21 -1.39,0.32 -1.63,-0.06 -1.65,-0.83 0.26,-0.35 -0.76,-0.73 -0.24,-1.18 0.18,-0.96 1.31,-0.83 0.11,-0.83 1.16,-0.92 0.05,-1.05 0.68,-0.96 1.76,-1.05 0.58,0.19 0.65,-0.42 z m 16.07,7.14 2.31,0.99 0.76,0.8 -0.26,0.32 -2.23,-0.1 -0.58,0.41 -0.47,1.24 -0.97,0.38 -0.55,-0.76 0.42,-0.54 -1.29,-0.32 -0.29,-1.34 3.15,-1.08 z m 3.46,2.2 1.26,1.98 1.5,0.89 -0.55,0.8 -2.02,-0.19 0.58,1.15 -0.31,0.73 -0.47,-0.76 -1.26,0.03 -0.03,-0.79 -1.26,0.06 -0.13,-0.38 0.69,-0.16 -0.19,-0.32 -1.36,-0.38 0.16,-0.8 0.39,0.41 0.81,-0.03 -0.66,-0.6 0.87,-1.24 1.98,-0.4 z m 23.4,2.67 0.1,0.32 -0.71,0.38 0.37,0.41 0.1,-0.45 0.42,0.03 -0.24,0.54 0.68,0.77 0.11,2.13 1.21,-0.25 0.55,0.83 -0.32,1.18 -1.89,1.11 -0.66,-0.51 -1.34,0.06 0.37,-0.25 -0.37,-0.64 0.58,-0.25 -1.34,-1.78 0.32,-0.54 -0.08,-1.75 0.53,0.57 -0.05,1.21 0.76,-0.38 -0.16,-1.05 1.13,0.64 -0.68,-1.02 -0.87,0.25 -0.29,-0.73 0.29,-0.83 1.48,0 z m -22.61,18.9 1.21,0.95 0.66,-0.22 1,0.83 -0.24,0.57 -0.76,0.13 0.68,0.32 0.26,0.64 0.95,-1.65 1.34,-0.03 -0.55,0.54 0.29,0.38 -0.81,0.45 0.16,0.92 -1.65,-0.1 -0.08,-0.48 -0.76,-0.28 -0.68,0.89 -1.08,0.03 -0.16,0.92 -0.89,-0.16 -0.26,-0.57 1.08,-0.19 0.05,-0.51 -0.79,-0.57 0.26,-0.76 -0.87,0.51 -0.45,-0.73 1.1,-0.38 -0.68,-0.98 0.55,-0.41 1.12,-0.06 z',
      Color.fromARGB(255, 223, 223, 223).withOpacity(0.0)
    ],
    [
      'm 148.84429,592.92884 0.68,0.78 -0.45,0.6 0.79,-0.31 0.66,0.22 -0.52,0.53 0.39,1.16 -0.55,1.22 -2.07,-0.5 -0.45,-1.44 0.79,-1.97 0.73,-0.29 z m -4.62,15.13 -1.44,0.53 -1.71,1.75 -0.47,2.03 -2.47,2.48 0.16,1.44 -1.31,1.47 -2.13,0.47 -2.94,-0.56 -3.12,3.25 -2.42,0.16 -3.81,1.06 -0.76,-0.41 -2.02,0.31 -2.68,2.16 -0.08,0.78 -1.81,0.69 -0.87,-0.37 -0.13,-0.53 -1.71,-0.06 -0.52,1.28 -1.47,-0.87 -2.15,0.19 -1.6,0.81 -3.7,0.84 -1.1,-1.69 -0.74,-0.15 -2.340004,0.63 -1.34,-1.06 -0.52,0.06 -3.31,1.5 -4.23,-1.12 -3.1,2.03 0.03,2.97 -0.55,0.16 -0.31,-0.62 -0.52,-0.03 -0.95,0.62 -0.89,-0.59 0.24,-1.12 -0.84,-0.03 -2.13,-2.87 -2.99,-1.28 -1.89,-1.56 -1.84,-3 0.58,-3.31 -0.58,-1.81 0.42,-0.78 1.37,-0.69 0.03,-1.41 2.76,-1.78 1.18,-1.81 1.21,0.19 2.18,-2.5 0.45,-2.82 4.2,-1.69 0.08,-1.69 0.37,-0.28 1.94,-0.03 1.89,-0.53 0.24,-0.53 1.31,0.06 1.66,-1.35 0.47,-0.03 0.71,0.78 1.16,-0.88 4.150004,-1.1 1.26,-1 1.34,-0.09 0.34,-0.81 0.74,-0.41 2.02,0.6 1.26,-0.22 1.16,-0.75 0.97,0.44 1.26,-0.69 2.08,0.16 0.79,-1.16 3.7,-0.25 0.11,-0.81 1,-1.19 1.89,1.51 0.87,-0.28 0.24,-0.85 0.87,0.35 3.78,-1.25 3.18,0.38 0.24,-0.94 3.02,0.6 0.32,0.53 1.84,-0.6 0.92,0.1 0.1,1.41 1.21,1.6 1.08,0.09 0.68,0.85 1,-0.63 2.21,0.28 1.05,0.75 -0.42,1.32 1.02,0 0.34,0.94 -0.16,1.32 -0.81,0.09 -0.18,0.75 1.81,1.44 1.34,-0.5 0.13,0.88 0.95,0.81 -0.47,0.56 -1,-0.66 -0.81,1.22 -0.1,1.03 1.5,1.1 -0.73,0.88 -0.63,-0.5 0.26,-0.47 -0.87,-0.34 -1,4.65 z',
      Color.fromARGB(255, 223, 223, 223).withOpacity(0.0)
    ],
    [
      'm 181.53429,232.61884 1.56,2.18 -0.31,2.81 -2.19,0.63 2.81,3.43 0,2.81 0.45,1.35 3.34,0.2 -0.09,1.45 -0.83,1.83 1.08,1.14 -1.86,6.1 0.57,-0.78 0.4,-0.33 0.71,0.14 0.62,0.86 0.31,0.04 -0.33,3.29 -0.94,2.81 -3.43,1.56 -0.91,0.04 -2.52,0.58 0.31,8.74 -2.18,2.49 -1.71,-2.05 -1.75,-1.35 -1.22,-3.1 0.14,-4.05 -0.27,-2.83 -1.35,-3.91 -2.7,-1.48 -1.88,-2.56 -0.14,-2.02 1.08,-2.43 0,-3.1 -0.13,-3.5 -0.27,-3.37 0.67,-2.43 -0.27,-3.1 -0.54,-2.02 -1.08,-2.02 0.41,-1.76 2.69,-1.08 2.57,0.81 1.48,1.62 2.69,1.62 2.57,0.94 z',
      Color.fromARGB(255, 223, 223, 223).withOpacity(0.0)
    ],
  ];

  Widget drawMap(int index) {
    WthrReport wthrReport = WthrReport();
    var areaColor = wthrReport.classifyLocation(Static.reportList![index]);
    for (int i = 0; i < paths.length; i++) {
      paths[i][1] = areaColor![i];
    }
    return SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
              width: MediaQuery.of(context).size.width * 0.80,
              height: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(right: 200, bottom: 300),
              child: Transform.scale(
                scale: 0.6,

                child: Stack(
                  // fit: StackFit.loose,
                  children: paths.map((e) {
                    return CustomPaint(
                        painter: MyPainter(
                            parseSvgPath(e[0] as String), e[1] as Color));
                  }).toList(),
                ),
                //   ),
                // ),
              )),
          alertBox(index),
        ]));
  }

  Widget alertBox(int index) {
    return Container(
        margin: EdgeInsets.only(top: 30),
        padding: EdgeInsets.all(20),
        width: MediaQuery.of(context).size.width * 0.90,
        decoration: BoxDecoration(
          color: Color.fromARGB(173, 170, 170, 170).withOpacity(0.1),
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        child: Column(children: [
          Row(children: [
            Icon(
              Icons.warning_amber,
              color: Color.fromARGB(255, 149, 182, 169),
            ),
            Text(
              '현재상황',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 20,
                // fontWeight: FontWeight.w300,
              ),
            ),
          ]),
          Row(children: [
            Icon(
              Icons.warning_amber,
              color: Color.fromARGB(255, 149, 182, 169),
            ),
            Text(
              '폭염이란?',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 20,
                // fontWeight: FontWeight.w300,
              ),
            ),
          ]),
          Row(children: [
            Icon(
              Icons.warning_amber,
              color: Color.fromARGB(255, 149, 182, 169),
            ),
            Text(
              '행동강령',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 20,
                // fontWeight: FontWeight.w300,
              ),
            ),
          ])
        ]));

    // Flexible(
    //     child: RichText(
    //         overflow: TextOverflow.ellipsis,
    //         maxLines: 1,
    //         text: TextSpan(
    //           text: label,
    //           style: TextStyle(
    //             color: Color.fromARGB(255, 181, 189, 186),
    //             fontSize: 20,
    //             fontWeight: FontWeight.w300,
    //           ),
    //         )))
  }
}

class MyPainter extends CustomPainter {
  final Path path;
  final Color color;
  MyPainter(this.path, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = 4.0;
    canvas.drawPath(path, paint);
    var border = Paint()
      ..color = Color.fromARGB(255, 94, 94, 94)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, border);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
