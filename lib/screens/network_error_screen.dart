import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class NetworkErrorScreen extends StatelessWidget {
  const NetworkErrorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text('Něco se nepovedlo'),
        elevation: 0,
      ),
      body: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.only(left: 24.0, right: 24.0),
        children: [
          SvgPicture.asset('assets/images/ErrorRobot.svg'),
          SizedBox(height: 48.0),
          Text(
              'Nepodařilo se mi spojit se serverem. Zkontroluj připojení k internetu nebo to zkus později.'),
        ],
      ),
    );
  }
}
