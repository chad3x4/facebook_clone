import 'package:intl/intl.dart';

class TimeConvert {
  String convert(String time) {
    String result = "";
    DateTime dateTime = DateFormat("yyyy-MM-ddTHH:mm:ss.SSSZ").parseUtc(time);
    if (DateTime.now().year - dateTime.year < 1) {
      if (DateTime.now().month - dateTime.month < 1) {
        if (DateTime.now().day - dateTime.day < 7) {
          if (DateTime.now().day - dateTime.day < 1) {
            if (DateTime.now().hour - dateTime.hour - 7 < 1) {
              if (DateTime.now().minute - dateTime.minute < 1) {
                result = "Vừa xong";
              } else {
                result = "${DateTime.now().minute - dateTime.minute} phút";
              }
            } else {
              result = "${DateTime.now().hour - dateTime.hour - 6} giờ";
            }
          } else {
            result = "${DateTime.now().day - dateTime.day} ngày";
          }
        } else {
          result =
              "${dateTime.day} tháng ${dateTime.month} lúc ${dateTime.hour}:${dateTime.minute}";
        }
      } else {
        result = "${DateTime.now().month - dateTime.month} tháng";
      }
    } else {
      result = "${DateTime.now().year - dateTime.year} năm";
    }

    return result;
  }
}

//2023-11-21T04:58:10.288Z