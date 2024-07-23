import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nurse_project/constants.dart';

class Swapper extends StatefulWidget {
  const Swapper({super.key});

  @override
  State<Swapper> createState() => _SwapperState();
}

class _SwapperState extends State<Swapper> {
  String mamail = FirebaseAuth.instance.currentUser?.email ?? "";
  FirebaseFirestore fstr = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Swap Requests"),
      ),
      body: StreamBuilder(
        stream: fstr
            .collection('swap_requests')
            .where('requested', isEqualTo: mamail)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var data = (snapshot.data as dynamic).docs;
            if (data.isEmpty) {
              return const Center(
                child: Text("You currently have no swap Requests"),
              );
            } else {
              return SingleChildScrollView(
                child: CupertinoListSection.insetGrouped(
                  children: List.generate(data.length, (index) {
                    return ListTile(
                      title: getNurseInfo(idYaNesi: data[index]['requestor']),
                      subtitle: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              "Looking to swap for ${data[index]['shift']} shift"),
                          getWardInfo(idYaWard: data[index]['ward']),
                        ],
                      ),
                      trailing: TextButton(
                        onPressed: () async {
                          await accept(
                            ward: data[index]['ward'],
                            shift: data[index]['shift'],
                            requestor: data[index]['requestor'],
                            swapId: data[index].id,
                          );
                        },
                        child: const Text("Accept"),
                      ),
                    );
                  }),
                ),
              );
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget getNurseInfo({idYaNesi}) {
    return idYaNesi != null
        ? StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(idYaNesi)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var nesi = (snapshot.data as dynamic).data();
                if (nesi == null) {
                  return const Text("Nurse data unavailable");
                }
                return Text(
                  "Nurse ${nesi['jina']}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                );
              } else if (snapshot.hasError) {
                return const Text("Data Unavailable");
              } else {
                return const Text("Please Wait...");
              }
            },
          )
        : const Text(
            "Shift Availbale",
            style: TextStyle(
              color: Colors.green,
            ),
          );
  }

  Widget getWardInfo({idYaWard}) {
    return idYaWard != null
        ? StreamBuilder(
            stream: fstr.collection('wards').doc(idYaWard).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var ward = (snapshot.data as dynamic).data();
                if (ward == null) {
                  return const Text("Ward data unavailable");
                }
                return Text("Ward name: ${ward['name']}");
              } else if (snapshot.hasError) {
                return const Text("Data Unavailable");
              } else {
                return const Text("Please Wait...");
              }
            },
          )
        : const Text(
            "Shift Availbale",
            style: TextStyle(
              color: Colors.green,
            ),
          );
  }

  accept({ward, shift, requestor, swapId}) async {
    indicateProgress(context: context);
    try {
      var shiftRes = await fstr
          .collection('shifts')
          .where('who', isEqualTo: mamail)
          .where('shift', isEqualTo: shift)
          .get();
      var shifts = shiftRes.docs;
      if (shifts.isEmpty) {
        mesenja(
          context: context,
          isGood: false,
          ujumbe: 'Was unable to swap shifts',
        );
      } else {
        await fstr.collection('shifts').doc(shifts[0].id).update({
          'who': requestor,
        });
        await fstr.collection('wards').doc(ward).update({shift: requestor});
        await fstr.collection('swap_requests').doc(swapId).delete();
      }
    } catch (err) {
      mesenja(
        context: context,
        isGood: false,
        ujumbe: err.toString(),
      );
    }

    dismissStuff(context: context);
  }
}
