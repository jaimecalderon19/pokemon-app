import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokemonapp/features/pokemon/presentation/providers/pokemon_notifier.dart';
import 'package:pokemonapp/features/pokemon/presentation/providers/pokemon_state.dart';
import 'package:pokemonapp/shared/presentation/widgets/pokemon_card_widget.dart';

class PokemonPage extends ConsumerStatefulWidget {
  const PokemonPage({super.key});

  @override
  ConsumerState<PokemonPage> createState() => _PokemonPageState();
}

class _PokemonPageState extends ConsumerState<PokemonPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      ref.read(pokemonProvider.notifier).loadNextPage();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pokemonProvider);
    final notifier = ref.read(pokemonProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Pokemon Riverpod Clean Arch')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar Pokemon',
                hintText: 'Nombre o ID',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          notifier.searchPokemon('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onSubmitted: (value) => notifier.searchPokemon(value),
              onChanged: (value) {
                // Optional: Real-time search or just update state to show generic list if empty
                if (value.isEmpty) {
                  notifier.searchPokemon('');
                  setState(() {}); // Rebuild to hide suffix icon
                } else {
                  setState(() {}); // Rebuild to show suffix icon
                }
              },
            ),
          ),
          Expanded(child: _buildContent(state)),
        ],
      ),
    );
  }

  Widget _buildContent(PokemonState state) {
    if (state.isLoading && state.pokemonList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.pokemon != null) {
      return SingleChildScrollView(
        child: PokemonCard(pokemon: state.pokemon!, isDetail: true),
      );
    }

    if (state.error != null && state.pokemonList.isEmpty) {
      return Center(
        child: Text(
          state.error!.message,
          style: const TextStyle(color: Colors.red, fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: state.pokemonList.length + (state.isNextPageLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < state.pokemonList.length) {
          final pokemon = state.pokemonList[index];
          return PokemonCard(pokemon: pokemon);
        } else {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
