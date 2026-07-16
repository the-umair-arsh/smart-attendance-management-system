import 'package:flutter/material.dart';

class SmartReportStudent extends StatelessWidget {
  const SmartReportStudent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Smart Report")),
      body: const Center(child: Text("Student Monthly Summary")),
    );
  }
}
