import 'package:flutter/material.dart';

double safeAreaTopInset(BuildContext context) =>
    MediaQuery.of(context).padding.top +
    MediaQuery.of(context).viewInsets.top;

double safeAreaBottomInset(BuildContext context) =>
    MediaQuery.of(context).padding.bottom +
    MediaQuery.of(context).viewInsets.bottom;
