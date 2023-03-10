import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pelis_app/helpers/debouncer.dart';
import 'package:pelis_app/models/models.dart';
import 'package:pelis_app/models/search_response.dart';

class MuvieProvider extends ChangeNotifier {
  String _baseUrl = 'api.themoviedb.org';
  String _apiKey = '7741c97bc01606f14b0e384dc9747642';
  String _languaeg = 'es-ES';

  List<Movie> onDisplayMovies = [];
  List<Movie> onPopularMovies = [];

  Map<int, List<Cast>> movieCast = {};

  int _popularPage = 0;

  final deboncer = Debouncer(
    duration: const Duration(milliseconds: 500),
  );

  final StreamController<List<Movie>> _suggestionStreamController =
      new StreamController.broadcast();

  Stream<List<Movie>> get suggestionSteam => _suggestionStreamController.stream;

  MuvieProvider() {
    getOnDisplayMovies();
    getPopularMovies();
  }

  Future<String> _getJsonData(String endpoint, [int page = 1]) async {
    final url = Uri.https(_baseUrl, endpoint, {
      'api_key': _apiKey,
      'language': _languaeg,
      'page': '$page',
    });

    final response = await http.get(url);

    return response.body;
  }

  getOnDisplayMovies() async {
    final jsonData = await _getJsonData('/3/movie/now_playing');

    final res = NowPlayingResponse.fromJson(jsonData);

    onDisplayMovies = res.results;

    notifyListeners();
  }

  getPopularMovies() async {
    _popularPage++;

    final jsonData = await _getJsonData('/3/movie/popular', _popularPage);

    final resPopular = PopularResponse.fromJson(jsonData);

    onPopularMovies = [...onPopularMovies, ...resPopular.results];

    notifyListeners();
  }

  Future<List<Cast>> getMovieCast(int movieId) async {
    //Todo: Revisar el mapa
    if (movieCast.containsKey(movieId)) return movieCast[movieId]!;

    final jsonData =
        await _getJsonData('/3/movie/$movieId/credits', _popularPage);

    final resCredits = CreditsResponse.fromJson(jsonData);

    movieCast[movieId] = resCredits.cast;

    return resCredits.cast;
  }

  Future<List<Movie>> seatchMovies(String query) async {
    final url = Uri.https(_baseUrl, '/3/search/movie',
        {'api_key': _apiKey, 'language': _languaeg, 'query': query});

    final response = await http.get(url);
    final searchResponse = SearchResponse.fromJson(response.body);

    return searchResponse.results;
  }

  void getSuggestionByQuery(String searchTerm) {
    deboncer.value = '';
    deboncer.onValue = (value) async {
      final results = await seatchMovies(value);
      _suggestionStreamController.add(results);
    };

    final timer = Timer.periodic(Duration(milliseconds: 300), (_) {
      deboncer.value = searchTerm;
    });

    Future.delayed(Duration(milliseconds: 301)).then((_) => timer.cancel());
  }
}
