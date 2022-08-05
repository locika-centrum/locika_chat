import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final Future<PackageInfo> packageInfo = PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('O aplikaci'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder:
                  (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
                if (snapshot.hasData) {
                  return Text(
                      '${snapshot.data!.appName} ${snapshot.data!.version} (build ${snapshot.data!.buildNumber})');
                } else {
                  return Container();
                }
              },
            ),
            SizedBox(height: 8),
            Text('Neuvěřitelně duchaplný text ...'),
          ],
        ),
      ),
    );
  }
}
