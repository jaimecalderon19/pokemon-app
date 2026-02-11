import 'package:pokemonapp/features/pokemon/domain/entities/pokemon.dart';

abstract class PokemonRepository {
  Future<Pokemon> getPokemon(String term);
  Future<List<Pokemon>> getPokemonList({
    required int offset,
    required int limit,
  });
}
