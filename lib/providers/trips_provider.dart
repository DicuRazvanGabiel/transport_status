import 'package:flutter/foundation.dart';
import '../models/trip_model.dart';

class TripProvider with ChangeNotifier {
  List<Trip> trips = [];
}
