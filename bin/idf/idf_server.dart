import 'package:shelf/shelf.dart' as shelf;

import '../server.dart';
import '../utils/network/request.dart';
import '../utils/network/response.dart';
import 'network/network.dart';
import 'network/requests/elevator/elevator_response.dart';

Future<shelf.Response> findElevators(InternalRequest request) async {
  var resp = await listElevators();

  if (resp == null || (resp is List && resp.isEmpty) || (resp is! List)) {
    return shelf.Response.internalServerError();
  } else {
    return shelf.Response.ok(
      InternalResponse.data(IDFElevatorsResponse.fromAPI(resp).toJson())
          .toJson(),
      headers: defaultResponseHeaders(),
    );
  }
}
