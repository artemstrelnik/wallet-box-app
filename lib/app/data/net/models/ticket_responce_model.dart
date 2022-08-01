class TicketResponceModel {
  TicketResponceModel({
    required this.id,
    required this.ofdId,
    required this.receiveDate,
    required this.subtype,
    required this.address,
    required this.content,
  });
  late final int id;
  late final String ofdId;
  late final String receiveDate;
  late final String subtype;
  late final String address;
  late final Content content;

  TicketResponceModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    ofdId = json['ofdId'];
    receiveDate = json['receiveDate'];
    subtype = json['subtype'];
    address = json['address'];
    content = Content.fromJson(json['content']);
  }
}

class Content {
  Content({
    required this.messageFiscalSign,
    required this.code,
    required this.fiscalDriveNumber,
    required this.kktRegId,
    required this.userInn,
    required this.fiscalDocumentNumber,
    required this.dateTime,
    required this.fiscalSign,
    required this.shiftNumber,
    required this.requestNumber,
    required this.operationType,
    required this.totalSum,
    required this.retailPlaceAddress,
    required this.operator,
    required this.cashTotalSum,
    required this.user,
    required this.appliedTaxationType,
    required this.items,
    required this.fnsUrl,
    required this.ecashTotalSum,
    required this.ndsNo,
    required this.operatorInn,
    required this.fiscalDocumentFormatVer,
    required this.prepaidSum,
    required this.creditSum,
    required this.provisionSum,
    required this.retailPlace,
    required this.region,
    required this.numberKkt,
    required this.redefineMask,
  });
  late final double? messageFiscalSign;
  late final int? code;
  late final String? fiscalDriveNumber;
  late final String? kktRegId;
  late final String? userInn;
  late final int? fiscalDocumentNumber;
  late final int? dateTime;
  late final int? fiscalSign;
  late final int? shiftNumber;
  late final int? requestNumber;
  late final int? operationType;
  late final int? totalSum;
  late final String? retailPlaceAddress;
  late final String? operator;
  late final int? cashTotalSum;
  late final String? user;
  late final int? appliedTaxationType;
  late final List<Items>? items;
  late final String? fnsUrl;
  late final int? ecashTotalSum;
  late final int? ndsNo;
  late final String? operatorInn;
  late final int? fiscalDocumentFormatVer;
  late final int? prepaidSum;
  late final int? creditSum;
  late final int? provisionSum;
  late final String? retailPlace;
  late final String? region;
  late final String? numberKkt;
  late final int? redefineMask;

  Content.fromJson(Map<String, dynamic> json) {
    messageFiscalSign = json['messageFiscalSign'];
    code = json['code'];
    fiscalDriveNumber = json['fiscalDriveNumber'];
    kktRegId = json['kktRegId'];
    userInn = json['userInn'];
    fiscalDocumentNumber = json['fiscalDocumentNumber'];
    dateTime = json['dateTime'];
    fiscalSign = json['fiscalSign'];
    shiftNumber = json['shiftNumber'];
    requestNumber = json['requestNumber'];
    operationType = json['operationType'];
    totalSum = json['totalSum'];
    retailPlaceAddress = json['retailPlaceAddress'];
    operator = json['operator'];
    cashTotalSum = json['cashTotalSum'];
    user = json['user'];
    appliedTaxationType = json['appliedTaxationType'];
    items = List.from(json['items']).map((e) => Items.fromJson(e)).toList();
    fnsUrl = json['fnsUrl'];
    ecashTotalSum = json['ecashTotalSum'];
    ndsNo = json['ndsNo'];
    operatorInn = json['operatorInn'];
    fiscalDocumentFormatVer = json['fiscalDocumentFormatVer'];
    prepaidSum = json['prepaidSum'];
    creditSum = json['creditSum'];
    provisionSum = json['provisionSum'];
    retailPlace = json['retailPlace'];
    region = json['region'];
    numberKkt = json['numberKkt'];
    redefineMask = json['redefine_mask'];
  }
}

class Items {
  Items({
    required this.paymentType,
    required this.productType,
    required this.name,
    required this.productCode,
    required this.price,
    required this.quantity,
    required this.nds,
    required this.sum,
  });
  late final int paymentType;
  late final int productType;
  late final String name;
  late final ProductCode productCode;
  late final int price;
  late final double quantity;
  late final int nds;
  late final int sum;

  Items.fromJson(Map<String, dynamic> json) {
    paymentType = json['paymentType'];
    productType = json['productType'];
    name = json['name'];
    productCode = ProductCode.fromJson(json['productCode']);
    price = json['price'];
    quantity = json['quantity'];
    nds = json['nds'];
    sum = json['sum'];
  }
}

class ProductCode {
  ProductCode({
    required this.rawProductCode,
    required this.productIdType,
    required this.gtin,
    required this.sernum,
  });
  late final String rawProductCode;
  late final int productIdType;
  late final String gtin;
  late final String sernum;

  ProductCode.fromJson(Map<String, dynamic> json) {
    rawProductCode = json['rawProductCode'];
    productIdType = json['productIdType'];
    gtin = json['gtin'];
    sernum = json['sernum'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['rawProductCode'] = rawProductCode;
    _data['productIdType'] = productIdType;
    _data['gtin'] = gtin;
    _data['sernum'] = sernum;
    return _data;
  }
}
