// pokemon_state.dart
import 'package:equatable/equatable.dart';
import 'package:pokemonapp/core/errors/failure.dart';
import 'package:pokemonapp/features/pokemon/domain/entities/pokemon.dart';

class PokemonState extends Equatable {
  final bool isLoading;
  final bool isNextPageLoading;
  final bool hasReachedMax;
  final List<Pokemon> pokemonList;
  final Pokemon? pokemon;
  final Failure? error;

  const PokemonState({
    this.isLoading = false,
    this.isNextPageLoading = false,
    this.hasReachedMax = false,
    this.pokemonList = const [],
    this.pokemon,
    this.error,
  });

  PokemonState copyWith({
    bool? isLoading,
    bool? isNextPageLoading,
    bool? hasReachedMax,
    List<Pokemon>? pokemonList,
    Pokemon? pokemon,
    Failure? error,
  }) {
    return PokemonState(
      isLoading: isLoading ?? this.isLoading,
      isNextPageLoading: isNextPageLoading ?? this.isNextPageLoading,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      pokemonList: pokemonList ?? this.pokemonList,
      pokemon: pokemon ?? this.pokemon,
      error:
          error, // Nota: Si pasas null en copyWith para borrar error, maneja esa lógica aquí si es necesario
    );
  }

  // Método helper que usas en tu provider
  PokemonState clearError() {
    return PokemonState(
      isLoading: isLoading,
      isNextPageLoading: isNextPageLoading,
      hasReachedMax: hasReachedMax,
      pokemonList: pokemonList,
      pokemon: pokemon,
      error: null,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isNextPageLoading,
    hasReachedMax,
    pokemonList,
    pokemon,
    error,
  ];
}
