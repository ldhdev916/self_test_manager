import 'package:json_annotation/json_annotation.dart';

final regionCodes = {
  "서울": "01",
  "부산": "02",
  "대구": "03",
  "인천": "04",
  "광주": "05",
  "대전": "06",
  "울산": "07",
  "세종": "08",
  "경기": "10",
  "강원": "11",
  "충북": "12",
  "충남": "13",
  "전북": "14",
  "전남": "15",
  "경북": "16",
  "경남": "17",
  "제주": "18"
};

final stageCodes = {"초등학교": 2, "중학교": 3, "고등학교": 4};

const apiUrl = "https://hcs.eduro.go.kr";
const transkeyUrl = "https://hcs.eduro.go.kr/transkeyServlet";

class YesNoConverter extends JsonConverter<bool, String> {

  const YesNoConverter();

  @override
  bool fromJson(String json) {
   switch(json) {
     case "Y":
       return true;
     case "N":
       return false;
     default:
       throw "Unexpected value: $json";
   }
  }

  @override
  String toJson(bool object) => object ? "Y" : "N";
}