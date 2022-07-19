import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';

import '../models/chat_response.dart';
import '../services/neziskovky_parser.dart';

Logger _log = Logger('RegisterScreen');

class RegisterScreen extends StatefulWidget {
  final String nextRoute;
  final Function setCookie;
  final Function setNick;

  const RegisterScreen({
    required this.nextRoute,
    required this.setCookie,
    required this.setNick,
    Key? key,
  }) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController _nickNameController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  bool _passwordVisible = false;
  String? _errorNick;
  String? _errorPassword;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text('Nová registrace'),
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
              errorText: this._errorNick,
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
              errorText: this._errorPassword,
            ),
          ),
          SizedBox(height: 24.0),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () {
                signUp(_nickNameController.text, _passwordController.text);
              },
              child: Text('Registruj se'),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              GoRouter.of(context).push('/login');
            },
            child: Text('Přihlásit se'),
          ),
        ],
      ),
    );
  }

  Future<void> signUp(String username, String password) async {
    ChatResponse result =
        await register(username: username, password: password);

    switch (result.statusCode) {
      case 200:
        this._errorNick = null;
        this._errorPassword = null;
        Navigator.pop(context);
        widget.setCookie(result.cookie);
        widget.setNick(username);

        GoRouter.of(context).push(widget.nextRoute);
        break;

      case 401:
        setState(() {
          if (result.message!.contains('existuje')) {
            this._errorNick = result.message;
            this._errorPassword = null;
          } else {
            this._errorNick = null;
            this._errorPassword = result.message;
          }
        });
        break;

      default:
        GoRouter.of(context).push('/network_error');
    }

    _log.finest('register: ${result.statusCode}');
    _log.finest('cookie: ${result.cookie}');
  }
}
