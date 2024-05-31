import 'dart:io';

import 'package:firebase_ml_vision/firebase_ml_vision.dart' as firebase_ml;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRHomeView extends StatefulWidget {
  const QRHomeView({super.key});

  @override
  State<QRHomeView> createState() => _QRHomeViewState();
}

class _QRHomeViewState extends State<QRHomeView> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  // Barcode? result;
  firebase_ml.Barcode? result;
  QRViewController? controller;
  File? pickedImage;
  String? uploadedQRCodeData;

  @override
  void reassemble() {
    super.reassemble();
    controller!.pauseCamera();
    controller!.resumeCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> scanQR() async {
    setState(() {
      result = null; // Reset the result before scanning
    });
    final qrView = QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SizedBox(
          height: 300,
          width: 300,
          child: qrView,
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData as firebase_ml.Barcode?;
        Navigator.of(context).pop();
      });
    });
  }

  Future<void> pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        pickedImage = File(pickedFile.path);
      });
      await _scanImageForQR(pickedImage!);
      // You can implement QR code recognition from image if needed
    }
  }

  Future<void> _scanImageForQR(File imageFile) async {
    final firebase_ml. FirebaseVisionImage visionImage =
       firebase_ml. FirebaseVisionImage.fromFile(imageFile);
    final firebase_ml.BarcodeDetector barcodeDetector =
        firebase_ml.FirebaseVision.instance.barcodeDetector();
    final List<Barcode> barcodes =
        (await barcodeDetector.detectInImage(visionImage)).cast<Barcode>();

    if (barcodes.isNotEmpty) {
      setState(() {
        result = barcodes.first as firebase_ml.Barcode?;
      });
    } else {
      setState(() {
        result = null;
      });
      _showErrorDialog('No QR code found in the image');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> uploadQRCode() async {
    // final uri = Uri.parse('http://your-local-server/upload');
    // final request = http.MultipartRequest('POST', uri);

    // if (pickedImage != null) {
    //   request.files.add(await http.MultipartFile.fromPath('file', pickedImage!.path));
    // } else if (result != null) {
    //   request.fields['qr_data'] = result!.code!;
    // }

    // final response = await request.send();

    // if (response.statusCode == 200) {
    //   final responseData = await response.stream.bytesToString();
    //   setState(() {
    //     uploadedQRCodeData = responseData; // Assume server returns the new QR code data
    //   });
    // } else {
    //   // Handle the error
    // }
  }

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
            if (result != null) Text('Scanned QR Code: ${result!}'),
            if (pickedImage != null) Image.file(pickedImage!),
            if (uploadedQRCodeData != null)
              QrImageView(
                data: uploadedQRCodeData!,
                version: QrVersions.auto,
                size: 200.0,
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: scanQR,
              child: const Text('Scan QR Code'),
            ),
            ElevatedButton(
              onPressed: pickImageFromGallery,
              child: const Text('Pick QR Code from Gallery'),
            ),
            ElevatedButton(
              onPressed: uploadQRCode,
              child: const Text('Upload QR Code'),
            ),
          ],
        ),
      ),
    );
  }
}
