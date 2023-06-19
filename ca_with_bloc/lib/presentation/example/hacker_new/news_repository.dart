import 'dart:convert';

import 'package:ca_with_bloc/presentation/example/hacker_new/story.dart';
import 'package:http/http.dart' as http;

class HackerNewsRepository {
  final _httpClient = http.Client();

  Future<Story> loadStory(int id) async {
    final response = await _httpClient
        .get(Uri.parse('https://hacker-news.firebaseio.com/v0/item/$id.json'));
    if (response.statusCode != 200) {
      throw http.ClientException('Failed to load story with id $id');
    }

    return Story.fromJson(json.decode(response.body));
  }

  Future<List<int>> loadTopStoryIds() async {
    final response = await _httpClient.get(
        Uri.parse('https://hacker-news.firebaseio.com/v0/topstories.json'));
    if (response.statusCode != 200) {
      throw http.ClientException('Failed to load top story ids');
    }

    return List<int>.from(json.decode(response.body));
  }

  void dispose() {
    _httpClient.close();
  }
}
