import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/route_manager.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:the_movie_db_flutter/cubits/index.dart';
import 'package:the_movie_db_flutter/repositories/index.dart';
import 'package:the_movie_db_flutter/services/index.dart';
import 'package:the_movie_db_flutter/util/index.dart';

Future<void> main() async {
  //debugPrint = (String? message, {int? wrapWidth}) {};

  WidgetsFlutterBinding.ensureInitialized();

  ConnectivityUtil.configureConnectivityStream();

  final HydratedStorage hydratedStorage = await HydratedStorage.build(
    storageDirectory: kIsWeb ? HydratedStorage.webStorageDirectory : await getTemporaryDirectory(),
  );

  SystemChrome.setPreferredOrientations(<DeviceOrientation>[DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    BlocOverrides.runZoned(
      () => HydratedBlocOverrides.runZoned(
        () => runApp(const MovieApp()),
        storage: hydratedStorage,
      ),
      blocObserver: CustomBlocObserver(),
    );
  });
}

class MovieApp extends StatelessWidget {
  const MovieApp({
    Key? key,
  }) : super(key: key);

  static final GlobalKey appKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final Dio _httpClient = Dio();
    _httpClient.options.headers["Content-Type"] = "application/json;charset=utf-8";
    _httpClient.options.headers["Accept"] = "application/json;charset=utf-8";
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
        BlocProvider<MoviesCubit>(create: (_) => MoviesCubit(MoviesRepository(MoviesService(_httpClient)))),
        BlocProvider<TvSeriesCubit>(create: (_) => TvSeriesCubit(TvSeriesRepository(TvSeriesService(_httpClient)))),
        BlocProvider<SessionIdCubit>(create: (_) => SessionIdCubit(SessionIdRepository(SessionIdService(_httpClient)))),
      ],
      child: BlocConsumer<ThemeCubit, ThemeState>(
        listener: (BuildContext context, ThemeState state) {},
        builder: (BuildContext context, ThemeState state) => ScreenUtilInit(
          designSize: const Size(410, 840),
          builder: () {
            return GetMaterialApp(
              key: appKey,
              title: 'Flutter The Movie DB',
              theme: context.watch<ThemeCubit>().lightTheme,
              darkTheme: context.watch<ThemeCubit>().darkTheme,
              themeMode: context.watch<ThemeCubit>().themeMode,
              locale: const Locale("tr", "TR"),
              builder: (BuildContext context, Widget? child) {
                final MediaQueryData data = MediaQuery.of(context);
                return MediaQuery(
                  data: data.copyWith(
                    textScaleFactor: 1.0,
                  ),
                  child: child ?? const SizedBox(),
                );
              },
              onGenerateRoute: Routes.generateRoute,
              onUnknownRoute: Routes.errorRoute,
              localizationsDelegates: <LocalizationsDelegate<dynamic>>[
                FlutterI18nDelegate(
                  translationLoader: FileTranslationLoader(),
                )..load(const Locale('tr', 'TR')),
                GlobalMaterialLocalizations.delegate,
                DefaultMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                DefaultCupertinoLocalizations.delegate,
              ],
              debugShowCheckedModeBanner: false,
              enableLog: true,
              logWriterCallback: (String text, {bool isError = false}) {
                debugPrint("GetXLog: $text");
              },
            );
          },
        ),
      ),
    );
  }
}
