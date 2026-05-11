package com.secureflow.docs.repository;

import com.secureflow.docs.model.DocumentRecord;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface DocumentRepository extends JpaRepository<DocumentRecord, Long> {
  List<DocumentRecord> findByOwnerUsernameOrSignerEmailOrderByCreatedAtDesc(String ownerUsername, String signerEmail);
}
