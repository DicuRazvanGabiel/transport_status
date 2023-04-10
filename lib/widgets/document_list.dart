import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_viewer/image_viewer.dart';
import 'package:loader_overlay/loader_overlay.dart';

import '../models/trip_model.dart';

class DocumentList extends StatelessWidget {
  final Trip trip;
  final Function addMoreDocuments;
  final List<String> images;
  final String imageLocation;

  const DocumentList(
      {super.key,
      required this.addMoreDocuments,
      required this.trip,
      required this.images,
      required this.imageLocation});

  void deleteDocument(String imageUrl, BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .doc(
      'drivers/$uid/order/${trip.id}',
    )
        .update({
      imageLocation: FieldValue.arrayRemove([imageUrl])
    });

    await FirebaseStorage.instance.refFromURL(imageUrl).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Documente:"),
        Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width - 18 - 50,
              height: 105,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      ImageViewer.showImageSlider(
                          images: images, startingPosition: index);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        children: [
                          Image.network(
                            images[index],
                            width: 70,
                            fit: BoxFit.cover,
                            height: 80,
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          InkWell(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text("Sterge document?"),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text("Nu")),
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              deleteDocument(
                                                  images[index], context);
                                            },
                                            child: const Text(
                                              "Da",
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ))
                                      ],
                                    );
                                  });
                            },
                            child: Container(
                              width: 70,
                              height: 20,
                              color: Colors.red,
                              child: const Center(
                                child: Text(
                                  "Sterge",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
                itemCount: images.length,
              ),
            ),
            Container(
              color: Colors.grey,
              height: 70,
              width: 50,
              child: Center(
                child: IconButton(
                  icon: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    addMoreDocuments(trip);
                  },
                ),
              ),
            )
          ],
        ),
        const SizedBox(
          height: 20,
        )
      ],
    );
  }
}
