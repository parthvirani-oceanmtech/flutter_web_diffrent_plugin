import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_web_diffrent_plugin/lifecycle_event_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(true);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TemplateHome(),
    );
  }
}

class TemplateHome extends StatelessWidget {
  const TemplateHome({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Template Home")),
      body: Center(
        child: ElevatedButton(
          child: Text("Open Template"),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => MyHomePage(title: 'Template Home')));
          },
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  InAppWebViewSettings options = InAppWebViewSettings(
    useShouldOverrideUrlLoading: true,
    mediaPlaybackRequiresUserGesture: false,
    useOnDownloadStart: true,
    useHybridComposition: true,
    allowsInlineMediaPlayback: true,
    javaScriptEnabled: true,
  );

  late PullToRefreshController pullToRefreshController;
  String url = "";
  double progress = 0;
  final urlController = TextEditingController();
  bool isMounted = true;
  bool isProdView = false;

  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    pullToRefreshController = PullToRefreshController(
      settings: PullToRefreshSettings(),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
  }

  @override
  void dispose() {
    isMounted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Future.delayed(Duration.zero, () {
    //   // WidgetsBinding.instance.handlePointerEvent(PointerUpEvent(
    //   //   pointer: 0,
    //   //   position: Offset(100, 100),
    //   // ));
    //   focusNode.requestFocus(FocusNode());
    // });

    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          // TextField(focusNode: focusNode),
          Expanded(
            child: Center(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  print('This will click');
                },
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.80,
                  width: MediaQuery.of(context).size.width,
                  child: InAppWebView(
                    key: webViewKey,
                    initialUrlRequest: URLRequest(
                      url: WebUri(
                        "https://dmt-template.oceanmtechrnd.com/templat?templete_id=69&unique_id=b04d87e16f4b4efd&user_id=937729&env=dev",
                      ),
                    ),
                    initialSettings: options,
                    pullToRefreshController: pullToRefreshController,
                    onWebViewCreated: (controller) {
                      webViewController = controller;
                    },
                    onLoadStart: (controller, url) {
                      setState(() {
                        this.url = url.toString();
                        urlController.text = this.url;
                      });
                    },
                    onPermissionRequest: (controller, permissionRequest) async {
                      return PermissionResponse(
                        resources: [PermissionResourceType.CAMERA],
                        action: PermissionResponseAction.GRANT,
                      );
                    },
                    shouldOverrideUrlLoading: (controller, navigationAction) async {
                      var uri = navigationAction.request.url!;

                      return NavigationActionPolicy.ALLOW;
                    },
                    onLoadStop: (controller, url) async {
                      pullToRefreshController.endRefreshing();
                      setState(() {
                        this.url = url.toString();
                        urlController.text = this.url;
                      });
                    },
                    onReceivedError: (controller, url, error) {
                      pullToRefreshController.endRefreshing();
                    },
                    onProgressChanged: (controller, progress) {
                      if (progress == 100) {
                        pullToRefreshController.endRefreshing();

                        try {
                          WidgetsBinding.instance.handlePointerEvent(const PointerDownEvent(
                            pointer: 0,
                            position: Offset(150, 150),
                          ));
                          WidgetsBinding.instance
                              .handlePointerEvent(const PointerUpEvent(pointer: 0, position: Offset(150, 150)));
                        } on Exception {}
                      }
                      setState(() {
                        this.progress = progress / 100;
                        urlController.text = url;
                      });
                    },
                    onUpdateVisitedHistory: (controller, url, androidIsReload) {
                      setState(() {
                        this.url = url.toString();
                        urlController.text = this.url;
                      });
                    },
                    onDownloadStartRequest: (controller, url) async {
                      print(url);
                    },
                    onConsoleMessage: (controller, consoleMessage) async {
                      if (consoleMessage.message.toString() == "textbox") {}
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
