import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:isolator/isolator.dart';

import 'test_data/test_states.dart';

const int DELAY = 100;
const int LONG_DELAY = 1000;

Future<void> wait([int milliseconds = 300]) async {
  await Future<void>.delayed(Duration(milliseconds: milliseconds));
}

Future<FrontendTest> createFrontend(int id) async {
  final FrontendTest frontendTest = FrontendTest();
  await frontendTest.init(id);
  return frontendTest;
}

int id = 0;

void main() {
  IsolatorConfig.setLongOperationsLogging(false);

  group('Group of tests for Isolator library', () {
    test('Creation of backend', () async {
      final FrontendTest frontend = await createFrontend(id++);
      await wait(DELAY);
      expect(frontend.valueAfterCreation, VALUE_AFTER_CREATION);
    });

    test('Get value from Backend in async (usual) mode', () async {
      final FrontendTest frontend = await createFrontend(id++);
      frontend.sendEventToBackend();
      await wait(DELAY);
      expect(frontend.asyncIntFromBackend, ASYNC_INT);
    });

    test('Get value from Backend in async (usual) mode with returning value', () async {
      final FrontendTest frontend = await createFrontend(id++);
      frontend.sendEventToBackendAndReturnResponseOnBackend();
      await wait(DELAY);
      expect(frontend.asyncIntFromBackend, ASYNC_INT);
    });

    test('Get value from Backend in synchronous mode', () async {
      final FrontendTest frontend = await createFrontend(id++);
      final int syncInt = await frontend.getValueFromBackendSynchronously();
      expect(syncInt, SYNC_INT);
    });

    test('Call observer after getting Backend event', () async {
      final FrontendTest frontend = await createFrontend(id++);
      final AnotherFrontend anotherFrontend = AnotherFrontend(frontend);
      frontend.onEvent(TestEvent.observer, anotherFrontend.subscriptionForFrontendTest);
      frontend.sendEventToBackend();
      await wait(DELAY);
      expect(anotherFrontend.intFromFrontendTest, ASYNC_INT);
    });

    test('Load large data from Backend by chunks', () async {
      final FrontendTest frontend = await createFrontend(id++);
      frontend.loadChunks();
      await wait(LONG_DELAY);
      expect(frontend.intChunks.length, 10000);
    });

    test('Load large data from Backend by chunks and call chunks in second time - first transaction must been aborted', () async {
      final FrontendTest frontend = await createFrontend(id++);

      /// First transaction call normally
      frontend.loadChunksWithCanceling();

      /// Call this transaction second time
      /// First transaction must been aborted and the second must been started correctly
      await Future<void>.delayed(const Duration(milliseconds: 10));
      frontend.loadChunksWithCanceling();
      await wait(LONG_DELAY);
      expect(frontend.intChunksCancel.length, 10000);

      /// If first transaction aborted correctly
      /// By test logic, all data list consist of 2
      expect(frontend.intChunksCancel, contains(2));
    }, timeout: Timeout(const Duration(minutes: 2)));

    test('Killing backend and call it`s method after that', () async {
      final FrontendTest frontend = await createFrontend(id++);
      frontend.kill();
      try {
        await frontend.getValueFromBackendSynchronously();
      } catch (error) {
        expect(error.toString(), contains('You must call "initBackend" method before send data'));
      }
    });

    test('Getting from backend value with invalid type', () async {
      bool isError = false;
      runZonedGuarded(() async {
        final FrontendTest frontend = await createFrontend(id++);
        frontend.invalidType();
      }, (error, stackTrace) {
        final String message = error.toString();
        isError = message == "type 'int' is not a subtype of type 'String' of 'intFromBackend'";
      });
      await wait(LONG_DELAY);
      expect(isError, true);
    });

    test('Handle error from backend', () async {
      bool isError = false;
      runZonedGuarded(() async {
        final FrontendTest frontend = await createFrontend(id++);
        frontend.runError();
        await wait(DELAY);
        isError = frontend.isErrorHandled;
      }, (error, stackTrace) {
        isError = isError && (error as List)[0].toString() == 'Exception: Manual error';
      });
      await wait(LONG_DELAY);
      expect(isError, true);
    });
  });
}
