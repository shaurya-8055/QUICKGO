import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/technician.dart';

class GeminiAIService {
  static const String _apiKey = 'AIzaSyBk3iLMocfigZ0KPiq1igjFZp-9IQRD0P8'; // TODO: Move to .env
  late final GenerativeModel _model;

  GeminiAIService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
    );
  }

  /// Analyze user's problem description and suggest the best service category
  Future<Map<String, dynamic>> analyzeServiceNeed(String problemDescription) async {
    try {
      final prompt = '''
Analyze this service request and determine the best service category and urgency:

Problem: "$problemDescription"

Respond in JSON format:
{
  "category": "one of: AC Repair, Plumber, Electrician, Appliance Repair, Mobile Repair, Painter",
  "urgency": "low, medium, or high",
  "estimatedDuration": "estimated time in hours",
  "suggestedMaterials": ["list of materials that might be needed"],
  "estimatedCost": "price range in INR"
}
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '{}';
      
      // Extract JSON from response (may have markdown code blocks)
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(text);
      if (jsonMatch != null) {
        return _parseJsonSafely(jsonMatch.group(0)!);
      }
      
      return {'error': 'Could not parse AI response'};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Rank technicians using AI based on multiple factors
  Future<List<Technician>> rankTechnicians({
    required List<Technician> technicians,
    required String serviceCategory,
    double? userLatitude,
    double? userLongitude,
    String? userProblemDescription,
  }) async {
    if (technicians.isEmpty) return [];

    try {
      // Build technician summary for AI
      final techniciansSummary = technicians.map((t) {
        final distance = t.distanceFrom(userLatitude, userLongitude);
        return {
          'id': t.id,
          'name': t.name,
          'rating': t.rating,
          'totalJobs': t.totalJobs,
          'experience': t.yearsExperience,
          'price': t.pricePerHour ?? 0,
          'distance': distance?.toStringAsFixed(1) ?? 'unknown',
          'verified': t.verified,
          'skills': t.skills,
        };
      }).toList();

      final prompt = '''
Rank these technicians for a "$serviceCategory" service request based on:
1. Rating (higher is better)
2. Experience (more years is better)
3. Total completed jobs (more is better)
4. Distance from customer (closer is better)
5. Price fairness (not too cheap, not too expensive)
6. Verified status (verified is better)

Problem: ${userProblemDescription ?? 'General service'}

Technicians:
${techniciansSummary.map((t) => '${t['id']}: ${t['name']} - Rating: ${t['rating']}, Jobs: ${t['totalJobs']}, Experience: ${t['experience']}y, Price: ₹${t['price']}/hr, Distance: ${t['distance']}km, Verified: ${t['verified']}').join('\n')}

Return only the technician IDs in order of recommendation (best first), separated by commas.
Example: id1,id2,id3
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text?.trim() ?? '';
      
      // Parse the ranked IDs
      final rankedIds = text.split(',').map((id) => id.trim()).where((id) => id.isNotEmpty).toList();
      
      // Reorder technicians based on AI ranking
      final Map<String, Technician> techMap = {for (var t in technicians) t.id: t};
      final List<Technician> ranked = [];
      
      for (final id in rankedIds) {
        if (techMap.containsKey(id)) {
          ranked.add(techMap[id]!);
          techMap.remove(id);
        }
      }
      
      // Add any remaining technicians that weren't ranked
      ranked.addAll(techMap.values);
      
      return ranked;
    } catch (e) {
      print('AI ranking error: $e');
      // Fallback: sort by rating and distance
      return _fallbackRanking(technicians, userLatitude, userLongitude);
    }
  }

  /// Estimate fair price for a service
  Future<Map<String, dynamic>> estimateFairPrice({
    required String serviceCategory,
    String? problemDescription,
    String? city,
  }) async {
    try {
      final prompt = '''
Estimate a fair price range for this service in ${city ?? 'India'}:

Service: $serviceCategory
Problem: ${problemDescription ?? 'Standard service'}

Provide:
1. Minimum price (INR)
2. Maximum price (INR)
3. Average market price (INR)
4. Factors affecting price

Respond in JSON:
{
  "minPrice": number,
  "maxPrice": number,
  "avgPrice": number,
  "factors": ["factor1", "factor2"]
}
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '{}';
      
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(text);
      if (jsonMatch != null) {
        return _parseJsonSafely(jsonMatch.group(0)!);
      }
      
      return {'error': 'Could not parse price estimate'};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Analyze reviews sentiment (detect fake/spam reviews)
  Future<Map<String, dynamic>> analyzeReviews(List<Map<String, dynamic>> reviews) async {
    if (reviews.isEmpty) return {'sentiment': 'neutral', 'fakeScore': 0};

    try {
      final reviewTexts = reviews.map((r) => '"${r['text']}" - ${r['rating']} stars').join('\n');
      
      final prompt = '''
Analyze these customer reviews and provide:
1. Overall sentiment (positive, neutral, negative)
2. Fake review probability (0-100, where 100 is definitely fake)
3. Common themes mentioned

Reviews:
$reviewTexts

Respond in JSON:
{
  "sentiment": "positive/neutral/negative",
  "fakeScore": number (0-100),
  "themes": ["theme1", "theme2"]
}
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '{}';
      
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(text);
      if (jsonMatch != null) {
        return _parseJsonSafely(jsonMatch.group(0)!);
      }
      
      return {'error': 'Could not analyze reviews'};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  Map<String, dynamic> _parseJsonSafely(String jsonString) {
    try {
      // Remove markdown code blocks if present
      String cleaned = jsonString
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      
      return json.decode(cleaned) as Map<String, dynamic>;
    } catch (e) {
      return {'error': 'JSON parse error'};
    }
  }
  }

  List<Technician> _fallbackRanking(
    List<Technician> technicians,
    double? userLat,
    double? userLon,
  ) {
    final List<Technician> sorted = List.from(technicians);
    sorted.sort((a, b) {
      // Sort by rating first
      final ratingCompare = b.rating.compareTo(a.rating);
      if (ratingCompare != 0) return ratingCompare;
      
      // Then by distance
      if (userLat != null && userLon != null) {
        final distA = a.distanceFrom(userLat, userLon) ?? double.infinity;
        final distB = b.distanceFrom(userLat, userLon) ?? double.infinity;
        final distCompare = distA.compareTo(distB);
        if (distCompare != 0) return distCompare;
      }
      
      // Finally by total jobs
      return b.totalJobs.compareTo(a.totalJobs);
    });
    return sorted;
  }
}
