import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nurse_project/screens/all_shifts.dart';
import 'package:nurse_project/screens/auth_stuff.dart';
import 'package:nurse_project/screens/dashboard.dart';
import 'package:nurse_project/screens/mashifts.dart';
import 'package:nurse_project/screens/off.dart';
import 'package:nurse_project/screens/swaps.dart';
import 'package:nurse_project/screens/time_off_requests.dart';

customDrawer({context}) {
  FirebaseAuth authObj = FirebaseAuth.instance;
  String username = authObj.currentUser!.displayName ?? "User";
  String usermail = authObj.currentUser!.email ?? "No emailfound";
  String userphoto = authObj.currentUser!.photoURL ?? "";

  return Drawer(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(0),
    ),
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: Colors.green.shade100,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey.shade400,
                  backgroundImage: NetworkImage(userphoto),
                ),
                const SizedBox(height: 4),
                Text(username),
                const SizedBox(height: 4),
                Text(usermail),
              ],
            )),
        usermail == "admin@gmail.com"
            ? ListTile(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) {
                      return const ShiftRequestsAdmin();
                    }),
                  );
                },
                leading: const Icon(Icons.dashboard),
                title: const Text(
                  "Admin Area",
                  style: TextStyle(fontSize: 16),
                ),
              )
            : const SizedBox(),
        const Divider(indent: 16 * 2, endIndent: 16 * 2),
        usermail == "admin@gmail.com"
            ? ListTile(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) {
                      return const TimeOffRequests();
                    }),
                  );
                },
                leading: const Icon(Icons.timer_off),
                title: const Text(
                  "Timeoff Requests",
                  style: TextStyle(fontSize: 16),
                ),
              )
            : const SizedBox(),
        const Divider(indent: 16 * 2, endIndent: 16 * 2),
        usermail == "admin@gmail.com"
            ? ListTile(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) {
                      return const AllShifts();
                    }),
                  );
                },
                leading: const Icon(Icons.calendar_month),
                title: const Text(
                  "All Shifts",
                  style: TextStyle(fontSize: 16),
                ),
              )
            : const SizedBox(),
        const Divider(indent: 16 * 2, endIndent: 16 * 2),
        ListTile(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) {
                return const Mashifts();
              }),
            );
          },
          leading: const Icon(Icons.edit_calendar),
          title: const Text(
            "Your Shifts",
            style: TextStyle(fontSize: 16),
          ),
        ),
        const Divider(indent: 16 * 2, endIndent: 16 * 2),
        ListTile(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) {
                return const Swapper();
              }),
            );
          },
          leading: const Icon(Icons.change_circle_outlined),
          title: const Text(
            "Swap Requests",
            style: TextStyle(fontSize: 16),
          ),
        ),
        const Divider(indent: 16 * 2, endIndent: 16 * 2),
        ListTile(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) {
                return const Offs();
              }),
            );
          },
          leading: const Icon(Icons.offline_bolt),
          title: const Text(
            "Your Offs",
            style: TextStyle(fontSize: 16),
          ),
        ),
        const Divider(indent: 16 * 2, endIndent: 16 * 2),
        ListTile(
          onTap: () async {
            await authObj.signOut();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) {
                return const Usahili();
              }),
              (route) => false,
            );
          },
          leading: const Icon(Icons.logout),
          title: const Text(
            "Logout",
            style: TextStyle(fontSize: 16),
          ),
        ),
        const Divider(indent: 16 * 2, endIndent: 16 * 2),
      ],
    ),
  );
}
