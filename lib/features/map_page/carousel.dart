import 'package:bysykkelen_stavanger/features/map_page/bloc/state.dart';
import 'package:bysykkelen_stavanger/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/bloc.dart';

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
            height: 80,
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
                      subtitle: Text('Free bikes: ${station.freeBikes}'),
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
