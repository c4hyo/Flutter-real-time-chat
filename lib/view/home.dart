import 'dart:convert';
import 'package:date_time_format/date_time_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pusher/bloc/chat/chat_bloc.dart';
import 'package:flutter_pusher/main.dart';
import 'package:flutter_pusher/model/user.dart';
import 'package:flutter_pusher/repository/api_repository.dart';
import 'package:pusher_websocket_flutter/pusher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final UserModel model;
  HomePage({this.model});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  _removeSession() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    setState(() {
      _pref.remove("token");
    });
  }

  _dialogLogout(){
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text("Logout"),
          children: <Widget>[
            SimpleDialogOption(
              child: Text("Yes"),
              onPressed: () {
                _removeSession();
                Pusher.disconnect();
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => Home()));
              },
            ),
            SimpleDialogOption(
              child: Text("No"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  GlobalKey<FormState> _key = GlobalKey<FormState>();
  ChatBloc _bloc;
  String _message;
  List _chatModel = [];
  Channel _channel;
  String _event = r"App\Events\MessageSent";
  _changeTime({String time}){
    final days = DateTime.parse(time);
    return DateTimeFormat.format(days,format:"D, d M Y, H:i:s");
  }
  ChatRepository _repo = new ChatRepository();
  @override
  void initState() {
    _bloc = BlocProvider.of<ChatBloc>(context);
    _bloc.add(ChatFetch(token: widget.model.apiToken));
    _initPusher();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Flutter Pusher Chat"),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () {
                _dialogLogout();
              })
        ],
      ),
      body: BlocListener<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatLoad) {
            setState(() {});
            for (int i = 0; i < state.model.length; i++) {
              setState(() {
                _chatModel.add({
                  "name": state.model[i].user.name,
                  "userId": state.model[i].userId,
                  "message": state.model[i].message,
                  "createdAt": state.model[i].createdAt
                });
              });
              // print(state.model[i]);
            }
          }
          if (state is ChatSuccess) {
            // _bloc.add(ChatFetch(token:widget.model.apiToken));
            setState(() {
              _message = '';
            });
          }
        },
        child: SafeArea(
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: Center(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: BlocBuilder<ChatBloc, ChatState>(
                      builder: (context, state) {
                        if (state is ChatInitial) {
                          return Center(
                            child: Text(state.toString()),
                          );
                        }
                        if (state is ChatLoad) {
                          return ListView.builder(
                            itemCount: _chatModel.length,
                            itemBuilder: (context, index) {
                              return (_chatModel.length == 0)
                                  ? Center(
                                      child: Text("Data null"),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: _chatModel[index]['userId'] ==
                                                widget.model.id.toString()
                                            ? _me(index)
                                            : _other(index),
                                      ),
                                    );
                            },
                          );
                        }
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    ),
                  ),
                  Container(
                    height: 75,
                    width: double.infinity,
                    color: Colors.grey[100],
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Form(
                            key: _key,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: TextFormField(
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                onSaved: (newValue) {
                                  _message = newValue;
                                },
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return "Tidak boleh kosong";
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.send),
                          onPressed: () {
                            if (_key.currentState.validate()) {
                              _key.currentState.save();
                              // _bloc.add(SendMessage(
                              //     message: _message,
                              //     token: widget.model.apiToken));
                              _repo.sendChat(
                                  message: _message,
                                  token: widget.model.apiToken);
                            }
                            setState(() {
                              _key.currentState.reset();
                            });
                          },
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Column _me(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            )
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  '${_chatModel[index]['message']}',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.all(10),
          child: Text(
            _changeTime(time: '${_chatModel[index]['createdAt']}'),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Column _other(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: Colors.amber[100],
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(20),
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            )
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  '${_chatModel[index]['name']}',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  '${_chatModel[index]['message']}',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.all(10),
          child: Text(
            _changeTime(time: '${_chatModel[index]['createdAt']}'),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Future<void> _initPusher() async {
    try {
      await Pusher.init("58e2f8fc06d0bd342705", PusherOptions(cluster: "ap1"));
    } catch (e) {
      throw Exception(e);
    }
    Pusher.connect(
      onConnectionStateChange: (state) {
        print(state.currentState);
      },
      onError: (err) {
        print(err.message);
      },
    );
    _channel = await Pusher.subscribe("chat");

    _channel.bind(_event, (eventBind) {
      if (mounted) {
        final data = json.decode(eventBind.data);
        print(data['user']['name']);
        setState(() {
          _chatModel.add({
            "name": data['user']['name'],
            "userId": data['message']['user_id'],
            "message": data['message']['message'],
            "createdAt": data['message']['created_at']
          });
        });
        print(_chatModel.length);
      }
    });
  }
}
