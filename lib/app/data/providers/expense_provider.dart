import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/utils/api_constants.dart';

class ExpenseProvider {
  Future<List<dynamic>> getExpenses() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/expenses'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load expenses');
    }
  }

  Future<void> createExpense(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/expenses'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create expense');
    }
  }

  Future<void> updateExpense(String id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/expenses/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update expense');
    }
  }

  Future<void> deleteExpense(String id) async {
    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/expenses/$id'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete expense');
    }
  }
}
