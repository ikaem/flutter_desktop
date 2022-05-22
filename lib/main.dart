import 'dart:async';
import 'dart:io';

// import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
// import 'package:english_words/english_words.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' hide MenuItem;
import 'package:flutter_platform_alert/flutter_platform_alert.dart';
import 'package:open_file/open_file.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Must add this line.
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = WindowOptions(
      size: const Size(800, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      // titleBarStyle: TitleBarStyle.hidden,
      titleBarStyle: TitleBarStyle.normal);
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.minimize();
    await windowManager.hide();
    // await windowManager.show();
    // await windowManager.focus();
  });

  // print("defaultTargetPlatform: $defaultTargetPlatform");

  runApp(const MaterialApp(home: MyApp()));

  // WidgetsFlutterBinding.ensureInitialized();
  // runApp(const MyApp());

  // doWhenWindowReady(() {
  //   final win = appWindow;
  //   const initialSize = Size(600, 450);
  //   win.minSize = initialSize;
  //   win.size = initialSize;
  //   win.alignment = Alignment.center;
  //   win.title = "How to use system tray with Flutter";
  //   win.hide();
  //   // win.show();
  // });
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final SystemTray _systemTray = SystemTray();
  final AppWindow _appWindow = AppWindow();

  Timer? _timer;
  final bool _toogleTrayIcon = true;

  @override
  void initState() {
    super.initState();
    initSystemTray();
    // () => AwesomeDialog(
    //         context: context,
    //         dialogType: DialogType.QUESTION,
    //         title: "Are you sure you want to quit?")
    //     .show();
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  Future<void> initSystemTray() async {
    String path = Platform.isWindows ? 'assets/icon.ico' : 'assets/icon.png';

    List<String> iconList = ['darts_icon', 'gift_icon'];

    final menu = [
      MenuItem(
          label: 'Encrypt file',
          onClicked: () async {
            FilePickerResult? result = await FilePicker.platform.pickFiles();
            print("this is result: $result");

            String filename = result?.files[0].path != null
                ? "${result?.files[0].path}.qrypt"
                : "";

            File encryptedFile = File(filename);

            await encryptedFile.writeAsString("NO text");

            OpenFile.open(encryptedFile.path);
          }),
      MenuItem(
          label: 'Decrypt file',
          onClicked: () async {
            FilePickerResult? result = await FilePicker.platform.pickFiles();
          }),
      MenuSeparator(),
      MenuItem(
        label: 'Exit',
        onClicked: () async {
          // await showDialog<void>(
          //   context: context,
          //   barrierDismissible: false, // user must tap button!
          //   builder: (BuildContext context) {
          //     return AlertDialog(
          //       title: const Text('AlertDialog Title'),
          //       content: SingleChildScrollView(
          //         child: ListBody(
          //           children: const <Widget>[
          //             Text('This is a demo alert dialog.'),
          //             Text('Would you like to approve of this message?'),
          //           ],
          //         ),
          //       ),
          //       actions: <Widget>[
          //         TextButton(
          //           child: const Text('Approve'),
          //           onPressed: () {
          //             Navigator.of(context).pop();
          //           },
          //         ),
          //       ],
          //     );
          //   },
          // );

          // print(context);
          // AwesomeDialog(
          //         context: context,
          //         dialogType: DialogType.QUESTION,
          //         title: "Are you sure you want to quit?")
          //     .show();

          await FlutterPlatformAlert.showAlert(
            windowTitle: 'Quit?',
            text: 'Are you sure you want to quit?',
            iconStyle: IconStyle.exclamation,
            alertStyle: AlertButtonStyle.abortRetryIgnore,
            options: FlutterPlatformAlertOption(
              preferMessageBoxOnWindows: true,
            ),
          );

          _appWindow.close();
        },
      ),
    ];

    // We first init the systray menu and then add the menu entries
    await _systemTray.initSystemTray(
      title: "system tray",
      iconPath: path,
      toolTip: "How to use system tray with Flutter",
    );

    await _systemTray.setContextMenu(menu);

    // handle system tray event
    _systemTray.registerSystemTrayEventHandler((eventName) {
      debugPrint("eventName: $eventName");
      if (eventName == "leftMouseDown") {
      } else if (eventName == "leftMouseUp") {
        _appWindow.show();
      } else if (eventName == "rightMouseDown") {
      } else if (eventName == "rightMouseUp") {
        _systemTray.popUpContextMenu();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // return MaterialApp(
    // debugShowCheckedModeBanner: false,
    // home: Scaffold(

    return Scaffold(
      body: WindowBorder(
        color: const Color(0xFF805306),
        width: 1,
        child: Row(
          children: const [
            LeftSide(),
            RightSide(),
          ],
        ),
      ),
    );
    // ),
    // );
  }
}

const backgroundStartColor = Color(0xFFFFD500);
const backgroundEndColor = Color(0xFFF6A00C);

class LeftSide extends StatelessWidget {
  const LeftSide({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Container(
        color: const Color(0xFFFFFFFF),
        child: Column(
          children: [
            WindowTitleBarBox(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [backgroundStartColor, backgroundEndColor],
                      stops: [0.0, 1.0]),
                ),
                child: MoveWindow(),
              ),
            ),
            Expanded(
              child: Container(),
            )
          ],
        ),
      ),
    );
  }
}

