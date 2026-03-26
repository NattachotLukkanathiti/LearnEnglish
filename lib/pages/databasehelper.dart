class SentenceModel {
  String id;
  List<String> sentence;
  List<String> choices;
  List<String> answers;
  String? image;  
  SentenceModel({
    required this.id,
    required this.sentence,
    required this.choices,
    required this.answers,
    this.image,
  });

  factory SentenceModel.fromFirestore(Map<String, dynamic> json, String id) {
    return SentenceModel(
      id: id,
      sentence: List<String>.from(json['sentence'] ?? []),
      choices: List<String>.from(json['choices'] ?? []),
      answers: List<String>.from(json['answers'] ?? []),
      image: json['image'],  
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sentence': sentence,
      'choices': choices,
      'answers': answers,
      'image': image,  
    };
  }
}
