package com.secureflow.docs.service;

import com.secureflow.docs.model.DocumentRecord;
import com.secureflow.docs.repository.DocumentRepository;
import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Service
public class DocumentService {

  private static final long MAX_UPLOAD_BYTES = 10L * 1024 * 1024;

  private final DocumentRepository repository;

  public DocumentService(DocumentRepository repository) {
    this.repository = repository;
  }

  public List<DocumentRecord> findForUser(String email) {
    return repository.findByOwnerUsernameOrSignerEmailOrderByCreatedAtDesc(email, email);
  }

  public DocumentRecord upload(String email, MultipartFile file, String category, String signerEmail, String deadline) {
    if (file == null || file.isEmpty()) {
      throw new IllegalArgumentException("Choose a document before uploading.");
    }
    if (file.getSize() > MAX_UPLOAD_BYTES) {
      throw new IllegalArgumentException("Document must be 10 MB or smaller.");
    }

    String safeFileName = TextSanitizer.cleanFileName(file.getOriginalFilename());
    String safeCategory = TextSanitizer.clean(category, 60);
    String safeSignerEmail = AuthService.normalizeEmail(signerEmail);
    String safeDeadline = TextSanitizer.clean(deadline, 120);

    DocumentRecord document = new DocumentRecord();
    document.setTitle(safeFileName);
    document.setCategory(safeCategory.isBlank() ? "Document" : safeCategory);
    document.setStatus("Signature requested");
    document.setOwner(email);
    document.setOwnerUsername(email);
    document.setSignerEmail(safeSignerEmail);
    document.setSignatureStatus(safeSignerEmail.equals(email) ? "Ready for my signature" : "Awaiting counterparty signature");
    document.setSignatureDeadline(safeDeadline);
    document.setOriginalFileName(safeFileName);
    document.setContentType(TextSanitizer.clean(file.getContentType(), 120));
    document.setFileSize(file.getSize());
    document.setExtractedSummary("Envelope prepared for governed review with ownership, signer, and audit metadata.");
    return repository.save(document);
  }
}
