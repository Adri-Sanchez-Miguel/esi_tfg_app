import 'package:cloud_firestore/cloud_firestore.dart';

class MessageService{
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  void save({required String collectionName, required Map<String, dynamic> collectionValues}){
    _fireStore.collection(collectionName).add(collectionValues);
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getMessage(String collectionName) async {
    return await _fireStore.collection(collectionName).get();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getMessageStream(String collectionName){
    return _fireStore.collection(collectionName).snapshots();
  }
}