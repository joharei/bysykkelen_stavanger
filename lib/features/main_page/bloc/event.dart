import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class MainEvent extends Equatable {
  final int navIndex;

  MainEvent({@required this.navIndex});

  @override
  List<Object> get props => [navIndex];
}
