package com.secureflow.docs.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.secureflow.docs.model.DocumentRecord;
import com.secureflow.docs.repository.DocumentRepository;
import java.util.Collection;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

class DemoDataInitializerTests {

  private static final String DEMO_EMAIL = "automission@company.com";
  private static final String LEGACY_EMAIL = "duyghu@company.com";

  // ADD THESE
  private static final String SIGNATURE_REQUESTED = "Signature requested";
  private static final String READY_FOR_MY_SIGNATURE = "Ready for my signature";

  private final DocumentRepository repository = mock(DocumentRepository.class);
  private final DemoDataInitializer initializer = new DemoDataInitializer(repository);

  @Test
  void runMigratesLegacyDemoOwnershipFields() {
    DocumentRecord legacyDocument = documentOwnedBy(LEGACY_EMAIL);
    when(repository.findAll()).thenReturn(List.of(legacyDocument));
    when(repository.findByOwnerUsernameOrSignerEmailOrderByCreatedAtDesc(DEMO_EMAIL, DEMO_EMAIL))
        .thenReturn(List.of(legacyDocument));

    initializer.run();

    ArgumentCaptor<Iterable<DocumentRecord>> savedRecords = documentRecordIterableCaptor();
    verify(repository).saveAll(savedRecords.capture());

    List<DocumentRecord> changedRecords = iterableToList(savedRecords.getValue());
    assertThat(changedRecords).containsExactly(legacyDocument);
    assertThat(legacyDocument.getOwner()).isEqualTo(DEMO_EMAIL);
    assertThat(legacyDocument.getOwnerUsername()).isEqualTo(DEMO_EMAIL);
    assertThat(legacyDocument.getSignerEmail()).isEqualTo(DEMO_EMAIL);
  }

  @Test
  void runSeedsEnterpriseSignatureRecordsWhenDemoMailboxIsEmpty() {
    when(repository.findAll()).thenReturn(List.of());
    when(repository.findByOwnerUsernameOrSignerEmailOrderByCreatedAtDesc(DEMO_EMAIL, DEMO_EMAIL))
        .thenReturn(List.of());

    initializer.run();

    ArgumentCaptor<Iterable<DocumentRecord>> savedRecords = documentRecordIterableCaptor();
    verify(repository).saveAll(savedRecords.capture());

    List<DocumentRecord> seededRecords = iterableToList(savedRecords.getValue());
    assertThat(seededRecords).hasSize(3);
    assertThat(seededRecords)
        .extracting(DocumentRecord::getTitle)
        .containsExactly(
            "Vendor Data Processing Addendum",
            "Regional Procurement Approval",
            "Employee Policy Attestation");

    assertThat(seededRecords).allSatisfy(document -> {
      assertThat(document.getContentType()).isEqualTo("application/pdf");
      assertThat(document.getCreatedAt()).isNotNull();
      assertThat(List.of(document.getOwnerUsername(), document.getSignerEmail()))
          .contains(DEMO_EMAIL);
    });

    verify(repository).save(org.mockito.ArgumentMatchers.argThat(document ->
        "Board Resolution Signature Packet".equals(document.getTitle())
            && DEMO_EMAIL.equals(document.getSignerEmail())
            && READY_FOR_MY_SIGNATURE.equals(document.getSignatureStatus())));

    verify(repository).save(org.mockito.ArgumentMatchers.argThat(document ->
        "Vendor Risk Exception Approval".equals(document.getTitle())
            && DEMO_EMAIL.equals(document.getSignerEmail())
            && READY_FOR_MY_SIGNATURE.equals(document.getSignatureStatus())));
  }

  @Test
  void runAddsMissingSignatureInboxRecordsToExistingDemoMailbox() {
    DocumentRecord existingDocument = documentOwnedBy(DEMO_EMAIL);
    when(repository.findAll()).thenReturn(List.of(existingDocument));
    when(repository.findByOwnerUsernameOrSignerEmailOrderByCreatedAtDesc(DEMO_EMAIL, DEMO_EMAIL))
        .thenReturn(List.of(existingDocument));

    initializer.run();

    verify(repository).save(org.mockito.ArgumentMatchers.argThat(document ->
        "Board Resolution Signature Packet".equals(document.getTitle())
            && "corporate.secretary@company.com".equals(document.getOwnerUsername())
            && DEMO_EMAIL.equals(document.getSignerEmail())));

    verify(repository).save(org.mockito.ArgumentMatchers.argThat(document ->
        "Vendor Risk Exception Approval".equals(document.getTitle())
            && "vendor.risk@company.com".equals(document.getOwnerUsername())
            && DEMO_EMAIL.equals(document.getSignerEmail())));

    verify(repository, times(2)).findAll();
    verify(repository, times(2))
        .findByOwnerUsernameOrSignerEmailOrderByCreatedAtDesc(anyString(), anyString());
  }

