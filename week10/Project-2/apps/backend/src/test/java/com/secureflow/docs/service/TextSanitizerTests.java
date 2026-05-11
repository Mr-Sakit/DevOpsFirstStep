package com.secureflow.docs.service;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

class TextSanitizerTests {

  @Test
  void cleanNormalizesRemovesUnsafeMarkupAndTruncates() {
    String cleaned = TextSanitizer.clean("  <Ｆinance\u0000 approval>\nready  ", 18);

    assertThat(cleaned).isEqualTo("Finance approval\nr");
  }

  @Test
  void cleanReturnsEmptyStringForNullInput() {
    assertThat(TextSanitizer.clean(null, 20)).isEmpty();
  }

  @Test
  void cleanFileNameKeepsSafeCharactersAndReplacesUnsafeCharacters() {
    assertThat(TextSanitizer.cleanFileName("vendor:dpa?.pdf")).isEqualTo("vendor_dpa_.pdf");
  }

  @Test
  void cleanFileNameFallsBackForBlankOrDotNames() {
    assertThat(TextSanitizer.cleanFileName("   ")).isEqualTo("uploaded-document");
    assertThat(TextSanitizer.cleanFileName(".")).isEqualTo("uploaded-document");
    assertThat(TextSanitizer.cleanFileName("..")).isEqualTo("uploaded-document");
  }
}
