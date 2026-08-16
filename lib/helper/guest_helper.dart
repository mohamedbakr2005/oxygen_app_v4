import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

class GuestHelper {
  static Future<int> getGuestId() async {
    final prefs = await SharedPreferences.getInstance();
    int? id = prefs.getInt('guest_id');

    if (id == null) {
      id = 100000 + Random().nextInt(900000);
      await prefs.setInt('guest_id', id);
    }
    return id;
  }
}
