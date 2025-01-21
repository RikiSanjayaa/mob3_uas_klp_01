import 'package:intl/intl.dart';

final NumberFormat currencyFormat =
    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

String formatToRP(dynamic input) {
  if (input is int || input is double) {
    return currencyFormat.format(input);
  } else {
    throw ArgumentError('Input must be an int or double');
  }
}
