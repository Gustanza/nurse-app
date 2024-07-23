import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nurse_project/constants.dart';

class ShiftRequestsAdmin extends StatefulWidget {
  const ShiftRequestsAdmin({super.key});

  @override
  State<ShiftRequestsAdmin> createState() => _ShiftRequestsAdminState();
}

class _ShiftRequestsAdminState extends State<ShiftRequestsAdmin> {
  FirebaseFirestore fstr = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Approve Shift Requests"),
      ),
      body: StreamBuilder(
          stream: fstr
              .collection('shift_requests')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var data = (snapshot.data as dynamic).docs;
              if (data.isEmpty) {
                return Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: const Text(
                      "There is no shift requests for now",
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              } else {
                return SingleChildScrollView(
                  child: CupertinoListSection.insetGrouped(
                    children: List.generate(data.length, (index) {
                      return ListTile(
                        title: getNurseInfo(idYaNesi: data[index]['who']),
                        subtitle: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            getWardInfo(idYaWard: data[index]['ward']),
                            Text(
                              "Requesting: ${data[index]['shift']} shift",
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              "${data[index]['timestamp'].toDate()}",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        trailing: TextButton(
                          onPressed: () {
                            if (!data[index]['approved']) {
                              approve(
                                wardId: data[index]['ward'],
                                shift: data[index]['shift'],
                                who: data[index]['who'],
                                shiftReqId: data[index].id,
                              );
                            } else {
                              disapprove(
                                wardId: data[index]['ward'],
                                shift: data[index]['shift'],
                                who: data[index]['who'],
                                shiftReqId: data[index].id,
                              );
                            }
                          },
                          child: data[index]['approved']
                              ? const Text("Disapprove")
                              : const Text("Approve"),
                        ),
                      );
                    }),
                  ),
                );
              }
            }
            return const Center(
                child: CircularProgressIndicator(
              color: Colors.green,
            ));
          }),
    );
  }

  Widget getNurseInfo({idYaNesi}) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(idYaNesi)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var nesi = (snapshot.data as dynamic).data();
          return Text(
            "Name: ${nesi['jina']}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          );
        } else if (snapshot.hasError) {
          return const Text("Data Unavailable");
        } else {
          return const Text("Please Wait...");
        }
      },
    );
  }

  Widget getWardInfo({idYaWard}) {
    return StreamBuilder(
      stream: fstr.collection('wards').doc(idYaWard).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var ward = (snapshot.data as dynamic).data();
          return Text(
            "Ward: ${ward['name']}",
            style: const TextStyle(fontSize: 16),
          );
        } else if (snapshot.hasError) {
          return const Text("Data Unavailable");
        } else {
          return const Text("Please Wait...");
        }
      },
    );
  }

  approve({wardId, shiftReqId, shift, who}) async {
    indicateProgress(context: context);
    try {
      var token = await FirebaseMessaging.instance.getToken();
      await fstr.collection("wards").doc(wardId).update({
        shift: who,
      });
      await fstr
          .collection('shift_requests')
          .doc(shiftReqId)
          .update({"approved": true});
      await fstr.collection('shifts').doc(shiftReqId).set({
        "shift": shift,
        "who": who,
        "ward": wardId,
        "token": token,
        "starttime": null,
        "endtime": null,
        "timestamp": DateTime.now(),
      });
    } catch (e) {
      mesenja(context: context, isGood: false, ujumbe: e.toString());
    }

    dismissStuff(context: context);
  }

  disapprove({wardId, shiftReqId, shift, who}) async {
    indicateProgress(context: context);
    try {
      await fstr.collection("wards").doc(wardId).update({
        shift: null,
      });
      await fstr
          .collection('shift_requests')
          .doc(shiftReqId)
          .update({"approved": false});
      await fstr.collection('shifts').doc(shiftReqId).delete();
    } catch (e) {
      mesenja(context: context, isGood: false, ujumbe: e.toString());
    }

    dismissStuff(context: context);
  }
}
