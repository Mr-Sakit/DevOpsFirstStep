package com.secureflow.docs.controller;

import com.secureflow.docs.service.AuthService;
import jakarta.servlet.http.HttpSession;
import jakarta.validation.constraints.NotBlank;
import java.util.Map;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Validated
@RestController
@RequestMapping("/api/auth")
public class AuthController {

  private final AuthService authService;

  public AuthController(AuthService authService) {
    this.authService = authService;
  }

  @PostMapping("/login")
  public Map<String, String> login(@RequestBody AuthRequest request, HttpSession session) {
    return authService.login(request.email(), request.password(), session);
  }

  @GetMapping("/me")
  public Map<String, String> me(HttpSession session) {
    return authService.currentUser(session);
  }

  @PostMapping("/logout")
  public Map<String, String> logout(HttpSession session) {
    session.invalidate();
    return Map.of("status", "logged-out");
  }

  public record AuthRequest(@NotBlank String email, @NotBlank String password) {
  }
}
