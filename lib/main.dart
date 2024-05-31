import 'package:flutter/material.dart';
import 'package:qrcodefromimage/home.dart';
import 'package:qrcodefromimage/qr.dart';

void main() {
  runApp(const QRCodeApp());
}

class QRCodeApp extends StatelessWidget {
  const QRCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Code App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const QRHomeView(),
    );
  }
}

