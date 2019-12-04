import 'package:bysykkelen_stavanger/features/bookings_list/bloc/bloc.dart';
import 'package:bysykkelen_stavanger/features/bookings_list/bookings_list_page.dart';
import 'package:bysykkelen_stavanger/features/main_page/bloc/bloc.dart';
import 'package:bysykkelen_stavanger/features/main_page/bloc/event.dart';
import 'package:bysykkelen_stavanger/features/main_page/bloc/state.dart';
import 'package:bysykkelen_stavanger/features/map/bloc/bloc.dart';
import 'package:bysykkelen_stavanger/features/map/map_page.dart';
import 'package:bysykkelen_stavanger/features/trips/bloc/bloc.dart';
import 'package:bysykkelen_stavanger/features/trips/trips_navigator.dart';
import 'package:bysykkelen_stavanger/shared/localization/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with TickerProviderStateMixin<MainPage> {
  final tripsNavigatorKey = GlobalKey<NavigatorState>();

  List<Widget> pages;
  List<AnimationController> faders;
  List<Key> pageKeys;

  @override
  void initState() {
    super.initState();

    pages = [
      MapPage(),
      BookingsListPage(),
      TripsNavigator(navigatorKey: tripsNavigatorKey),
    ];
    faders = pages
        .map(
          (_) => AnimationController(
            vsync: this,
            duration: Duration(milliseconds: 300),
          ),
        )
        .toList();
    faders[BlocProvider.of<MainBloc>(context).state.navIndex].value = 1.0;
    pageKeys = List.generate(pages.length, (index) => GlobalKey()).toList();
  }

  @override
  void dispose() {
    for (var controller in faders) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<BikeStationsBloc>(
          create: (context) => BikeStationsBloc(),
        ),
        BlocProvider<BookingsBloc>(
          create: (context) => BookingsBloc(),
        ),
        BlocProvider<TripsBloc>(
          create: (context) => TripsBloc(),
        ),
      ],
      child: BlocBuilder<MainBloc, MainState>(
        builder: (context, state) {
          return WillPopScope(
            onWillPop: () async =>
                !await tripsNavigatorKey.currentState.maybePop(),
            child: Scaffold(
              body: Stack(
                children: _buildPages(),
              ),
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: state.navIndex,
                onTap: (index) {
                  BlocProvider.of<MainBloc>(context)
                      .add(MainEvent(navIndex: index));
                },
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.map),
                    title: Text(Localization.of(context).mapPageTitle),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.view_list),
                    title: Text(Localization.of(context).bookingsPageTitle),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.history),
                    title: Text(Localization.of(context).tripsPageTitle),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildPages() {
    Widget buildTransition(int pageIndex) => FadeTransition(
        opacity:
            faders[pageIndex].drive(CurveTween(curve: Curves.fastOutSlowIn)),
        child: KeyedSubtree(
          key: pageKeys[pageIndex],
          child: pages[pageIndex],
        ));
    Widget buildForward(int pageIndex) {
      faders[pageIndex].forward();
      return buildTransition(pageIndex);
    }

    Widget buildIgnorePointer(int pageIndex) {
      faders[pageIndex].reverse();
      if (faders[pageIndex].isAnimating) {
        return IgnorePointer(child: buildTransition(pageIndex));
      }
      return Offstage(child: buildTransition(pageIndex));
    }

    return [
      for (var pageIndex = 0; pageIndex < pages.length; pageIndex++)
        if (pageIndex == BlocProvider.of<MainBloc>(context).state.navIndex)
          buildForward(pageIndex)
        else
          buildIgnorePointer(pageIndex)
    ];
  }
}
