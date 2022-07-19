import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';

import '../models/chat_response.dart';
import '../services/neziskovky_parser.dart';

Logger _log = Logger('LoginScreen');

class LoginScreen extends StatefulWidget {
  final String nextRoute;
  final Function setCookie;
  final String? nickName;

  LoginScreen({
    required this.nextRoute,
    required this.setCookie,
    this.nickName,
    Key? key,
  }) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _nickNameController;
  bool _isValidForm = true;
  TextEditingController _passwordController = new TextEditingController();
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    _nickNameController =
        new TextEditingController(text: widget.nickName ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text('Přihlásit se'),
        elevation: 0,
      ),
      body: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.only(left: 24.0, right: 24.0),
        children: [
          SizedBox(height: 48.0),
          SafeArea(
            child: SvgPicture.asset('assets/images/centrum-locika-logo.svg'),
          ),
          SizedBox(height: 48.0),
          TextField(
            controller: _nickNameController,
            autofocus: false,
            decoration: InputDecoration(
              hintText: 'Přezdívka',
              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
            ),
          ),
          SizedBox(height: 8.0),
          TextField(
            controller: _passwordController,
            autofocus: false,
            obscureText: !this._passwordVisible,
            decoration: InputDecoration(
              hintText: 'Heslo',
              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
              errorText:
                  this._isValidForm ? null : 'Chybné heslo nebo přezdívka',
              suffixIcon: IconButton(
                icon: Icon(this._passwordVisible
                    ? Icons.visibility
                    : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    this._passwordVisible = !this._passwordVisible;
                  });
                },
              ),
            ),
          ),
          SizedBox(height: 24.0),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () {
                signIn(_nickNameController.text, _passwordController.text);
              },
              child: Text('Přihlásit se'),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              GoRouter.of(context).push('/register');
            },
            child: Text('Registruj se'),
          ),
        ],
      ),
    );
  }

  Future<void> signIn(String username, String password) async {
    ChatResponse result =
        await authenticate(username: username, password: password);

    switch (result.statusCode) {
      case 200:
        this._isValidForm = true;
        Navigator.pop(context);
        widget.setCookie(result.cookie);

        GoRouter.of(context).push(widget.nextRoute);
        break;

      case 401:
        setState(() {
          this._isValidForm = false;
        });
        break;

      default:
        GoRouter.of(context).push('/network_error');
    }

    _log.finest('login: ${result.statusCode}');
    _log.finest('cookie: ${result.cookie}');
  }
}
