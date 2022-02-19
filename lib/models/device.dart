class Device {
  final String serial;
  final String model;
  final String product;
  final int? transportId;
  final String name;

  Device(this.serial, this.model, this.product, this.transportId, this.name);

  factory Device.fromText(String text) {
    RegExp product = RegExp(
      r"product:([^\s]+)\s",
      caseSensitive: false,
      multiLine: false,
    );

    RegExp model = RegExp(
      r"model:([^\s]+)\s",
      caseSensitive: false,
      multiLine: false,
    );

    RegExp device = RegExp(
      r"device:([^\s]+)\s",
      caseSensitive: false,
      multiLine: false,
    );

    RegExp transportId = RegExp(
      r"transport_id:([^\s]+)",
      caseSensitive: false,
      multiLine: false,
    );

    RegExp name = RegExp(
      r"^[^\s]+",
      caseSensitive: false,
      multiLine: false,
    );

    return Device(
      name.firstMatch(text)?.group(0) ?? 'unknown',
      model.firstMatch(text)?.group(1) ?? 'unknown',
      product.firstMatch(text)?.group(1) ?? 'unknown',
      int.tryParse(transportId.firstMatch(text)?.group(1) ?? "-1"),
      device.firstMatch(text)?.group(1) ?? 'unknown',
    );
  }
}
