import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokemonapp/core/errors/failure.dart';
import 'package:pokemonapp/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokemonapp/features/pokemon/presentation/providers/pokemon_notifier.dart';
import 'package:pokemonapp/features/pokemon/presentation/providers/pokemon_state.dart';
import 'package:riverpod_test/riverpod_test.dart';

import '../../../../helpers/test_helpers.dart';

void main() {
  late MockGetPokemon mockGetPokemon;
  late MockGetPokemonList mockGetPokemonList;

  setUp(() {
    mockGetPokemon = MockGetPokemon();
    mockGetPokemonList = MockGetPokemonList();
  });

  group('PokemonNotifier', () {
    const tPokemonList = [Pokemon(id: 1, name: 'bulbasaur', imageUrl: 'url')];
    const tPokemon = Pokemon(id: 1, name: 'bulbasaur', imageUrl: 'url');

    testNotifier<PokemonNotifier, PokemonState>(
      'emits state with pokemon list when loadInitialList is successful',
      provider: pokemonProvider,
      overrides: [
        pokemonProvider.overrideWith(() {
          final notifier = PokemonNotifier();
          return notifier;
        }),
      ],
      setUp: () {
        when(
          () => mockGetPokemonList(
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => tPokemonList);
      },
      expect: () => [
        const PokemonState(
          isLoading: true,
          hasReachedMax: false,
          pokemonList: [],
        ),
        const PokemonState(
          isLoading: false,
          hasReachedMax: true,
          pokemonList: tPokemonList,
        ),
      ],
    );

    testNotifier<PokemonNotifier, PokemonState>(
      'emits state with error when loadInitialList fails',
      provider: pokemonProvider,
      overrides: [
        pokemonProvider.overrideWith(() {
          final notifier = PokemonNotifier();
          return notifier;
        }),
      ],
      setUp: () {
        when(
          () => mockGetPokemonList(
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          ),
        ).thenThrow(Exception('Error'));
      },
      expect: () => [
        const PokemonState(
          isLoading: true,
          hasReachedMax: false,
          pokemonList: [],
        ),
        const PokemonState(
          isLoading: true,
          hasReachedMax: false,
          pokemonList: [],
          error: ServerFailure('Exception: Error'),
        ),
        const PokemonState(
          isLoading: false,
          hasReachedMax: false,
          pokemonList: [],
          error: ServerFailure('Exception: Error'),
        ),
      ],
    );

    testNotifier<PokemonNotifier, PokemonState>(
      'searchPokemon emits state with pokemon when successful',
      provider: pokemonProvider,
      overrides: [
        pokemonProvider.overrideWith(() {
          final notifier = PokemonNotifier();
          return notifier;
        }),
      ],
      setUp: () {
        when(
          () => mockGetPokemonList(
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => []);
        when(() => mockGetPokemon(any())).thenAnswer((_) async => tPokemon);
      },
      expect: () => [
        const PokemonState(
          isLoading: true,
          hasReachedMax: false,
          pokemonList: [],
        ),
        const PokemonState(
          isLoading: false,
          hasReachedMax: true,
          pokemonList: [],
        ),
        // Estados de la búsqueda
        const PokemonState(
          isLoading: true,
          hasReachedMax: true,
          pokemonList: [],
          pokemon: null,
          error: null,
        ),
        const PokemonState(
          isLoading: false,
          hasReachedMax: true,
          pokemonList: [],
          pokemon: tPokemon,
        ),
      ],
    );

    testNotifier<PokemonNotifier, PokemonState>(
      'searchPokemon emits state with error when fails',
      provider: pokemonProvider,
      overrides: [
        pokemonProvider.overrideWith(() {
          final notifier = PokemonNotifier();
          return notifier;
        }),
      ],
      setUp: () {
        when(
          () => mockGetPokemonList(
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => []);
        when(() => mockGetPokemon(any())).thenThrow(Exception('Error'));
      },
      expect: () => [
        // Estados de carga inicial
        const PokemonState(
          isLoading: true,
          hasReachedMax: false,
          pokemonList: [],
        ),
        const PokemonState(
          isLoading: false,
          hasReachedMax: true,
          pokemonList: [],
        ),
        // Estados de la búsqueda (Error)
        const PokemonState(
          isLoading: true,
          hasReachedMax: true,
          pokemonList: [],
          pokemon: null,
          error: null,
        ),
        const PokemonState(
          isLoading: true,
          hasReachedMax: true,
          pokemonList: [],
          pokemon: null,
          error: ServerFailure('Exception: Error'),
        ),
        const PokemonState(
          isLoading: false,
          hasReachedMax: true,
          pokemonList: [],
          pokemon: null,
          error: ServerFailure('Exception: Error'),
        ),
      ],
    );
  });
}
