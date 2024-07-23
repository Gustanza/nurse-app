import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nurse_project/constants.dart';

class AllShifts extends StatelessWidget {
  const AllShifts({super.key});

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore fstr = FirebaseFirestore.instance;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("All Shifts"),
      ),
      body: StreamBuilder(
          stream: fstr.collection('shifts').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var shifts = (snapshot.data as dynamic).docs;
              if (shifts.isEmpty) {
                return const Center(child: Text("There are no shifts"));
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
                    text: "${st != null ? st.toDate() : 'Shift not started'}",
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
                    text: "${et != null ? et.toDate() : 'Shift not ended'}",
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ])),
              ],
            ),
          );
        }),
      ),
    );
  }
}
