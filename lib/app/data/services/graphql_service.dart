import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;
import '../../core/utils/api_constants.dart';

import 'package:get_storage/get_storage.dart';

class GraphQLService extends GetxService {
  late GraphQLClient client;

  @override
  void onInit() {
    super.onInit();
    final HttpLink httpLink = HttpLink(
      ApiConstants.baseUrl,
      httpClient: TimeoutClient(timeout: const Duration(seconds: 30)),
    );

    final AuthLink authLink = AuthLink(
      getToken: () async {
        final box = GetStorage();
        final token = box.read('token');
        return token != null ? 'Bearer $token' : null;
      },
    );

    final Link link = authLink.concat(httpLink);

    client = GraphQLClient(
      link: link,
      // The default store is the InMemoryStore, which does NOT persist to disk
      cache: GraphQLCache(),
    );
  }

  Future<QueryResult> performQuery(
    String query, {
    Map<String, dynamic>? variables,
    FetchPolicy? fetchPolicy,
  }) async {
    final options = QueryOptions(
      document: gql(query),
      variables: variables ?? {},
      fetchPolicy:
          fetchPolicy ??
          FetchPolicy
              .networkOnly, // Default to networkOnly to ensure fresh data
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

class TimeoutClient extends http.BaseClient {
  final http.Client _inner = http.Client();
  final Duration timeout;

  TimeoutClient({this.timeout = const Duration(seconds: 60)});

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    print('TimeoutClient: Sending request to ${request.url}');
    try {
      final response = await _inner.send(request).timeout(timeout);
      print(
        'TimeoutClient: Response received with status ${response.statusCode}',
      );
      return response;
    } catch (e) {
      print('TimeoutClient: Error sending request: $e');
      rethrow;
    }
  }
}
