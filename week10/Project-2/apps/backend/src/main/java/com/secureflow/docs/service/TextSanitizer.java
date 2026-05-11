package com.secureflow.docs.service;

import java.text.Normalizer;

public final class TextSanitizer {

  private TextSanitizer() {
  }

  public static String clean(String value, int maxLength) {
    if (value == null) {
      return "";
    }
    String normalized = Normalizer.normalize(value, Normalizer.Form.NFKC)
        .replaceAll("[\\p{Cntrl}&&[^\r\n\t]]", "")
        .replace("<", "")
        .replace(">", "")
        .trim();
    if (normalized.length() > maxLength) {
      return normalized.substring(0, maxLength);
    }
    return normalized;
  }

  public static String cleanFileName(String value) {
    String cleaned = clean(value, 180).replaceAll("[^a-zA-Z0-9._ -]", "_");
    if (cleaned.isBlank() || cleaned.equals(".") || cleaned.equals("..")) {
      return "uploaded-document";
    }
    return cleaned;
  }
}
