import 'dart:convert';

class InternalResponse {
  dynamic response;
  String error;

  InternalResponse.data(this.response) : error = null;

  InternalResponse.error(this.error) : response = null;

  String toJson() => json.encode({'response': response, 'error': error});
}
