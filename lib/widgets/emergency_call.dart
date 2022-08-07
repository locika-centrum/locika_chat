import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class EmergencyCallWidget extends StatelessWidget {
  const EmergencyCallWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0),
      child: Center(
        child: GestureDetector(
          onTap: () async {
            // Call
            // await FlutterPhoneDirectCaller.callNumber('#99');
            showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: Text('V O L Á M'),
                  content: Text('No tedy ještě ne - páč na 112 se mi ještě volat nechce'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'Cancel'),
                      child: const Text('Zrušit'),
                    ),
                  ],
                ));
          },
          child: Text(
            'Volat 112',
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
        ),
      ),
    );
  }
}
