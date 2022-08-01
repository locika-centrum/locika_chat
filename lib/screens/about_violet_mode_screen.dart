import 'package:flutter/material.dart';

class AboutVioletModeScreen extends StatelessWidget {
  const AboutVioletModeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Fialový režim'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Tady ti popíšeme tríček, jak se dostaneš z hry do fialového režimu...'),
            SizedBox(height: 16,),
            Text('Klikneš sem, přihlásíš se a jedeš :)'),
            SizedBox(height: 16,),
            Text('(tady to bude popsané)'),
          ],
        ),
      ),
    );
  }
}
