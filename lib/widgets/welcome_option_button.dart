import 'package:flutter/material.dart';

class WelcomeOptionButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final Function routeToMain;

  WelcomeOptionButton({
    Key? key,
    required this.routeToMain,
    this.title = '',
    this.subtitle = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            routeToMain();
          },
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 16,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        this.title,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(this.subtitle),
                    ],
                  ),
                  Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
      ],
    );
  }
}
