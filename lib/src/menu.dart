import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Add from here ...
const String kExamplePage = '''
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
// ... to here.

enum _MenuOptions {
  navigationDelegate,
  listCookies,
  clearCookies,
  addCookie,
  setCookie,
  removeCookie,
  // Add from here ...
  loadFlutterAsset,
  loadLocalFile,
  loadHtmlString,
  // ... to here.

}

class Menu extends StatefulWidget {
  const Menu({required this.controller, super.key});

  final Completer<WebViewController> controller;

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  final CookieManager cookieManager = CookieManager();
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
              case _MenuOptions.clearCookies:
                _onClearCookies();
                break;
              case _MenuOptions.listCookies:
                _onListCookies(controller.data!);
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
              // Add from here ...
              case _MenuOptions.loadFlutterAsset:
                _onLoadFlutterAssetExample(controller.data!, context);
                break;
              case _MenuOptions.loadLocalFile:
                _onLoadLocalFileExample(controller.data!, context);
                break;
              case _MenuOptions.loadHtmlString:
                _onLoadHtmlStringExample(controller.data!, context);
                break;
              // ... to here.

            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem<_MenuOptions>(
              value: _MenuOptions.navigationDelegate,
              child: Text('Navigate to YouTube'),
            ),
            const PopupMenuItem<_MenuOptions>(
              value: _MenuOptions.clearCookies,
              child: Text('Clear cookies'),
            ),
            const PopupMenuItem<_MenuOptions>(
              value: _MenuOptions.listCookies,
              child: Text('List cookies'),
            ),
            const PopupMenuItem<_MenuOptions>(
              value: _MenuOptions.addCookie,
              child: Text('Add cookie'),
            ),
            const PopupMenuItem<_MenuOptions>(
              value: _MenuOptions.setCookie,
              child: Text('Set cookie'),
            ),
            const PopupMenuItem<_MenuOptions>(
              value: _MenuOptions.removeCookie,
              child: Text('Remove cookie'),
            ),
            // Add from here ...
            const PopupMenuItem<_MenuOptions>(
              value: _MenuOptions.loadFlutterAsset,
              child: Text('Load Flutter Asset'),
            ),
            const PopupMenuItem<_MenuOptions>(
              value: _MenuOptions.loadHtmlString,
              child: Text('Load HTML string'),
            ),
            const PopupMenuItem<_MenuOptions>(
              value: _MenuOptions.loadLocalFile,
              child: Text('Load local file'),
            ),
            // ... to here.
          ],
        );
      },
    );
  }

// Fungsi menampilkan list cookie
  Future<void> _onListCookies(WebViewController controller) async {
    final String cookies =
        await controller.runJavascriptReturningResult('document.cookie');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(cookies.isNotEmpty ? cookies : 'There are no cookies.'),
      ),
    );
  }

// Fungsi mengahapus semua cookie
  Future<void> _onClearCookies() async {
    final hadCookies = await cookieManager.clearCookies();
    String message = 'There were cookies. Now, they are gone!';
    if (!hadCookies) {
      message = 'There were no cookies to clear.';
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

// Fungsi menambahkan cookie
  Future<void> _onAddCookie(WebViewController controller) async {
    await controller.runJavascript('''var date = new Date();
  date.setTime(date.getTime()+(30*24*60*60*1000));
  document.cookie = "FirstName=John; expires=" + date.toGMTString();''');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Custom cookie added.'),
      ),
    );
  }

//  Fungsi mengaktifkan cookie kembali
  Future<void> _onSetCookie(WebViewController controller) async {
    await cookieManager.setCookie(
      const WebViewCookie(name: 'foo', value: 'bar', domain: 'flutter.dev'),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Custom cookie is set.'),
      ),
    );
  }

// Fungsi menghapus/menonaktifkan cookie
  Future<void> _onRemoveCookie(WebViewController controller) async {
    await controller.runJavascript(
        'document.cookie="FirstName=John; expires=Thu, 01 Jan 1970 00:00:00 UTC" ');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Custom cookie removed.'),
      ),
    );
  }

  // Fungsi memuat HTML melalui file assets
  Future<void> _onLoadFlutterAssetExample(
      WebViewController controller, BuildContext context) async {
    await controller.loadFlutterAsset('assets/www/index.html');
  }

  //Fungsi memuat HTML melalui file lokal(temporary)
  Future<void> _onLoadLocalFileExample(
      WebViewController controller, BuildContext context) async {
    final String pathToIndex = await _prepareLocalFile();

    await controller.loadFile(pathToIndex);
  }

  // Fungsi menyiapkan file lokal dengan bantuan plugin pat_provider dan dart:io
  static Future<String> _prepareLocalFile() async {
    final String tmpDir = (await getTemporaryDirectory()).path;
    final File indexFile = File('$tmpDir/www/index.html');

    await Directory('$tmpDir/www').create(recursive: true);
    await indexFile.writeAsString(kExamplePage);

    return indexFile.path;
  }

  // Fungsi memuat HTML melalui variabel string
  Future<void> _onLoadHtmlStringExample(
      WebViewController controller, BuildContext context) async {
    await controller.loadHtmlString(kExamplePage);
  }
}
