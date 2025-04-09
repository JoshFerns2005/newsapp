import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:news_app/newsweb.dart';
import 'newsweb.dart';

class News extends StatefulWidget {
  @override
  final VoidCallback toggleTheme;
  const News({super.key, required this.toggleTheme});
  _NewsState createState() => _NewsState();
}

class _NewsState extends State<News> {
  List articles = [];
  List filteredArticles = [];
  bool isLoading = true;
  final searchController = TextEditingController();
  String searchQuery = '';

  Future<void> fetchNews() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(
          'https://newsapi.org/v2/top-headlines?country=us&apiKey=9180de6cc4544de891fd7a5a5a3d33d7'));
      if (response.statusCode == 200) {
        setState(() {
          articles = json.decode(response.body)['articles'];
        });
        _filterArticles();
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      print('Error fetching news: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch news')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterArticles() {
    setState(() {
      if (searchQuery.isEmpty) {
        filteredArticles = articles;
      } else {
        filteredArticles = articles.where((article) {
          final title = article['title']?.toLowerCase() ?? '';
          final description = article['description']?.toLowerCase() ?? '';
          return title.contains(searchQuery.toLowerCase()) ||
              description.contains(searchQuery.toLowerCase());
        }).toList();
      }
      isLoading = false;
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchNews();
    searchController.addListener(() {
      searchQuery = searchController.text;
      _filterArticles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('News Feed'),
        actions: [
          IconButton(
            icon: Icon(Icons.brightness_6),
            onPressed: widget.toggleTheme,
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.04,
              vertical: MediaQuery.of(context).size.height * 0.01,
            ),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search news...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: fetchNews,
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: filteredArticles.length,
                      itemBuilder: (context, index) {
                        final article = filteredArticles[index];
                        final imageUrl = article['urlToImage'];
                        final title = article['title'] ?? 'No Title';
                        final description =
                            article['description'] ?? 'No Description';
                        final source =
                            article['source']['name'] ?? 'Unknown Source';
                        final publishedAt = article['publishedAt'] ?? '';
                        final publishedDate =
                            DateTime.tryParse(publishedAt)?.toLocal();

                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  NewsWeb(url: article['url']),
                            ),
                          ),
                          child: Card(
                            margin: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.03,
                              vertical:
                                  MediaQuery.of(context).size.height * 0.01,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  imageUrl != null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.network(
                                            imageUrl,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.25,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.25,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.25,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.25,
                                          color: Colors.grey[300],
                                        ),
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.03),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.005),
                                        Text(
                                          description,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.01),
                                        Row(
                                          children: [
 
                                            SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.01),
                                            Expanded(
                                              child: Text(
                                                source,
                                                style: TextStyle(fontSize: 12),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.02),
                                            Text(
                                              publishedDate != null
                                                  ? '${publishedDate.day}/${publishedDate.month}/${publishedDate.year}'
                                                  : '',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
