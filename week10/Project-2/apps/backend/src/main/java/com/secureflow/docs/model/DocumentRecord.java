package com.secureflow.docs.model;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.time.Instant;

@Entity
public class DocumentRecord {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @NotBlank
  @Size(max = 160)
  private String title;

  @NotBlank
  @Size(max = 60)
  private String category;

  @NotBlank
  @Size(max = 60)
  private String status;

  @NotBlank
  @Size(max = 100)
  private String owner;

  @NotBlank
  @Size(max = 120)
  private String ownerUsername;

  @NotBlank
  @Size(max = 120)
  private String signerEmail;

  @NotBlank
  @Size(max = 60)
  private String signatureStatus;

  @Size(max = 120)
  private String signatureDeadline;

  @Size(max = 255)
  private String originalFileName;

  @Size(max = 120)
  private String contentType;

  private Long fileSize;

  @Size(max = 500)
  private String extractedSummary;
  private Instant createdAt = Instant.now();

  public Long getId() {
    return id;
  }

  public void setId(Long id) {
    this.id = id;
  }

  public String getTitle() {
    return title;
  }

  public void setTitle(String title) {
    this.title = title;
  }

  public String getCategory() {
    return category;
  }

  public void setCategory(String category) {
    this.category = category;
  }

  public String getStatus() {
    return status;
  }

  public void setStatus(String status) {
    this.status = status;
  }

  public String getOwner() {
    return owner;
  }

  public void setOwner(String owner) {
    this.owner = owner;
  }

  public String getOwnerUsername() {
    return ownerUsername;
  }

  public void setOwnerUsername(String ownerUsername) {
    this.ownerUsername = ownerUsername;
  }

  public String getSignerEmail() {
    return signerEmail;
  }

  public void setSignerEmail(String signerEmail) {
    this.signerEmail = signerEmail;
  }

  public String getSignatureStatus() {
    return signatureStatus;
  }

  public void setSignatureStatus(String signatureStatus) {
    this.signatureStatus = signatureStatus;
  }

  public String getSignatureDeadline() {
    return signatureDeadline;
  }

  public void setSignatureDeadline(String signatureDeadline) {
    this.signatureDeadline = signatureDeadline;
  }

  public String getOriginalFileName() {
    return originalFileName;
  }

  public void setOriginalFileName(String originalFileName) {
    this.originalFileName = originalFileName;
  }

  public String getContentType() {
    return contentType;
  }

  public void setContentType(String contentType) {
    this.contentType = contentType;
  }

  public Long getFileSize() {
    return fileSize;
  }

  public void setFileSize(Long fileSize) {
    this.fileSize = fileSize;
  }

  public String getExtractedSummary() {
    return extractedSummary;
  }

  public void setExtractedSummary(String extractedSummary) {
    this.extractedSummary = extractedSummary;
  }

  public Instant getCreatedAt() {
    return createdAt;
  }

  public void setCreatedAt(Instant createdAt) {
    this.createdAt = createdAt;
  }
}
