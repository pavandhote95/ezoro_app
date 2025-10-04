import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class ApiService extends GetxService {
  final String baseUrl = 'https://kotiboxglobaltech.com/travel_app/api';
  final GetStorage box = GetStorage();
  static const int _timeoutSeconds = 30;
    final GetConnect _client = GetConnect();
  // Generic POST helper with logging
  Future<Response> postData(
    String url,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
    int timeoutSeconds = 30,
  }) async {
    try {
      print("🌍 POST Request to: $url");
      print("📦 Request Body: $body");
      if (headers != null) print("🧾 Request Headers: $headers");

      final response = await _client
          .post(url, body, headers: headers)
          .timeout(Duration(seconds: timeoutSeconds));

      print("📥 Response Status: ${response.statusCode}");
      print("📥 Response Body: ${response.body}");
      print("📥 Response Headers: ${response.headers}");
      if (response.hasError) {
        print("⚠️ Response Error: ${response.statusText}");
      }

      return response;
    } catch (e, st) {
      print("❌ API Error: $e");
      print("📍 StackTrace: $st");
      rethrow;
    }
  }

  // Convenience wrapper specifically for saving device token
  Future<bool> saveDeviceToken({
    required int userId,
    required String deviceType,
    required String deviceToken,
  }) async {
    const String url =
        'https://kotiboxglobaltech.com/travel_app/api/push/save-token';

    final body = {
      'user_id': userId.toString(),
      'device_type': deviceType,
      'device_token': deviceToken,
    };

    final response = await postData(url, body);

    // adjust condition depending on your API (200/201 etc.)
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("✅ saveDeviceToken success for user $userId");
      return true;
    } else {
      print("❌ saveDeviceToken failed: ${response.statusCode}");
      return false;
    }
  }

  // Register User
  Future<http.Response> registerUser(Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl/register');
    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(Duration(seconds: _timeoutSeconds));
      return response;
    } catch (e) {
      throw Exception('Failed to register: $e');
    }
  }


  // Login User
  Future<http.Response> loginUser({
    String? email,
    String? phoneNumber,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/login');
    final Map<String, dynamic> body = {
      if (email != null && email.isNotEmpty) 'email': email,
      if (phoneNumber != null && phoneNumber.isNotEmpty)
        'phone_number': phoneNumber,
      'password': password,
    };

    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(Duration(seconds: _timeoutSeconds));
      return response;
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  // Forgot Password
  Future<http.Response> forgotPassword(String email) async {
    final url = Uri.parse('$baseUrl/forgot-password');
    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'email': email}),
          )
          .timeout(Duration(seconds: _timeoutSeconds));
      return response;
    } catch (e) {
      throw Exception('Failed to send forgot password request: $e');
    }
  }

  // Fetch Posts (always return map with status + data)
  Future<Map<String, dynamic>> fetchPosts() async {
    final url = Uri.parse('$baseUrl/posts');
    try {
      final response = await http
          .get(url)
          .timeout(Duration(seconds: _timeoutSeconds));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse is List) {
          return {'status': true, 'data': jsonResponse};
        } else if (jsonResponse is Map<String, dynamic>) {
          return {
            'status': jsonResponse['status'] ?? true,
            'data': jsonResponse['data'] ?? [],
          };
        } else {
          throw Exception('Unexpected API response format');
        }
      } else {
        throw Exception('Failed to fetch posts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch posts: $e');
    }
  }
    // Send OTP
  Future<http.Response> sendOtp(String phoneNumber) async {
    final url = Uri.parse('$baseUrl/send-otp');
    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({"phone_number": phoneNumber}),
          )
          .timeout(Duration(seconds: _timeoutSeconds));

      return response;
    } catch (e) {
      throw Exception('Failed to send OTP: $e');
    }
  }

  // Verify OTP
  Future<http.Response> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    final url = Uri.parse('$baseUrl/verify-otp');
    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              "phone_number": phoneNumber,
              "otp": otp,
            }),
          )
          .timeout(Duration(seconds: _timeoutSeconds));

      return response;
    } catch (e) {
      throw Exception('Failed to verify OTP: $e');
    }
  }


  // Fetch Posts by Location
  Future<Map<String, dynamic>> fetchPostsByLocation(String location) async {
    final url = Uri.parse('$baseUrl/posts/location');
    try {
      debugPrint("📍 Fetching posts for location: $location"); // print location
      debugPrint("🌐 API URL: $url"); // print URL

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'location': location}),
          )
          .timeout(Duration(seconds: _timeoutSeconds));

      debugPrint("🔵 Response Status Code: ${response.statusCode}");
      debugPrint("📦 Raw Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse is List) {
          debugPrint("✅ Response is a List with ${jsonResponse.length} items");
          return {'status': true, 'data': jsonResponse};
        } else if (jsonResponse is Map<String, dynamic>) {
          debugPrint("✅ Response is a Map with keys: ${jsonResponse.keys}");
          return {
            'status': jsonResponse['status'] ?? true,
            'data': jsonResponse['data'] ?? [],
          };
        } else {
          debugPrint("❌ Unexpected response type: ${jsonResponse.runtimeType}");
          throw Exception('Unexpected API response format');
        }
      } else {
        throw Exception(
          'Failed to fetch location posts: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('🚨 Error in fetchPostsByLocation: $e');
      throw Exception('Failed to fetch location posts: $e');
    }
  }
  Future<dynamic> deletePost(String token, int postId) async {
  final url = Uri.parse('https://kotiboxglobaltech.com/travel_app/api/post-delete');
  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'post_id': postId}),
  );
  return response;
}


  // Add Post with Multiple Image Uploads
  Future<http.Response> addPost({
    required String question,
    required String location,
    List<File>? imageFiles,
  }) async {
    final token = box.read('token');
    if (token == null) throw Exception('User not authenticated.');

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/add-posts'),
    );
    request.fields.addAll({'question': question, 'location': location});

    if (imageFiles != null && imageFiles.isNotEmpty) {
      for (var file in imageFiles) {
        request.files.add(
          await http.MultipartFile.fromPath('images[]', file.path),
        );
      }
    }

    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    try {
      final streamedResponse = await request.send().timeout(
        Duration(seconds: _timeoutSeconds),
      );
      return await http.Response.fromStream(streamedResponse);
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  // Logout User
  Future<http.Response> logoutUser(String token) async {
    final url = Uri.parse('$baseUrl/logout');
    try {
      final response = await http
          .post(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(Duration(seconds: _timeoutSeconds));
      return response;
    } catch (e) {
      throw Exception('Failed to logout: $e');
    }
  }



  // Post Like

  Future<String> postLikes(String currentType, int postId) async {
    final url = Uri.parse(
      'https://kotiboxglobaltech.com/travel_app/api/post/react',
    );
    final newType = currentType == "like" ? "dislike" : "like";

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization":
            "Bearer 274|xoqQF15YnD15XPGi3cIBrJYD2FIV8ZrHLj89c36Pcacc88f1",
      },
      body: jsonEncode({"post_id": postId, "type": newType}),
    );
    print('\x1B[31mApi Start\x1B[0m');

    final body = jsonDecode(response.body);
    print("API response: $body");

    if (response.statusCode == 201) {
      if (body["status"] == true) {
        return body["data"]["type"] ?? newType;
      } else {
        throw Exception("Server rejected: ${body["message"]}");
      }
    } else {
      throw Exception("HTTP error ${response.statusCode}: ${response.body}");
    }
  }

  // Update Profile

  Future<void> updateProfile(
    String? image,
    String? first_name,
    String? last_name,
    String? email,
    String? phone_number,
    String? bio,
    String? travel_interest,
    String? visited_place,
    String? dream_destination,
    String? language,
     // String? travelType,
  //     String? travelMode
  ) async {
    final url = Uri.parse(
      'https://kotiboxglobaltech.com/travel_app/api/update-profile',
    );

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization":
            "Bearer 274|xoqQF15YnD15XPGi3cIBrJYD2FIV8ZrHLj89c36Pcacc88f1",
      },
      body: jsonEncode({
        "image": image,
        "first_name": first_name,
        "last_name": last_name,
        "email": email,
        "phone_number": phone_number,
        "bio": bio,
        "travel_interest": travel_interest,
        "visited_place": visited_place,
        "dream_destination": dream_destination,
        "language": language,
      //   "travelType": travelType,
     //   "travelMode" : travelMode
      },)
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = jsonDecode(response.body);


      return body;
    } else {
      throw Exception("Failed to update profile: ${response.body}");
    }
  }
  
  
  
  Future<void> addComment (
      int postId,
      String comment,
      )async
  {
    final url= Uri.parse('https://kotiboxglobaltech.com/travel_app/api/add-comments');

    final response = await http.post(url,headers: {
      "Content-Type": "application/json",
      "Authorization":
      "Bearer 274|xoqQF15YnD15XPGi3cIBrJYD2FIV8ZrHLj89c36Pcacc88f1",
    },
    body: jsonEncode({
      "post_id": postId,
      "comment": comment,
    })
    );

     if(response.statusCode == 200)
       {
         final body = jsonDecode(response.body);
         print('\x1B[31m$body\x1B[0m');
         return body;
       }
       else
       {
         throw Exception("Failed to add comment: ${response.body}");
       }
  }

  
Future<List<Map<String, dynamic>>> searchLocation(String query) async {
    if (query.isEmpty) return [];

    final url = Uri.parse(
      "https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=10&addressdetails=1",
    );

    final response = await http.get(url, headers: {
      "User-Agent": "flutter_app" // required by Nominatim policy
    });

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception("Failed to fetch location");
    }
  }


// Yeh function post_id: 61 ke liye "like" ya "dislike" reaction bhejta hai
Future<http.Response> getProfileById(String token, int userId) async {
  try {
    final url = Uri.parse("$baseUrl/get-profile-byid/$userId");

    // Debug print request details
    print("🔹 API CALL: GET $url");
    print("🔹 Headers: {Authorization: Bearer $token}");

    final response = await http.get(
      url,
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    // Debug print response details
    print("✅ Status Code: ${response.statusCode}");
    print("✅ Response Body: ${response.body}");

    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception(
          "Failed to load profile: ${response.statusCode} - ${response.body}");
    }
  } catch (e) {
    print("❌ Exception: $e");
    rethrow;
  }
}

}