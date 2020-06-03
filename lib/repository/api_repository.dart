import 'package:flutter_pusher/model/user.dart';
import 'package:flutter_pusher/model/chat.dart';
import 'package:dio/dio.dart';

Dio dio = new Dio();
Response response;
String chatUri = "https://api-todo.mdcnugroho.xyz/api/chat";

class UserRepository {
  Future<UserModel> login({UserModel model}) async {
    FormData formData = new FormData.fromMap(
        {"email": model.email, "password": model.password});
    try {
      response = await dio.post(
          "https://api-todo.mdcnugroho.xyz/api/user/login",
          data: formData);
      var models = response.data;
      UserModel userModel = UserModel.fromJson(models);
      return userModel;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<int> registrasi({UserModel model}) async {
    try {
      FormData datas = FormData.fromMap({
        'name': model.name,
        'password': model.password,
        'email': model.email
      });
      response = await dio.post("https://api-todo.mdcnugroho.xyz/api/user",
          data: datas,
          options: Options(headers: {"Accept": "application/json"}));

      return response.statusCode;
    } catch (e) {
      throw Exception(e);
    }
  }
}

class ChatRepository {
  Future<List<ChatModel>> index({String token}) async {
    try {
      response = await dio.get(chatUri,
          options: Options(responseType: ResponseType.json, headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json"
          }));
      List list = response.data;
      List<ChatModel> chatModel =
          list.map((e) => ChatModel.fromJson(e)).toList();
      return chatModel;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<int> sendChat({String message, String token}) async {
    try {
      FormData formData = FormData.fromMap({"message": message});
      response = await dio.post(chatUri,
          data: formData,
          options: Options(responseType: ResponseType.json, headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json"
          }));
      return response.statusCode;
    } catch (e) {
      throw Exception(e);
    }
  }
}
