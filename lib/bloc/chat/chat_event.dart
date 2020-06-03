part of 'chat_bloc.dart';

@immutable
abstract class ChatEvent {}
class ChatFetch extends ChatEvent{
  final String token;
  ChatFetch({@required this.token});
}
class SendMessage extends ChatEvent{
  final String token;
  final String message;
  SendMessage({@required this.token,@required this.message});
}