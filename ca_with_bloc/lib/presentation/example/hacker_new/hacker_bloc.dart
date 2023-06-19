import 'dart:async';
import 'dart:math';

import 'package:ca_with_bloc/presentation/example/hacker_new/load_story_state.dart';
import 'package:ca_with_bloc/presentation/example/hacker_new/story.dart';
import 'package:ca_with_bloc/presentation/example/hacker_new/user_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'news_repository.dart';

class HackerNewsBloc extends Bloc<UserEvent, LoadStoryState> {
  static const int INIT_PAGE_SIZE = 10;
  final _topStoryIds = List<int>.empty(growable: true);
  final _repository = HackerNewsRepository();

  HackerNewsBloc() : super(LoadingState()) {
    print("hanhmh1203 init HackerNewsBloc");
    on<ReloadEvent>((event, emit) async {
      print(
          "hanhmh1203 ReloadEvent _isLoadingMoreTopStories $_isLoadingMoreTopStories");
      if (_isLoadingMoreTopStories) return;
      _isLoadingMoreTopStories = true;
      emit(LoadingState());
      _topStories.clear();
      await _loadIds();
      await _loadData();
      print(
          "hanhmh1203 ReloadEvent LoadedState _currentStoryIndex $_currentStoryIndex");
      print(
          "hanhmh1203 ReloadEvent LoadedState _topStories size: ${_topStories.length}");
      emit(LoadedState(_topStories));
      _isLoadingMoreTopStories = false;
    });
    on<LoadMoreEvent>((event, emit) async {
      print(
          "hanhmh1203 LoadMoreEvent _isLoadingMoreTopStories $_isLoadingMoreTopStories");
      if (_isLoadingMoreTopStories) return;
      _isLoadingMoreTopStories = true;
      await _loadData();
      print(
          "hanhmh1203 LoadMoreEvent LoadedState _currentStoryIndex $_currentStoryIndex");
      print(
          "hanhmh1203 LoadMoreEvent LoadedState _topStories size: ${_topStories.length}");
      emit(LoadedState(_topStories));
      _isLoadingMoreTopStories = false;
    });
  }

  Future _loadIds() async {
    _topStoryIds.clear();
    _topStoryIds.addAll(await _repository.loadTopStoryIds());
  }

  Future _loadData() async {
    final storySize =
        min(_currentStoryIndex + INIT_PAGE_SIZE, _topStoryIds.length);
    for (int index = _currentStoryIndex; index < storySize; index++) {
      _topStories.add(await _repository.loadStory(_topStoryIds[index]));
    }
    _currentStoryIndex = _topStories.length;
  }
  static const int PAGE_SIZE = 3;
  var _isLoadingMoreTopStories = false;
  var _currentStoryIndex = 0;


  final _topStories = List<Story>.empty(growable: true);

}
