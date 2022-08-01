import 'package:flutter/material.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:wallet_box/app/core/themes/colors.dart';

class DataTimeWidget extends StatelessWidget {
  const DataTimeWidget({Key? key, required this.now, required this.updateDate})
      : super(key: key);

  final DateTime now;
  final Function? updateDate;

  @override
  Widget build(BuildContext context) {
    return DatePickerWidget(
      looping: false, // default is not looping
      lastDate: now, //DateTime(1960),
      initialDate: now, // DateTime(1994),
      dateFormat: "MMMM-dd-yyyy",
      locale: DatePicker.localeFromString('ru'),
      onChange: (DateTime newDate, _) {
        updateDate?.call(newDate);
      },
      pickerTheme: const DateTimePickerTheme(
        confirmTextStyle: TextStyle(color: CustomColors.blue, fontSize: 19),
        cancelTextStyle: TextStyle(color: CustomColors.blue, fontSize: 19),
        itemTextStyle: TextStyle(color: CustomColors.pink, fontSize: 19),
        dividerColor: Colors.transparent,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
