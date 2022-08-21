import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:logger/logger.dart';
import 'package:wallet_box/app/data/net/models/permission_role_provider.dart';
import 'package:http_parser/http_parser.dart';

bool trustSelfSigned = true;
HttpClient httpClient = HttpClient()
  ..badCertificateCallback =
      (X509Certificate cert, String host, int port) => trustSelfSigned;
IOClient ioClient = IOClient(httpClient);

class Session {
  static final Session _singleton = Session._internal();

  factory Session() {
    return _singleton;
  }

  Session._internal();

  late ShowAlertProvider _alert;

  Map<String, String> headers = {
    //"Accept-Language": "*",
    "accept": "*/*",
    "Content-Type": "application/json",
  };

  final String _baseUrl = 'api.wallet-box.ru';

  Future<void> setAlertProvider({required ShowAlertProvider alert}) async {
    _alert = alert;
  }

  Future<void> setToken({required String token}) async {
    headers["Authorization"] = "Bearer " + token;
  }

  Future<void> removeToken() async {
    headers.remove("Authorization");
  }

  Future<Response> authCheckRegister({
    required Map<String, Object> body,
  }) async {
    final Uri uri = Uri.https(
      _baseUrl,
      "/api/v1/auth/check-register",
    );

    Response response = await ioClient.post(
      uri,
      headers: headers,
      body: jsonEncode(body).replaceAll('\\', ''),
    );

    Logger().d("""Тип запроса: Post
    Ссылка: ${uri.toString()}
    Тело запроса: ${body.toString()}
    Код ответа: ${response.statusCode}
    """);

    if (response.statusCode == 502) {
      _alert.setError =
          "В работе приложения произошла ошибка,\nмы уже работает над ее устранением!";
    }

    return response;
  }

  Future<Response> userAuth({
    required Map<String, Object> body,
  }) async {
    final Uri uri = Uri.https(
      _baseUrl,
      "/api/v1/auth/",
    );

    Response response = await ioClient.post(
      uri,
      headers: headers,
      body: jsonEncode(body).replaceAll('\\', ''),
    );

    Logger().i(response.body.toString());

    Logger().d("""Тип запроса: Post
    Ссылка: ${uri.toString()}
    Тело запроса: ${body.toString()}
    Код ответа: ${response.statusCode}
    """);

    if (response.statusCode == 502) {
      _alert.setError =
          "В работе приложения произошла ошибка,\nмы уже работает над ее устранением!";
    }
    return response;
  }

  Future<Response> smsSubmit({
    required Map<String, Object> body,
  }) async {
    final Uri uri = Uri.https(
      _baseUrl,
      "/api/v1/auth/sms-submit",
    );

    Response response = await ioClient.post(
      uri,
      headers: headers,
      body: jsonEncode(body).replaceAll('\\', ''),
    );

    Logger().d("""Тип запроса: Post
    Ссылка: ${uri.toString()}
    Тело запроса: ${body.toString()}
    Код ответа: ${response.statusCode}
    """);

    if (response.statusCode == 502) {
      _alert.setError =
          "В работе приложения произошла ошибка,\nмы уже работает над ее устранением!";
    }
    return response;
  }

  Future<Response> smsSubmitResult({
    required Map<String, Object> body,
  }) async {
    final Uri uri = Uri.https(
      _baseUrl,
      "/api/v1/auth/sms-submit/result",
    );

    Response response = await ioClient.post(
      uri,
      headers: headers,
      body: jsonEncode(body).replaceAll('\\', ''),
    );

    Logger().d("""Тип запроса: Post
    Ссылка: ${uri.toString()}
    Тело запроса: ${body.toString()}
    Код ответа: ${response.statusCode}
    """);

    if (response.statusCode == 502) {
      _alert.setError =
          "В работе приложения произошла ошибка,\nмы уже работает над ее устранением!";
    }
    return response;
  }

