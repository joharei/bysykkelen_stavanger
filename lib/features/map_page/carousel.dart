import 'package:bysykkelen_stavanger/features/info_card/book_bike_page.dart';
import 'package:bysykkelen_stavanger/features/map_page/bloc/bloc.dart';
import 'package:bysykkelen_stavanger/features/map_page/bloc/state.dart';
import 'package:bysykkelen_stavanger/models/models.dart';
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
            height: 145,
            child: PageView.builder(
              controller: _pageController,
              itemCount: stations.length,
              itemBuilder: (context, index) {
                var station = stations[index];
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  child: Card(
                    child: ListTile(
                      title: Text(station.name),
                      subtitle: Column(
                        children: [
                          Text('Free bikes: ${station.freeBikes}'),
                          Padding(padding: EdgeInsets.only(top: 16)),
                          RaisedButton(
                            onPressed: () => BookBikePage.show(
                                  context,
                                  Provider.of(context),
                                  station,
                                ),
                            child: Text('Book bike'),
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
