import 'package:flutter/material.dart';
import 'api.dart'; // your humanized api.dart

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "News App",
      home: NewsPage(),
    );
  }
}

class NewsPage extends StatefulWidget {
  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  List<NewsArticle> articles = [];
  bool loading = true;
  TextEditingController searchController = TextEditingController();
  NewsService newsService = NewsService();

  @override
  void initState() {
    super.initState();
    newsFetch();
  }

  void newsFetch() async {
    setState(() => loading = true);
    articles = await newsService.fetchTopArticles(10);
    setState(() => loading = false);
  }

  void newSearch() async {
    String query = searchController.text.trim();
    if (query.isEmpty) return;

    setState(() => loading = true);
    articles = await newsService.searchByKeyword(query);
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sowlutions News App"), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "You can search news here",
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(onPressed: newSearch, child: Text("Search")),
              ],
            ),
          ),
          if (loading)
            Expanded(child: Center(child: CircularProgressIndicator())),
          if (!loading)
            Expanded(
              child: ListView.builder(
                itemCount: articles.length,
                itemBuilder: (context, index) {
                  NewsArticle article = articles[index];
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 3,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (article.image != "")
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Image.network(
                              article.image,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 150,
                                  color: Colors.grey[300],
                                  child: Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                        SizedBox(height: 8),
                        Text(
                          article.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "By: ${article.author}",
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color.fromARGB(255, 41, 73, 189),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          article.description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
