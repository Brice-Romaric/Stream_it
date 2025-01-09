import 'package:flutter/material.dart';

import '../../Models/Profile.dart';

class UserPageHome extends StatefulWidget {
  const UserPageHome({super.key});

  @override
  State<UserPageHome> createState() => _UserPageHomeState();
}

class _UserPageHomeState extends State<UserPageHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
         title: Text("Vos profils") ,
         backgroundColor: Colors.purple,
       ),
      body:  Container(
        child:GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, mainAxisSpacing: 20, crossAxisSpacing: 20),

            // itemCount: Catalog.getProductsCount(),

            itemBuilder: (context, index) {
            //  Profile profiles = Profile.getProduct(index);
            //  return buildGridViewProductItem(profiles);
            }),

        )
      );
  }
}
