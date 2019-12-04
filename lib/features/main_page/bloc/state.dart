import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class MainState extends Equatable {
  final int navIndex;

  MainState({@required this.navIndex}) : assert(navIndex != null);

  MainState copyWith({int navIndex}) =>
      MainState(navIndex: navIndex ?? this.navIndex);

  @override
  List<Object> get props => [navIndex];
}
