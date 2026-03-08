import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/report_model.dart';

class ApiService {
  static const String apiUrl = 'https://oracleapex.com/ords/malek_apex/student/requests';

  static Future<bool> submitReport(ReportModel report) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(report.toJson()),
      );

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      return false;
    }
  }
}
