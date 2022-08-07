import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:locika_game_test/providers/app_settings.dart';

class HowItWorksDialog extends StatelessWidget {
  const HowItWorksDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  child: SvgPicture.asset('assets/images/sloth_02.svg',),
                  backgroundColor: Colors.white,
                ),
                Expanded(
                  child: Bubble(
                    nip: BubbleNip.leftBottom,
                    alignment: Alignment.topLeft,
                    color: Colors.grey.shade300,
                    child:
                        Text('Ahoj, nechceš zjistit, jak funguje fialový režim?'),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: ElevatedButton(
              onPressed: () {
                AppSettings().data.showVioletModeInfo = false;
                Navigator.pop(context);
                GoRouter.of(context).push('/about_violet_mode');
              },
              child: Text('Prozkoumat'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(35),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
