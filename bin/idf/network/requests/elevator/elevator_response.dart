class IDFElevatorsResponse {
  Iterable<IDFElevatorResponse> elevators;

  IDFElevatorsResponse.fromAPI(List api)
      : elevators = api.map(
          (e) => IDFElevatorResponse.fromAPI(e),
        );

  Map<String, dynamic> toJson() => {
        'elevators': elevators
            .map(
              (e) => e.toJson(),
            )
            .toList(growable: false),
      };
}

class IDFElevatorResponse {
  final String id;
  final String name;
  final String location;
  final String direction;
  final DateTime lastUpdate;
  final ElevatorStatus status;
  final ElevatorFailureReason? reason;
  final ElevatorCoordinates coordinates;

  IDFElevatorResponse.fromAPI(Map<String, dynamic> api)
      : id = api['fields']['liftid'],
        name = api['fields']['zdcname'],
        location = api['fields']['liftsituation'] ?? '',
        direction = api['fields']['liftdirection'] ?? '',
        lastUpdate = api['fields']['liftstateupdate'] == null
            ? DateTime.now()
            : DateTime.parse(api['fields']['liftstateupdate']),
        status = _extractStatus(api['fields']['liftstatus']),
        reason = _extractReason(api['fields']['liftteason']),
        coordinates = ElevatorCoordinates.fromAPI(api['geometry']);

  static ElevatorStatus _extractStatus(dynamic status) {
    switch (status) {
      case 'available':
        return ElevatorStatus.available;
      case 'notavailable':
        return ElevatorStatus.unavailable;
      default:
        return ElevatorStatus.unknown;
    }
  }

  static ElevatorFailureReason? _extractReason(dynamic reason) {
    switch (reason) {
      case 'liftFailure':
        return ElevatorFailureReason.liftFailure;
      case 'closedForMaintenance':
        return ElevatorFailureReason.liftFailure;
      case 'undefineEquipmentProblem':
        return ElevatorFailureReason.unknown;
      default:
        return null;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'coordinates': coordinates.toJson(),
        'location': location,
        'direction': direction,
        'lastUpdate': lastUpdate.millisecondsSinceEpoch,
        'status': status.toString().replaceAll('ElevatorStatus.', ''),
        'reason': reason?.toString().replaceAll('ElevatorFailureReason.', ''),
      };
}

class ElevatorCoordinates {
  final double latitude;
  final double longitude;

  ElevatorCoordinates.fromAPI(Map<String, dynamic> api)
      : latitude = (api['coordinates'] as List).elementAt(1),
        longitude = (api['coordinates'] as List).elementAt(0);

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
      };
}

enum ElevatorStatus {
  available,
  unavailable,
  unknown,
}

enum ElevatorFailureReason {
  liftFailure,
  maintenance,
  unknown,
}
