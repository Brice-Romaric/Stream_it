import 'package:flutter/material.dart';
import 'package:stream_it/models/model.dart';

abstract class DetailsScreen<T extends Model> extends StatefulWidget {
  final T item;
  final String title;

  const DetailsScreen({super.key, required this.item, required this.title});

  @override
  State<DetailsScreen<T>> createState() => _DetailsScreenState<T>();

  Widget buildFieldsContainer(BuildContext context) {
    return Column(
        children: item.map((entry) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "${entry.key} : ",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text("${entry.value}")
        ],
      );
    }).toList());
  }
}

class _DetailsScreenState<T extends Model> extends State<DetailsScreen<T>> {
  @override
  Widget build(BuildContext context) {
    var lowerTitle = widget.title.toLowerCase();
    var capitalTitle =
        "${widget.title[0].toUpperCase()}${widget.title.substring(1).toLowerCase()}";

    return Scaffold(
        appBar: AppBar(
          title: Text(
            "${capitalTitle}s",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        body: Container(
            padding: EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Détails d'${lowerTitle == 'catégorie' ? 'une' : 'un'} $lowerTitle",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                widget.buildFieldsContainer(context)
              ],
            )));
  }
}
