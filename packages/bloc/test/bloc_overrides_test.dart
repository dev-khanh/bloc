import 'package:bloc/bloc.dart';
import 'package:bloc/src/bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class FakeBlocObserver extends Fake implements BlocObserver {}

void main() {
  group('BlocOverrides', () {
    group('runZoned', () {
      test('uses default BlocObserver when not specified', () {
        BlocOverrides.runZoned(() {
          final overrides = BlocOverrides.current;
          expect(overrides!.blocObserver, isA<BlocObserver>());
        });
      });

      test('uses default EventTransformer when not specified', () {
        BlocOverrides.runZoned(() {
          final overrides = BlocOverrides.current;
          expect(overrides!.eventTransformer, isA<EventTransformer>());
        });
      });

      test('uses custom BlocObserver when specified', () {
        final blocObserver = FakeBlocObserver();
        BlocOverrides.runZoned(() {
          final overrides = BlocOverrides.current;
          expect(overrides!.blocObserver, equals(blocObserver));
        }, blocObserver: blocObserver);
      });

      test('uses custom EventTransformer when specified', () {
        final eventTransformer = (Stream events, EventMapper mapper) {
          return events.asyncExpand<dynamic>(mapper);
        };
        BlocOverrides.runZoned(() {
          final overrides = BlocOverrides.current;
          expect(overrides!.eventTransformer, equals(eventTransformer));
        }, eventTransformer: eventTransformer);
      });

      test(
          'uses current BlocObserver when not specified '
          'and zone already contains a BlocObserver', () {
        final blocObserver = FakeBlocObserver();
        BlocOverrides.runZoned(() {
          BlocOverrides.runZoned(() {
            final overrides = BlocOverrides.current;
            expect(overrides!.blocObserver, equals(blocObserver));
          });
        }, blocObserver: blocObserver);
      });

      test(
          'uses current EventTransformer when not specified '
          'and zone already contains a EventTransformer', () {
        final eventTransformer = (Stream events, EventMapper mapper) {
          return events.asyncExpand<dynamic>(mapper);
        };
        BlocOverrides.runZoned(() {
          BlocOverrides.runZoned(() {
            final overrides = BlocOverrides.current;
            expect(overrides!.eventTransformer, equals(eventTransformer));
          });
        }, eventTransformer: eventTransformer);
      });

      test(
          'uses nested BlocObserver when specified '
          'and zone already contains a BlocObserver', () {
        final rootBlocObserver = FakeBlocObserver();
        BlocOverrides.runZoned(() {
          final nestedBlocObserver = FakeBlocObserver();
          BlocOverrides.runZoned(() {
            final overrides = BlocOverrides.current;
            expect(overrides!.blocObserver, equals(nestedBlocObserver));
          }, blocObserver: nestedBlocObserver);
        }, blocObserver: rootBlocObserver);
      });

      test(
          'uses nested EventTransformer when specified '
          'and zone already contains an EventTransformer', () {
        final rootEventTransformer = (Stream events, EventMapper mapper) {
          return events.asyncExpand<dynamic>(mapper);
        };
        BlocOverrides.runZoned(() {
          final nestedEventTransformer = (Stream events, EventMapper mapper) {
            return events.asyncExpand<dynamic>(mapper);
          };
          BlocOverrides.runZoned(() {
            final overrides = BlocOverrides.current;
            expect(overrides!.eventTransformer, equals(nestedEventTransformer));
          }, eventTransformer: nestedEventTransformer);
        }, eventTransformer: rootEventTransformer);
      });
    });
  });
}
