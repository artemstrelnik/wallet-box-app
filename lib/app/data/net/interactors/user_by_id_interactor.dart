import 'dart:convert';
import 'dart:core';
import 'dart:io';


import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wallet_box/app/data/net/models/permissions_response.dart';
import 'package:wallet_box/app/data/net/models/user_registration_model.dart';

import '../api.dart';

class UserByIdInteractor {
  Future<File> writeToFile(ByteData data, String name) async {
    final dbBytes = await rootBundle.load('assets/file'); // <= your ByteData
    final buffer = data.buffer;
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    var filePath =
        tempPath + '/file_01.tmp'; // file_01.tmp is dump file, can be anything
    return new File(filePath).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  Future<String?> csv(
      {required Map<String, String> body, required String token}) async {
    try {
      late File file;
      await Session().setToken(token: token);
      String _t = "/api/v1/user/export";

      var response = await Session().generalRequest(
        url: _t,
        body: body,
      );
      if (response.statusCode == 200) {
        Directory tempDir = await getTemporaryDirectory();
        String tempPath = tempDir.path;
        var filePath =
            tempPath + '/wallet_box_${body["start"]}_${body["end"]}.csv';
        file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      }
      return null;
    } catch (ex) {
      return null;
    }
  }

  Future<RolePermissonsResponse?> permissionsForRole(
      {required Map<String, String> body, required String token}) async {
    try {
      await Session().setToken(token: token);
      String _t = "/api/v1/user-role/permission/role/" + body["roleId"]!;
      var response = await Session().generalRequestGet(
        url: _t,
        queryParameters: {},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final RolePermissonsResponse _result =
            RolePermissonsResponse.fromJson(data);
        return _result;
      }
      return null;
    } catch (ex) {
      return null;
    }
  }

  Future<UserRegistrationModel?> execute(
      {required Map<String, String> body, required String token}) async {
    try {
      await Session().setToken(token: token);
      String _t = "/api/v1/user/" + body["id"]!;
      var response = await Session().generalRequestGet(
        url: _t,
        queryParameters: {},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        Logger().i(data.toString());
        final UserRegistrationModel _result =
            UserRegistrationModel.fromJson(data);
        return _result;
      }
      return null;
    } catch (ex) {
      return null;
    }
  }

  Future<bool?> cleanData({required Map<String, String> body}) async {
    try {
      String _t = "/api/v1/user/clean";
      var response = await Session().generalPatchRequest(
        url: _t,
        body: body,
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return true;
      }
      return null;
    } catch (ex) {
      return null;
    }
  }
}
