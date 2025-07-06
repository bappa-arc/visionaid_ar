import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:country_picker/country_picker.dart';
import 'package:visionaid_ar/widgets/country_emergency_number.dart';
import 'package:visionaid_ar/features/fully_blind/tts_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _customContactController =
      TextEditingController();
  String selectedCountry = 'IN';
  String emergencyNumber = '112';
  bool sendSms = false;
  bool makeCall = false;
  bool callCustomContact = false;
  bool ttsEnabled = true;
  double ttsRate = 0.5;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await SettingsManager().loadSettings();
    setState(() {
      _customContactController.text = settings['customContact'];
      selectedCountry = settings['selectedCountry'];
      emergencyNumber = settings['emergencyNumber'];
      sendSms = settings['sendSms'];
      makeCall = settings['makeCall'];
      callCustomContact = settings['callCustomContact'];
      ttsRate = settings['ttsRate'];
    });
  }

  Future<void> _saveSettings() async {
    await SettingsManager().saveSettings(
      customContact: _customContactController.text,
      selectedCountry: selectedCountry,
      emergencyNumber: emergencyNumber,
      sendSms: sendSms,
      makeCall: makeCall,
      callCustomContact: callCustomContact,
      ttsRate: ttsRate,
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Changes saved successfully')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color.fromARGB(255, 157, 168, 230),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Emergency Settings
          _buildSectionHeader('Emergency Settings'),
          const SizedBox(height: 10),
          TextField(
            controller: _customContactController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Emergency Contact Number',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () {
              showCountryPicker(
                context: context,
                onSelect: (country) {
                  setState(() {
                    selectedCountry = country.countryCode;
                    emergencyNumber =
                        countryEmergencyNumbers[country.countryCode] ?? '112';
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
                    "Country: $selectedCountry",
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
          const SizedBox(height: 10),
          CheckboxListTile(
            title: const Text("Send SMS to my entered contact"),
            value: sendSms,
            onChanged: (val) => setState(() => sendSms = val!),
          ),
          CheckboxListTile(
            title: Text("Call your country's emergency number"),
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
          const Divider(),

          // Speech Settings
          _buildSectionHeader('Speech Settings'),
          const SizedBox(height: 10),
          ListTile(
            title: const Text('Speech Rate'),
            subtitle: Slider(
              value: ttsRate,
              onChanged: (val) {
                setState(() {
                  ttsRate = val;
                });
                TTSHelper().updateTTSSettings(
                  enabled: true,
                  rate: ttsRate,
                  voice: 'female', // or use your preferred/default voice
                );
              },
              min: 0.1,
              max: 2.0,
            ),
          ),
          const Divider(),

          // Save Button
          Center(
            child: ElevatedButton(
              onPressed: _saveSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 122, 140, 243),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
                textStyle: const TextStyle(fontSize: 16),
              ),
              child: const Text(
                'Save All Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }
}

class SettingsManager {
  static final SettingsManager _instance = SettingsManager._internal();

  factory SettingsManager() => _instance;

  SettingsManager._internal();

  Future<void> saveSettings({
    required String customContact,
    required String selectedCountry,
    required String emergencyNumber,
    required bool sendSms,
    required bool makeCall,
    required bool callCustomContact,
    required double ttsRate,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('customContact', customContact);
    await prefs.setString('selectedCountry', selectedCountry);
    await prefs.setString('emergencyNumber', emergencyNumber);
    await prefs.setBool('sendSms', sendSms);
    await prefs.setBool('makeCall', makeCall);
    await prefs.setBool('callCustomContact', callCustomContact);
    await prefs.setDouble('ttsRate', ttsRate);
  }

  Future<Map<String, dynamic>> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'customContact': prefs.getString('customContact') ?? '',
      'selectedCountry': prefs.getString('selectedCountry') ?? 'India',
      'emergencyNumber': prefs.getString('emergencyNumber') ?? '112',
      'sendSms': prefs.getBool('sendSms') ?? false,
      'makeCall': prefs.getBool('makeCall') ?? false,
      'callCustomContact': prefs.getBool('callCustomContact') ?? false,
      'ttsRate': prefs.getDouble('ttsRate') ?? 0.5,
    };
  }
}
