abstract final class OllamaConstants {
  OllamaConstants._();

  static const String defaultModel = 'gemma4:31b';
  static const double defaultTemperature = 0.6;
  static const int defaultNumPredict = 512;
  static const bool defaultStream = false;
  static const bool defaultThink = false;

  static const Map<String, dynamic> defaultOptions = {
    'temperature': defaultTemperature,
    'num_predict': defaultNumPredict,
  };
}