part of 'chat_bloc.dart';

@immutable
abstract class ChatState {}

class ChatInitial extends ChatState {}
class ChatLoad extends ChatState{
  final List<ChatModel> model;
  ChatLoad({this.model});
}
class ChatSuccess extends ChatState{
  final String message;
  ChatSuccess({this.message});
}
class ChatError extends ChatState{
  final String message;
  ChatError({this.message});
}