import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:pokemonapp/core/errors/failure.dart';
import 'package:pokemonapp/features/pokemon/domain/usecases/get_pokemon.dart';
import 'package:pokemonapp/features/pokemon/domain/usecases/get_pokemon_list.dart';
import 'package:pokemonapp/features/pokemon/presentation/providers/pokemon_state.dart';

final pokemonProvider = StateNotifierProvider<PokemonNotifier, PokemonState>((
  ref,
) {
  return PokemonNotifier(
    GetIt.instance<GetPokemon>(),
    GetIt.instance<GetPokemonList>(),
  );
});

class PokemonNotifier extends StateNotifier<PokemonState> {
  final GetPokemon _getPokemon;
  final GetPokemonList _getPokemonList;

  PokemonNotifier(this._getPokemon, this._getPokemonList)
    : super(const PokemonState()) {
    loadInitialList();
  }

  Future<void> loadInitialList() async {
    state = state.copyWith(
      isLoading: true,
      hasReachedMax: false,
      pokemonList: [],
    );
    try {
      final list = await _getPokemonList(offset: 0, limit: 20);
      state = state.copyWith(
        isLoading: false,
        pokemonList: list,
        hasReachedMax: list.length < 20,
      );
    } catch (e) {
      state = state.copyWithFailure(error: ServerFailure(e.toString()));
      // Opcional: isLoading false
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
      // Si la query es vacía, volvemos a mostrar la lista (si ya la tenemos cargada, idealmente no recargar)
      // O podemos recargar la lista inicial.
      // Por simplicidad, recargamos la lista inicial o si ya tenemos lista, solo limpiamos el pokemon search result.
      state = state.copyWith(pokemon: null, error: null);
      if (state.pokemonList.isEmpty) {
        loadInitialList();
      }
      return;
    }

    state = state.copyWith(isLoading: true, error: null, pokemon: null);

    // Convert string to lower case for API
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
