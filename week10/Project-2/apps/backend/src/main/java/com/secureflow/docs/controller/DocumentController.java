package com.secureflow.docs.controller;

import com.secureflow.docs.model.DocumentRecord;
import com.secureflow.docs.service.AuthService;
import com.secureflow.docs.service.DocumentService;
import jakarta.servlet.http.HttpSession;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/documents")
public class DocumentController {

  private final DocumentService documentService;
  private final AuthService authService;

  public DocumentController(DocumentService documentService, AuthService authService) {
    this.documentService = documentService;
    this.authService = authService;
  }

  @GetMapping
  public List<DocumentRecord> listDocuments(HttpSession session) {
    String username = authService.requireUser(session);
    return documentService.findForUser(username);
  }

  @PostMapping
  @ResponseStatus(HttpStatus.CREATED)
  public DocumentRecord uploadDocument(
      @RequestParam("file") MultipartFile file,
      @RequestParam(value = "category", defaultValue = "Document") String category,
      @RequestParam("signerEmail") String signerEmail,
      @RequestParam(value = "deadline", defaultValue = "Standard SLA") String deadline,
      HttpSession session
  ) {
    String username = authService.requireUser(session);
    return documentService.upload(username, file, category, signerEmail, deadline);
  }
}
