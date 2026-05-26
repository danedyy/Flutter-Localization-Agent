sealed class TransalatorAgent {}

class GeminiTranslatorAgent extends TransalatorAgent{
  final String model;
  final String geminiApiKey;
   GeminiTranslatorAgent({
    this.model = 'gemini-3.5-flash',
    required this.geminiApiKey
   });
}