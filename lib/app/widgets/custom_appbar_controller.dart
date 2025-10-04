
// === location_controller.dart ===
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:travel_app2/app/modules/my_profile/controllers/my_profile_controller.dart';

class LocationController extends GetxController {
  var currentAddress = 'Fetching location...'.obs;
  var city = ''.obs;

  @override
  void onInit() {
    super.onInit();
    getCurrentLocation();
  MyProfileController().fetchProfile();
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      currentAddress.value = 'Location services disabled';
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        currentAddress.value = 'Permission denied';
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      currentAddress.value = 'Permission permanently denied';
      return;
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

    if (placemarks.isNotEmpty) {
      final place = placemarks.first;
      currentAddress.value = '${place.locality}, ${place.administrativeArea}, ${place.country}';
      city.value = place.locality ?? 'Unknown';
    }
  }
}
