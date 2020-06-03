import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pusher/bloc/user/user_bloc.dart';
import 'package:flutter_pusher/model/user.dart';
import 'package:flutter_pusher/view/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:flutter_pusher/view/auth/registrasi.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  GlobalKey<FormState> _key = new GlobalKey<FormState>();
  String _email, _password;
  UserBloc _bloc;

  _session({String token,String name,int id}) async{
    SharedPreferences _pref = await SharedPreferences.getInstance();
    setState(() {
      _pref.setString("token", token);
      _pref.setString("name", name);
      _pref.setString("id", id.toString());
    });
  }
  
  @override
  void initState() {
    _bloc = BlocProvider.of<UserBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: BlocListener<UserBloc, UserState>(
            listener: (context, state) {
              if (state is UserLoginSuccess) {
                _session(
                  id: state.model.id,
                  token: state.model.apiToken,
                  name: state.model.name
                );
                UserModel models = UserModel(
                  id: state.model.id,
                  apiToken: state.model.apiToken,
                  name: state.model.name
                );
                Toast.show("Success", context, gravity: Toast.BOTTOM);
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => HomePage(
                      model: models,
                    )));
              }
              if (state is UserError) {
                Toast.show("Error", context, gravity: Toast.BOTTOM);
              }
            },
            child: Column(
              children: <Widget>[
                Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.blue[100],
                  child: Center(
                      child: Text(
                    "Login",
                    style: TextStyle(fontSize: 30),
                  )),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _key,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          onSaved: (newValue) {
                            _email = newValue;
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Required";
                            }
                            if (!EmailValidator.validate(value)) {
                              return "Invalid email format";
                            }
                            return null;
                          },
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: "Email",
                            labelStyle: TextStyle(color: Colors.black),
                            border: border(),
                            enabledBorder: border(),
                            focusedBorder: border(),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: TextFormField(
                            onSaved: (newValue) {
                              _password = newValue;
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return "Required";
                              }

                              return null;
                            },
                            keyboardType: TextInputType.emailAddress,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: "Password",
                              labelStyle: TextStyle(color: Colors.black),
                              border: border(),
                              enabledBorder: border(),
                              focusedBorder: border(),
                            ),
                          ),
                        ),
                        BlocBuilder<UserBloc, UserState>(
                          builder: (context, state) {
                            if (state is UserInitial) {
                              return _loginButton();
                            }
                            if (state is UserLoginSuccess) {
                              return _loginButton();
                            }
                            if (state is UserSuccess) {
                              return _loginButton();
                            }
                            if (state is UserError) {
                              return Column(
                                children: <Widget>[
                                  _loginButton(),
                                  Text(state.message)
                                ],
                              );
                            }
                            if (state is UserWaiting) {
                              return _loading();
                            }
                            return _loginButton();
                          },
                        ),
                        Padding(
                          padding: EdgeInsets.all(20),
                          child: InkWell(
                            child: Text("Registrasi"),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_)=>Registrasi()));
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Padding _loading() {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: MaterialButton(
        color: Colors.blue[100],
        height: 60,
        minWidth: 200,
        onPressed: () {
          print("login");
        },
        child: CircularProgressIndicator(),
      ),
    );
  }

  Padding _loginButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: MaterialButton(
        color: Colors.blue[100],
        height: 60,
        minWidth: 200,
        onPressed: () {
          if (_key.currentState.validate()) {
            _key.currentState.save();
            UserModel userModel =
                new UserModel(email: _email, password: _password);
            _bloc.add(UserLogin(model: userModel));
          }
        },
        child: Text("Login"),
      ),
    );
  }

  UnderlineInputBorder border() {
    return UnderlineInputBorder(
      borderSide:
          BorderSide(color: Colors.black, style: BorderStyle.solid, width: 5),
    );
  }
}
