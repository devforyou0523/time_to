import 'package:flutter/material.dart';

import '../widgets/svg_with_shadow.dart';

class FocusTimerPage extends StatelessWidget {
  const FocusTimerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          svgWithShadow(assetName: "assets/images/focus.svg"),
          SizedBox(height: 16),
          Text('집중 타이머', style: TextStyle(fontSize: 24)),
          SizedBox(height: 8),
          Text('여기에 집중 타이머 UI를 구현하세요.'),
        ],
      ),
    );
  }
}
