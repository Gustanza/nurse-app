import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:nurse_project/constants.dart';

class Offs extends StatefulWidget {
  const Offs({super.key});

  @override
  State<Offs> createState() => _OffsState();
}

class _OffsState extends State<Offs> {
  DateTime? starttime;
  DateTime? endtime;
  var fstr = FirebaseFirestore.instance.collection("offs");
  String? mamail = FirebaseAuth.instance.currentUser!.email;
  String? maname = FirebaseAuth.instance.currentUser!.displayName;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Offs"),
      ),
      body: StreamBuilder(
          stream: fstr.where('email', isEqualTo: mamail).snapshots(),
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
                          trailing: Text(
                            data[index]['approved']
                                ? "Approved"
                                : "Not Approved",
                          ),
                        );
                      }),
                    ),
                  ),
                );
              }
            }
            return const Center(child: CircularProgressIndicator());
          }),
      bottomSheet: SizedBox(
        height: MediaQuery.of(context).size.height * 0.3,
        child: CupertinoListSection.insetGrouped(
          children: [
            ListTile(
              onTap: () async {
                starttime = await timeItself();
                setState(() {});
              },
              title: Text(
                starttime != null ? "$starttime" : "Choose Start Date/Time",
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
            ListTile(
              onTap: () async {
                endtime = await timeItself();
                setState(() {});
              },
              title: Text(
                endtime != null ? "$endtime" : "Choose End Date/Time",
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: MaterialButton(
                color: Colors.green,
                onPressed: () async {
                  indicateProgress(context: context);
                  if (validate()) {
                    var token = await FirebaseMessaging.instance.getToken();
                    await fstr.add({
                      "email": mamail,
                      "name": maname,
                      "start": starttime,
                      "end": endtime,
                      "approved": false,
                      "token": token,
                    });
                  }
                  dismissStuff(context: context);
                  setState(() {
                    starttime = null;
                    endtime = null;
                  });
                },
                child: const Text("Send request"),
              ),
            )
          ],
        ),
      ),
    );
  }

  timeItself() async {
    return await DatePicker.showDateTimePicker(
      context,
      showTitleActions: true,
      minTime: DateTime.now(),
      maxTime: DateTime(2025, 12, 12),
      onChanged: (date) {},
      onConfirm: (date) {},
      currentTime: DateTime.now(),
      locale: LocaleType.en,
    );
  }

  validate() {
    if (starttime == null) {
      mesenja(
        context: context,
        isGood: false,
        ujumbe: "Choose start date and time",
      );
      return false;
    }
    if (endtime == null) {
      mesenja(
        context: context,
        isGood: false,
        ujumbe: "Choose end date and time",
      );
      return false;
    }
    return true;
  }
}
