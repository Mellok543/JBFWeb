import 'package:flutter_test/flutter_test.dart';
import 'package:jbforsaken_web/router.dart';

void main() {
  test('router starts at the root route', () {
    expect(router.routeInformationProvider.value.uri.path, '/');
  });

  test('router can navigate to the admin path', () {
    router.go('/admin');
    expect(router.routeInformationProvider.value.uri.path, '/admin');
    router.go('/');
  });
}
