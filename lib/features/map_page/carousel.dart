import 'package:bysykkelen_stavanger/features/book_bike/book_bike_page.dart';
import 'package:bysykkelen_stavanger/features/map_page/bloc/bloc.dart';
import 'package:bysykkelen_stavanger/features/map_page/bloc/state.dart';
import 'package:bysykkelen_stavanger/models/models.dart';
import 'package:bysykkelen_stavanger/shared/localization/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class BikeCarousel extends StatelessWidget {
  final _pageController = PageController(viewportFraction: 0.9);

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: BlocProvider.of<BikeStationsBloc>(context),
      listener: (context, BikesState state) {
        if (state is BikesLoaded && state.selectedMarkerId != null) {
          var stations = state.stations.values.toList();
          var selectedStationId = state.selectedMarkerId;
          _pageController.jumpToPage(
            stations.indexWhere((station) => station.id == selectedStationId),
          );
        }
      },
      child: BlocBuilder(
        bloc: BlocProvider.of<BikeStationsBloc>(context),
        builder: (context, BikesState state) {
          List<Station> stations = [];
          if (state is BikesLoaded) {
            stations = state.stations.values.toList();
          }

          return SizedBox(
            height: 165,
            child: PageView.builder(
              controller: _pageController,
              itemCount: stations.length,
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
                            onPressed: () => BookBikePage.show(
                                  context,
                                  Provider.of(context),
                                  station,
                                ),
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
