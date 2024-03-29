import 'package:auto_route/auto_route.dart';
import 'package:ca_with_bloc/presentation/ocr/detector_view.dart';

import '../example/counter_page.dart';
import 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends $AppRouter {
  @override
  List<AutoRoute> get routes {
    return [
      AutoRoute(
          path: "/text_recognizer_view",
          page: TextRecognizerView.page,
          ),
      AutoRoute(path: "/my_form", page: MyForm.page),
      AutoRoute(
        path: "/counter",
        page: CounterRoute.page,
          initial: true
      ),
      AutoRoute(path: "/login", page: LoginRoute.page),
    ];
  }
}
