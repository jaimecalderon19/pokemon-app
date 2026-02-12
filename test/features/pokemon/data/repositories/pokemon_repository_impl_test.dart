import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokemonapp/core/errors/exceptions.dart';
import 'package:pokemonapp/features/pokemon/data/models/pokemon_model.dart';
import 'package:pokemonapp/features/pokemon/data/repositories/pokemon_repository_impl.dart';
import 'package:pokemonapp/features/pokemon/domain/entities/pokemon.dart';

import '../../../../helpers/test_helpers.dart';

void main() {
  late PokemonRepositoryImpl repository;
  late MockPokemonRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockPokemonRemoteDataSource();
    repository = PokemonRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  group('getPokemon', () {
    const tPokemonName = 'bulbasaur';
    const tPokemonModel = PokemonModel(
      id: 1,
      name: 'bulbasaur',
      imageUrl: 'url',
    );
    const Pokemon tPokemon = tPokemonModel;

    test(
      'should return data when the call to remote data source is successful',
      () async {
        when(
          () => mockRemoteDataSource.getPokemon(any()),
        ).thenAnswer((_) async => tPokemonModel);

        final result = await repository.getPokemon(tPokemonName);

        verify(() => mockRemoteDataSource.getPokemon(tPokemonName));
        expect(result, equals(tPokemon));
      },
    );

    test(
      'should throw ServerException when the call to remote data source is unsuccessful',
      () async {
        when(
          () => mockRemoteDataSource.getPokemon(any()),
        ).thenThrow(ServerException());

        expect(
          () => repository.getPokemon(tPokemonName),
          throwsA(isA<ServerException>()),
        );
      },
    );
  });

  group('getPokemonList', () {
    const tOffset = 0;
    const tLimit = 20;
    const tPokemonModelList = [
      PokemonModel(id: 1, name: 'bulbasaur', imageUrl: 'url'),
    ];
    const List<Pokemon> tPokemonList = tPokemonModelList;

    test(
      'should return data when the call to remote data source is successful',
      () async {
        when(
          () => mockRemoteDataSource.getPokemonList(
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => tPokemonModelList);

        final result = await repository.getPokemonList(
          offset: tOffset,
          limit: tLimit,
        );

        verify(
          () => mockRemoteDataSource.getPokemonList(
            offset: tOffset,
            limit: tLimit,
          ),
        );
        expect(result, equals(tPokemonList));
      },
    );

    test(
      'should throw ServerException when the call to remote data source is unsuccessful',
      () async {
        when(
          () => mockRemoteDataSource.getPokemonList(
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          ),
        ).thenThrow(ServerException());

        expect(
          () => repository.getPokemonList(offset: tOffset, limit: tLimit),
          throwsA(isA<ServerException>()),
        );
      },
    );
  });
}
