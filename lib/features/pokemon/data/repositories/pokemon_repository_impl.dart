import 'package:pokemonapp/core/errors/exceptions.dart';
import 'package:pokemonapp/features/pokemon/data/datasources/pokemon_remote_data_source.dart';

import 'package:pokemonapp/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokemonapp/features/pokemon/domain/repositories/pokemon_repository.dart';

class PokemonRepositoryImpl implements PokemonRepository {
  final PokemonRemoteDataSource remoteDataSource;

  PokemonRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Pokemon> getPokemon(String term) async {
    try {
      final remotePokemon = await remoteDataSource.getPokemon(term);
      return remotePokemon;
    } on ServerException {
      throw ServerException();
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<List<Pokemon>> getPokemonList({
    required int offset,
    required int limit,
  }) async {
    try {
      final remotePokemonList = await remoteDataSource.getPokemonList(
        offset: offset,
        limit: limit,
      );
      return remotePokemonList;
    } on ServerException {
      throw ServerException();
    } catch (e) {
      throw ServerException();
    }
  }
}
