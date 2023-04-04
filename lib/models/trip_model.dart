import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

enum ImagesPickupDelivery { Pickup, Delivery }

class Pickup {
  final DateTime pickUpTime;
  final String pickUpAddress;
  final String cargo;
  final String? refNumber;
  final String transitTime;
  final List<String>? images;

  Pickup(
      {required this.pickUpTime,
      required this.pickUpAddress,
      required this.cargo,
      this.refNumber,
      required this.transitTime,
      this.images});
}

class Delivery {
  final DateTime deliveryTime;
  final String deliveryAddress;
  final String? refNumber;
  final String contact;
  List<String>? images;

  Delivery({
    required this.deliveryTime,
    required this.deliveryAddress,
    this.refNumber,
    required this.contact,
  });
}

class Trip with ChangeNotifier {
  final String id;
  Pickup pickup;
  Delivery delivery;
  bool isPickedup;
  bool isDelivered;
  final uid = FirebaseAuth.instance.currentUser!.uid;
  List<String> imagesPickup;
  List<String> imagesDelivery;

  Trip(
      {required this.id,
      required this.pickup,
      required this.delivery,
      this.isPickedup = false,
      this.isDelivered = false,
      required this.imagesPickup,
      required this.imagesDelivery});

  Future<void> setPickedupTrue() async {
    await FirebaseFirestore.instance
        .doc('drivers/$uid/order/$id')
        .update({"isPickedup": true});
    isPickedup = true;
    notifyListeners();
  }

  Future<void> setDeliveredTrue() async {
    await FirebaseFirestore.instance
        .doc('drivers/$uid/order/$id')
        .update({"isDelivered": true});
    isDelivered = true;
    notifyListeners();
  }

  Future<void> addImageLink(String imageLink, ImagesPickupDelivery type) async {
    final location = type == ImagesPickupDelivery.Pickup
        ? 'images_pickup'
        : 'images_delivery';
    await FirebaseFirestore.instance.doc('drivers/$uid/order/$id').update({
      location: FieldValue.arrayUnion([imageLink])
    });
  }
}
