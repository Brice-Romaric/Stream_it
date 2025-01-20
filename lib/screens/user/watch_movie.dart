/*import 'package:flutter/material.dart';

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
} */

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class WatchMovie extends StatefulWidget {
  final  profile_name;
  final  profile_id;
  final  movie_url;
  final  movie_title;

  const WatchMovie({
    super.key,
    required this.profile_name,
    required this.profile_id,
    required this.movie_url,
    required this.movie_title,
  }) ;

  @override
  State<WatchMovie> createState() => _WatchMovieState();
}

class _WatchMovieState extends State<WatchMovie> {
 // late VideoPlayerController _controller;
  late YoutubePlayerController _controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = YoutubePlayerController(
        initialVideoId: YoutubePlayer.convertUrlToId(widget.movie_url)!, // Conversion de l'URL en ID
        flags: YoutubePlayerFlags(
          autoPlay: true, // Lecture automatique
          mute: false,    // Son activé par défaut
        ),
      );

      setState(() {
        isLoading = false;
      });

    } catch (e) {
      print("Erreur lors de l'initialisation de la vidéo : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Impossible de charger la vidéo")),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie_title),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Lecteur YouTube
          YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true, // Afficher la barre de progression
            onReady: () {
              print("Le lecteur est prêt !");
            },
          ),

        ],
      ),
    );
  }
}
