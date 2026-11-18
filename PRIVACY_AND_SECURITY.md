# ClearAir AI — Privacy & Security Architecture

## Zero PII Collection Policy

ClearAir AI is designed from the ground up to respect user privacy:

1. **No User Accounts or Logins**: The application functions completely anonymously without requiring email addresses, phone numbers, or passwords.
2. **No Medical Records or Names**: The Family Safety Planner asks only for counts of adults, children, and seniors, general sensitivity categories, and general budget preferences. It never requests personal names, medical histories, or exact dates of birth.
3. **No Unnecessary Geolocation Harvesting**: Geolocation permission is entirely optional. Users can select cities manually through the open geocoding search or pick from predefined demo locations.

---

## Client-Side Security & Secret Management

- **Zero Hardcoded API Secrets**: The client source code contains no API keys or secret tokens.
- **Client-Side Key Isolation**: If a user chooses to connect their own Gemini API key in Settings, the key is stored solely in the browser's local `SharedPreferences` (HTML5 LocalStorage) and is never transmitted to any third-party telemetry server or intermediary proxy.
- **Untrusted AI Output Sanitization**: AI responses are treated strictly as untrusted text strings. ClearAir AI never renders arbitrary HTML, executes Javascript, or parses dangerous markdown tags returned by LLMs.
- **Safe Network Degradation**: If network requests to Open-Meteo or the Gemini endpoint fail or timeout, the application degrades gracefully to cached measurements or deterministic local recommendations without crashing or exposing raw stack traces.

---

## Local Data Reset & Erase Controls

In the **Settings** section, users can trigger a full local data reset:
- Clears all saved household compositions and vulnerability tags.
- Erases all custom saved locations.
- Clears conversation history and cached atmospheric data.
- Resets theme and standard settings back to clean initial states.
