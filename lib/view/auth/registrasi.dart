import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pusher/bloc/user/user_bloc.dart';
import 'package:flutter_pusher/model/user.dart';
import 'package:toast/toast.dart';

class Registrasi extends StatefulWidget {
  @override
  _RegistrasiState createState() => _RegistrasiState();
}

class _RegistrasiState extends State<Registrasi> {
  GlobalKey<FormState> _key = new GlobalKey<FormState>();
  String _email, _password,_name;
  UserBloc _bloc;

  
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
              if (state is UserSuccess) {
                Toast.show("Success", context,gravity: Toast.BOTTOM);
                Navigator.pop(context);
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
                    "Register",
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
                            _name = newValue;
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Required";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: "Name",
                            labelStyle: TextStyle(color: Colors.black),
                            border: border(),
                            enabledBorder: border(),
                            focusedBorder: border(),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top:30),
                          child: TextFormField(
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
                              if (value.length <6) {
                                return "Minimal 6 karakter";
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
                new UserModel(email: _email, password: _password,name: _name);
            print(userModel.name);
            _bloc.add(UserRegistrasi(model: userModel));
          }
        },
        child: Text("Register"),
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