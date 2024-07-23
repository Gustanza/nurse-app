import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nurse_project/constants.dart';
import 'package:nurse_project/drawer.dart';

class Nyumbani extends StatefulWidget {
  const Nyumbani({super.key});

  @override
  State<Nyumbani> createState() => _NyumbaniState();
}

class _NyumbaniState extends State<Nyumbani> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 24,
          title: const Text("NurseApp"),
        ),
        drawer: customDrawer(context: context),
        body: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('wards').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var data = (snapshot.data as dynamic).docs;
                return Body(data: data);
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }));
  }
}

class Body extends StatefulWidget {
  final dynamic data;
  const Body({super.key, required this.data});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: Text(
              "Request Shift",
              style: TextStyle(
                fontSize: 18,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: CupertinoListSection.insetGrouped(
              margin: EdgeInsets.zero,
              children: List.generate(
                widget.data.length,
                (index) {
                  return ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    trailing: IconButton.filled(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                          Colors.green[200],
                        ),
                      ),
                      onPressed: () async {
                        await pullInfo(idYaWard: widget.data[index].id);
                      },
                      icon: const Icon(
                        Icons.arrow_forward_ios,
                        // color: Colors.white,
                      ),
                    ),
                    title: Text(
                      "${widget.data[index]['name']}",
                      style: const TextStyle(
                        fontSize: 18, color: Colors.green,
                        // fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Morning Shift:     ',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: widget.data[index]['morning'] != null
                                    ? "Allocated"
                                    : "Available",
                                style: TextStyle(
                                  color: widget.data[index]['morning'] != null
                                      ? Colors.red
                                      : Colors.green,
                                  // fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Evening Shift:     ',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: widget.data[index]['evening'] != null
                                    ? "Allocated"
                                    : "Available",
                                style: TextStyle(
                                  color: widget.data[index]['evening'] != null
                                      ? Colors.red
                                      : Colors.green,
                                  // fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Night Shift:         ',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: widget.data[index]['night'] != null
                                    ? "Allocated"
                                    : "Available",
                                style: TextStyle(
                                  color: widget.data[index]['night'] != null
                                      ? Colors.red
                                      : Colors.green,
                                  // fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  pullInfo({idYaWard}) {
    return showModalBottomSheet(
        context: context,
        showDragHandle: true,
        builder: (context) {
          return FullInfo(idYaWard: idYaWard);
        });
  }
}

class FullInfo extends StatefulWidget {
  final String idYaWard;
  const FullInfo({super.key, required this.idYaWard});

  @override
  State<FullInfo> createState() => _FullInfoState();
}

class _FullInfoState extends State<FullInfo> {
  String mamail = FirebaseAuth.instance.currentUser?.email ?? "";
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('wards')
          .doc(widget.idYaWard)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var data = (snapshot.data as dynamic).data();
          return Column(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "${data['name']}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              CupertinoListSection.insetGrouped(
                children: [
                  ListTile(
                    title: const Text(
                      "Morning Shift",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: getNurseInfo(idYaNesi: data['morning']),
                    trailing: TextButton(
                      onPressed: () {
                        if (data['morning'] == null) {
                          requestShift(
                            shift: "morning",
                            who: mamail,
                            ward: widget.idYaWard,
                          );
                        } else {
                          requestSwap(
                            shift: "morning",
                            who: data['morning'],
                            ward: widget.idYaWard,
                          );
                        }
                      },
                      child: Text(
                        data['morning'] == null
                            ? "Request Shift"
                            : "Request Swap",
                      ),
                    ),
                  ),
                  ListTile(
                    title: const Text(
                      "Evening Shift",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: getNurseInfo(idYaNesi: data['evening']),
                    trailing: TextButton(
                      onPressed: () {
                        if (data['evening'] == null) {
                          requestShift(
                            shift: "evening",
                            who: mamail,
                            ward: widget.idYaWard,
                          );
                        } else {
                          requestSwap(
                            shift: "evening",
                            who: data['evening'],
                            ward: widget.idYaWard,
                          );
                        }
                      },
                      child: Text(
                        data['evening'] == null
                            ? "RequestShift"
                            : "Request Swap",
                      ),
                    ),
                  ),
                  ListTile(
                    title: const Text(
                      "Night Shift",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: getNurseInfo(idYaNesi: data['night']),
                    trailing: TextButton(
                      onPressed: () {
                        if (data['night'] == null) {
                          requestShift(
                            shift: "night",
                            who: mamail,
                            ward: widget.idYaWard,
                          );
                        } else {
                          requestSwap(
                            shift: "night",
                            who: data['night'],
                            ward: widget.idYaWard,
                          );
                        }
                      },
                      child: Text(
                        data['night'] == null
                            ? "Request Shift"
                            : "Request Swap",
                      ),
                    ),
                  )
                ],
              )
            ],
          );
        } else if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
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
                return Text("Nurse ${nesi['jina']}");
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

  requestShift({ward, shift, who}) async {
    indicateProgress(context: context);
    try {
      var token = await FirebaseMessaging.instance.getToken();
      await FirebaseFirestore.instance.collection('shift_requests').add({
        "ward": ward,
        "shift": shift,
        "who": who,
        "approved": false,
        "token": token,
        "started": null,
        "ended": null,
        "timestamp": DateTime.now(),
      });
      mesenja(
        context: context,
        isGood: true,
        ujumbe: "Shift request sent succesfully",
      );
    } catch (e) {
      mesenja(
        context: context,
        isGood: true,
        ujumbe: "Error occured",
      );
    }
    dismissStuff(context: context);
    dismissStuff(context: context);
  }

  requestSwap({ward, shift, who}) async {
    indicateProgress(context: context);
    try {
      var token = await FirebaseMessaging.instance.getToken();
      await FirebaseFirestore.instance.collection('swap_requests').add({
        "ward": ward,
        "shift": shift,
        "requestor": mamail,
        "requested": who,
        "token": token,
        "timestamp": DateTime.now(),
      });
      mesenja(
        context: context,
        isGood: true,
        ujumbe: "Swap request sent succesfully",
      );
    } catch (e) {
      mesenja(
        context: context,
        isGood: true,
        ujumbe: "Error occured",
      );
    }
    dismissStuff(context: context);
    dismissStuff(context: context);
  }
}
