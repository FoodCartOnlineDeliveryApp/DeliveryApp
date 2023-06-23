class VehicletypeList {
  final List<VehicleType>? photos;

  VehicletypeList({
    this.photos,
  });

  factory VehicletypeList.fromJson(List<dynamic> parsedJson) {
    List<VehicleType> photos = <VehicleType>[];
    photos = parsedJson.map((i) => VehicleType.fromJson(i)).toList();

    return new VehicletypeList(photos: photos);
  }
}

class VehicleType {
  final String? license;
  final String? vehical_type;

  VehicleType({this.license, this.vehical_type});

  factory VehicleType.fromJson(Map<String, dynamic> json) {
    return new VehicleType(
      license: json['license'].toString(),
      vehical_type: json['vehical_type'],
    );
  }
}
