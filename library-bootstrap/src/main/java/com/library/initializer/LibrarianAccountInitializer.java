package com.library.initializer;

import com.library.user.domain.entities.Role;
import com.library.user.domain.entities.User;
import com.library.user.domain.port.IPasswordHasher;
import com.library.user.domain.repository.RoleRepository;
import com.library.user.domain.repository.UserRepository;
import com.library.user.domain.valueobject.Email;
import com.library.user.domain.valueobject.PasswordHash;
import com.library.user.domain.valueobject.UserProfile;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import java.time.LocalDate;

@Slf4j
@Component
@Order(4) // Run after RoleDataInitializer (which has default order = 1)
@RequiredArgsConstructor
public class LibrarianAccountInitializer implements CommandLineRunner {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final IPasswordHasher passwordHasher;

    // Default admin credentials
    private static final String ADMIN_EMAIL = "librarian@hcmut.edu.vn";
    private static final String ADMIN_PASSWORD = "librarian";
    private static final String ADMIN_FULL_NAME = "System Administrator";

    @Override
    public void run(String... args) {
        log.info("Starting admin account initialization...");

        initializeAdminAccount();

        log.info("Admin account initialization completed.");
    }

    /**
     * Initialize the default admin account if it doesn't exist.
     */
    private void initializeAdminAccount() {
        Email adminEmail = Email.of(ADMIN_EMAIL);

        // Check if admin account already exists
        if (userRepository.existsByEmail(adminEmail)) {
            log.debug("Admin account '{}' already exists, skipping initialization.", ADMIN_EMAIL);
            return;
        }

        // Get ADMIN role
        Role adminRole = roleRepository.findByName("LIBRARIAN")
            .orElseThrow(() -> new IllegalStateException(
                "ADMIN role not found. Ensure RoleDataInitializer runs before AdminAccountInitializer."
            ));

        // Create admin user profile
        UserProfile adminProfile = UserProfile.create(
            ADMIN_FULL_NAME,
            LocalDate.of(1990, 1, 1), // Default date of birth
            "0000000000",              // Default phone
            "System"                   // Default address
        );

        // Hash the password
        PasswordHash passwordHash = PasswordHash.createFromRaw(ADMIN_PASSWORD, passwordHasher);

        // Create admin user
        User adminUser = User.create(adminEmail, passwordHash, adminProfile, adminRole);

        // Activate the admin account
        adminUser.activate();

        // Save to database
        userRepository.save(adminUser);
    }
}
