import 'dart:io';
import 'dart:ui' as ui;

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share/share.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String qrData = '';
  File? selectedImage;
  final ImagePicker _picker = ImagePicker();
  final GlobalKey _globalKey = GlobalKey();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
      _extractQRCode();
    }
  }

 Future<void> _extractQRCode() async {
    if (selectedImage != null) {
      try {
        final ScanResult result = await BarcodeScanner.scan(options: const ScanOptions(
          restrictFormat: [BarcodeFormat.qr],
          useCamera: -1,
        ));
        setState(() {
          qrData = result.rawContent;
        });
      } catch (e) {
        if (kDebugMode) {
          print('Error decoding QR code: $e');
        }
        setState(() {
          qrData = 'Error decoding QR code';
        });
      }
    }
  }

  // Future<void> _shareQRCode() async {
  //   if (qrData.isNotEmpty) {
  //     try {
  //       RenderRepaintBoundary boundary =
  //           _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
  //       ui.Image image = await boundary.toImage();
  //       ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  //       if (byteData != null) {
  //         final buffer = byteData.buffer.asUint8List();

  //         final directory = (await getApplicationDocumentsDirectory()).path;
  //         final imgFile = File('$directory/qr_code.png');
  //         imgFile.writeAsBytesSync(buffer);

  //         Share.shareFiles([imgFile.path], text: 'Here is your QR code');
  //       }
  //     } catch (e) {
  //       print('Error sharing QR code: $e');
  //     }
  //   }
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Select QR Code Image'),
            ),
            const SizedBox(height: 20),
            if (qrData.isNotEmpty)
              QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 200.0,
              ),
            const SizedBox(height: 20),
            // if (qrData.isNotEmpty)
            //   ElevatedButton(
            //     onPressed: _shareQRCode,
            //     child: const Text('Share QR Code'),
            //   ),
          ],
        ),
      ),
    );
  }
}
