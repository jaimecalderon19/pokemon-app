import 'package:pokemonapp/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokemonapp/features/pokemon/domain/repositories/pokemon_repository.dart';

class GetPokemonList {
  final PokemonRepository repository;

  GetPokemonList(this.repository);

  Future<List<Pokemon>> call({int offset = 0, int limit = 20}) async {
    return await repository.getPokemonList(offset: offset, limit: limit);
  }
}
