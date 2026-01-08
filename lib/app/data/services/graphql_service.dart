import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;
import '../../core/utils/api_constants.dart';

class GraphQLService extends GetxService {
  late GraphQLClient client;

  @override
  void onInit() {
    super.onInit();
    final HttpLink httpLink = HttpLink(
      ApiConstants.baseUrl,
      httpClient: TimeoutClient(timeout: const Duration(seconds: 30)),
    );

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
