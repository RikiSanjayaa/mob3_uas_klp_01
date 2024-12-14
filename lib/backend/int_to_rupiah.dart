import 'package:intl/intl.dart';

final NumberFormat currencyFormat =
    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

String intToRP(int input) {
  return currencyFormat.format(input);
}

String doubleToRP(double input) {
  return currencyFormat.format(input);
}
