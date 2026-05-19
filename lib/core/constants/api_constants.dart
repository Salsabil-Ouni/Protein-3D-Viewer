class ApiConstants {
  static const String pdbBaseUrl = 'https://data.rcsb.org/rest/v1/core';
  static const String pdbSearchUrl = 'https://search.rcsb.org/rcsbsearch/v2/query';
  static const String pdbFileBaseUrl = 'https://files.rcsb.org/download';
  static const String mockAuthBaseUrl = 'https://reqres.in/api';
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Google Gemini API — get a free key at https://aistudio.google.com/
  static const String geminiApiKey = 'AIzaSyDpB97nIrjjfqfkgeh86i6XcJ3gX5Ru0Cw';
  static const String geminiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-lite:generateContent';
}
