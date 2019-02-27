// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserResponse _$UserResponseFromJson(Map<String, dynamic> json) {
  return UserResponse(
      json['data'] == null
          ? null
          : Data.fromJson(json['data'] as Map<String, dynamic>),
      json['errorCode'] as int,
      json['errorMsg'] as String);
}

Map<String, dynamic> _$UserResponseToJson(UserResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
      'errorCode': instance.errorCode,
      'errorMsg': instance.errorMsg
    };

Data _$DataFromJson(Map<String, dynamic> json) {
  return Data(
      json['chapterTops'] as List,
      json['collectIds'] as List,
      json['email'] as String,
      json['icon'] as String,
      json['id'] as int,
      json['password'] as String,
      json['token'] as String,
      json['type'] as int,
      json['username'] as String);
}

Map<String, dynamic> _$DataToJson(Data instance) => <String, dynamic>{
      'chapterTops': instance.chapterTops,
      'collectIds': instance.collectIds,
      'email': instance.email,
      'icon': instance.icon,
      'id': instance.id,
      'password': instance.password,
      'token': instance.token,
      'type': instance.type,
      'username': instance.username
    };