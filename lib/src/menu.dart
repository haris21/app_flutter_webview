import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

const String kExamaplePage = '''
<!DOCTYPE html>
<html lang="en">
<head>
       <title>Load file or HTML string example</title>
</head>
<body>
    <h1>Local demo page</h1>
    <p>
        This is an example page used to demonstrate how to load a local file or HTML
        string using the <a href="https://pub.dev/packages/webview_flutter">Flutter
        webview</a> plugin.
       </p>
       
</body>
</html>
''';

enum _MenuOptions {
  navigationDelegate,
  userAgent,
  javascripChannel,

  listCookies,
  clearCookies,
  addCookie,
  setCookie,
  removeCookie,

  loadFlutterAsset,
  loadLocalFile,
  loadHtmlString,
}

class Menu extends StatefulWidget {
  const Menu({Key? key, required this.controller}) : super(key: key);

  final Completer<WebViewController> controller;

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  final CookieManager cookieManager = CookieManager();

  Future<void> _onListCookies(WebViewController controller) async {
    final String cookies =
        await controller.runJavascriptReturningResult('document.cookie');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(cookies.isNotEmpty ? cookies : 'There no cookies'),
      ),
    );
  }

  Future<void> _onClearCookies() async {
    final hadCookies = await cookieManager.clearCookies();
    String message = 'There were cookies. Now, they ara gone!';
    if (!hadCookies) {
      message = 'There were no cookies no clear';
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Future<void> _onAddCookie(WebViewController controller) async {
    await controller.runJavascript('''
    var date=new Date();
    date.setTime(date.getTime()+(30*24*60*60*1000));
    document.cookie='FirstName=John;Expires='+date.toGMTString();''');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Custom cookie added'),
      ),
    );
  }

  Future<void> _onSetCookie(WebViewController controller) async {
    await cookieManager.setCookie(
      const WebViewCookie(name: 'foo', value: 'bar', domain: 'flutter.dev'),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Custom cookie is set'),
      ),
    );
  }

  Future<void> _onRemoveCookie(WebViewController controller) async {
    await controller.runJavascript(
        'document.cookie="FirstName=John; Expires=Thu, 01 Jan 1970 00:00:00 UTC');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Custom Cookie removed.'),
      ),
    );
  }

  Future<void> _onLoadFlutterAssetsExample(
      WebViewController controller, BuildContext context) async {
    await controller.loadFlutterAsset('assets/www/index.html');
  }

  Future<void> _onLoadLocalExample(
      WebViewController controller, BuildContext context) async {
    final String pathToIndex = await _prepareLocalFile();

    await controller.loadFile(pathToIndex);
  }

  static Future<String> _prepareLocalFile() async {
    final String tmpDir = (await getTemporaryDirectory()).path;
    final File indexFile = File('$tmpDir/www/index.html');

    await Directory('$tmpDir/www').create(recursive: true);
    await indexFile.writeAsString(kExamaplePage);

    return indexFile.path;
  }

  Future<void> _onLoadHtmlStringExample(
      WebViewController controller, BuildContext context) async {
    await controller.loadHtmlString(kExamaplePage);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: widget.controller.future,
      builder: (context, controller) {
        return PopupMenuButton<_MenuOptions>(
          onSelected: (value) async {
            switch (value) {
              case _MenuOptions.navigationDelegate:
                controller.data!.loadUrl('https://youtube.com');
                break;

              case _MenuOptions.userAgent:
                final userAgent = await controller.data!
                    .runJavascriptReturningResult('navigator.userAgent');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      userAgent,
                    ),
                  ),
                );
                break;
              case _MenuOptions.javascripChannel:
                await controller.data!.runJavascript('''
                var req = new XMLHttpRequest();
                req.open('GET', "https://api.ipify.org/?format=json");
                req.onload=function(){
                  if(req.status==200){
                    let response=JSON.parse(req.responseText);
                    SnackBar.postMessage('IP Adrress : " +response.ip);
                  }else{
                    SnackBar.postMessage('Error :' +req.status);
                  }
                }
                req.send();''');
                break;
              case _MenuOptions.listCookies:
                _onListCookies(controller.data!);
                break;
              case _MenuOptions.clearCookies:
                _onClearCookies();
                break;
              case _MenuOptions.addCookie:
                _onAddCookie(controller.data!);
                break;
              case _MenuOptions.setCookie:
                _onSetCookie(controller.data!);
                break;
              case _MenuOptions.removeCookie:
                _onRemoveCookie(controller.data!);
                break;
              case _MenuOptions.loadFlutterAsset:
                _onLoadFlutterAssetsExample(controller.data!, context);
                break;
              case _MenuOptions.loadLocalFile:
                _onLoadLocalExample(controller.data!, context);
                break;
              case _MenuOptions.loadHtmlString:
                _onLoadHtmlStringExample(controller.data!, context);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem<_MenuOptions>(
              value: _MenuOptions.navigationDelegate,
              child: Text('Navigate to Youtube'),
            ),
            const PopupMenuItem<_MenuOptions>(
              value: _MenuOptions.userAgent,
              child: Text('Show User Agent'),
            ),
            const PopupMenuItem<_MenuOptions>(
              value: _MenuOptions.javascripChannel,
              child: Text('LookUp IP Address'),
            ),
            const PopupMenuItem<_MenuOptions>(
              value: _MenuOptions.clearCookies,
              child: Text('Clear cookies'),
            ),
            const PopupMenuItem(
              value: _MenuOptions.listCookies,
              child: Text('List cookies'),
            ),
            const PopupMenuItem(
              value: _MenuOptions.addCookie,
              child: Text('Add cookie'),
            ),
            const PopupMenuItem(
              value: _MenuOptions.setCookie,
              child: Text('Set cookie'),
            ),
            const PopupMenuItem(
              value: _MenuOptions.removeCookie,
              child: Text('Remove cookies'),
            ),
            const PopupMenuItem<_MenuOptions>(
              value: _MenuOptions.loadFlutterAsset,
              child: Text('Load HTML Asset'),
            ),
            const PopupMenuItem(
              value: _MenuOptions.loadHtmlString,
              child: Text('Load HTML String'),
            ),
            const PopupMenuItem(
              child: Text('Load Local File'),
              value: _MenuOptions.loadLocalFile,
            )
          ],
        );
      },
    );
  }
}
