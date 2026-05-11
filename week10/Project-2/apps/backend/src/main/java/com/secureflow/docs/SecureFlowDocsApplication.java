package com.secureflow.docs;

import com.microsoft.applicationinsights.attach.ApplicationInsights;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class SecureFlowDocsApplication {

  public static void main(String[] args) {
    if (System.getenv("APPLICATIONINSIGHTS_CONNECTION_STRING") != null
        && !System.getenv("APPLICATIONINSIGHTS_CONNECTION_STRING").isBlank()) {
      ApplicationInsights.attach();
    }
    SpringApplication.run(SecureFlowDocsApplication.class, args);
  }
}
