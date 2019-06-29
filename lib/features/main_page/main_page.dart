import 'package:bysykkelen_stavanger/features/bookings_list/bookings_list_page.dart';
import 'package:bysykkelen_stavanger/features/map/bloc/bloc.dart';
import 'package:bysykkelen_stavanger/features/map/map_page.dart';
import 'package:bysykkelen_stavanger/features/trips/trips_page.dart';
import 'package:bysykkelen_stavanger/repositories/repositories.dart';
import 'package:bysykkelen_stavanger/shared/localization/localization.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  final BikeRepository bikeRepository;

  const MainPage({Key key, @required this.bikeRepository}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  BikeStationsBloc bikeStationsBloc;
  List<Widget> pages;

  int navIndex = 0;

  @override
  void initState() {
    super.initState();
    bikeStationsBloc = BikeStationsBloc(bikeRepository: widget.bikeRepository);
    pages = [
      MapPage(bikeStationsBloc: bikeStationsBloc),
      BookingsListPage(bikeRepository: widget.bikeRepository),
      TripsPage(),
    ];
  }

  @override
  void dispose() {
    bikeStationsBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[navIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navIndex,
        onTap: (index) => setState(() {
          navIndex = index;
        }),
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
    );
  }
}
