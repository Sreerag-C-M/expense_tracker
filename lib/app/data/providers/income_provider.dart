import 'package:get/get.dart';
import '../services/graphql_service.dart';
import '../queries.dart';

class IncomeProvider {
  final GraphQLService _gqlService = Get.find<GraphQLService>();

  Future<void> createIncome(Map<String, dynamic> data) async {
    final result = await _gqlService.performMutation(
      GqlQueries.addIncome,
      variables: data,
    );
    if (result.hasException) {
      throw Exception(
        result.exception?.toString() ?? 'Failed to create income',
      );
    }
  }

  Future<void> updateIncome(String id, Map<String, dynamic> data) async {
    final variables = {'id': id, ...data};
    final result = await _gqlService.performMutation(
      GqlQueries.updateIncome,
      variables: variables,
    );
    if (result.hasException) {
      throw Exception(
        result.exception?.toString() ?? 'Failed to update income',
      );
    }
  }
}
