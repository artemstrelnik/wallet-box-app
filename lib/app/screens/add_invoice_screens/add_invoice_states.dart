import 'package:wallet_box/app/data/net/models/bills_response.dart';

abstract class AddInvoiceState {
  const AddInvoiceState();
}

class ListLoadingState extends AddInvoiceState {
  const ListLoadingState();
}

class ListLoadedState extends AddInvoiceState {
  const ListLoadedState();
}

class ListErrorState extends AddInvoiceState {
  const ListErrorState();
}

class ListLoadingOpacityState extends AddInvoiceState {
  const ListLoadingOpacityState();
}

class ListLoadingOpacityHideState extends AddInvoiceState {
  const ListLoadingOpacityHideState();
}

class BillCreateState extends AddInvoiceState {
  const BillCreateState({this.bill});

  final Bill? bill;
}

class NumberEntryState extends AddInvoiceState {
  const NumberEntryState();
}

class SecureEntryState extends AddInvoiceState {
  const SecureEntryState();
}

class CodeScreen extends AddInvoiceState {
  CodeScreen({
    required this.tinkoffUserId,
    required this.phone,
    required this.password,
    required this.date,
  });
  String tinkoffUserId;
  String phone;
  String password;
  DateTime date;
}

class UpdateDateState extends AddInvoiceState {
  UpdateDateState({
    required this.date,
  });
  DateTime date;
}

class GoToHomeScreen extends AddInvoiceState {
  const GoToHomeScreen();
}
