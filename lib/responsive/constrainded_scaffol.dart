/* 

CONSTRAINED SCAFFOLD

This is a normal scaffold but the width is constrained so that it behaves consistenly on larger screens

*/

import 'package:flutter/material.dart';

class ConstraindedScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? drawer;
  const ConstraindedScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.drawer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      drawer: drawer,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 430),
          child: body,
        ),
      ),
    );
  }
}
