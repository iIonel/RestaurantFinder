import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {

  static Future<http.Response> getRequest(String endpoint, {Map<String, String>? queryParams}) async {
    final uri = Uri.parse('$endpoint').replace(queryParameters: queryParams);
    final response = await http.get(uri);
    return response;
  }

  static Future<http.Response> postRequest(String endpoint, {Map<String, String>? queryParams}) async {
    final uri = Uri.parse('$endpoint').replace(queryParameters: queryParams);
    final response = await http.post(uri, headers: {'Content-Type': 'application/json'});
    return response;
  }
}
