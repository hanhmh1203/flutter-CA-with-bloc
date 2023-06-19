// import 'package:ca_with_bloc/presentation/counter_bloc.dart';
// import 'package:ca_with_bloc/presentation/counter_event.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// void main() {
//   Bloc.observer = const AppBlocObserver();
//   runApp(const MyApp());
// }
// /// {@template app_bloc_observer}
// /// Custom [BlocObserver] that observes all bloc and cubit state changes.
// /// {@endtemplate}
// class AppBlocObserver extends BlocObserver {
//   /// {@macro app_bloc_observer}
//   const AppBlocObserver();
//
//   @override
//   void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
//     super.onChange(bloc, change);
//     if (bloc is Cubit) print(change);
//   }
//
//   @override
//   void onTransition(
//       Bloc<dynamic, dynamic> bloc,
//       Transition<dynamic, dynamic> transition,
//       ) {
//     super.onTransition(bloc, transition);
//     print(transition);
//   }
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => ThemeCubit(),
//       child: const AppView(),
//     );
//     // return MaterialApp(
//     //   title: 'Flutter Demo',
//     //   theme: ThemeData(
//     //     colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//     //     useMaterial3: true,
//     //   ),
//     //   home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     // );
//   }
// }
// /// {@template brightness_cubit}
// /// A simple [Cubit] that manages the [ThemeData] as its state.
// /// {@endtemplate}
// class ThemeCubit extends Cubit<ThemeData> {
//   /// {@macro brightness_cubit}
//   ThemeCubit() : super(_lightTheme);
//
//   static final _lightTheme = ThemeData(
//     floatingActionButtonTheme: const FloatingActionButtonThemeData(
//       foregroundColor: Colors.white,
//     ),
//     brightness: Brightness.light,
//   );
//
//   static final _darkTheme = ThemeData(
//     floatingActionButtonTheme: const FloatingActionButtonThemeData(
//       foregroundColor: Colors.black,
//     ),
//     brightness: Brightness.dark,
//   );
//
//   /// Toggles the current brightness between light and dark.
//   void toggleTheme() {
//     emit(state.brightness == Brightness.dark ? _lightTheme : _darkTheme);
//   }
// }
// /// {@template app_view}
// /// A [StatelessWidget] that:
// /// * reacts to state changes in the [ThemeCubit]
// /// and updates the theme of the [MaterialApp].
// /// * renders the [CounterPage].
// /// {@endtemplate}
// class AppView extends StatelessWidget {
//   /// {@macro app_view}
//   const AppView({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<ThemeCubit, ThemeData>(
//       builder: (_, theme) {
//         return MaterialApp(
//           theme: theme,
//           home: const CounterPage(),
//         );
//       },
//     );
//   }
// }
// /// {@template counter_page}
// /// A [StatelessWidget] that:
// /// * provides a [CounterBloc] to the [CounterView].
// /// {@endtemplate}
// class CounterPage extends StatelessWidget {
//   /// {@macro counter_page}
//   const CounterPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => CounterBloc(),
//       child: const CounterView(),
//     );
//   }
// }
//
// /// {@template counter_view}
// /// A [StatelessWidget] that:
// /// * demonstrates how to consume and interact with a [CounterBloc].
// /// {@endtemplate}
// class CounterView extends StatelessWidget {
//   /// {@macro counter_view}
//   const CounterView({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Counter')),
//       body: Center(
//         child: BlocBuilder<CounterBloc, int>(
//           builder: (context, count) {
//             return Text(
//               '$count',
//               style: Theme.of(context).textTheme.displayLarge,
//             );
//           },
//         ),
//       ),
//       floatingActionButton: Column(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: <Widget>[
//           FloatingActionButton(
//             child: const Icon(Icons.add),
//             onPressed: () {
//               context.read<CounterBloc>().add(IncrementEvent());
//             },
//           ),
//           const SizedBox(height: 4),
//           FloatingActionButton(
//             child: const Icon(Icons.remove),
//             onPressed: () {
//               context.read<CounterBloc>().add(DecrementEvent());
//             },
//           ),
//           const SizedBox(height: 4),
//           FloatingActionButton(
//             child: const Icon(Icons.brightness_6),
//             onPressed: () {
//               context.read<ThemeCubit>().toggleTheme();
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//
//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.
//
//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".
//
//   final String title;
//
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;
//
//   void _incrementCounter() {
//     setState(() {
//       // This call to setState tells the Flutter framework that something has
//       // changed in this State, which causes it to rerun the build method below
//       // so that the display can reflect the updated values. If we changed
//       // _counter without calling setState(), then the build method would not be
//       // called again, and so nothing would appear to happen.
//       _counter++;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return Scaffold(
//       appBar: AppBar(
//         // TRY THIS: Try changing the color here to a specific color (to
//         // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
//         // change color while the other colors stay the same.
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text(widget.title),
//       ),
//       body: Center(
//         // Center is a layout widget. It takes a single child and positions it
//         // in the middle of the parent.
//         child: Column(
//           // Column is also a layout widget. It takes a list of children and
//           // arranges them vertically. By default, it sizes itself to fit its
//           // children horizontally, and tries to be as tall as its parent.
//           //
//           // Column has various properties to control how it sizes itself and
//           // how it positions its children. Here we use mainAxisAlignment to
//           // center the children vertically; the main axis here is the vertical
//           // axis because Columns are vertical (the cross axis would be
//           // horizontal).
//           //
//           // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
//           // action in the IDE, or press "p" in the console), to see the
//           // wireframe for each widget.
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }
