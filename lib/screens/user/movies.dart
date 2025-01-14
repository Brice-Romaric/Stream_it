
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
  List<Movie> movies = [];

  var ctg=CategoryRepository();
  List<Category> categories = [];

  Future<void> recuperation() async{
    try{
      movies = await flm.getAll();
      //categories=await ctg.getAll();
      setState(() {

      });
    } catch (e) {
      print("Erreur: $e");
    }finally {
      print("oh $movies ");
      //print("oh $categories ");
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
              crossAxisCount: 2,mainAxisSpacing: 10,crossAxisSpacing: 10),
            itemCount:movies.length ,
            itemBuilder: (context,index) {
               List<Movie> categoryMovies=  ctg.getManyMany<Movie>(categories[index], "movie_categories") as List<Movie>;
               print("oh $categoryMovies");
               return Card(
                  elevation: 5,
                  color: Colors.purple,
                  child: categoryMovies.isEmpty
                      ? const Center(child: Text("Aucun film disponible"))
                      :Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(categoryMovies[index].coverUrl),
                            radius: 30,
                          ),
                          ListTile(
                              title:Text(categoryMovies[index].title) ,
                            subtitle: Text(categoryMovies[index].views as String),
                          ),
                          Text(categoryMovies[index].description,style: TextStyle(fontSize: 20,
                            fontWeight: FontWeight.bold,),
                          )
                        ],
                      ),
                    );
                    }
                ),
        ) ;
  }
}
