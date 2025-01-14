import 'package:flutter/material.dart';
import 'package:stream_it/repositories/favorite.dart';
import 'package:stream_it/screens/user/watch_movie.dart';

import '../../models/movie.dart';
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

  List<Movie> all_movies = [];

  Future<void> recuperation() async{
    try{
      final fetchedmovies = await prf.getManyMany<Movie>(widget.profile_id, "favorite");
      print("e $fetchedmovies");
      setState(() {
        all_movies=fetchedmovies;
      });
    }catch (e) {
      print("Erreur: $e");
    }finally {
      print("e $all_movies");
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
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,mainAxisSpacing: 20,crossAxisSpacing: 20),
          itemCount: all_movies.length,
          padding: EdgeInsets.all(10),
          itemBuilder: (context,index){
            var movie=all_movies[index];
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
                elevation: 5,
                color: Colors.purple.shade100,
                      child: Column(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(movie.coverUrl ?? ''),
                              radius: 40,
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
                             Text(
                                movie.description,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
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
