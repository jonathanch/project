import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartkit_pro/app/routes.dart';
//import 'package:smartkit_pro/ui/fullApps/foodMaster/helper/drawerstyle/utils.dart';
import 'package:smartkit_pro/ui/theme/theme.dart';

import '../ui/fullApps/hotelBooking/global/global.dart';

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  sharedPreferences = await SharedPreferences.getInstance();
  await Firebase.initializeApp(); /* initialise Firebase */
 /* SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
     // statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark));
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]); */
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ThemeAndRTLCubit>(
      create: (_) => ThemeAndRTLCubit(),
      child: Builder(builder: (context) {
        return BlocBuilder<ThemeAndRTLCubit, ThemeAndRTLState>(
          bloc: context.read<ThemeAndRTLCubit>(),
          builder: (context, state) {
            return MaterialApp(
              builder: (context, child) => Directionality(
                  textDirection: state.textDirection, child: child!),
              theme: state.theme,
              debugShowCheckedModeBanner: false,
              initialRoute: Routes.home,
              onGenerateRoute: Routes.onGenerateRoute,
            );
          },
        );
      }),
    );
  }
}
