part of 'user_bloc.dart';

@immutable
abstract class UserEvent {}

class UserLogin extends UserEvent{
  final UserModel model;
  UserLogin({@required this.model});
}
class UserRegistrasi extends UserEvent{
  final UserModel model;
  UserRegistrasi({@required this.model});
}
