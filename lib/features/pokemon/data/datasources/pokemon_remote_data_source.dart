import 'package:dio/dio.dart';
import 'package:pokemonapp/core/errors/exceptions.dart';
import 'package:pokemonapp/core/network/dio_client.dart';
import 'package:pokemonapp/features/pokemon/data/models/pokemon_model.dart';

abstract class PokemonRemoteDataSource {
  Future<PokemonModel> getPokemon(String term);
  Future<List<PokemonModel>> getPokemonList({
    required int offset,
    required int limit,
  });
}

class PokemonRemoteDataSourceImpl implements PokemonRemoteDataSource {
  final DioClient dioClient;

  PokemonRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<PokemonModel> getPokemon(String term) async {
    try {
      final response = await dioClient.dio.get('/pokemon/$term');
      if (response.statusCode == 200) {
        return PokemonModel.fromJson(response.data);
      } else {
        throw ServerException();
      }
    } on DioException {
      throw ServerException();
    }
  }

  @override
  Future<List<PokemonModel>> getPokemonList({
    required int offset,
    required int limit,
  }) async {
    try {
      final response = await dioClient.dio.get(
        '/pokemon',
        queryParameters: {'offset': offset, 'limit': limit},
      );
      if (response.statusCode == 200) {
        final List results = response.data['results'];
        return results.map((e) => PokemonModel.fromListJson(e)).toList();
      } else {
        throw ServerException();
      }
    } on DioException {
      throw ServerException();
    }
  }
}
