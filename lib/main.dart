import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pusher/bloc/chat/chat_bloc.dart';
import 'package:flutter_pusher/bloc/user/user_bloc.dart';
import 'package:flutter_pusher/model/user.dart';
import 'package:flutter_pusher/view/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'view/auth/login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<UserBloc>(
          create: (context) => UserBloc(),
        ),
        BlocProvider<ChatBloc>(
          create: (context) => ChatBloc(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.blueGrey[100],
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Home(),
      ),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _token, _name, _id;
  UserModel models;
  _cekSession() async {
    SharedPreferences _p = await SharedPreferences.getInstance();
    setState(() {
      _token = _p.getString("token") ?? null;
      _name = _p.getString("name") ?? null;
      _id = _p.getString("id") ?? null;
      models = UserModel(apiToken: _token, id: int.parse(_id), name: _name);
    });
  }

  @override
  void initState() {
    _cekSession();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return (_token == null)
        ? LoginPage()
        : HomePage(
          model: models,
        );
  }
}
