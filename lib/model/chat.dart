import 'package:flutter_pusher/model/user.dart';

class ChatModel {
  int id;
  String userId;
  String message;
  String createdAt;
  String updatedAt;
  UserModel user;

  ChatModel(
      {this.id, this.userId, this.message, this.createdAt, this.updatedAt});

  ChatModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    message = json['message'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    user = json['user']!= null? new UserModel.fromJson(json['user']):null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['message'] = this.message;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if(this.user != null){
      data['user'] = this.user.toJson();
    }
    return data;
  }
}
