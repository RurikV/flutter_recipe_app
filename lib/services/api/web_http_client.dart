// Dummy implementations of dart:io classes for web platform

// Dummy X509Certificate class for web
class X509Certificate {
  // Add any necessary properties or methods
}

// Dummy HttpClient class for web
class HttpClient {
  // Add any necessary properties or methods

  // Dummy badCertificateCallback setter
  set badCertificateCallback(bool Function(X509Certificate, String, int) callback) {
    // No-op for web
  }
}

// Dummy IOHttpClientAdapter class for web
class IOHttpClientAdapter {
  // Dummy createHttpClient setter
  set createHttpClient(HttpClient Function() callback) {
    // No-op for web
  }
}