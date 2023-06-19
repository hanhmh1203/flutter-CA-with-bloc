import 'package:ca_with_bloc/presentation/example/hacker_new/story.dart';
import 'package:equatable/equatable.dart';

abstract class LoadStoryState extends Equatable {}

class LoadingState extends LoadStoryState {
  @override
  List<Object?> get props => [];
}

class LoadedState extends LoadStoryState {
  List<Story> stories = [];

  LoadedState(this.stories);

  @override
  List<Story> get props => stories;

}

class ErrorState extends LoadStoryState {
  final String error;

  ErrorState(this.error);

  @override
  List<Object?> get props => [error];
}
