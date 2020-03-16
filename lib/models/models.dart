class PhilippineData {
  final int id;
  final String caseNo;
  final String caseStatus;
  final String dtStamp;
  final String sex;
  final String age;
  final String nationality;
  final String healthStatus;
  final String symptoms;
  final String residentOf;
  final String currentlyAt;
  final String transType;

  PhilippineData({
    this.id,
    this.caseNo,
    this.caseStatus,
    this.dtStamp,
    this.sex,
    this.age,
    this.nationality,
    this.healthStatus,
    this.symptoms,
    this.residentOf,
    this.currentlyAt,
    this.transType,
  });

  factory PhilippineData.fromJson(Map<String, dynamic> json) {
    return PhilippineData(
      id: json['id'],
      caseNo: json['case_no'],
      caseStatus: json['case_status'],
      dtStamp: json['case_dtstamp'],
      sex: json['sex'],
      age: json['age'],
      nationality: json['nationality'] ?? "NONE",
      symptoms: json['symptoms'],
      residentOf: json['resident_of'],
      currentlyAt: json['currently_at'],
      transType: json['trans_type'],
      healthStatus: json['health_status'],
    );
  }
}
