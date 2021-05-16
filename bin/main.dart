import 'dart:io';

import 'package:args/args.dart';

import 'server.dart';

void main(List<String> args) async {
  var parser = ArgParser()..addOption('port', abbr: 'p', defaultsTo: '8080');

  var result = parser.parse(args);

  var port = int.tryParse(result['port']);

  if (port == null) {
    stdout.writeln(
        'Could not parse port value \'${result['port']}\' into a number.');
    // 64: command line usage error
    exitCode = 64;
    return;
  }

  await runServer(port);
}
