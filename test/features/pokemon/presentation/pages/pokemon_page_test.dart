import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokemonapp/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokemonapp/features/pokemon/presentation/pages/pokemon_page.dart';
import 'package:pokemonapp/features/pokemon/presentation/providers/pokemon_notifier.dart';

import '../../../../helpers/test_helpers.dart';

// Helper to mock Image.network
class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _TestHttpClient();
  }
}

class _TestHttpClient extends Mock implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) {
    return Future.value(_TestHttpClientRequest());
  }
}

class _TestHttpClientRequest extends Mock implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() {
    return Future.value(_TestHttpClientResponse());
  }
}

class _TestHttpClientResponse extends Mock implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => 0; // Empty image

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([
      <int>[0], // minimal data
    ]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

void main() {
  late MockGetPokemon mockGetPokemon;
  late MockGetPokemonList mockGetPokemonList;

  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });

  setUp(() {
    mockGetPokemon = MockGetPokemon();
    mockGetPokemonList = MockGetPokemonList();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        pokemonProvider.overrideWith(() {
          final notifier = PokemonNotifier();
          return notifier;
        }),
      ],
      child: const MaterialApp(home: PokemonPage()),
    );
  }

  testWidgets('shows loading indicator when state is loading', (tester) async {
    // Arrange
    // Default state of Notifier calls loadInitialList immediately.
    // We mock getPokemonList to never complete (or complete later) to keep it loading?
    // Or we mock it to return empty list first?
    // Actually, notifier calls loadInitialList in constructor.
    // We want to test the initial loading state.

    when(
      () => mockGetPokemonList(
        offset: any(named: 'offset'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async {
      await Future.delayed(const Duration(milliseconds: 50)); // Simulate delay
      return [];
    });

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    // Initial paint happens here. State should be loading: true.

    // Assert
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Finish pending timers
    await tester.pumpAndSettle();
  });

  testWidgets('shows pokemon list when data is loaded', (tester) async {
    // Arrange
    const tPokemonList = [
      Pokemon(id: 1, name: 'bulbasaur', imageUrl: 'https://example.com/1.png'),
      Pokemon(id: 2, name: 'ivysaur', imageUrl: 'https://example.com/2.png'),
    ];

    when(
      () => mockGetPokemonList(
        offset: any(named: 'offset'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => tPokemonList);

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle(); // Wait for data to load

    // Assert
    expect(find.byType(ListView), findsOneWidget);
    expect(find.text('BULBASAUR'), findsOneWidget);
    expect(find.text('IVYSAUR'), findsOneWidget);
  });

  testWidgets('shows error message when error occurs', (tester) async {
    // Arrange
    when(
      () => mockGetPokemonList(
        offset: any(named: 'offset'),
        limit: any(named: 'limit'),
      ),
    ).thenThrow(Exception('Server Error'));

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Exception: Server Error'), findsOneWidget);
  });
}
