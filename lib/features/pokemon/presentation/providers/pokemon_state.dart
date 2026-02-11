import 'package:pokemonapp/core/errors/failure.dart';
import 'package:pokemonapp/features/pokemon/domain/entities/pokemon.dart';

class PokemonState {
  final bool isLoading; // Para búsqueda o carga inicial de lista
  final bool isNextPageLoading; // Para paginación
  final Failure? error;
  final Pokemon? pokemon; // Resultado de búsqueda
  final List<Pokemon> pokemonList;
  final bool hasReachedMax;

  const PokemonState({
    this.isLoading = false,
    this.isNextPageLoading = false,
    this.error,
    this.pokemon,
    this.pokemonList = const [],
    this.hasReachedMax = false,
  });

  PokemonState copyWith({
    bool? isLoading,
    bool? isNextPageLoading,
    Failure? error,
    Pokemon? pokemon,
    List<Pokemon>? pokemonList,
    bool? hasReachedMax,
  }) {
    return PokemonState(
      isLoading: isLoading ?? this.isLoading,
      isNextPageLoading: isNextPageLoading ?? this.isNextPageLoading,
      error:
          error, // Si no se pasa, se limpia el error anterior si es null explícito? No, aquí mantenemos el patrón usual.
      // Pero mejor: si se pasa error, se usa. Si no, se mantiene.
      // Para limpiar error, usar clearError.
      // Wait, user logic for copyWith usually keeps old value if null.
      // For error, we might want to clear it explicitly. Let's keep strict copyWith.
      pokemon: pokemon ?? this.pokemon,
      pokemonList: pokemonList ?? this.pokemonList,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  PokemonState copyWithFailure({Failure? error}) {
    return PokemonState(
      isLoading: isLoading,
      isNextPageLoading: isNextPageLoading,
      error: error,
      pokemon: pokemon,
      pokemonList: pokemonList,
      hasReachedMax: hasReachedMax,
    );
  }

  PokemonState clearError() {
    return copyWithFailure(error: null);
  }
}
