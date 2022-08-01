import 'package:wallet_box/app/data/enum.dart';

abstract class AddInvoiceEvent {
  const AddInvoiceEvent();
}

class PageOpenedEvent extends AddInvoiceEvent {}

class StartBillCreateEvent extends AddInvoiceEvent {
  StartBillCreateEvent({required this.balance, required this.name});
  final String name;
  final String balance;
}

class BankStartConnect extends AddInvoiceEvent {
  BankStartConnect({required this.phone});
  final String phone;
}

class SaveBankEvent extends AddInvoiceEvent {
  SaveBankEvent({
    required this.bank,
    required this.password,
    required this.phone,
    required this.date,
  });
  final BankTypes bank;
  final String phone;
  final String password;
  final DateTime date;
}

class SaveTochkaBankEvent extends AddInvoiceEvent {
  SaveTochkaBankEvent({
    required this.bank,
    required this.date,
    this.code,
  });
  final BankTypes bank;
  final DateTime date;
  final String? code;
}

class BankConnectSubmit extends AddInvoiceEvent {
  BankConnectSubmit({required this.code});
  final String code;
}

class DateUpdateEvent extends AddInvoiceEvent {
  DateUpdateEvent({required this.date});
  final DateTime date;
}

class BillUpdateEvent extends AddInvoiceEvent {
  BillUpdateEvent({
    required this.id,
    required this.balance,
    required this.name,
  });
  final String id;
  final String name;
  final String balance;
}
