import 'package:flutter/material.dart';
import 'package:stream_it/models/user.dart';
import 'package:stream_it/repositories/user.dart';
import 'package:stream_it/screens/user/movies.dart';

import '../../models/avatar.dart';
import '../../models/profile.dart';
import '../../repositories/avatar.dart';
import '../../repositories/profile.dart';
import 'addProfils.dart';


class UserPageHome extends StatefulWidget {
  final idUser;
  const UserPageHome({super.key,required this.idUser});

  @override
  State<UserPageHome> createState() => _UserPageHomeState();
}

class _UserPageHomeState extends State<UserPageHome> {

  @override
  void initState() {
    super.initState();
    assigne();
  }

  var pr=ProfileRepository();
    List<Profile> profilesTmp = [];
  List<Profile> profiles = [];

  var a=AvatarRepository();
  Map<String, Avatar> AvatarCache = {};  // stoqué touts les avatars
    List<Avatar>AvatarCacheTmp=[];

  Future<void> assigne() async{
    try{
      profilesTmp = await pr.getAll();
      AvatarCacheTmp=await a.getAll();

      // Filtrer les profils de l'utilisateur actuel
      profiles = profilesTmp.where((p) => p.userId == widget.idUser).toList();

      // Construire le cache des avatars
      for (var avatar in AvatarCacheTmp) {
        AvatarCache[avatar.id!] = avatar;
      }
        setState(() {});

    } catch (e) {
      print("Erreur: $e");
    }
  }

  //affichage dans gridview
  Widget  buildGridViewProfile(Profile profile,Avatar avatar){
    return GestureDetector(
       onTap: (){
         Navigator.push(context, MaterialPageRoute(builder: (context){
            return Movies(profile_name:profile.name);
           }
         )
         );
       },
     child: Card(
        elevation: 10,
       color: Colors.purpleAccent,
      child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              CircleAvatar(
              backgroundImage: NetworkImage(avatar.url),
                radius: 30,
              ),
            ListTile(
            //  title:Text(profile.name) ,
            ),
              Text(profile.name,style: TextStyle(fontSize: 20,
                  fontWeight: FontWeight.bold,),
              )
        ],
      ),
      ),
    ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
         title: Text("VOS PROFILS",style: TextStyle(fontSize:20,fontWeight: FontWeight.bold ),) ,
         //backgroundColor: Colors.purple,
       ),
      body:  profiles.isEmpty
          ? Center(child: CircularProgressIndicator())  // Afficher un indicateur de chargement si la liste est vide
          :GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2,
            mainAxisSpacing: 5,crossAxisSpacing: 5 ),

              itemCount: profiles!.length,
              itemBuilder: (context,index){
                  Profile profile = profiles[index];
                  Avatar? avatar = AvatarCache[profile.avatarId!];
                return buildGridViewProfile(profile,avatar!);
            },
          ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () async {
            if(profiles.length<5){
              var result =await Navigator.push(context,
                  MaterialPageRoute(builder: (context){
                    return AddProfil(idUser:widget.idUser);
                  }
                  )
              );
              // Rafraîchir les données si un profil a été ajouté
              if (result == true) {
                await assigne();
              }
            }
            else{
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Vous avez atteint le nombre maximum de profils par utilisateur"))
              );
            }

        },
        ),
      );
  }

}
