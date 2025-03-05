import 'package:flutter/material.dart';
import 'package:patrol_track_mobile/pages/report/report.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class Scanner extends StatefulWidget {
  @override
  _ScannerState createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  bool _flashOn = false;
  bool _frontCam = false;
  GlobalKey _qrKey = GlobalKey();
  QRViewController? _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          QRView(
            key: _qrKey,
            overlay: QrScannerOverlayShape(
              borderColor: Colors.white,
              borderRadius: 5,
            ),
            onQRViewCreated: _onQRViewCreated,
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 60),
              child: const Text(
                "Patrol Track",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ButtonBar(
              alignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                IconButton(
                  onPressed: () async {
                    setState(() {
                      _flashOn = !_flashOn;
                    });
                    await _controller?.toggleFlash();
                  },
                  icon: Icon(_flashOn ? Icons.flash_on : Icons.flash_off),
                  color: Colors.white,
                ),
                IconButton(
                  onPressed: () async {
                    await _controller?.flipCamera();
                    setState(() {});
                  },
                  icon:
                      Icon(_frontCam ? Icons.camera_front : Icons.camera_rear),
                  color: Colors.white,
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close),
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this._controller = controller;
    controller.scannedDataStream.listen((Barcode barcode) async {
      await controller.pauseCamera();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ReportPage(scanResult: barcode.code ?? 'No data found'),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}