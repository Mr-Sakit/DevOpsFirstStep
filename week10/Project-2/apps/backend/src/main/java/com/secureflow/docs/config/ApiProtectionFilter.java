package com.secureflow.docs.config;

import com.secureflow.docs.service.AuthService;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Set;
import org.springframework.stereotype.Component;

@Component
public class ApiProtectionFilter implements Filter {

  private static final Set<String> SAFE_METHODS = Set.of("GET", "HEAD", "OPTIONS");

  @Override
  public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
      throws IOException, ServletException {
    HttpServletRequest httpRequest = (HttpServletRequest) request;
    HttpServletResponse httpResponse = (HttpServletResponse) response;
    String path = httpRequest.getRequestURI();

    if (path.startsWith("/api/admin") || path.equals("/api/auth/signup")) {
      httpResponse.sendError(HttpServletResponse.SC_NOT_FOUND);
      return;
    }

    boolean isPublicAuthWrite = path.equals("/api/auth/login");
    if (path.startsWith("/api/") && !isPublicAuthWrite && !SAFE_METHODS.contains(httpRequest.getMethod())) {
      HttpSession session = httpRequest.getSession(false);
      String sentToken = httpRequest.getHeader("X-CSRF-Token");
      Object savedToken = session == null ? null : session.getAttribute(AuthService.SESSION_CSRF);
      if (!(savedToken instanceof String csrfToken) || sentToken == null || !csrfToken.equals(sentToken)) {
        httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN, "CSRF token missing or invalid.");
        return;
      }
    }

    chain.doFilter(request, response);
  }
}
