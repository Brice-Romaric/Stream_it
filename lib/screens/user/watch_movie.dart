import 'package:flutter/material.dart';

class WatchMovie extends StatefulWidget {
  final profile_id;
  final profile_name;
  final movie_id;
  final movie_title;

  const WatchMovie({super.key,this.profile_name,this.profile_id,this.movie_id,this.movie_title});

  @override
  State<WatchMovie> createState() => _WatchMovieState();
}

class _WatchMovieState extends State<WatchMovie> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text("vous suivez le film: ${widget.movie_title}",style: TextStyle(fontSize:25,fontWeight: FontWeight.bold ),) ,
        //backgroundColor: Colors.purple,
      ),
    );
  }
}
