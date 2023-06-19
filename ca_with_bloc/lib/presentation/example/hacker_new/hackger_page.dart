import 'package:ca_with_bloc/presentation/example/hacker_new/hacker_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HackerPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    var bloc = HackerNewsBloc();
    return BlocProvider(create: (_) => bloc,
      child: Container(),
    );
  }
  
}