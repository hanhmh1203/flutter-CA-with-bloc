// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i5;
import 'package:ca_with_bloc/presentation/example/counter_page.dart' as _i3;
import 'package:ca_with_bloc/presentation/example/form_validation/view/my_form.dart'
    as _i1;
import 'package:ca_with_bloc/presentation/example/login_form/view/login_page.dart'
    as _i2;
import 'package:ca_with_bloc/presentation/ocr/text_detector_view.dart' as _i4;

abstract class $AppRouter extends _i5.RootStackRouter {
  $AppRouter({super.navigatorKey});

  @override
  final Map<String, _i5.PageFactory> pagesMap = {
    MyForm.name: (routeData) {
      return _i5.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i1.MyForm(),
      );
    },
    LoginRoute.name: (routeData) {
      return _i5.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i2.LoginPage(),
      );
    },
    CounterRoute.name: (routeData) {
      return _i5.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i3.CounterPage(),
      );
    },
    TextRecognizerView.name: (routeData) {
      return _i5.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i4.TextRecognizerView(),
      );
    },
  };
}

/// generated route for
/// [_i1.MyForm]
class MyForm extends _i5.PageRouteInfo<void> {
  const MyForm({List<_i5.PageRouteInfo>? children})
      : super(
          MyForm.name,
          initialChildren: children,
        );

  static const String name = 'MyForm';

  static const _i5.PageInfo<void> page = _i5.PageInfo<void>(name);
}

/// generated route for
/// [_i2.LoginPage]
class LoginRoute extends _i5.PageRouteInfo<void> {
  const LoginRoute({List<_i5.PageRouteInfo>? children})
      : super(
          LoginRoute.name,
          initialChildren: children,
        );

  static const String name = 'LoginRoute';

  static const _i5.PageInfo<void> page = _i5.PageInfo<void>(name);
}

/// generated route for
/// [_i3.CounterPage]
class CounterRoute extends _i5.PageRouteInfo<void> {
  const CounterRoute({List<_i5.PageRouteInfo>? children})
      : super(
          CounterRoute.name,
          initialChildren: children,
        );

  static const String name = 'CounterRoute';

  static const _i5.PageInfo<void> page = _i5.PageInfo<void>(name);
}

/// generated route for
/// [_i4.TextRecognizerView]
class TextRecognizerView extends _i5.PageRouteInfo<void> {
  const TextRecognizerView({List<_i5.PageRouteInfo>? children})
      : super(
          TextRecognizerView.name,
          initialChildren: children,
        );

  static const String name = 'TextRecognizerView';

  static const _i5.PageInfo<void> page = _i5.PageInfo<void>(name);
}
