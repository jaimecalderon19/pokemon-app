import 'package:pokemonapp/features/pokemon/domain/entities/pokemon.dart';

class PokemonModel extends Pokemon {
  const PokemonModel({
    required super.id,
    required super.name,
    required super.imageUrl,
  });

  factory PokemonModel.fromJson(Map<String, dynamic> json) {
    return PokemonModel(
      id: json['id'],
      name: json['name'],
      imageUrl: json['sprites']['front_default'] ?? '',
    );
  }

  factory PokemonModel.fromListJson(Map<String, dynamic> json) {
    final url = json['url'] as String;

    final idStr = url.split('/')[6];
    final id = int.parse(idStr);
    return PokemonModel(
      id: id,
      name: json['name'],
      imageUrl:
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sprites': {'front_default': imageUrl},
    };
  }
}
