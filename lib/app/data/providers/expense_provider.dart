import 'package:get/get.dart';
import '../services/graphql_service.dart';
import '../queries.dart';

class ExpenseProvider {
  final GraphQLService _gqlService = Get.find<GraphQLService>();

  Future<List<dynamic>> getExpenses() async {
    final result = await _gqlService.performQuery(GqlQueries.getExpenses);

    if (!result.hasException && result.data != null) {
      return result.data!['expenses'];
    } else {
      throw Exception(
        result.exception?.toString() ?? 'Failed to load expenses',
      );
    }
  }

  Future<void> createExpense(Map<String, dynamic> data) async {
    final result = await _gqlService.performMutation(
      GqlQueries.addExpense,
      variables: data,
    );
    if (result.hasException) {
      throw Exception(
        result.exception?.toString() ?? 'Failed to create expense',
      );
    }
  }

  Future<void> updateExpense(String id, Map<String, dynamic> data) async {
    final variables = {'id': id, ...data};
    final result = await _gqlService.performMutation(
      GqlQueries.updateExpense,
      variables: variables,
    );
    if (result.hasException) {
      throw Exception(
        result.exception?.toString() ?? 'Failed to update expense',
      );
    }
  }

  Future<void> deleteExpense(String id) async {
    final result = await _gqlService.performMutation(
      GqlQueries.deleteExpense,
      variables: {'id': id},
    );
    if (result.hasException) {
      throw Exception(
        result.exception?.toString() ?? 'Failed to delete expense',
      );
    }
  }
}
