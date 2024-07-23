import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nurse_project/constants.dart';

class TimeOffRequests extends StatefulWidget {
  const TimeOffRequests({super.key});

  @override
  State<TimeOffRequests> createState() => _TimeOffRequestsState();
}

class _TimeOffRequestsState extends State<TimeOffRequests> {
  var fstr = FirebaseFirestore.instance.collection("offs");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Time-off requests"),
      ),
      body: StreamBuilder(
          stream: fstr.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var data = (snapshot.data as dynamic).docs;
              if (data.isEmpty) {
                return const Center(
                  child: Text("You have no off requests yet"),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.only(bottom: kToolbarHeight * 5),
                  child: SingleChildScrollView(
                    child: CupertinoListSection.insetGrouped(
                      children: List.generate(data.length, (index) {
                        final DateFormat formatter =
                            DateFormat('EEEE, d\'th\', MMMM, yyyy, HH, mm');
                        var sdate =
                            formatter.format(data[index]['start'].toDate());
                        var edate =
                            formatter.format(data[index]['end'].toDate());

                        return ListTile(
                            title: Text(
                              data[index]['name'],
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("From: $sdate"),
                                Text("Until: $edate"),
                              ],
                            ),
                            trailing: TextButton(
                              onPressed: () async {
                                indicateProgress(context: context);
                                await fstr.doc(data[index].id).update({
                                  "approved": !data[index]['approved'],
                                });
                                dismissStuff(context: context);
                              },
                              child: Text(
                                !data[index]['approved']
                                    ? "Approve"
                                    : "Disapprove",
                              ),
                            ));
                      }),
                    ),
                  ),
                );
              }
            }
            return const Center(child: CircularProgressIndicator());
          }),
    );
  }
}
