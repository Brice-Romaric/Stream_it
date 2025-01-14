
import 'package:flutter/material.dart';

import '../../models/category.dart';
import '../../models/movie.dart';
import '../../repositories/category.dart';
import '../../repositories/movie.dart';

class Movies extends StatefulWidget {
  final profile_name;
  const Movies({super.key,this.profile_name});

  @override
  State<Movies> createState() => _MoviesState();
}

class _MoviesState extends State<Movies> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    recuperation();
  }

  bool isLoading = true;
  var flm=MovieRepository();
  var ctg=CategoryRepository();

  List<Movie> all_movies = [];
  List<Category> categories = [];
  Map<Category, List<Movie>> categoryMoviesMap = {};

  Future<void> recuperation() async{
    try{
      final fetchedCategories =await ctg.getAll();
      final fetchedMovies =await flm.getAll();
      final Map<Category, List<Movie>> fetchedCategoryMoviesMap = {};

      for (var category in fetchedCategories) {
        final movies = await ctg.getManyMany<Movie>(category, "movie_categories");
        fetchedCategoryMoviesMap[category] = movies;
        print("opo $fetchedCategoryMoviesMap");
      }

      setState(() {
        all_movies=fetchedMovies;
        categories = fetchedCategories;
        categoryMoviesMap = fetchedCategoryMoviesMap;
      });

    } catch (e) {
      print("Erreur: $e");
    }finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text("Chargement...")),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
        appBar: AppBar(
          title: Text("VOS FILMS:${widget.profile_name}",style: TextStyle(fontSize:20,fontWeight: FontWeight.bold ),) ,
            //backgroundColor: Colors.purple,
          ),
        body:GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,mainAxisSpacing: 10,crossAxisSpacing: 10),
            itemCount:categoryMoviesMap.length ,
            itemBuilder: (context,index) {
              var  category = categories[index];
              var movies = categoryMoviesMap[category] ?? [];

              return Card(
                elevation: 5,
                color: Colors.purple.shade100,
                child: movies.isEmpty
                    ? const Center(child: Text("Aucun film disponible"))
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: movies.map((movie) {
                    return Column(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(movie.coverUrl ?? ''),
                          radius: 30,
                        ),
                        ListTile(
                          title: Text(movie.title),
                          subtitle: Text("${movie.views} vues"),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            movie.description,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              );
            }
            ),
        ) ;
  }
}
