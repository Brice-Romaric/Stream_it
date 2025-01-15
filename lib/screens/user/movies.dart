import 'package:flutter/material.dart';

import 'package:stream_it/screens/user/watch_movie.dart';

import 'package:stream_it/models/history.dart';
import '../../models/category.dart';
import '../../models/favorite.dart';
import '../../models/movie.dart';

import 'package:stream_it/repositories/favorite.dart';
import 'package:stream_it/repositories/history.dart';
import '../../repositories/category.dart';
import '../../repositories/movie.dart';

import 'favorite.dart';
import 'history.dart';

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
  var fav=FavoriteRepository();
   var hst=HistoryRepository();

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

  Future<bool> isFavorite(Movie movie) async {
    try {
      final result = await fav.search({"movie_id": movie.id, "profile_id": widget.profile_id});
      return result.isNotEmpty;
    } catch (e) {
      print("Erreur lors de la vérification des favoris : $e");
      return false;
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
                            movie.views++;
                            var now = DateTime.now();
                            History hst1=History(profileId:widget.profile_id , movieId:movie.id!, datetime: now );
                            hst.search({"movie_id": movie.id, "profile_id": widget.profile_id}).then((result){
                                if(result.isEmpty) {
                                  flm.update(movie).then((_) {
                                    hst.create(hst1).then((_) {
                                      setState(() {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text(
                                                "Ajout aux historiques")
                                            )
                                        );
                                      });
                                    });
                                  });
                                }else{
                                  flm.update(movie).then((_) {
                                    setState(() {

                                    });
                                  });
                                }
                            }).then((_){
                              Navigator.push(context, MaterialPageRoute(builder: (context){
                                return WatchMovie(profile_name:widget.profile_name,profile_id:widget.profile_id,
                                    movie_id:movie.id,movie_title:movie.title);
                              })
                              );
                            });
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
                                            child:  IconButton(
                                              onPressed: () {
                                                //ajout ou retrait dans favoris
                                                Favorite fav1=Favorite(profileId:widget.profile_id , movieId:movie.id! );
                                                fav.search({"movie_id": movie.id, "profile_id": widget.profile_id}).then((result){
                                                  if(result.isEmpty){
                                                    fav.create(fav1).then((_) {
                                                        setState(() {
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                              SnackBar(content: Text("Ajout aux favoris"))
                                                          );
                                                        });
                                                    });
                                                  }else{
                                                    fav.delete(result[0]).then((_){
                                                      setState(() {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(content: Text("Retrait des favoris"))
                                                        );
                                                      });
                                                    });
                                                  }
                                                });
                                              },
                                                icon: Icon(Icons.favorite_border_outlined )
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
                           leading:Icon(Icons.favorite_border_outlined),
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
                                   return HistoryView(profile_name:widget.profile_name,profile_id:widget.profile_id);
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
