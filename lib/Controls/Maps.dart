import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

class MapUtils {
  MapUtils._();

  static Future<void> openMap(double latitude, double longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }

  static Future<Position> locateUser() async {
    GeolocationStatus geolocationStatus =
        await Geolocator().checkGeolocationPermissionStatus();
    if (geolocationStatus == GeolocationStatus.granted) {
      Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
          .then((location) {
        if (location != null) {
          print("Location: ${location.latitude},${location.longitude}");
        }
        return location;
      });
    } else
      return null;
  }
}
