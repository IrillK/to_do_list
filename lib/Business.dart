import 'dart:convert';

Business businessFromJson(String str){
  final jsonData = json.decode(str);
  return Business.fromMap(jsonData);
}

String businessToJson(Business data){
  final dyn = data.toMap();
  return json.encode(dyn);
}

class Business {
   int id;
   String text;
   bool blocked;

  Business({this.id, this.text, this.blocked});

  factory Business.fromMap(Map<String, dynamic> json) => new Business(
    id: json["id"],
    text: json["text"],
    blocked: json["blocked"] ==1,
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "text": text,
    "blocked": blocked,
  };

}