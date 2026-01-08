import 'package:get/get.dart';
import '../services/graphql_service.dart';
import '../queries.dart';

class CategoryProvider {
  final GraphQLService _gqlService = Get.find<GraphQLService>();

  Future<List<dynamic>> getCategories() async {
    final result = await _gqlService.performQuery(GqlQueries.getCategories);

    if (!result.hasException && result.data != null) {
      return result.data!['categories'];
    } else {
      throw Exception(
        result.exception?.toString() ?? 'Failed to load categories',
      );
    }
  }

  Future<void> createCategory(Map<String, dynamic> data) async {
    final result = await _gqlService.performMutation(
      GqlQueries.addCategory,
      variables: data,
    );
    if (result.hasException) {
      throw Exception(
        result.exception?.toString() ?? 'Failed to create category',
      );
    }
  }

  Future<void> deleteCategory(String id) async {
    final result = await _gqlService.performMutation(
      GqlQueries.deleteCategory,
      variables: {'id': id},
    );
    if (result.hasException) {
      throw Exception(
        result.exception?.toString() ?? 'Failed to delete category',
      );
    }
  }
}
