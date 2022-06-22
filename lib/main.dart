import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'homeNavigation.dart';


void main() {
  runApp(ProviderScope(
    child:  MaterialApp(
      home: HomeNavigation(),
    ),
  ));
}

