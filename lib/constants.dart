import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

String defIMG =
    "https://thumbs.dreamstime.com/b/default-avatar-profile-icon-vector-social-media-user-image-182145777.jpg";

indicateProgress({context}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    },
  );
}

dismissStuff({context}) {
  Navigator.of(context).pop();
}

mesenja({context, ujumbe, isGood}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(ujumbe),
      backgroundColor: isGood ? Colors.green : Colors.red,
    ),
  );
}

Widget getWardInfo({idYaWard}) {
  FirebaseFirestore fstr = FirebaseFirestore.instance;
  return StreamBuilder(
    stream: fstr.collection('wards').doc(idYaWard).snapshots(),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        var ward = (snapshot.data as dynamic).data();
        return RichText(
            text: TextSpan(children: [
          const TextSpan(
            text: "Ward name: ",
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: "${ward['name']}",
            style: const TextStyle(
              color: Colors.black,
            ),
          ),
        ]));
      } else if (snapshot.hasError) {
        return const Text("Data Unavailable");
      } else {
        return const Text("Please Wait...");
      }
    },
  );
}
