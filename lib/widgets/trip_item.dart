import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:transport_status/widgets/document_list.dart';

import '../models/trip_model.dart';
import 'pickup_tile.dart';

class TripItem extends StatelessWidget {
  const TripItem(
      {super.key,
      required this.trip,
      required this.markAsPickedup,
      required this.markAsDelivered});

  final Trip trip;
  final Function markAsPickedup;
  final Function markAsDelivered;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Incarcare:",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (trip.isPickedup)
                const Icon(
                  Icons.check,
                  color: Colors.green,
                ),
            ],
          ),
          PickupTile(left: "Adresa:", right: trip.pickup.pickUpAddress),
          PickupTile(
              left: "Data si ora:",
              right:
                  DateFormat('dd/MM - HH:mm').format(trip.pickup.pickUpTime)),
          PickupTile(left: "Marfa:", right: trip.pickup.cargo),
          PickupTile(left: "Trimp transit:", right: trip.pickup.transitTime),
          if (trip.pickup.refNumber != null)
            PickupTile(left: 'Ref:', right: trip.pickup.refNumber!),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              trip.isPickedup
                  ? DocumentList(
                      trip: trip,
                      addMoreDocuments: markAsPickedup,
                      images: trip.imagesPickup,
                      imageLocation: 'images_pickup',
                    )
                  : ElevatedButton(
                      onPressed: () {
                        markAsPickedup(trip);
                      },
                      child: const Text("Incarcare")),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Descarcare:",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (trip.isDelivered)
                const Icon(
                  Icons.check,
                  color: Colors.green,
                ),
            ],
          ),
          PickupTile(left: "Adresa:", right: trip.delivery.deliveryAddress),
          PickupTile(
              left: "Data si ora:",
              right: DateFormat('dd/MM - HH:mm')
                  .format(trip.delivery.deliveryTime)),
          PickupTile(left: "Contact:", right: trip.delivery.contact),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!trip.isPickedup)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.timelapse,
                    color: Colors.red,
                  ),
                ),
              if (trip.isPickedup && !trip.isDelivered)
                ElevatedButton(
                    onPressed: () {
                      markAsDelivered(trip);
                    },
                    child: const Text("Descarcare")),
              if (trip.isDelivered == true)
                DocumentList(
                    trip: trip,
                    addMoreDocuments: markAsDelivered,
                    images: trip.imagesDelivery,
                    imageLocation: 'images_delivery')
            ],
          ),
          Divider(
            height: 20,
            thickness: 8,
            color: Theme.of(context).colorScheme.background,
          )
        ],
      ),
    );
  }
}
