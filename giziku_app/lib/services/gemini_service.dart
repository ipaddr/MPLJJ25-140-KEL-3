import 'dart:convert';
import 'package:http/http.dart' as http;

// Ganti dengan API Key Gemini Anda
// PENTING: Jangan menyimpan API Key sensitif langsung di kode aplikasi yang akan dirilis.
// Gunakan variabel lingkungan atau cara yang lebih aman untuk aplikasi produksi.
const String _geminiApiKey =
    'AIzaSyDwseI11-Ed3-P0uMXqicELHEZGpj7iKhg'; // <-- GANTI INI
const String _geminiApiUrl =
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$_geminiApiKey';

Future<String> getGeminiResponse(String prompt) async {
  try {
    final response = await http.post(
      Uri.parse(_geminiApiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Parsing respons dari Gemini API
      // Struktur respons bisa bervariasi, sesuaikan dengan dokumentasi API
      if (data['candidates'] != null && data['candidates'].isNotEmpty) {
        final candidate = data['candidates'][0];
        if (candidate['content'] != null &&
            candidate['content']['parts'] != null &&
            candidate['content']['parts'].isNotEmpty) {
          return candidate['content']['parts'][0]['text'] ??
              'Maaf, saya tidak mengerti.';
        }
      }
      return 'Maaf, saya tidak dapat memproses permintaan Anda saat ini.';
    } else {
      // Handle error response
      print('Error API: ${response.statusCode}');
      print('Response body: ${response.body}');
      return 'Terjadi kesalahan saat menghubungi bot. Kode status: ${response.statusCode}';
    }
  } catch (e) {
    // Handle network or other errors
    print('Error: $e');
    return 'Terjadi kesalahan: $e';
  }
}
