import 'package:flutter/material.dart';
import 'package:stream_it/screens/user/watch_movie.dart';

import '../../models/movie.dart';
import '../../repositories/movie.dart';
import '../../repositories/profile.dart';

class HistoryView extends StatefulWidget {
  final profile_id;
  final profile_name;

  const HistoryView({super.key,this.profile_name,this.profile_id});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    recuperation();
  }

  bool isLoading = true;
  var prf=ProfileRepository();
  var flm=MovieRepository();

  List<Movie> all_movies = [];

  Future<void> recuperation() async{
    try{
      final fetchedmovies = await prf.getManyMany<Movie>(widget.profile_id, "history");
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
        title: Text("VOTRE HISTORIQUE ",style: TextStyle(fontSize:25,fontWeight: FontWeight.bold ),) ,
        //backgroundColor: Colors.purple,
      ),
        body:all_movies.isEmpty
            ? Center(
              child: Text(
                "Aucun historique disponible",
                style: TextStyle(color: Colors.grey,fontSize: 20),
              ),
            )
            :GridView.builder(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 350,mainAxisExtent: 250,mainAxisSpacing: 20,crossAxisSpacing: 20),
            itemCount: all_movies.length,
            padding: EdgeInsets.all(10),
            itemBuilder: (context,index){
              var movie=all_movies[index];
              return GestureDetector(
                onTap: (){
                  movie.views++;
                  flm.update(movie);
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
                                setState(() {

                                });
                              },
                              icon: const Icon(Icons.favorite_border_outlined)),
                        ]
                    )
                ),
              );
            }
        )
    );
  }
}
