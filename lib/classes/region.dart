class Region {
  Map<String, double> corner1;
  Map<String, double> corner2;
  Map<String, double> corner3;
  Map<String, double> corner4;
  Region(this.corner1, this.corner2, this.corner3, this.corner4);
  List<Map<String, double>> toJson() => [corner1, corner2, corner3, corner4];
  Region.fromJson(List<Map<String, double>> json)
      : corner1 = json[0],
        corner2 = json[1],
        corner3 = json[2],
        corner4 = json[3];
}
