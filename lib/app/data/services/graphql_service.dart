import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../core/utils/api_constants.dart';

class GraphQLService extends GetxService {
  late GraphQLClient client;

  @override
  void onInit() {
    super.onInit();
    final HttpLink httpLink = HttpLink(ApiConstants.baseUrl);

    client = GraphQLClient(
      link: httpLink,
      // The default store is the InMemoryStore, which does NOT persist to disk
      cache: GraphQLCache(),
    );
  }

  Future<QueryResult> performQuery(
    String query, {
    Map<String, dynamic>? variables,
  }) async {
    final options = QueryOptions(
      document: gql(query),
      variables: variables ?? {},
    );

    final result = await client.query(options);

    if (result.hasException) {
      print('GraphQL Query Error: ${result.exception.toString()}');
    }

    return result;
  }

  Future<QueryResult> performMutation(
    String mutation, {
    Map<String, dynamic>? variables,
  }) async {
    final options = MutationOptions(
      document: gql(mutation),
      variables: variables ?? {},
    );

    final result = await client.mutate(options);

    if (result.hasException) {
      print('GraphQL Mutation Error: ${result.exception.toString()}');
    }

    return result;
  }
}
