import '../models/geo.dart';
import '../models/nomad_location.dart';
import '../models/nomad_user.dart';

class MockData {
  static const currentUser = NomadUser(
    id: 'me',
    name: 'You',
    age: 28,
    lookingFor: LookingFor.both,
    activities: ['hiking', 'coffee', 'photography', 'surfing', 'yoga'],
    travelStyle: TravelStyle.slowExplorer,
    workSituation: WorkSituation.remoteWorker,
    adventureScore: 1240,
  );

  static const nearbyNomads = <NomadUser>[
    NomadUser(
      id: 'u1',
      name: 'Sarah',
      age: 27,
      lookingFor: LookingFor.dating,
      activities: ['climbing', 'hiking', 'photography'],
      travelStyle: TravelStyle.fastMover,
      workSituation: WorkSituation.remoteWorker,
      adventureScore: 980,
    ),
    NomadUser(
      id: 'u2',
      name: 'Mike',
      age: 31,
      lookingFor: LookingFor.friends,
      activities: ['fishing', 'camping', 'trail running'],
      travelStyle: TravelStyle.slowExplorer,
      workSituation: WorkSituation.seasonal,
      adventureScore: 620,
    ),
    NomadUser(
      id: 'u3',
      name: 'Jess',
      age: 25,
      lookingFor: LookingFor.both,
      activities: ['yoga', 'surfing', 'van builds'],
      travelStyle: TravelStyle.weekendWarrior,
      workSituation: WorkSituation.other,
      adventureScore: 1410,
    ),
  ];

  static const myPosition = LatLng(34.0522, -118.2437);

  static const mutualInterested = <String>{'u1'};

  static const nearbyLocations = <NomadLocation>[
    NomadLocation(userId: 'u1', position: LatLng(34.0622, -118.2437)),
    NomadLocation(userId: 'u2', position: LatLng(34.0450, -118.2550)),
    NomadLocation(userId: 'u3', position: LatLng(34.0555, -118.2350)),
  ];
}
