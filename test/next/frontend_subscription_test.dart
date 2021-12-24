import 'package:flutter_test/flutter_test.dart';
import 'package:isolator/src/frontend/frontend_event_subscription.dart';
import 'package:isolator/src/tools/helpers.dart';

import 'frontend_subscription/event.dart';
import 'frontend_subscription/front.dart';

Front? frontend;
Front get front => frontend!;

Future<void> main() async {
  group('Frontend subscription', () {
    setUp(() async {
      frontend = Front();
      await front.init();
    });

    tearDown(() async {
      await front.destroy();
      frontend = null;
    });

    test('Run action [sendEventAboutInt]', () async {
      int value = 0;
      void listener(Event event) {
        value = front.value;
      }

      final FrontendEventSubscription subscription = front.subscribeOnEvent<Event>(listener: listener, event: Event.computeInt);
      front.sendEventAboutInt();
      await wait(200);
      expect(value, 42);
      subscription.close();
      value = 0;
      front.sendEventAboutInt();
      await wait(100);
      expect(value, 0);
    });
  });
}
