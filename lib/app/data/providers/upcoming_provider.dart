import 'package:get/get.dart';
import '../services/graphql_service.dart';
import '../queries.dart';

class UpcomingProvider {
  final GraphQLService _gqlService = Get.find<GraphQLService>();

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

  Future<void> createUpcomingPayment(Map<String, dynamic> data) async {
    final result = await _gqlService.performMutation(
      GqlQueries.addUpcomingPayment,
      variables: data,
    );
    if (result.hasException) {
      throw Exception(
        result.exception?.toString() ?? 'Failed to create upcoming payment',
      );
    }
  }

  Future<void> deleteUpcomingPayment(String id) async {
    final result = await _gqlService.performMutation(
      GqlQueries.deleteUpcomingPayment,
      variables: {'id': id},
    );
    if (result.hasException) {
      throw Exception(
        result.exception?.toString() ?? 'Failed to delete upcoming payment',
      );
    }
  }

  Future<void> updateUpcomingPayment(
    String id,
    Map<String, dynamic> data,
  ) async {
    final variables = {'id': id, ...data};
    final result = await _gqlService.performMutation(
      GqlQueries
          .updateUpcomingPayment, // Need to verify if this query exists in GqlQueries
      variables: variables,
    );
    if (result.hasException) {
      throw Exception(
        result.exception?.toString() ?? 'Failed to update upcoming payment',
      );
    }
  }
}
