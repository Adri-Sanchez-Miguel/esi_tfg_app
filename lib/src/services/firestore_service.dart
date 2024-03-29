import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService{
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  Future<void> save({required String collectionName, required Map<String, dynamic> collectionValues}) async {
      await _fireStore.collection(collectionName).add(collectionValues);
  }

  Future<void> update({required DocumentReference document, required Map<String, dynamic> collectionValues}) async {
    _fireStore.runTransaction((transaction) async{
      DocumentSnapshot freshSnap = await transaction.get(document);
      await transaction.update(freshSnap.reference, collectionValues);
    });
  }

  Future<void> delete({required DocumentReference document}) async {
    _fireStore.runTransaction((transaction) async{
      DocumentSnapshot freshSnap = await transaction.get(document);
      await transaction.delete(freshSnap.reference);
    });
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getMessage({required String collectionName}) async {
    return await _fireStore.collection(collectionName).get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getOrderedMessage({required String field, required String collectionName}) async {
    return await _fireStore.collection(collectionName).orderBy(field, descending: true).get();
  }
}