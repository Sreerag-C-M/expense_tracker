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
}
