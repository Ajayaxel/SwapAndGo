import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swap_app/bloc/active_subscription/active_subscription_bloc.dart';
import 'package:swap_app/bloc/auth_bloc.dart';
 import 'package:swap_app/services/active_subscription_service.dart';
import 'package:swap_app/bloc/station/station_bloc.dart';
import 'package:swap_app/bloc/station/station_event.dart';
import 'package:swap_app/bloc/qrcode/qrcode_bloc.dart';
import 'package:swap_app/bloc/profile_image/profile_image_bloc.dart';
import 'package:swap_app/bloc/address/address_bloc.dart';
import 'package:swap_app/presentation/widget/app_wrapper.dart';
import 'package:swap_app/repo/station_repository.dart';
import 'package:swap_app/repo/profile_image_repository.dart';
import 'package:swap_app/repo/address_repository.dart';
import 'package:swap_app/services/storage_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
   await StorageHelper.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(),
        ),
        BlocProvider(
          create: (context) => StationBloc(StationRepository())..add(LoadStations()),
        ),
        BlocProvider(
          create: (context) => QrcodeBloc(),
        ),
        BlocProvider(
          create: (context) => ProfileImageBloc(repository: ProfileImageRepository()),
        ),
        BlocProvider(
          create: (context) => AddressBloc(addressRepository: AddressRepository()),
        ),
        BlocProvider(
          create: (context) => ActiveSubscriptionBloc(activeSubscriptionService: ActiveSubscriptionService()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: Color(0xff000000),
          fontFamily: GoogleFonts.manrope().fontFamily,
        ),
        home: AppWrapper(),
      ),
    );
  }
}


