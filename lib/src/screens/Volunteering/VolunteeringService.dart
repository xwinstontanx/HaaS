import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../firebase_options_senzehub.dart';

class VolunteeringService {
  var userUid = "";
  var userName = "";
  var userRole = "";
  var userOrgId = "";
  var elderlyUnderCareList = [];
  var elderlyUnderCareListNewEmergency = [];
  var elderlyUnderCareListNewMsg = [];
  late QuerySnapshot elderlyUnderCare;

  Future<void> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userUid = prefs.getString('userUid')!;
    userName = prefs.getString('userName')!;
    userRole = prefs.getString('userRole')!;
    userOrgId = prefs.getString('userOrgId')!;
  }

  Future<void> getElderlyList() async {
    final FirebaseApp secondaryApp = await Firebase.initializeApp(
      name: 'SecondaryApp',
      options: SecondaryFirebaseOptions.currentPlatform,
    );
    await FirebaseFirestore.instanceFor(app: secondaryApp)
        .collection('volunteers')
        .doc(userUid)
        .collection('ElderlyUnderCare')
        .get()
        .then((querySnapshot) async {
      elderlyUnderCareList = [];
      for (var queryDocumentSnapshot in querySnapshot.docs) {
        Map<String, dynamic> data = queryDocumentSnapshot.data();
        await FirebaseFirestore.instanceFor(app: secondaryApp)
            .collection('Users')
            .doc(data['Uid'])
            .get()
            .then((profile) async => {
                  if (profile.exists)
                    {
                      elderlyUnderCareList.add({
                        'Uid': profile.id,
                        'data': profile.data(),
                      })
                    }
                });
      }
    });
  }

  Future<void> getElderlyListLastMsg() async {
    for (var elderly in elderlyUnderCareList) {
      final FirebaseApp secondaryApp = await Firebase.initializeApp(
        name: 'SecondaryApp',
        options: SecondaryFirebaseOptions.currentPlatform,
      );
      await FirebaseFirestore.instanceFor(app: secondaryApp)
          .collection('VolunteerChats')
          .doc(elderly['Uid'].toString())
          .collection('Chats')
          .orderBy('CreatedAt', descending: false)
          .limit(1)
          .get()
          .then((querySnapshot) async {
        if (querySnapshot.docs.isNotEmpty) {
          for (var queryDocumentSnapshot in querySnapshot.docs) {
            Map<String, dynamic> data = queryDocumentSnapshot.data();
            var newMsg = false;
            if (data['Uid'] == userUid) {
              elderlyUnderCareListNewMsg.add(false);
            } else {
              elderlyUnderCareListNewMsg.add(true);
            }
          }
        } else {
          elderlyUnderCareListNewMsg.add(false);
        }
      });
    }
  }

  Future<void> getElderlyListLastEmergency() async {
    for (var elderly in elderlyUnderCareList) {
      final FirebaseApp secondaryApp = await Firebase.initializeApp(
        name: 'SecondaryApp',
        options: SecondaryFirebaseOptions.currentPlatform,
      );
      await FirebaseFirestore.instanceFor(app: secondaryApp)
          .collection('Notification')
          .where('NotifyStatus', whereIn: ["open"])
          .where('SeniorUid', isEqualTo: elderly['Uid'])
          .get()
          .then((querySnapshot) async {
            if (querySnapshot.docs.isNotEmpty) {
              elderlyUnderCareListNewEmergency.add(true);
            } else {
              elderlyUnderCareListNewEmergency.add(false);
            }
          });
    }
  }
}
