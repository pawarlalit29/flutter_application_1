import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/screen_one/post_data.dart';
import 'package:http/http.dart' as http;

class ScreenOne extends StatefulWidget {
  const ScreenOne({Key? key}) : super(key: key);

  @override
  State<ScreenOne> createState() => _ScreenOneState();
}

class _ScreenOneState extends State<ScreenOne> {
  StreamController? _streamController;

  Future<PostData> fetchData() async {
    var url = Uri.https('newsapi.org','v2/everything',{'q':'tesla','from':'2022-07-18','sortBy':'publishedAt','apiKey':'246f768c43fb46a19be7edbd218893d1'});
    final response = await http.get(url,);

    if (response.statusCode == 200) {
      return PostData.fromJson(json.decode(response.body));
    } else {
      return PostData();
    }
  }

  loadPost() async {
    fetchData().then((value) async {
      _streamController?.add(value);
      return value;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    _streamController = StreamController();
    loadPost();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
      stream: _streamController?.stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }

        if (snapshot.hasData) {
          PostData data = snapshot.data as PostData;

          return ListView.builder(
            itemCount: data.articles?.length ?? 0,
            itemBuilder: (BuildContext context, int i) {
          
            return ListItemView(data.articles?[i] ?? Articles());
          });
        }

        if(snapshot.connectionState!= ConnectionState.done){
          return const Center(child: CircularProgressIndicator());
        }

        if(!snapshot.hasData && snapshot.connectionState == ConnectionState.done)
        {
          return const Text('No Post');
        }

        return Container();
      },
    ));
  }
}

class ListItemView extends StatelessWidget {
   
   Articles? articles;
   
   ListItemView(this.articles,{Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.withOpacity(0.7)
      ),
      margin: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(articles?.title ?? '',style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold
              ),),
          Container(
            height: 150,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              shape: BoxShape.rectangle,
              image: DecorationImage(image: NetworkImage(articles?.urlToImage ?? '',),fit: BoxFit.cover)
            ),
          ),
          SizedBox(height: 5,),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(articles?.publishedAt ?? ''))
        ],
      ),
    );
  }
}
