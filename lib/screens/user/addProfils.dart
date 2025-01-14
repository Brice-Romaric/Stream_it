import 'package:flutter/material.dart';

import '../../models/avatar.dart';
import '../../repositories/avatar.dart';
import '../../repositories/profile.dart';

class AddProfil extends StatefulWidget {
  final idUser;
  const AddProfil({super.key,required this.idUser});

  @override
  State<AddProfil> createState() => _AddProfilState();
}

class _AddProfilState extends State<AddProfil> {

  @override
  void initState() {
    super.initState();
    getAvatars();
  }
      bool isLoading = true;
     var nameController=TextEditingController();
     var a=AvatarRepository();
      var p=ProfileRepository();
     List<Avatar>avatar=[];
      Avatar ?avatarSelected;

     var _mykey=GlobalKey<FormState>();

     Future<void> getAvatars() async{
       try{
         avatar=await a.getAll();
         if (avatar.isNotEmpty) {
           avatarSelected = avatar[0];
         }

       }catch (e) {
         print("Erreur: $e");
       }finally {
         setState(() {
           isLoading = false; // Marquer la fin du chargement
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
        title: Text("AJOUT DE PROFILS",style: TextStyle(fontSize:20,fontWeight: FontWeight.bold )),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Form(
              key: _mykey,
                  child: Column(
                    children: [
                      SizedBox(height: 20,),
                      TextFormField(
                        controller: nameController,
                        validator: (value){
                           if (value==null || value!.isEmpty){
                             return "saisissez le nom de votre profil";
                           }
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          prefixIcon:Icon(Icons.accessibility) ,
                          label: Text("Nom Profil"),
                          hintText: "choisissez nom du profil",
                        ),
                      ),

                      SizedBox(height: 30,),

                      Row(
                        children: [
                          Text("CHOIX AVATAR:"),
                          SizedBox(width: 20,),
                          avatar.isEmpty
                              ? CircularProgressIndicator()
                         : DropdownButton(value: avatarSelected,
                              items: avatar.map(
                                  (a)=>DropdownMenuItem(
                                        child: CircleAvatar(
                                          radius: 20,
                                          backgroundImage: NetworkImage(a!.url)
                                        ),
                                    value: a,
                                  )
                              ).toList(),
                              onChanged: (e){
                                  setState(() {
                                     avatarSelected=e!;
                                  });
                              }
                              ),
                        ],
                      ),
                      SizedBox(height: 100,),
                      SizedBox(
                        width: double.infinity,
                        height:50,
                        child: ElevatedButton(
                          style:const ButtonStyle(
                            backgroundColor:WidgetStatePropertyAll(Colors.purpleAccent),
                          ) ,
                            child: Text("Ajout de profil",style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),),
                          onPressed: (){
                              if (_mykey.currentState!.validate()) {
                                var name=nameController.text;
                                var userId=widget.idUser;
                                var AvatarId=avatarSelected!.id;
                                 p.create({
                                  "avatar_id":AvatarId,
                                  "name":name,
                                  "user_id":userId
                                });
                                   ScaffoldMessenger.of(context).showSnackBar(
                                       SnackBar(content: Text("nouveau profil créé"))
                                   );

                                Navigator.pop(context, true);
                              }
                            },
                        ),
                      )
                  ],
            )
            ),
          )
        ],
      ),

    );
  }
}
