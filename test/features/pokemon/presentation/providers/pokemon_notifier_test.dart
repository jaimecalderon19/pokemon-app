import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokemonapp/core/errors/failure.dart';
import 'package:pokemonapp/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokemonapp/features/pokemon/domain/usecases/get_pokemon.dart';
import 'package:pokemonapp/features/pokemon/domain/usecases/get_pokemon_list.dart';
import 'package:pokemonapp/features/pokemon/presentation/providers/pokemon_notifier.dart';
import 'package:pokemonapp/features/pokemon/presentation/providers/pokemon_state.dart';
import 'package:riverpod_test/riverpod_test.dart';

import '../../../../helpers/test_helpers.dart';

void main() {
  late MockGetPokemon mockGetPokemon;
  late MockGetPokemonList mockGetPokemonList;

  setUp(() async {
    await GetIt.instance.reset();

    mockGetPokemon = MockGetPokemon();
    mockGetPokemonList = MockGetPokemonList();

    GetIt.instance.registerSingleton<GetPokemon>(mockGetPokemon);
    GetIt.instance.registerSingleton<GetPokemonList>(mockGetPokemonList);
  });

  group('PokemonNotifier', () {
    const tPokemonList = [Pokemon(id: 1, name: 'bulbasaur', imageUrl: 'url')];
    const tPokemon = Pokemon(id: 1, name: 'bulbasaur', imageUrl: 'url');

    // ─── loadInitialList: success ─────────────────────────────────────────────
    testNotifier<PokemonNotifier, PokemonState>(
      'emits state with pokemon list when loadInitialList is successful',
      provider: pokemonProvider,
      overrides: [pokemonProvider.overrideWith(() => PokemonNotifier())],
      setUp: () {
        when(
          () => mockGetPokemonList(
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => tPokemonList);
      },
      // build() returns PokemonState(isLoading:true) — NOT captured by testNotifier.
      // Only the state set inside loadInitialList() appears here.
      expect: () => [
        const PokemonState(
          isLoading: false,
          hasReachedMax: true,
          pokemonList: tPokemonList,
        ),
      ],
    );

    // ─── loadInitialList: failure ─────────────────────────────────────────────
    testNotifier<PokemonNotifier, PokemonState>(
      'emits state with error when loadInitialList fails',
      provider: pokemonProvider,
      overrides: [pokemonProvider.overrideWith(() => PokemonNotifier())],
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
          isLoading: false,
          hasReachedMax: false,
          pokemonList: [],
          error: ServerFailure('Exception: Error'),
        ),
      ],
    );

    // ─── searchPokemon: success ───────────────────────────────────────────────
    testNotifier<PokemonNotifier, PokemonState>(
      'searchPokemon emits state with pokemon when successful',
      provider: pokemonProvider,
      overrides: [pokemonProvider.overrideWith(() => PokemonNotifier())],
      setUp: () {
        when(
          () => mockGetPokemonList(
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => []); // Lista vacía para carga inicial

        when(() => mockGetPokemon(any())).thenAnswer((_) async => tPokemon);
      },
      // MODIFICACIÓN AQUÍ: Hacemos el act asíncrono y esperamos un tick
      act: (notifier) async {
        await Future.delayed(Duration.zero); // Deja que loadInitialList termine
        await notifier.searchPokemon('bulbasaur');
      },
      expect: () => [
        // 1. Estado de loadInitialList (el microtask del build termina primero)
        const PokemonState(
          isLoading: false,
          hasReachedMax: true,
          pokemonList: [],
          error: null,
        ),
        // 2. Comienza searchPokemon (Loading vuelve a true)
        const PokemonState(
          isLoading: true,
          hasReachedMax: true, // Mantiene el true de la carga inicial
          pokemonList: [],
          pokemon: null,
          error: null,
        ),
        // 3. Termina searchPokemon (Éxito)
        const PokemonState(
          isLoading: false,
          hasReachedMax: true,
          pokemonList: [],
          pokemon: tPokemon,
          error: null,
        ),
      ],
    );

    // ─── searchPokemon: failure ───────────────────────────────────────────────
    testNotifier<PokemonNotifier, PokemonState>(
      'searchPokemon emits state with error when fails',
      provider: pokemonProvider,
      overrides: [pokemonProvider.overrideWith(() => PokemonNotifier())],
      setUp: () {
        when(
          () => mockGetPokemonList(
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => []);

        when(() => mockGetPokemon(any())).thenThrow(Exception('Error'));
      },
      // MODIFICACIÓN AQUÍ TAMBIÉN
      act: (notifier) async {
        await Future.delayed(Duration.zero);
        await notifier.searchPokemon('bulbasaur');
      },
      expect: () => [
        // 1. loadInitialList termina
        const PokemonState(
          isLoading: false,
          hasReachedMax: true,
          pokemonList: [],
        ),
        // 2. searchPokemon empieza
        const PokemonState(
          isLoading: true,
          hasReachedMax: true,
          pokemonList: [],
          pokemon: null,
          error: null,
        ),
        // 3. searchPokemon falla
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
