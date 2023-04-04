import 'package:flutter/material.dart';

import '../models/trip_model.dart';

class DocumentList extends StatelessWidget {
  final Trip trip;
  final Function addMoreDocuments;
  final List<String> images;

  const DocumentList(
      {super.key,
      required this.addMoreDocuments,
      required this.trip,
      required this.images});

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
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Image.network(
                      images[index],
                      width: 65,
                      fit: BoxFit.cover,
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
