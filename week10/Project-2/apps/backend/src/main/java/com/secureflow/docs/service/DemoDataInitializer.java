package com.secureflow.docs.service;

import com.secureflow.docs.model.DocumentRecord;
import com.secureflow.docs.repository.DocumentRepository;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

@Component
public class DemoDataInitializer implements CommandLineRunner {

  private static final String LEGACY_DEMO_EMAIL = "duyghu@company.com";
  private static final String DEMO_EMAIL = "automission@company.com";

  private final DocumentRepository repository;

  public DemoDataInitializer(DocumentRepository repository) {
    this.repository = repository;
  }

  @Override
  public void run(String... args) {
    migrateLegacyDemoRecords();
    seedDemoRecordsWhenEmpty();
    ensureSignatureInboxDemoRecords();
    removeRetiredSentDemoRecords();
  }

  private void migrateLegacyDemoRecords() {
    List<DocumentRecord> changed = new ArrayList<>();

    for (DocumentRecord document : repository.findAll()) {
      boolean updated = false;

      if (LEGACY_DEMO_EMAIL.equalsIgnoreCase(document.getOwner())) {
        document.setOwner(DEMO_EMAIL);
        updated = true;
      }

      if (LEGACY_DEMO_EMAIL.equalsIgnoreCase(document.getOwnerUsername())) {
        document.setOwnerUsername(DEMO_EMAIL);
        updated = true;
      }

      if (LEGACY_DEMO_EMAIL.equalsIgnoreCase(document.getSignerEmail())) {
        document.setSignerEmail(DEMO_EMAIL);
        updated = true;
      }

      if (updated) {
        changed.add(document);
      }
    }

    if (!changed.isEmpty()) {
      repository.saveAll(changed);
    }
  }

  private void seedDemoRecordsWhenEmpty() {
    List<DocumentRecord> mailboxRecords = repository.findByOwnerUsernameOrSignerEmailOrderByCreatedAtDesc(DEMO_EMAIL, DEMO_EMAIL);
    if (!mailboxRecords.isEmpty()) {
      return;
    }

    repository.saveAll(defaultDemoRecords());
  }

  private void ensureSignatureInboxDemoRecords() {
    List<DocumentRecord> mailboxRecords = repository.findByOwnerUsernameOrSignerEmailOrderByCreatedAtDesc(DEMO_EMAIL, DEMO_EMAIL);
    boolean boardResolutionExists = mailboxRecords.stream()
        .anyMatch(document -> "Board Resolution Signature Packet".equalsIgnoreCase(document.getTitle()));
    boolean vendorRiskExists = mailboxRecords.stream()
        .anyMatch(document -> "Vendor Risk Exception Approval".equalsIgnoreCase(document.getTitle()));

    if (!boardResolutionExists) {
      repository.save(demoRecord(new DemoRecordData(
          "Board Resolution Signature Packet",
          "Governance",
          "Signature requested",
          "corporate.secretary@company.com",
          DEMO_EMAIL,
          "Ready for my signature",
          "Due tomorrow",
          "board-resolution-signature-packet.pdf",
          218736L,
          "Corporate secretary prepared a board resolution envelope requiring executive approval.")));
    }

    if (!vendorRiskExists) {
      repository.save(demoRecord(new DemoRecordData(
          "Vendor Risk Exception Approval",
          "Risk",
          "Signature requested",
          "vendor.risk@company.com",
          DEMO_EMAIL,
          "Ready for my signature",
          "Due in 48 hours",
          "vendor-risk-exception-approval.pdf",
          176512L,
          "Risk office routed a vendor exception memo for controlled signature approval.")));
    }
  }

  private void removeRetiredSentDemoRecords() {
    List<String> retiredSentTitles = List.of(
        "Backend.txt",
        "group1_final.png",
        "group1_final.jpg",
        "secureflow-test-contract.txt");

    List<DocumentRecord> retiredRecords = repository.findAll().stream()
        .filter(document -> DEMO_EMAIL.equalsIgnoreCase(document.getOwnerUsername()))
        .filter(document -> !DEMO_EMAIL.equalsIgnoreCase(document.getSignerEmail()))
        .filter(document -> retiredSentTitles.stream().anyMatch(title -> title.equalsIgnoreCase(document.getTitle())))
        .toList();

    if (!retiredRecords.isEmpty()) {
      repository.deleteAll(retiredRecords);
    }
  }

  private List<DocumentRecord> defaultDemoRecords() {
    return List.of(
        demoRecord(new DemoRecordData(
            "Vendor Data Processing Addendum",
            "Contract",
            "Signature requested",
            "legal.ops@company.com",
            DEMO_EMAIL,
            "Ready for my signature",
            "Due today",
            "vendor-dpa.pdf",
            482304L,
            "Legal prepared this envelope for controlled signature with evidence capture.")),
        demoRecord(new DemoRecordData(
            "Regional Procurement Approval",
            "Invoice",
            "Signature requested",
            DEMO_EMAIL,
            "finance.approver@company.com",
            "Awaiting counterparty signature",
            "Due this week",
            "procurement-approval.pdf",
            140992L,
            "Finance review packet sent with spend owner and signer metadata.")),
        demoRecord(new DemoRecordData(
            "Employee Policy Attestation",
            "Policy",
            "Completed",
            "people.ops@company.com",
            DEMO_EMAIL,
            "Signed and archived",
            "Completed",
            "policy-attestation.pdf",
            90112L,
            "Policy acknowledgement completed and retained for audit.")));
  }

  private DocumentRecord demoRecord(DemoRecordData data) {
    DocumentRecord document = new DocumentRecord();

    document.setTitle(data.title());
    document.setCategory(data.category());
    document.setStatus(data.status());
    document.setOwner(data.ownerUsername());
    document.setOwnerUsername(data.ownerUsername());
    document.setSignerEmail(data.signerEmail());
    document.setSignatureStatus(data.signatureStatus());
    document.setSignatureDeadline(data.signatureDeadline());
    document.setOriginalFileName(data.originalFileName());
    document.setContentType("application/pdf");
    document.setFileSize(data.fileSize());
    document.setExtractedSummary(data.extractedSummary());
    document.setCreatedAt(Instant.now());

    return document;
  }

  private record DemoRecordData(
      String title,
      String category,
      String status,
      String ownerUsername,
      String signerEmail,
      String signatureStatus,
      String signatureDeadline,
      String originalFileName,
      Long fileSize,
      String extractedSummary) {
  }
}
