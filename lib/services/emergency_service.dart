import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmergencyService {
  static Future<void> activateEmergencyMode() async {
    await _requestPermissions();

    final prefs = await SharedPreferences.getInstance();
    final bool sendSms = prefs.getBool('sendSms') ?? true;
    final bool makeCall = prefs.getBool('makeCall') ?? true;
    final bool callCustomContact = prefs.getBool('callCustomContact') ?? false;
    final String customContact = prefs.getString('customContact') ?? '';
    final String emergencyNumber = prefs.getString('emergencyNumber') ?? '112';

    String locationUrl = "Location unavailable";
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      locationUrl =
          "https://maps.google.com/?q=${position.latitude},${position.longitude}";
    } catch (e) {
      debugPrint("Could not get location: $e");
    }

    String message = "🚨 Emergency! I need help.\nLocation: $locationUrl";

    // 1. Send SMS first
    if (sendSms && customContact.isNotEmpty) {
      await _sendSms(customContact, message);
      // Wait for 3 seconds before making the call
      await Future.delayed(const Duration(seconds: 3));
    }

    // 2. Make a call after SMS
    if (callCustomContact && customContact.isNotEmpty) {
      await FlutterPhoneDirectCaller.callNumber(customContact);
    } else if (makeCall) {
      await FlutterPhoneDirectCaller.callNumber(emergencyNumber);
    }
  }

  static Future<void> _requestPermissions() async {
    await Permission.location.request();
    await Permission.sms.request();
    await Permission.phone.request();
  }

  static Future<void> _sendSms(String phoneNumber, String message) async {
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: {'body': message},
    );
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      debugPrint("Could not launch SMS app");
    }
  }
}
