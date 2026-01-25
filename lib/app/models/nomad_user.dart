enum LookingFor { dating, friends, both }

typedef UserId = String;

typedef VideoId = String;

typedef ConversationId = String;

enum TravelStyle { slowExplorer, fastMover, weekendWarrior }

enum WorkSituation { remoteWorker, seasonal, retired, other }

class NomadUser {
  const NomadUser({
    required this.id,
    required this.name,
    required this.age,
    required this.lookingFor,
    required this.activities,
    required this.travelStyle,
    required this.workSituation,
    required this.adventureScore,
  });

  final UserId id;
  final String name;
  final int age;
  final LookingFor lookingFor;
  final List<String> activities;
  final TravelStyle travelStyle;
  final WorkSituation workSituation;
  final int adventureScore;
}
