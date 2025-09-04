import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class NewsController extends GetxController {
  // API Configuration
  static const String _apiKey = 'ee5d604b47584f2a80d179a0a241e798';
  static const String _baseUrl = 'https://newsapi.org/v2';

  // Observable variables
  var isLoading = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  
  // News data
  var newsList = <NewsArticle>[].obs;
  var filteredNewsList = <NewsArticle>[].obs;
  
  // Search functionality
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNews();
  }

  // Fetch news from API
  Future<void> fetchNews({String query = 'plants'}) async {
    try {
      isLoading(true);
      hasError(false);
      errorMessage('');

      final response = await http.get(
        Uri.parse('$_baseUrl/everything?q=$query&apiKey=$_apiKey&pageSize=50&sortBy=publishedAt'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'ok') {
          final articles = data['articles'] as List;
          
          // Filter out articles with null or [Removed] content
          final validArticles = articles.where((article) {
            return article['title'] != null && 
                   article['title'] != '[Removed]' &&
                   article['description'] != null &&
                   article['description'] != '[Removed]' &&
                   article['urlToImage'] != null;
          }).toList();
          
          newsList.value = validArticles
              .map((article) => NewsArticle.fromJson(article))
              .toList();
          
          filteredNewsList.value = newsList;
        } else {
          hasError(true);
          errorMessage('Failed to fetch news: ${data['message']}');
        }
      } else if (response.statusCode == 429) {
        hasError(true);
        errorMessage('Too many requests. Please try again later.');
      } else {
        hasError(true);
        errorMessage('Failed to fetch news. Status code: ${response.statusCode}');
      }
    } catch (e) {
      hasError(true);
      errorMessage('Network error: $e');
      print('News API error: $e');
    } finally {
      isLoading(false);
    }
  }

  // Search functionality
  void searchNews(String query) {
    searchQuery(query);
    
    if (query.isEmpty) {
      filteredNewsList.value = newsList;
    } else {
      filteredNewsList.value = newsList.where((article) {
        return article.title.toLowerCase().contains(query.toLowerCase()) ||
               article.description.toLowerCase().contains(query.toLowerCase()) ||
               article.source.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
  }

  // Refresh news
  Future<void> refreshNews() async {
    await fetchNews();
  }

  // Format date
  String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

// News Article Model
class NewsArticle {
  final String title;
  final String description;
  final String source;
  final String imageUrl;
  final String url;
  final DateTime publishedAt;
  final String author;

  NewsArticle({
    required this.title,
    required this.description,
    required this.source,
    required this.imageUrl,
    required this.url,
    required this.publishedAt,
    required this.author,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No Description',
      source: json['source']['name'] ?? 'Unknown Source',
      imageUrl: json['urlToImage'] ?? '',
      url: json['url'] ?? '',
      publishedAt: json['publishedAt'] != null 
          ? DateTime.parse(json['publishedAt'])
          : DateTime.now(),
      author: json['author'] ?? 'Unknown Author',
    );
  }
}