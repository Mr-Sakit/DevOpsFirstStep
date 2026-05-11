package com.secureflow.docs.service;

import com.secureflow.docs.model.UserAccount;
import com.secureflow.docs.repository.UserRepository;
import jakarta.servlet.http.HttpSession;
import java.security.SecureRandom;
import java.util.Base64;
import java.util.Map;
import org.springframework.boot.CommandLineRunner;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthService {

  public static final String SESSION_USER = "secureflowUser";
  public static final String SESSION_CSRF = "secureflowCsrf";
  private static final String DEFAULT_USER_EMAIL = "automission@company.com";

  private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();
  private final SecureRandom secureRandom = new SecureRandom();
  private final UserRepository userRepository;
  private final String defaultUserPassword;

  public AuthService(UserRepository userRepository, @Value("${secureflow.default-user.password:}") String defaultUserPassword) {
    this.userRepository = userRepository;
    this.defaultUserPassword = defaultUserPassword;
  }

  @Bean
  CommandLineRunner defaultUser(UserRepository users) {
    return args -> {
      UserAccount user = users.findById(DEFAULT_USER_EMAIL).orElseGet(UserAccount::new);
      boolean isNewUser = user.getEmail() == null || user.getEmail().isBlank();
      if (isNewUser) {
        user.setEmail(DEFAULT_USER_EMAIL);
      }
      if (isNewUser || (defaultUserPassword != null && !defaultUserPassword.isBlank())) {
        user.setPasswordHash(passwordEncoder.encode(initialPassword()));
      }
      users.save(user);
    };
  }

  public Map<String, String> login(String email, String password, HttpSession session) {
    String safeEmail = normalizeEmail(email);
    UserAccount user = userRepository.findById(safeEmail)
        .orElseThrow(() -> new IllegalArgumentException("Invalid corporate email or password."));
    if (!passwordEncoder.matches(password, user.getPasswordHash())) {
      throw new IllegalArgumentException("Invalid corporate email or password.");
    }
    session.setAttribute(SESSION_USER, user.getEmail());
    String csrfToken = createCsrfToken();
    session.setAttribute(SESSION_CSRF, csrfToken);
    return Map.of("email", user.getEmail(), "csrfToken", csrfToken);
  }

  public String requireUser(HttpSession session) {
    Object username = session.getAttribute(SESSION_USER);
    if (username instanceof String value && !value.isBlank()) {
      return value;
    }
    throw new SecurityException("Login required.");
  }

  public Map<String, String> currentUser(HttpSession session) {
    String username = requireUser(session);
    Object csrf = session.getAttribute(SESSION_CSRF);
    String csrfToken = csrf instanceof String value ? value : "";
    if (csrfToken.isBlank()) {
      csrfToken = createCsrfToken();
      session.setAttribute(SESSION_CSRF, csrfToken);
    }
    return Map.of("email", username, "csrfToken", csrfToken);
  }

  public static String normalizeEmail(String value) {
    String safeEmail = TextSanitizer.clean(value, 120).toLowerCase();
    if (!safeEmail.matches("^[a-z0-9._%+-]+@company\\.com$")) {
      throw new IllegalArgumentException("Use your corporate @company.com email address.");
    }
    return safeEmail;
  }

  private String createCsrfToken() {
    byte[] token = new byte[32];
    secureRandom.nextBytes(token);
    return Base64.getUrlEncoder().withoutPadding().encodeToString(token);
  }

  private String initialPassword() {
    if (defaultUserPassword != null && !defaultUserPassword.isBlank()) {
      return defaultUserPassword;
    }
    byte[] password = new byte[24];
    secureRandom.nextBytes(password);
    return Base64.getUrlEncoder().withoutPadding().encodeToString(password);
  }
}
