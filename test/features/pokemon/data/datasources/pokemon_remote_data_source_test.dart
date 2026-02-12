import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokemonapp/core/errors/exceptions.dart';
import 'package:pokemonapp/features/pokemon/data/datasources/pokemon_remote_data_source.dart';
import 'package:pokemonapp/features/pokemon/data/models/pokemon_model.dart';

import '../../../../helpers/test_helpers.dart';

void main() {
  late PokemonRemoteDataSourceImpl dataSource;
  late MockDioClient mockDioClient;
  late MockDio mockDio;

  setUp(() {
    mockDioClient = MockDioClient();
    mockDio = MockDio();
    when(() => mockDioClient.dio).thenReturn(mockDio);
    dataSource = PokemonRemoteDataSourceImpl(dioClient: mockDioClient);
  });

  group('getPokemon', () {
    const tPokemonName = 'bulbasaur';
    const tPokemonModel = PokemonModel(
      id: 1,
      name: 'bulbasaur',
      imageUrl: 'url',
    );

    test('should return PokemonModel when the response code is 200', () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          data: {
            'id': 1,
            'name': 'bulbasaur',
            'sprites': {'front_default': 'url'},
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final result = await dataSource.getPokemon(tPokemonName);

      expect(result, equals(tPokemonModel));
    });

    test(
      'should throw ServerException when the response code is 404 or other',
      () async {
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            data: 'Something went wrong',
            statusCode: 404,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final call = dataSource.getPokemon;

        expect(() => call(tPokemonName), throwsA(isA<ServerException>()));
      },
    );

    test('should throw ServerException when DioException occurs', () async {
      when(
        () => mockDio.get(any()),
      ).thenThrow(DioException(requestOptions: RequestOptions(path: '')));

      final call = dataSource.getPokemon;

      expect(() => call(tPokemonName), throwsA(isA<ServerException>()));
    });
  });

  group('getPokemonList', () {
    const tOffset = 0;
    const tLimit = 20;
    const tPokemonModelList = [
      PokemonModel(
        id: 1,
        name: 'bulbasaur',
        imageUrl:
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png',
      ),
    ];

    test(
      'should return List<PokemonModel> when the response code is 200',
      () async {
        when(
          () => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: {
              'results': [
                {
                  'name': 'bulbasaur',
                  'url': 'https://pokeapi.co/api/v2/pokemon/1/',
                },
              ],
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.getPokemonList(
          offset: tOffset,
          limit: tLimit,
        );

        expect(result, equals(tPokemonModelList));
      },
    );

    test(
      'should throw ServerException when the response code is not 200',
      () async {
        when(
          () => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: 'Something went wrong',
            statusCode: 404,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final call = dataSource.getPokemonList;

        expect(
          () => call(offset: tOffset, limit: tLimit),
          throwsA(isA<ServerException>()),
        );
      },
    );
  });
}
