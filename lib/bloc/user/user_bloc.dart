import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_pusher/model/user.dart';
import 'package:flutter_pusher/repository/api_repository.dart';
import 'package:meta/meta.dart';

part 'user_event.dart';
part 'user_state.dart';

UserRepository _repo = new UserRepository();

class UserBloc extends Bloc<UserEvent, UserState> {
  @override
  UserState get initialState => UserInitial();

  @override
  Stream<UserState> mapEventToState(
    UserEvent event,
  ) async* {
    if(event is UserLogin){
      yield* _login(event.model);
    }else if(event is UserRegistrasi){
      yield* _registrasi(event.model);
    }
  }
}

Stream<UserState> _login(model) async*{
  yield UserWaiting();
  try {
    UserModel user = await _repo.login(model: model);
    yield UserLoginSuccess(model: user);
  } catch (e) {
    yield UserError(message: e.toString());
  }
}
Stream<UserState> _registrasi(models) async*{
  try {
    int s = await _repo.registrasi(model: models);
    yield UserSuccess(message: s.toString());
  } catch (e) {
    yield UserError(message: e.toString());
  }
}