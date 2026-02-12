import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokemonapp/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokemonapp/features/pokemon/domain/usecases/get_pokemon.dart';

import '../../../../helpers/test_helpers.dart';

void main() {
  late GetPokemon useCase;
  late MockPokemonRepository mockPokemonRepository;

  setUp(() {
    mockPokemonRepository = MockPokemonRepository();
    useCase = GetPokemon(mockPokemonRepository);
  });

  const tPokemonName = 'bulbasaur';
  const tPokemon = Pokemon(id: 1, name: 'bulbasaur', imageUrl: 'url');

  test('should get pokemon from the repository', () async {
    when(
      () => mockPokemonRepository.getPokemon(any()),
    ).thenAnswer((_) async => tPokemon);

    final result = await useCase(tPokemonName);

    expect(result, tPokemon);
    verify(() => mockPokemonRepository.getPokemon(tPokemonName));
    verifyNoMoreInteractions(mockPokemonRepository);
  });
}
