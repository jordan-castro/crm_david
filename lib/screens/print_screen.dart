import 'package:flutter/material.dart';

class PrintScreen extends StatefulWidget {
  static const routeName = "/print";

  const PrintScreen({super.key});

  @override
  State<PrintScreen> createState() => _PrintScreenState();
}

class _PrintScreenState extends State<PrintScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
    // return Scaffold(
    //   appBar: AppBar(
    //     title: const Text("Print"),
    //     backgroundColor: Colors.blue,
    //   ),
    //   body: Center(
    //     child: ,
    //   ),
    // );
  }
}
