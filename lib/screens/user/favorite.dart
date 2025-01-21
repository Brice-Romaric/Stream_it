import 'package:flutter/material.dart';
import 'package:stream_it/repositories/favorite.dart';
import 'package:stream_it/screens/user/watch_movie.dart';

import '../../models/favorite.dart';
import '../../models/history.dart';
import '../../models/movie.dart';
import '../../repositories/category.dart';
import '../../repositories/history.dart';
import '../../repositories/movie.dart';
import '../../repositories/profile.dart';

class Favorites extends StatefulWidget {
  final profile_id;
  final profile_name;
  const Favorites({super.key,this.profile_name,this.profile_id});

  @override
  State<Favorites> createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    recuperation();
  }

  bool isLoading = true;
  var prf=ProfileRepository();
  var flm=MovieRepository();
  var hst=HistoryRepository();
  var ctg=CategoryRepository();
  var fav=FavoriteRepository();

  List<Movie> all_movies = [];

  Future<void> recuperation() async{
    try{
      final fetchedmovies = await prf.getManyMany<Movie>(widget.profile_id, "favorite");
      setState(() {
        all_movies=fetchedmovies;
      });
    }catch (e) {
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
        title: Text("VOS FAVORIS",style: TextStyle(fontSize:25,fontWeight: FontWeight.bold ),) ,
        //backgroundColor: Colors.purple,
      ),
      body:all_movies.isEmpty
          ? Center(
            child: Text(
              "Aucun favoris disponible",
              style: TextStyle(color: Colors.grey,fontSize: 20),
            ),
          )
          :GridView.builder(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
           mainAxisSpacing: 20,crossAxisSpacing: 20, maxCrossAxisExtent: 350,mainAxisExtent: 250),
          itemCount: all_movies.length,
          padding: EdgeInsets.all(10),
          itemBuilder: (context,index){
            var movie=all_movies[index];
            return GestureDetector(
              onTap: (){
                var now = DateTime.now();
                History hst1=History(profileId:widget.profile_id , movieId:movie.id!, datetime: now );
                hst.search({"movie_id": movie.id, "profile_id": widget.profile_id}).then((result){
                  if(result.isEmpty) {
                    movie.views++;
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
                  }
                }).then((_){
                  Navigator.push(context, MaterialPageRoute(builder: (context){
                    return WatchMovie(profile_name:widget.profile_name,profile_id:widget.profile_id,
                        movie_url:movie.url,movie_title:movie.title);
                  })
                  );
                });
              },
              child: Card(

                elevation: 5,
                color: Colors.purple.shade100,
                      child: Column(
                          children: [
                            SizedBox(height:10),
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
                            IconButton(
                                onPressed: () {
                                  //ajout ou retrait dans favoris
                                  Favorite fav1=Favorite(profileId:widget.profile_id , movieId:movie.id! );
                                  fav.search({"movie_id": movie.id, "profile_id": widget.profile_id}).then((result){
                                    if(result.isEmpty){
                                      print("impossible de ne pass quelque chose ici ");
                                    }else{
                                      fav.delete(result[0]).then((_){
                                          ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text("Retrait des favoris"))
                                          );
                                      });
                                    }
                                  }).then((_){
                                     Navigator.pop(context);
                                  });
                                },
                                icon: const Icon(Icons.favorite,color: Colors.pink,)
                            ),
                          ]
                      )
              ),
            );
          }
      ) ,
    );
  }
}
