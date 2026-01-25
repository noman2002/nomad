import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/geo.dart';
import '../../models/nomad_location.dart';
import '../firebase_refs.dart';

class LocationsService {
  static Stream<List<NomadLocation>> watchLocations({int limit = 50}) {
    return FirebaseRefs.locations()
        .orderBy('updatedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map(_fromDoc).toList();
    });
  }

  static NomadLocation _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final userId = (data?['userId'] as String?) ?? doc.id;
    final lat = (data?['lat'] as num?)?.toDouble() ?? 0;
    final lng = (data?['lng'] as num?)?.toDouble() ?? 0;
    return NomadLocation(userId: userId, position: LatLng(lat, lng));
  }
}
