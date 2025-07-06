import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:country_picker/country_picker.dart';
import 'package:visionaid_ar/widgets/country_emergency_number.dart';

class FirstTimeSetupScreen extends StatefulWidget {
  const FirstTimeSetupScreen({Key? key}) : super(key: key);

  @override
  State<FirstTimeSetupScreen> createState() => _FirstTimeSetupScreenState();
}

class _FirstTimeSetupScreenState extends State<FirstTimeSetupScreen> {
  String selectedCountryCode = 'IN';
  String emergencyNumber = '112';
  String customContact = '';
  bool sendSms = true;
  bool makeCall = true;
  bool callCustomContact = false;

  void _saveSettingsAndContinue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTimeSetupDone', true);
    await prefs.setString('emergencyNumber', emergencyNumber);
    await prefs.setString('customContact', customContact);
    await prefs.setBool('sendSms', sendSms);
    await prefs.setBool('makeCall', makeCall);
    await prefs.setBool('callCustomContact', callCustomContact);

    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Emergency Setup",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.redAccent,
      ),
      body: GestureDetector(
        onTap:
            () => FocusScope.of(context).unfocus(), // Dismiss keyboard on tap
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Choose your country:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () {
                  showCountryPicker(
                    context: context,
                    onSelect: (Country country) {
                      setState(() {
                        selectedCountryCode = country.countryCode;
                        emergencyNumber =
                            countryEmergencyNumbers[country.countryCode] ??
                            '112';
                      });
                    },
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Country: $selectedCountryCode",
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        "Emergency: $emergencyNumber",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Emergency Contact Number",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  customContact = value;
                },
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              const Divider(),
              const Text(
                "Preferences:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              CheckboxListTile(
                title: const Text("Send SMS to my entered contact"),
                value: sendSms,
                onChanged: (val) {
                  setState(() {
                    sendSms = val!;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text("Call your country's emergency number"),
                value: makeCall,
                onChanged: (val) {
                  setState(() {
                    makeCall = val!;
                    if (makeCall) {
                      callCustomContact = false; // Disable custom contact call
                    }
                  });
                },
              ),
              CheckboxListTile(
                title: const Text("Call your entered contact number"),
                value: callCustomContact,
                onChanged: (val) {
                  setState(() {
                    callCustomContact = val!;
                    if (callCustomContact) {
                      makeCall = false; // Disable country emergency call
                    }
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveSettingsAndContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Text(
                  "Save & Continue",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
