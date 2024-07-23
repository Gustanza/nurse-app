import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nurse_project/constants.dart';

class Mashifts extends StatelessWidget {
  const Mashifts({super.key});

  @override
  Widget build(BuildContext context) {
    String mamail = FirebaseAuth.instance.currentUser?.email ?? "";

    FirebaseFirestore fstr = FirebaseFirestore.instance;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("My Shifts"),
      ),
      body: StreamBuilder(
          stream: fstr
              .collection('shifts')
              .where("who", isEqualTo: mamail)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var shifts = (snapshot.data as dynamic).docs;
              if (shifts.isEmpty) {
                return const Center(child: Text("You have no shifts"));
              } else {
                return BuildShifts(shifts: shifts);
              }
            } else if (snapshot.hasError) {
              return Center(child: Text("${snapshot.error}"));
            }
            return const Center(child: CircularProgressIndicator());
          }),
    );
  }
}

class BuildShifts extends StatelessWidget {
  final dynamic shifts;
  const BuildShifts({super.key, required this.shifts});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: CupertinoListSection.insetGrouped(
        children: List.generate(shifts.length, (index) {
          var s = shifts[index]['shift'];
          var w = shifts[index]['ward'];
          var st = shifts[index]['starttime'];
          var et = shifts[index]['endtime'];
          return ListTile(
            title: RichText(
                text: TextSpan(children: [
              const TextSpan(
                text: "Shift type: ",
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: "${s[0].toUpperCase() + s.substring(1)} shift",
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
            ])),
            subtitle: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                getWardInfo(idYaWard: w),
                const SizedBox(height: 4),
                RichText(
                    text: TextSpan(children: [
                  const TextSpan(
                    text: "Started at: ",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: "${st != null ? st.toDate() : 'Click to start'}",
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ])),
                const SizedBox(height: 4),
                RichText(
                    text: TextSpan(children: [
                  const TextSpan(
                    text: "Ended at: ",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: "${et != null ? et.toDate() : 'Click to end'}",
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ])),
              ],
            ),
            trailing: IconButton.filled(
              onPressed: () async {
                await showCupertinoModalPopup(
                  context: context,
                  builder: (context) {
                    return CupertinoActionSheet(
                      actions: [
                        st == null
                            ? CupertinoActionSheetAction(
                                onPressed: () async {
                                  await FirebaseFirestore.instance
                                      .collection('shifts')
                                      .doc(shifts[index].id)
                                      .update({
                                    "starttime": DateTime.now(),
                                  });
                                  dismissStuff(context: context);
                                },
                                child: const Text("Start Shift"),
                              )
                            : CupertinoActionSheetAction(
                                onPressed: () {
                                  dismissStuff(context: context);
                                },
                                child: const Text("Shift already started"),
                              ),
                        et == null
                            ? CupertinoActionSheetAction(
                                onPressed: () async {
                                  await FirebaseFirestore.instance
                                      .collection('shifts')
                                      .doc(shifts[index].id)
                                      .update({
                                    "endtime": DateTime.now(),
                                  });
                                  dismissStuff(context: context);
                                },
                                child: const Text("End Shift"),
                              )
                            : CupertinoActionSheetAction(
                                onPressed: () {
                                  dismissStuff(context: context);
                                },
                                child: const Text("Shift already ended"),
                              )
                      ],
                      cancelButton: CupertinoActionSheetAction(
                        isDestructiveAction: true,
                        onPressed: () {
                          dismissStuff(context: context);
                        },
                        child: const Text("Dismiss"),
                      ),
                    );
                  },
                );
              },
              icon: const Icon(Icons.arrow_forward_ios),
              style: const ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.green),
              ),
            ),
          );
        }),
      ),
    );
  }
}
