import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tic_tac_toe/model/history_hive_model.dart';
import 'package:flutter_tic_tac_toe/screens/main_menu.dart';
import 'package:flutter_tic_tac_toe/storage/history_box.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';

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
          home: MyHomePage(),
        ),
      );
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MainMenu()),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(255, 180, 180, 180),
                onPrimary: Colors.white,
                minimumSize: Size(80.0.w, 8.0.h),
              ),
              child: Text(
                'Start',
                style: TextStyle(
                  fontSize: 20.0.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: () {
                SystemNavigator.pop();
              },
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(255, 180, 180, 180),
                onPrimary: Colors.white,
                minimumSize: Size(80.0.w, 8.0.h),
              ),
              child: Text(
                'Quit',
                style: TextStyle(
                  fontSize: 20.0.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
