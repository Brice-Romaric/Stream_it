
import 'package:flutter/material.dart';
import 'package:stream_it/screens/user/history.dart';
import 'package:stream_it/screens/user/watch_movie.dart';

import '../../models/category.dart';
import '../../models/movie.dart';
import '../../repositories/category.dart';
import '../../repositories/movie.dart';
import 'favorite.dart';

class Movies extends StatefulWidget {
  final profile_name;
  final avatar_url;
  final profile_id;
  const Movies({super.key,this.profile_name,this.profile_id,this.avatar_url});

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
          title: Text("VOS FILMS",style: TextStyle(fontSize:25,fontWeight: FontWeight.bold ),) ,
            //backgroundColor: Colors.purple,
          ),
        body:ListView.builder(
            scrollDirection: Axis.vertical,
            padding: const EdgeInsets.all(10),
             itemCount:categories.length ,
            itemBuilder: (context,index) {
              var  category = categories[index];
              var movies = categoryMoviesMap[category] ?? [];

              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              // Nom de la catégorie
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        category.name,
                        style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                        ),
                      ),
                    ),
                SizedBox(
                  height: 250, // Hauteur des cartes de films
                    child: movies.isEmpty
                        ? Center(
                          child: Text(
                        "Aucun film disponible",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                    :ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: movies.length,
                      itemBuilder: (context, movieIndex) {
                        var movie = movies[movieIndex];
                        return GestureDetector(
                          onTap: (){
                              //logique incrementation des vues
                            Navigator.push(context, MaterialPageRoute(builder: (context){
                              return WatchMovie(profile_name:widget.profile_name,profile_id:widget.profile_id,
                                  movie_id:movie.id,movie_title:movie.title);
                              })
                            );
                          },
                           child: Card(
                                margin: const EdgeInsets.only(right: 10),
                                elevation: 5,
                                color: Colors.purple.shade100,
                                child: SizedBox(
                                    width: 200,// Largeur de chaque carte
                                    child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          CircleAvatar(
                                            backgroundImage: NetworkImage(movie.coverUrl ?? ''),
                                            radius: 50,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              movie.title,
                                              style: const TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Text("${movie.views} vues",
                                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              movie.description,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ]
                                    )
                                )
                            )
                        );
                      }
                    )
                  ),
              ]
              );
            }
            ),
          drawer: Builder(
              builder: (context){
                  return Drawer(
                    backgroundColor: Colors.purple.shade100,
                    child: Column(
                       children: [
                         DrawerHeader(
                            child: Column(
                              children: [
                                CircleAvatar(
                                  backgroundImage: NetworkImage(widget.avatar_url),
                                  radius: 50,
                                ),
                                SizedBox(height: 5,),
                                Text("${widget.profile_name}",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                                ],
                              )
                         ),
                         ListTile(
                           leading:Icon(Icons.heart_broken),
                           title: Text("VOS FAVORIS"),
                           onTap:  () {
                              Navigator.push((context),MaterialPageRoute(builder: (context){
                                return Favorites(profile_name:widget.profile_name,profile_id:widget.profile_id);
                              }
                              )
                              );
                           },
                         ),
                         ListTile(
                           leading:Icon(Icons.history_rounded),
                           title:Text("VOTRE HISTORIQUE"),
                           onTap:  () {
                                 Navigator.push((context),MaterialPageRoute(builder: (context){
                                   return History(profile_name:widget.profile_name,profile_id:widget.profile_id);
                                 }
                              )
                             );
                           },
                         ),
                       ],
                    ),
                  );
                }
          ) ,
        ) ;
  }
}
