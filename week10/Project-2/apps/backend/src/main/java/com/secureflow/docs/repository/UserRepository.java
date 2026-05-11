package com.secureflow.docs.repository;

import com.secureflow.docs.model.UserAccount;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserRepository extends JpaRepository<UserAccount, String> {
}
