import 'package:intl/intl.dart';

class DateFormatHelper {
  static String format(DateTime? value) {
    if (value == null) {
      return '—';
    }

    return DateFormat('yyyy-MM-dd HH:mm').format(value.toLocal());
  }
}
