import 'package:bysykkelen_stavanger/features/book_bike/book_bike_page.dart';
import 'package:bysykkelen_stavanger/features/map/bloc/bloc.dart';
import 'package:bysykkelen_stavanger/features/map/bloc/event.dart';
import 'package:bysykkelen_stavanger/features/map/bloc/state.dart';
import 'package:bysykkelen_stavanger/models/models.dart';
import 'package:bysykkelen_stavanger/shared/localization/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BikeCarousel extends StatefulWidget {
  @override
  _BikeCarouselState createState() => _BikeCarouselState();
}

class _BikeCarouselState extends State<BikeCarousel> {
  final _pageController = PageController(viewportFraction: 0.9);
  var _animatingToPage = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: BlocProvider.of<BikeStationsBloc>(context),
      listener: (context, BikesState state) async {
        if (state is BikesLoaded && state.selectedMarkerId != null) {
          final selectedStationId = state.selectedMarkerId;
          final page = state.stations
              .indexWhere((station) => station.id == selectedStationId);
          if (state.wasResumed) {
            _pageController.jumpToPage(page);
          } else {
            _animatingToPage = true;
            await _pageController.animateToPage(
              page,
              duration: Duration(milliseconds: 500),
              curve: Curves.ease,
            );
            _animatingToPage = false;
          }
        }
      },
      child: BlocBuilder(
        bloc: BlocProvider.of<BikeStationsBloc>(context),
        builder: (context, BikesState state) {
          List<Station> stations = [];
          if (state is BikesLoaded) {
            stations = state.stations;
          }

          return SizedBox(
            height: 165,
            child: PageView.builder(
              controller: _pageController,
              itemCount: stations.length,
              onPageChanged: (page) {
                if (!_animatingToPage) {
                  BlocProvider.of<BikeStationsBloc>(context)
                      .add(MarkerSelected(stationId: stations[page].id));
                }
              },
              itemBuilder: (context, index) {
                var station = stations[index];
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.only(left: 4, right: 4, bottom: 16),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 6,
                    child: ListTile(
                      title: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Center(
                          child: Text(station.name),
                          heightFactor: 1,
                        ),
                      ),
                      subtitle: Column(
                        children: [
                          Text(Localization.of(context)
                              .availableBikes(station.freeBikes)),
                          Padding(padding: EdgeInsets.only(top: 16)),
                          RaisedButton(
                            onPressed: () =>
                                BookBikePage.show(context, station),
                            child: Text(Localization.of(context).bookBike),
                          ),
                        ],
                      ),
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
