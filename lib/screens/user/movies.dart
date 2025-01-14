
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
  var flm=MovieRepository();
  List<Movie> movies = [];

  var ctg=CategoryRepository();
  List<Category> categories = [];

  Future<void> recuperation() async{
    try{
      movies = await flm.getAll();
      categories=await ctg.getAll();

    } catch (e) {
      print("Erreur: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Text("VOS FILMS:${widget.profile_name}",style: TextStyle(fontSize:20,fontWeight: FontWeight.bold ),) ,
    //backgroundColor: Colors.purple,
      ),
        body:Container(
          height: 300,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,)
          )
        ) ,

    );
  }
}
