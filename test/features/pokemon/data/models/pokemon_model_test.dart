import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokemonapp/features/pokemon/data/models/pokemon_model.dart';
import 'package:pokemonapp/features/pokemon/domain/entities/pokemon.dart';

void main() {
  const tPokemonModel = PokemonModel(
    id: 1,
    name: 'bulbasaur',
    imageUrl:
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png',
  );

  test('should be a subclass of Pokemon entity', () async {
    expect(tPokemonModel, isA<Pokemon>());
  });

  group('fromJson', () {
    test('should return a valid model from JSON', () async {
      final Map<String, dynamic> jsonMap = {
        'id': 1,
        'name': 'bulbasaur',
        'sprites': {
          'front_default':
              'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png',
        },
      };

      final result = PokemonModel.fromJson(jsonMap);

      expect(result, tPokemonModel);
    });
  });

  group('fromListJson', () {
    test('should return a valid model from List JSON', () async {
      final Map<String, dynamic> jsonMap = {
        'name': 'bulbasaur',
        'url': 'https://pokeapi.co/api/v2/pokemon/1/',
      };

      final result = PokemonModel.fromListJson(jsonMap);

      expect(result, tPokemonModel);
    });
  });

  group('toJson', () {
    test('should return a JSON map containing the proper data', () async {
      final result = tPokemonModel.toJson();

      final expectedJsonMap = {
        'id': 1,
        'name': 'bulbasaur',
        'sprites': {
          'front_default':
              'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png',
        },
      };

      expect(result, expectedJsonMap);
    });
  });
}
