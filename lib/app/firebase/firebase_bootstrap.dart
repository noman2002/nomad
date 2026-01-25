import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseBootstrap {
  static Future<void> configure() async {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );
  }
}
