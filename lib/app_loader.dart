import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hung/ui/views/startup/wise_splash_screen.dart';
import 'package:stacked_services/stacked_services.dart';

import 'app/app.router.dart';

class AppData {
  const AppData();
}

class MyApp extends StatelessWidget {
  const MyApp({
    required this.data,
    super.key,
  });
  final AppData data;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "云宇之洲",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F1F1),
        brightness: Brightness.light,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
        fontFamily: 'Poppins',
      ),
      initialRoute: Routes.homeView,
      onGenerateRoute: StackedRouter().onGenerateRoute,
      navigatorKey: StackedService.navigatorKey,
      navigatorObservers: [
        StackedService.routeObserver,
      ],
      builder: EasyLoading.init(),
    );
  }
}

class AppLoader extends StatefulWidget {
  const AppLoader({super.key});

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader>
    with SingleTickerProviderStateMixin {
  final _isSplashScreenVisible = ValueNotifier(true);

  final _data = ValueNotifier<AppData?>(null);

  late final _controller = WiseSplashScreen.createController(this);

  Future<void>? _loader;

  @override
  void initState() {
    super.initState();

    _controller.addStatusListener(
      (AnimationStatus status) {
        _isSplashScreenVisible.value = !status.isCompleted;
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loader ??= _load(context);
  }

  @override
  void dispose() {
    _isSplashScreenVisible.dispose();
    _data.dispose();
    _controller.dispose();

    super.dispose();
  }

  Future<void> _load(BuildContext context) async {
    await Future<void>.delayed(const Duration(milliseconds: 1000));

    _data.value = const AppData();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _controller.forward().ignore();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ValueListenableBuilder(
              valueListenable: _data,
              builder: (context, data, _) {
                if (data == null) {
                  return const SizedBox.shrink();
                }

                return MyApp(
                  data: data,
                );
              },
            ),
            ValueListenableBuilder(
              valueListenable: _isSplashScreenVisible,
              builder: (context, isSplashScreenVisible, splashScreen) {
                if (isSplashScreenVisible) {
                  return splashScreen!;
                }

                return const SizedBox.shrink();
              },
              child: WiseSplashScreen(controller: _controller),
            ),
          ],
        ),
      ),
    );
  }
}
