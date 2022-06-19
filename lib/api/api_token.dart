import 'package:json_annotation/json_annotation.dart';

class UsersToken {
  final String token;

  UsersToken(this.token);

  factory UsersToken.fromJson(dynamic json) => UsersToken(json);
}

class UsersTokenConverter extends JsonConverter<UsersToken, String> {

  const UsersTokenConverter();

  @override
  UsersToken fromJson(String json) => UsersToken(json);

  @override
  String toJson(UsersToken object) => object.token;

}

class UserToken {
  final String token;

  UserToken(this.token);
}

class UserTokenConverter extends JsonConverter<UserToken, String> {

  const UserTokenConverter();

  @override
  UserToken fromJson(String json) => UserToken(json);

  @override
  String toJson(UserToken object) => object.token;
}
