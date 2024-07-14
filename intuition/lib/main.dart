
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Intution',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Scan QR Codes ! '),
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
  final GlobalKey qrkey = GlobalKey(debugLabel: "QR");
  Barcode? result;
  QRViewController? controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
              flex: 5,
              child: QRView(key: qrkey, onQRViewCreated: _onQRViewCreated)),
          Expanded(
              flex: 1,
              child: Center(
                child: (result != null)
                    ? Text("BarCode data: ${result!.code}")
                    : const Text("Scan a code"),
              )
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        controller.pauseCamera();
        showDialog(
          context: context,
          builder: (context){
            return AlertDialog(
              title: const Text('Open'),
              icon: const Icon(Icons.announcement),
              shadowColor: Colors.grey,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)
              ),
              content: Text("Link: ${result!.code}"),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      controller.resumeCamera();
                    },
                    child: const Text('Cancel')
                ),
                TextButton(
                    onPressed: () {
                      _launchInBrowser(result!.code.toString());
                      Navigator.pop(context);
                      controller.resumeCamera();
                    },
                    child: const Text('Open')
                ),
              ],
            );
          },
        );
      });
    });
  }

  void _launchInBrowser(String string) async {
    await launchUrl(Uri.parse(string));
  }
}
