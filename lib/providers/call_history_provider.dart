import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:leanware_assessment/models/call_history.dart';

class CallHistoryProvider {
  CallHistoryProvider(this.userId) {
    _ref = FirebaseFirestore.instance
        .collection('History')
        .doc(userId)
        .collection('Calls');
  }

  late CollectionReference _ref;
  late String userId;

  saveRecord(String id, CallHistoryModel call) async {
    await _ref.doc(id).set(call.toJson());
  }

  Future<List<CallHistoryModel>> getCallHistory() async {
    QuerySnapshot querySnapshot =
        await _ref.orderBy('date', descending: true).limit(10).get();

    List<CallHistoryModel> allData = querySnapshot.docs
        .map(
          (QueryDocumentSnapshot<Object?> doc) => CallHistoryModel.fromJson(
            doc.id,
            doc.data()! as Map<String, dynamic>,
          ),
        )
        .toList();

    return allData;
  }
}