class RightSide extends StatelessWidget {
  const RightSide({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: const Color(0xFFFFFFFF),
        child: Column(
          children: [
            WindowTitleBarBox(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [backgroundStartColor, backgroundEndColor],
                      stops: [0.0, 1.0]),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: MoveWindow(),
                    ),
                    const WindowButtons()
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final buttonColors = WindowButtonColors(
    iconNormal: const Color(0xFF805306),
    mouseOver: const Color(0xFFF6A00C),
    mouseDown: const Color(0xFF805306),
    iconMouseOver: const Color(0xFF805306),
    iconMouseDown: const Color(0xFFFFD500));

final closeButtonColors = WindowButtonColors(
    mouseOver: const Color(0xFFD32F2F),
    mouseDown: const Color(0xFFB71C1C),
    iconNormal: const Color(0xFF805306),
    iconMouseOver: Colors.white);

class WindowButtons extends StatelessWidget {
  const WindowButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColors),
        MaximizeWindowButton(colors: buttonColors),
        CloseWindowButton(colors: closeButtonColors),
      ],
    );
  }
}


// old down here
// import 'dart:io';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:system_tray/system_tray.dart';
// import 'package:window_manager/window_manager.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   // Must add this line.
//   await windowManager.ensureInitialized();

//   WindowOptions windowOptions = WindowOptions(
//       size: Size(800, 600),
//       center: true,
//       backgroundColor: Colors.transparent,
//       skipTaskbar: false,
//       // titleBarStyle: TitleBarStyle.hidden,
//       titleBarStyle: TitleBarStyle.normal);
//   windowManager.waitUntilReadyToShow(windowOptions, () async {
//     // await windowManager.hide();
//     await windowManager.show();
//     // await windowManager.focus();
//   });

//   print("defaultTargetPlatform: $defaultTargetPlatform");

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         // This is the theme of your application.
//         //
//         // Try running your application with "flutter run". You'll see the
//         // application has a blue toolbar. Then, without quitting the app, try
//         // changing the primarySwatch below to Colors.green and then invoke
//         // "hot reload" (press "r" in the console where you ran "flutter run",
//         // or simply save your changes to "hot reload" in a Flutter IDE).
//         // Notice that the counter didn't reset back to zero; the application
//         // is not restarted.
//         primarySwatch: Colors.blue,
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({Key? key, required this.title}) : super(key: key);

//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.

//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;

//   @override
//   void initState() {
//     super.initState();
//   }

//   void _incrementCounter() {
//     setState(() {
//       // This call to setState tells the Flutter framework that something has
//       // changed in this State, which causes it to rerun the build method below
//       // so that the display can reflect the updated values. If we changed
//       // _counter without calling setState(), then the build method would not be
//       // called again, and so nothing would appear to happen.
//       _counter++;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return Scaffold(
//       appBar: AppBar(
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text(widget.title),
//       ),
//       body: Center(
//         // Center is a layout widget. It takes a single child and positions it
//         // in the middle of the parent.
//         child: Column(
//           // Column is also a layout widget. It takes a list of children and
//           // arranges them vertically. By default, it sizes itself to fit its
//           // children horizontally, and tries to be as tall as its parent.
//           //
//           // Invoke "debug painting" (press "p" in the console, choose the
//           // "Toggle Debug Paint" action from the Flutter Inspector in Android
//           // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
//           // to see the wireframe for each widget.
//           //
//           // Column has various properties to control how it sizes itself and
//           // how it positions its children. Here we use mainAxisAlignment to
//           // center the children vertically; the main axis here is the vertical
//           // axis because Columns are vertical (the cross axis would be
//           // horizontal).
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headline4,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         // child: const Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }

// Future<void> initSystemTray() async {
//   String path =
//       Platform.isWindows ? 'assets/app_icon.ico' : 'assets/app_icon.png';

//   final menu = [
//     MenuItem(label: 'Show'),
//     MenuItem(label: 'Hide'),
//     MenuItem(label: 'Exit'),
//   ];

//   // We first init the systray menu and then add the menu entries
//   await _systemTray.initSystemTray(
//     title: "system tray",
//     iconPath: path,
//   );

//   await _systemTray.setContextMenu(menu);

//   // handle system tray event
//   _systemTray.registerSystemTrayEventHandler((eventName) {
//     debugPrint("eventName: $eventName");
//     if (eventName == "leftMouseDown") {
//     } else if (eventName == "leftMouseUp") {
//       _systemTray.popUpContextMenu();
//     } else if (eventName == "rightMouseDown") {
//     } else if (eventName == "rightMouseUp") {
//       _appWindow.show();
//     }
//   });
// }
