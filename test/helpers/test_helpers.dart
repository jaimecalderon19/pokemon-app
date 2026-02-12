import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokemonapp/core/network/dio_client.dart';
import 'package:pokemonapp/features/pokemon/data/datasources/pokemon_remote_data_source.dart';
import 'package:pokemonapp/features/pokemon/domain/repositories/pokemon_repository.dart';
import 'package:pokemonapp/features/pokemon/domain/usecases/get_pokemon.dart';
import 'package:pokemonapp/features/pokemon/domain/usecases/get_pokemon_list.dart';

class MockDio extends Mock implements Dio {}

class MockDioClient extends Mock implements DioClient {}

class MockPokemonRepository extends Mock implements PokemonRepository {}

class MockPokemonRemoteDataSource extends Mock
    implements PokemonRemoteDataSource {}

class MockGetPokemon extends Mock implements GetPokemon {}

class MockGetPokemonList extends Mock implements GetPokemonList {}
