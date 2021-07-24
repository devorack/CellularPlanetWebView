import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'CellularPlanet'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int state;
  bool error;

  WebViewController webViewController;
  final GlobalKey<RefreshIndicatorState> refreshKey =
      GlobalKey<RefreshIndicatorState>();
  void initState() {
    super.initState();
    // Enable hybrid composition.
    this.state = 0;
    this.error = false;
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return MaterialApp(
      title: 'CellularPlanet',
      home: Scaffold(
          body: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(top: 32),
            height: size.height,
            width: size.width,
            color: Color.fromRGBO(55, 71, 106, 1),
            child: WebView(
              onWebViewCreated: (control) {
                print(control.toString());
                setState(() {
                  this.state = 1;
                  this.webViewController = control;
                });
                print("init");
              },
              onPageStarted: (onStart) {
                print("strat" + onStart);
              },
              onWebResourceError: (onStart) {
                print("error" + onStart.description);
                setState(() {
                  this.error = true;
                });
              },
              onPageFinished: (onStart) {
                print("finish" + onStart);
                setState(() {
                  this.state = 0;
                });
              },
              initialUrl: "https://cp.app-sistemas.com/cellular/",
              javascriptMode: JavascriptMode.unrestricted,
            ),
          ),
          state == 1
              ? Container(
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(55, 71, 106, 1),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: 50),
                        CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ],
                    ),
                  ),
                )
              : Container(),
          error
              ? RefreshIndicator(
                  key: refreshKey,
                  onRefresh: () async {
                    refreshKey.currentState?.show();
                    await Future.delayed(Duration(seconds: 2));
                    await webViewController.reload().then((value) {
                      setState(() {
                        this.state = 0;
                        this.error = false;
                      });
                    });
                  },
                  color: Theme.of(context).primaryColor,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(55, 71, 106, 1),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(height: 50),
                          Text(
                            "Error de conexion",
                            style: TextStyle(color: Colors.white),
                          ),
                          IconButton(
                              onPressed: () async {
                                refreshKey.currentState?.show();
                                await webViewController.reload().then((value) {
                                  setState(() {
                                    this.state = 0;
                                  });
                                });
                              },
                              icon: Icon(
                                Icons.refresh,
                                color: Colors.white,
                              )),
                        ],
                      ),
                    ),
                  ),
                )
              : Container()
        ],
      )),
    );
  }
}
