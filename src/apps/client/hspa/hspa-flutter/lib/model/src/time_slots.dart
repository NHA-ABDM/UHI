import 'package:flutter/material.dart';

class TimeSlots {
  final TimeOfDay timeOfDay;
  final TimeOfDayFormat timeOfDayFormat;

  TimeSlots({required this.timeOfDay, this.timeOfDayFormat = TimeOfDayFormat.h_colon_mm_space_a});
}