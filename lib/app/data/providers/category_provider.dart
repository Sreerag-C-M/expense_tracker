import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/utils/api_constants.dart';

class CategoryProvider {
  Future<List<dynamic>> getCategories() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/categories'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<void> createCategory(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/categories'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create category');
    }
  }

  Future<void> deleteCategory(String id) async {
    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/categories/$id'),
    );
    if (response.statusCode != 200) {
      // Handle "Cannot delete default" error or others
      final msg = json.decode(response.body)['message'] ?? 'Failed to delete';
      throw Exception(msg);
    }
  }
}
