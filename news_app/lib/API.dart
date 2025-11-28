import 'dart:convert';
import 'package:http/http.dart' as http;

// in this class, we define the structure of a news article
class NewsArticle {
  String title;
  String description;
  String url;
  String image;
  String author;
  String publishedAt;

  NewsArticle({
    required this.title,
    required this.description,
    required this.url,
    required this.image,
    required this.author,
    required this.publishedAt,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    String title = '';
    String description = '';
    String url = '';
    String image = '';
    String author = 'Unknown';
    String publishedAt = '';

    if (json['title'] != null) {
      title = json['title'];
    }
    if (json['description'] != null) {
      description = json['description'];
    }
    if (json['url'] != null) {
      url = json['url'];
    }
    if (json['image'] != null) {
      image = json['image'];
    }
    if (json['source'] != null && json['source']['name'] != null) {
      author = json['source']['name'];
    }
    if (json['publishedAt'] != null) {
      publishedAt = json['publishedAt'];
    }

    return NewsArticle(
      title: title,
      description: description,
      url: url,
      image: image,
      author: author,
      publishedAt: publishedAt,
    );
  }
}

class NewsService {
  final String apiKey = "f771b3d5c356e4821d0dcea1a4ea82e1";
  final String baseUrl = "https://gnews.io/api/v4";

  Future<List<NewsArticle>> fetchTopArticles(int n) async {
    String url =
        baseUrl +
        '/top-headlines?max=' +
        n.toString() +
        '&lang=en&apikey=' +
        apiKey;
    var response = await http.get(Uri.parse(url));
    //checking the response status here
    if (response.statusCode != 200) {
      print('Failed to load news');
      return [];
    }
    //decode the response body
    var data = json.decode(response.body);

    // prepare an empty list for articles
    List<NewsArticle> articles = [];
    for (var item in data['articles']) {
      NewsArticle article = NewsArticle.fromJson(item);
      articles.add(article);
    }
    return articles;
  }

  // search articles by keyword
  Future<List<NewsArticle>> searchByKeyword(String keyword) async {
    String url = baseUrl + '/search?q=' + keyword + '&lang=en&apikey=' + apiKey;

    var response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      print('Failed to search news');
      return [];
    }
    var data = json.decode(response.body);

    List<NewsArticle> articles = [];
    for (var item in data['articles']) {
      NewsArticle article = NewsArticle.fromJson(item);
      articles.add(article);
    }
    return articles;
  }

  Future<NewsArticle?> searchByTitle(String title) async {
    List<NewsArticle> articles = await searchByKeyword(title);
    for (int i = 0; i < articles.length; i++) {
      NewsArticle article = articles[i];
      if (article.title.toLowerCase().contains(title.toLowerCase())) {
        return article;
      }
    }
    return null;
  }

  Future<NewsArticle?> searchByAuthor(String author) async {
    List<NewsArticle> articles = await fetchTopArticles(50);
    for (int i = 0; i < articles.length; i++) {
      NewsArticle article = articles[i];
      if (article.author.toLowerCase().contains(author.toLowerCase())) {
        return article;
      }
    }
    return null;
  }
}
