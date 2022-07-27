import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../responsive_ui/two_sections_ui.dart';
import '../widgets/welcome_options.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Hraj s příšerou'),
      ),
      body: TwoSectionUI(
        firstSection: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 64),
          child: SvgPicture.asset('assets/images/monster_02.svg'),
        ),
        secondSection: WelcomeOptions(),
      ),
    );
  }
}
