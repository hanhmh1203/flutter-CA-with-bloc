import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:ca_with_bloc/presentation/example/hacker_new/story.dart';
import 'package:ca_with_bloc/presentation/example/hacker_new/user_event.dart';
import 'package:ca_with_bloc/presentation/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../counter_bloc.dart';
import '../counter_event.dart';
import '../router/app_router.dart';
import 'hacker_new/hacker_bloc.dart';
import 'hacker_new/load_story_state.dart';

/// {@template counter_page}
/// A [StatelessWidget] that:
/// * provides a [CounterBloc] to the [CounterView].
/// {@endtemplate}
@RoutePage()
class CounterPage extends StatelessWidget {
  /// {@macro counter_page}
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    print("hanhmh1203 CounterPage scrren size width:$width, height: ${height}");
    return MultiBlocProvider(
      providers: [
        BlocProvider<CounterBloc>(
          create: (_) => CounterBloc(),
        ),
        BlocProvider<HackerNewsBloc>(
          create: (_) => HackerNewsBloc(),
        )
      ],
      child: const CounterView(),
    );
  }
}

/// {@template counter_view}
/// A [StatelessWidget] that:
/// * demonstrates how to consume and interact with a [CounterBloc].
/// {@endtemplate}
class CounterView extends StatelessWidget {
  /// {@macro counter_view}
  const CounterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Optical Character Recognition",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text(
            "Open",
            style: TextStyle(fontSize: 24),
          ),
          onPressed: () {
            GetIt.instance<AppRouter>().pushNamed(AppRouter.pathRecognizerView);
          },
        ),
      ),
    );
  }

  Widget _couterPage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter')),
      body: Column(
        children: [
          Center(
            child: BlocBuilder<CounterBloc, int>(
              builder: (context, count) {
                return Text(
                  '$count',
                  style: Theme.of(context).textTheme.displayLarge,
                );
              },
            ),
          ),
          Center(
            child: BlocBuilder<HackerNewsBloc, LoadStoryState>(
              buildWhen: (previousState, currentState) {
                return true; // Always trigger a rebuild
              },
              builder: (context, state) {
                if (state is LoadingState) {
                  return Text("loading");
                }
                if (state is LoadedState) {
                  print(
                      "hanhmh1203 BlocBuilder state.props.length ${state.props.length}");
                  return SizedBox(
                    height: 300,
                    child: ListView.builder(
                      itemCount: state.props.length,
                      itemBuilder: (BuildContext context, int index) {
                        final item = state.props[index];
                        return ListTile(
                          title: Text('Number: ${item.id}'),
                          subtitle: Text(item.author),
                        );
                      },
                    ),
                  );
                }
                if (state is ErrorState) {
                  return Text("error");
                }
                return Text("unknow");
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            heroTag: "refresh",
            child: const Icon(Icons.refresh),
            onPressed: () {
              context.read<HackerNewsBloc>().add(ReloadEvent());
            },
          ),
          const SizedBox(height: 4),
          FloatingActionButton(
            heroTag: "loadmore",
            child: const Icon(Icons.downloading),
            onPressed: () {
              context.read<HackerNewsBloc>().add(LoadMoreEvent());
            },
          ),
          const SizedBox(height: 4),
          FloatingActionButton(
            heroTag: "next",
            child: const Icon(Icons.navigate_next),
            onPressed: () {
              GetIt.instance<AppRouter>().pushNamed(AppRouter.pathRecognizerView);
              // AutoRouter.of(context).pushNamed("/login");
              // context.read<HackerNewsBloc>().add(ReloadEvent());
              // context.read<ThemeCubit>().toggleTheme();
            },
          ),
        ],
      ),
    );
  }
}
