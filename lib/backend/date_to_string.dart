import 'package:intl/intl.dart';

final DateFormat dateFormat = DateFormat('d MMMM yyyy');

String dateToString(DateTime date) {
  return dateFormat.format(date);
}
