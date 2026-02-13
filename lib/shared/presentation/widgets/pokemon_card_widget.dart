import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:pokemonapp/features/pokemon/domain/entities/pokemon.dart';

class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;
  final bool isDetail;

  const PokemonCard({super.key, required this.pokemon, this.isDetail = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.network(
              pokemon.imageUrl,
              height: isDetail ? 200 : 150,
              width: isDetail ? 200 : 150,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 100, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Text(
              pokemon.name.toUpperCase(),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (isDetail) ...[
              const SizedBox(height: 10),
              Text(
                'ID: ${pokemon.id}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

//Preview widget in devtools
@Preview(name: 'PokemonCard')
Widget previewPokemonCard() {
  return PokemonCard(
    pokemon: Pokemon(
      id: 1,
      name: 'Pikachu',
      imageUrl:
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/1.png',
    ),
  );
}
