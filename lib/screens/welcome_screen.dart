import 'package:flutter/material.dart';

import '../responsive_ui/two_sections_ui.dart';
import '../widgets/welcome_options.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Naše supr hra'),
      ),
      body: const TwoSectionUI(
        firstSection: Text('logo'),
        secondSection: WelcomeOptions(),
      ),
    );
  }
}
