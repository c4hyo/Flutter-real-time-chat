import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_pusher/model/chat.dart';
import 'package:flutter_pusher/repository/api_repository.dart';
import 'package:meta/meta.dart';

part 'chat_event.dart';
part 'chat_state.dart';

ChatRepository _repository = new ChatRepository();

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  @override
  ChatState get initialState => ChatInitial();

  @override
  Stream<ChatState> mapEventToState(
    ChatEvent event,
  ) async* {
    if(event is ChatFetch){
      yield* _fetch(event.token);
    }else if(event is SendMessage){
      yield* _send(event.token,event.message);
    }
  }
}
Stream<ChatState> _fetch(token) async*{
  try {
    List<ChatModel> chat = await _repository.index(token: token);
    yield ChatLoad(model: chat);
  } catch (e) {
    yield ChatError(message: e.toString());
  }
}
Stream<ChatState> _send(token,message) async*{
  try {
    int s =  await _repository.sendChat(message: message,token:token);
    yield ChatSuccess(message: s.toString());
  } catch (e) {
    yield ChatError(message: e.toString());
  }
}