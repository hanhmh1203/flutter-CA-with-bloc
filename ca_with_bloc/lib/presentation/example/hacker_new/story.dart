class Story {
  int score=0;
  String author="";
  int id=0;
  int time=0;
  String title="";
  String type="";
  int descendants=-1;
  String url="";
  List<int> kids= List.empty();

  Story({
    required this.score,
    required this.author,
    required this.id,
    required this.time,
    required this.title,
    required this.type,
    required this.descendants,
    required this.url,
    required this.kids,
  });

  Story.fromJson(Map<String, dynamic> json) {
    score = json['score'];
    author = json['by'];
    id = json['id'];
    time = json['time'];
    title = json['title'];
    type = json['type'];
    descendants = json['descendants'];
    url = json['url'];
    kids = json['kids']?.cast<int>()??[];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['score'] = score;
    data['by'] = author;
    data['id'] = id;
    data['time'] = time;
    data['title'] = title;
    data['type'] = type;
    data['descendants'] = descendants;
    data['url'] = url;
    data['kids'] = kids;
    return data;
  }
}
