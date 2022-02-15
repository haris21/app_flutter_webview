import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NavigationContols extends StatelessWidget {
  const NavigationContols({Key? key, required this.controller})
      : super(key: key);
  final Completer<WebViewController> controller;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: controller.future,
      builder: (context, snapshot) {
        final WebViewController? controller = snapshot.data;
        if (snapshot.connectionState != ConnectionState.done ||
            controller == null) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const <Widget>[
              Icon(Icons.arrow_back),
              Icon(Icons.arrow_forward),
              Icon(Icons.replay),
            ],
          );
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              onPressed: () async {
                if (await controller.canGoBack()) {
                  await controller.goBack();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20.0),
                        ),
                      ),
                      content: Text(
                        'No back history iterm',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  );
                  return;
                }
              },
              icon: const Icon(Icons.arrow_back),
            ),
            IconButton(
              onPressed: () async {
                if (await controller.canGoForward()) {
                  await controller.goForward();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20.0),
                        ),
                      ),
                      content: Text(
                        'No forward history item',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  );
                  return;
                }
              },
              icon: const Icon(Icons.arrow_forward),
            ),
            IconButton(
              onPressed: () {
                controller.reload();
              },
              icon: const Icon(Icons.replay),
            ),
            const SizedBox(
              width: 10,
            ),
          ],
        );
      },
    );
  }
}
