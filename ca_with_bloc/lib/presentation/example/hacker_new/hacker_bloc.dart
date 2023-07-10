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

  void _reloadEvent(ReloadEvent event, Emitter<LoadStoryState> emit) async {
    print("hanhmh1203 ReloadEvent ");
    if (_isLoadingMoreTopStories) return;
    _isLoadingMoreTopStories = true;
    emit(LoadingState());
    _topStories.clear();
    await _loadIds();
    await _loadData();
    print(
        "hanhmh1203 ReloadEvent LoadedState _topStories size: ${_topStories.length}");
    emit(LoadedState(_topStories));
    _isLoadingMoreTopStories = false;
  }

  void _loadMoreEvent(LoadMoreEvent event, Emitter<LoadStoryState> emit) async {
    print("hanhmh1203 LoadMoreEvent ");
    if (_isLoadingMoreTopStories) return;
    _isLoadingMoreTopStories = true;
    await _loadData();
    print(
        "hanhmh1203 LoadMoreEvent LoadedState _currentStoryIndex $_currentStoryIndex");
    print(
        "hanhmh1203 LoadMoreEvent LoadedState _topStories size: ${_topStories.length}");
    emit(LoadedState(_topStories));
    _isLoadingMoreTopStories = false;
  }

  HackerNewsBloc() : super(LoadingState()) {
    on<ReloadEvent>(_reloadEvent);
    on<LoadMoreEvent>(_loadMoreEvent);
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