  @Test
  void runDoesNotDuplicateSignatureInboxRecordsWhenTheyAlreadyExist() {
    DocumentRecord boardResolution = documentOwnedBy(DEMO_EMAIL);
    boardResolution.setTitle("Board Resolution Signature Packet");

    DocumentRecord vendorRisk = documentOwnedBy(DEMO_EMAIL);
    vendorRisk.setTitle("Vendor Risk Exception Approval");

    when(repository.findAll()).thenReturn(List.of(boardResolution, vendorRisk));
    when(repository.findByOwnerUsernameOrSignerEmailOrderByCreatedAtDesc(DEMO_EMAIL, DEMO_EMAIL))
        .thenReturn(List.of(boardResolution, vendorRisk));

    initializer.run();

    verify(repository, times(2)).findAll();
    verify(repository, times(2))
        .findByOwnerUsernameOrSignerEmailOrderByCreatedAtDesc(anyString(), anyString());

    verify(repository, never()).save(any(DocumentRecord.class));
    verify(repository, never())
        .saveAll(org.mockito.ArgumentMatchers.<Iterable<DocumentRecord>>any());
  }

  @Test
  void runDeletesRetiredSentRecordsForDemoMailbox() {
    DocumentRecord activeInboxRecord = documentOwnedBy(DEMO_EMAIL);
    activeInboxRecord.setTitle("Board Resolution Signature Packet");
    activeInboxRecord.setOwnerUsername("corporate.secretary@company.com");
    activeInboxRecord.setSignerEmail(DEMO_EMAIL);

    DocumentRecord retiredSentRecord = sentDocument("Backend.txt");
    DocumentRecord retainedSentRecord = sentDocument("automission.docx");

    when(repository.findAll()).thenReturn(
        List.of(activeInboxRecord, retiredSentRecord, retainedSentRecord));

    when(repository.findByOwnerUsernameOrSignerEmailOrderByCreatedAtDesc(
        DEMO_EMAIL, DEMO_EMAIL))
        .thenReturn(List.of(activeInboxRecord, retiredSentRecord, retainedSentRecord));

    initializer.run();

    ArgumentCaptor<Iterable<DocumentRecord>> deletedRecords =
        documentRecordIterableCaptor();

    verify(repository).deleteAll(deletedRecords.capture());

    assertThat(iterableToList(deletedRecords.getValue()))
        .containsExactly(retiredSentRecord);
  }

  private static DocumentRecord documentOwnedBy(String email) {
    DocumentRecord document = new DocumentRecord();
    document.setTitle("Board Approval");
    document.setCategory("Contract");

    // FIXED
    document.setStatus(SIGNATURE_REQUESTED);

    document.setOwner(email);
    document.setOwnerUsername(email);
    document.setSignerEmail(email);
    document.setSignatureStatus("Ready for signature");
    return document;
  }

  private static DocumentRecord sentDocument(String title) {
    DocumentRecord document = documentOwnedBy(DEMO_EMAIL);
    document.setTitle(title);
    document.setSignerEmail("legal.approver@company.com");
    document.setSignatureStatus("Awaiting counterparty signature");
    return document;
  }

  @SuppressWarnings("unchecked")
  private static ArgumentCaptor<Iterable<DocumentRecord>>
      documentRecordIterableCaptor() {
    return ArgumentCaptor.forClass(Iterable.class);
  }

  private static List<DocumentRecord> iterableToList(
      Iterable<DocumentRecord> records) {

    if (records instanceof Collection<DocumentRecord> collection) {
      return List.copyOf(collection);
    }

    return org.assertj.core.util.Lists.newArrayList(records);
  }
}
