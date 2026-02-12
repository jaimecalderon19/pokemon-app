import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokemonapp/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokemonapp/features/pokemon/domain/usecases/get_pokemon_list.dart';

import '../../../../helpers/test_helpers.dart';

void main() {
  late GetPokemonList useCase;
  late MockPokemonRepository mockPokemonRepository;

  setUp(() {
    mockPokemonRepository = MockPokemonRepository();
    useCase = GetPokemonList(mockPokemonRepository);
  });

  const tOffset = 0;
  const tLimit = 20;
  const tPokemonList = [Pokemon(id: 1, name: 'bulbasaur', imageUrl: 'url')];

  test('should get pokemon list from the repository', () async {
    when(
      () => mockPokemonRepository.getPokemonList(
        offset: any(named: 'offset'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => tPokemonList);

    final result = await useCase(offset: tOffset, limit: tLimit);

    expect(result, tPokemonList);
    verify(
      () =>
          mockPokemonRepository.getPokemonList(offset: tOffset, limit: tLimit),
    );
    verifyNoMoreInteractions(mockPokemonRepository);
  });
}
