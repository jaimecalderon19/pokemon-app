import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:pokemonapp/core/errors/failure.dart';
import 'package:pokemonapp/features/pokemon/domain/usecases/get_pokemon.dart';
import 'package:pokemonapp/features/pokemon/domain/usecases/get_pokemon_list.dart';
import 'package:pokemonapp/features/pokemon/presentation/providers/pokemon_state.dart';

final pokemonProvider = NotifierProvider<PokemonNotifier, PokemonState>(() {
  return PokemonNotifier();
});

class PokemonNotifier extends Notifier<PokemonState> {
  late final GetPokemon _getPokemon;
  late final GetPokemonList _getPokemonList;

  @override
  PokemonState build() {
    _getPokemon = GetIt.instance<GetPokemon>();
    _getPokemonList = GetIt.instance<GetPokemonList>();

    Future.microtask(() => loadInitialList());

    return const PokemonState(
      isLoading: true,
      hasReachedMax: false,
      pokemonList: [],
    );
  }

  Future<void> loadInitialList() async {
    try {
      final list = await _getPokemonList(offset: 0, limit: 20);
      state = state.copyWith(
        isLoading: false,
        pokemonList: list,
        hasReachedMax: list.length < 20,
      );
    } catch (e) {
      state = state.copyWithFailure(error: ServerFailure(e.toString()));
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> loadNextPage() async {
    if (state.isNextPageLoading || state.hasReachedMax) return;

    state = state.copyWith(isNextPageLoading: true);
    final offset = state.pokemonList.length;

    try {
      final list = await _getPokemonList(offset: offset, limit: 20);
      state = state.copyWith(
        isNextPageLoading: false,
        pokemonList: [...state.pokemonList, ...list],
        hasReachedMax: list.isEmpty,
      );
    } catch (e) {
      state = state.copyWithFailure(error: ServerFailure(e.toString()));
      state = state.copyWith(isNextPageLoading: false);
    }
  }

  Future<void> searchPokemon(String query) async {
    if (query.isEmpty) {
      state = state.copyWith(pokemon: null, error: null);
      if (state.pokemonList.isEmpty) {
        await loadInitialList();
      }
      return;
    }

    state = state.copyWith(isLoading: true, error: null, pokemon: null);

    final term = query.trim().toLowerCase();

    try {
      final pokemon = await _getPokemon(term);
      state = state.copyWith(isLoading: false, pokemon: pokemon);
    } catch (e) {
      state = state.copyWithFailure(error: ServerFailure(e.toString()));
      state = state.copyWith(isLoading: false);
    }
  }

  void clearError() {
    state = state.clearError();
  }
}
