import 'package:flutter/material.dart';
import 'package:pelis_app/providers/movies_provider.dart';
import 'package:pelis_app/widgets/widgets.dart';
import 'package:provider/provider.dart';

import 'package:pelis_app/search/search_delegate.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final moviesProvier = Provider.of<MuvieProvider>(context);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Peliculas en cines'),
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () =>
                  showSearch(context: context, delegate: MovieSearchdelegare()),
              icon: const Icon(Icons.search_outlined),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(children: [
            // Todo: cardSwiper
            CardSwiper(movies: moviesProvier.onDisplayMovies),

            // Todo: Listado de peliculas
            MovieSlider(
              movies: moviesProvier.onPopularMovies,
              title: 'Populares!',
              onNextPage: () => moviesProvier.getPopularMovies(),
            ),
          ]),
        ));
  }
}