  Future<Response> generalRequest({
    required Map<String, dynamic> body,
    required String url,
  }) async {
    Logger().w(url.toString());
    final Uri uri = Uri.https(
      _baseUrl,
      url,
    );

    Logger().i(url.toString());
    Logger().i(body.toString());

    Response response = await ioClient.post(
      uri,
      headers: headers,
      body: jsonEncode(body).replaceAll('\\', ''),
    );

    Logger().w(response.body.toString());

    Logger().d("""Тип запроса: Post
    Ссылка: ${uri.toString()}
    Тело запроса: ${body.toString()}
    Код ответа: ${response.statusCode}
    """);

    if (response.statusCode == 403) {
      _alert.setVisible = true;
    }

    if (response.statusCode == 502) {
      _alert.setError =
          "В работе приложения произошла ошибка,\nмы уже работает над ее устранением!";
    }

    return response;
  }

  Future<Response> generalRequestGet({
    required String url,
    required Map<String, dynamic> queryParameters,
    bool error = true,
  }) async {
    final Uri uri = Uri.https(
      _baseUrl,
      url,
      queryParameters,
    );

    Logger().e(uri.toString());
    Logger().e(queryParameters.toString());

    Response response = await ioClient.get(
      uri,
      headers: headers,
    );

    Logger().i(response.body.toString());

    Logger().d("""Тип запроса: Get
    Ссылка: ${uri.toString()}
    Тело запроса: ${queryParameters.toString()}
    Код ответа: ${response.statusCode}
    """);

    if (response.statusCode == 403 && error) {
      _alert.setVisible = true;
    }

    if (response.statusCode == 502) {
      _alert.setError =
          "В работе приложения произошла ошибка,\nмы уже работает над ее устранением!";
    }

    return response;
  }

  Future<Response> generalPatchRequest({
    required Map<String, dynamic> body,
    required String url,
  }) async {
    final Uri uri = Uri.https(
      _baseUrl,
      url,
    );

    late Response response;
    try {
      response = await ioClient.patch(
        uri,
        headers: headers,
        body: json.encode(body),
      );
    } catch (e) {
      print('No Internet connection 😑 $e');
    }

    Logger().i(response.body.toString());

    Logger().d("""Тип запроса: Patch
    Ссылка: ${uri.toString()}
    Тело запроса: ${body.toString()}
    Код ответа: ${response.statusCode}
    """);

    if (response.statusCode == 403) {
      _alert.setVisible = true;
    }

    if (response.statusCode == 502) {
      _alert.setError =
          "В работе приложения произошла ошибка,\nмы уже работает над ее устранением!";
    }

    return response;
  }

  Future<Response> generalRequestDelete({
    required String url,
  }) async {
    final Uri uri = Uri.https(
      _baseUrl,
      url,
    );

    Response response = await ioClient.delete(
      uri,
      headers: headers,
    );

    Logger().d("""Тип запроса: Delete
    Ссылка: ${uri.toString()}
    Код ответа: ${response.statusCode}
    """);

    if (response.statusCode == 403) {
      _alert.setVisible = true;
    }

    if (response.statusCode == 502) {
      _alert.setError =
          "В работе приложения произошла ошибка,\nмы уже работает над ее устранением!";
    }

    return response;
  }

  Future<StreamedResponse?> uploadFile({
    required Map<String, dynamic> body,
    required String url,
  }) async {
    final Uri uri = Uri.https(
      _baseUrl,
      url,
    );

    var request = new http.MultipartRequest("POST", uri);
    request.headers['Authorization'] = headers["Authorization"]!;
    request.files.add(
      new http.MultipartFile.fromBytes(
        'file',
        await File.fromUri(Uri.parse(body["path"])).readAsBytes(),
        contentType: MediaType(
          'image',
          body["path"].toString().split(".").last,
        ),
        filename: "test." + body["path"].toString().split(".").last,
      ),
    );

    var response = await request.send();
    Logger().d("""Тип запроса: Post
    Ссылка: ${uri.toString()}
    Код ответа: ${response.statusCode}
    """);
    if (response.statusCode == 403) {
      _alert.setVisible = true;
    }

    if (response.statusCode == 502) {
      _alert.setError =
          "В работе приложения произошла ошибка,\nмы уже работает над ее устранением!";
    }
    return response;
  }
}
