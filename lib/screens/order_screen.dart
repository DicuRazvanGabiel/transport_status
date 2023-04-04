import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:transport_status/enums/DriverStatus.dart';
import 'package:transport_status/models/trip_model.dart';
import 'package:transport_status/screens/loading_screen.dart';
import 'package:transport_status/widgets/bottom_sheet_item.dart';
import '../enums/MenuOptions.dart';
import '../widgets/trip_item.dart';

class OrderScreen extends StatelessWidget {
  static const String routeName = '/order';
  final ImagePicker _picker = ImagePicker();
  final DriverStatus status;

  OrderScreen({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    print(status);

    Future<void> uploadGalaryImages(
        Trip trip, ImagesPickupDelivery type) async {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        context.loaderOverlay.show();
        for (XFile img in images) {
          await addImageUrl(uid, trip, img, type);
        }
        context.loaderOverlay.hide();
      }
    }

    Future<void> takePicture(Trip trip, ImagesPickupDelivery type) async {
      XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        context.loaderOverlay.show();
        await addImageUrl(uid, trip, image, type);
        context.loaderOverlay.hide();
      }
    }

    void markAsPickedup(Trip trip) async {
      showModalBottomSheet(
          context: context,
          builder: (ctx) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BottomSheetItem(
                    title: 'Incarca poze',
                    trailingIcon: Icons.upload,
                    leadingIcon: Icons.photo,
                    onTap: () async {
                      Navigator.of(context).pop();
                      await uploadGalaryImages(
                          trip, ImagesPickupDelivery.Pickup);
                      trip.setPickedupTrue();
                    },
                  ),
                  BottomSheetItem(
                    title: 'Camera',
                    trailingIcon: Icons.upload,
                    leadingIcon: Icons.add_a_photo,
                    onTap: () async {
                      Navigator.of(context).pop();
                      await takePicture(trip, ImagesPickupDelivery.Pickup);
                      trip.setPickedupTrue();
                    },
                  ),
                ],
              ),
            );
          });
    }

    void markAsDelivered(Trip trip) async {
      showModalBottomSheet(
          context: context,
          builder: (ctx) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BottomSheetItem(
                    title: 'Incarca poze',
                    trailingIcon: Icons.upload,
                    leadingIcon: Icons.photo,
                    onTap: () async {
                      Navigator.of(context).pop();
                      await uploadGalaryImages(
                          trip, ImagesPickupDelivery.Delivery);
                      trip.setDeliveredTrue();
                    },
                  ),
                  BottomSheetItem(
                    title: 'Camera',
                    trailingIcon: Icons.upload,
                    leadingIcon: Icons.add_a_photo,
                    onTap: () async {
                      Navigator.of(context).pop();
                      await takePicture(trip, ImagesPickupDelivery.Delivery);
                      trip.setDeliveredTrue();
                    },
                  ),
                ],
              ),
            );
          });
    }

    void showDialogOnLogout() {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Deconectare"),
          content: const Text("Esti sigur ca vrei sa te deconectezi?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Nu"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                FirebaseAuth.instance.signOut();
              },
              child: const Text("Da", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    }

    void showDialogOnRest() {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Pauza"),
          content: const Text("Esti sigur ca vrei sa faci pauza?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Nu"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                FirebaseFirestore.instance.doc('drivers/$uid').update({
                  'status': 'rest',
                });
              },
              child: const Text("Da", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    }

    void showDialogOnCloreOrder() {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Inchide cursa"),
          content: const Text("Esti sigur ca vrei sa inchizi cursa?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Nu"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await FirebaseFunctions.instance
                    .httpsCallable("onCloseOrder")
                    .call({"driverID": uid});
              },
              child: const Text("Da", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    }

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('drivers/$uid/order')
          .snapshots(),
      builder: (BuildContext context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.data == null) return const LoadingScreen();

        final length = snapshot.data!.docs.length;
        final trips = createTrips(snapshot);

        final appBar = AppBar(
          title: const Text("Cursa"),
          actions: [
            PopupMenuButton(
              itemBuilder: (_) => [
                if (trips.isNotEmpty)
                  const PopupMenuItem(
                    value: MenuOptions.rest,
                    child: Text("Pauza"),
                  ),
                if (trips.isNotEmpty)
                  const PopupMenuItem(
                    value: MenuOptions.closeOrder,
                    child: Text("Inchide cursa"),
                  ),
                const PopupMenuItem(
                  value: MenuOptions.logout,
                  child: Text("Deconectare"),
                ),
              ],
              icon: const Icon(Icons.more_vert),
              onSelected: (MenuOptions value) async {
                if (MenuOptions.logout == value) {
                  showDialogOnLogout();
                }
                if (MenuOptions.closeOrder == value) {
                  context.loaderOverlay.show();

                  context.loaderOverlay.hide();
                }
                if (MenuOptions.rest == value) {
                  showDialogOnRest();
                }
              },
            ),
          ],
        );

        return Scaffold(
          appBar: appBar,
          body: trips.isEmpty
              ? const Center(
                  child: Text("Nu ai nicio cursa in desfasurare"),
                )
              : LoaderOverlay(
                  child: SizedBox(
                    height: double.infinity,
                    width: double.infinity,
                    child: ListView.builder(
                      itemBuilder: (_, index) {
                        Trip trip = trips[index];
                        return TripItem(
                          trip: trip,
                          markAsPickedup: markAsPickedup,
                          markAsDelivered: markAsDelivered,
                        );
                      },
                      itemCount: length,
                    ),
                  ),
                ),
        );
      },
    );
  }

  List<dynamic> createTrips(
    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
  ) {
    List<dynamic> trips = [];
    for (final element in snapshot.data!.docs) {
      final pickup = Pickup(
          pickUpAddress: element['pickup_address'] as String,
          pickUpTime: (element['pickup_time'] as Timestamp).toDate(),
          cargo: element['cargo'] as String,
          transitTime: element['transit_time'] as String,
          refNumber: element['ref_number'] as String);
      final delivery = Delivery(
          deliveryAddress: element['delivery_address'] as String,
          deliveryTime: (element['delivery_time'] as Timestamp).toDate(),
          refNumber: element['ref_number'] as String,
          contact: element['contact'] as String);

      final isPickedup = element.data().containsKey('isPickedup')
          ? element['isPickedup']
          : false;

      final isDelivered = element.data().containsKey('isDelivered')
          ? element['isDelivered']
          : false;

      List<String> imagesPickup = element.data().containsKey('images_pickup')
          ? List.castFrom(element['images_pickup'] as List ?? [])
          : [];

      List<String> imagesDelivery =
          element.data().containsKey('images_delivery')
              ? List.castFrom(element['images_delivery'] as List ?? [])
              : [];

      final trip = Trip(
          id: element.id,
          pickup: pickup,
          delivery: delivery,
          isPickedup: isPickedup,
          isDelivered: isDelivered,
          imagesPickup: imagesPickup,
          imagesDelivery: imagesDelivery);

      trips.add(trip);
    }
    return trips;
  }

  Future<void> addImageUrl(
      String uid, Trip trip, XFile img, ImagesPickupDelivery type) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child(uid)
        .child(trip.id)
        .child(img.name);
    await ref.putFile(File(img.path));
    final downloadLinkFuture = await ref.getDownloadURL();
    trip.addImageLink(downloadLinkFuture.toString(), type);
  }
}
