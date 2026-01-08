import 'package:get/get.dart';
import '../services/graphql_service.dart';
import '../queries.dart';

class DashboardProvider {
  final GraphQLService _gqlService = Get.find<GraphQLService>();

  Future<Map<String, dynamic>> getDashboardData() async {
    final result = await _gqlService.performQuery(GqlQueries.getDashboardData);

    if (!result.hasException && result.data != null) {
      return result.data!['dashboard'];
    } else {
      throw Exception(
        result.exception?.toString() ?? 'Failed to load dashboard data',
      );
    }
  }

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

  Future<List<dynamic>> getIncomes() async {
    final result = await _gqlService.performQuery(GqlQueries.getIncomes);

    if (!result.hasException && result.data != null) {
      return result.data!['incomes'];
    } else {
      throw Exception(result.exception?.toString() ?? 'Failed to load incomes');
    }
  }

  Future<List<dynamic>> getUpcomingPayments() async {
    final result = await _gqlService.performQuery(
      GqlQueries.getUpcomingPayments,
    );

    if (!result.hasException && result.data != null) {
      return result.data!['upcomingPayments'];
    } else {
      throw Exception(
        result.exception?.toString() ?? 'Failed to load upcoming payments',
      );
    }
  }
}
