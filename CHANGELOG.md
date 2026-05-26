## 1.1.1

* increased service timeout to 10 minutes

## 1.1.0

* Add `TransalatorAgent` sealed type and `GeminiTranslatorAgent` for configuring LLM translators.
* **Breaking:** Remove `LLM` enum; `LLMTranslatorFactory.createTranslator` now takes a `TransalatorAgent` (e.g. `GeminiTranslatorAgent(geminiApiKey: '...')`) instead of `(LLM, String apiKey)`.
* Add configurable Gemini model via `GeminiTranslatorAgent.model` (defaults to `gemini-3.5-flash`).
* Require Dart SDK `^3.12.0`.

## 1.0.1

* Add support for web

## 1.0.0

* Initial release with Gemini API localization features.

