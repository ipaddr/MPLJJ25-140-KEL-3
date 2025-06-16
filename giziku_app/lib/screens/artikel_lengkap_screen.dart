import 'package:flutter/material.dart';

class ArtikelLengkapScreen extends StatelessWidget {
  final List<Map<String, String>> artikelList;

  const ArtikelLengkapScreen({Key? key, required this.artikelList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Artikel Lengkap'),
      ),
      body: ListView.builder(
        itemCount: artikelList.length,
        itemBuilder: (context, index) {
          final artikel = artikelList[index];
          return ListTile(
            title: Text(artikel['title']!),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // TODO: Navigate to the full article screen
              print('Tapped on ${artikel['title']}');
            },
          );
        },
      ),
    );
  }
}