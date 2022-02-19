class DownloadInfo {
  final int count;
  final int skipped;
  final double speed;
  final String speedUnit;
  final double size;
  final String sizeUnit;
  final double duration;
  final String durationUnit;
  final bool hasData;

  DownloadInfo(this.count, this.skipped, this.speed, this.speedUnit, this.size,
      this.sizeUnit, this.duration, this.durationUnit, this.hasData);

  DownloadInfo.initial()
      : count = 0,
        skipped = 0,
        speed = 0,
        speedUnit = 'unknown',
        size = 0,
        sizeUnit = 'unkown',
        duration = 0,
        durationUnit = 'unkown',
        hasData = false;

  factory DownloadInfo.parseText(text) {
    var match = RegExp(
      r":\s+(\d+).+,\s+(\d+).+\.\s+(\d+\.\d+)\s+([KMG]B\/s)\s\((\d+)\s+(\w+).+\s(\d+\.\d+)(\w+)\)",
      caseSensitive: false,
      multiLine: false,
    ).firstMatch(text);

    return DownloadInfo(
        int.parse(match?.group(1) ?? '0'),
        int.parse(match?.group(2) ?? '0'),
        double.parse(match?.group(3) ?? '0.0'),
        match?.group(4) ?? 'unknown',
        double.parse(match?.group(5) ?? '0.0'),
        match?.group(6) ?? 'unknown',
        double.parse(match?.group(7) ?? '0.0'),
        match?.group(8) ?? 'unknown',
        true);
  }
}
