package com.library.catalog.infrastructure.persistence.entity;

import com.library.shared.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.HashSet;
import java.util.Set;

@Entity
@Table(name = "publications", indexes = {
    @Index(name = "idx_publication_isbn", columnList = "isbn", unique = true),
    @Index(name = "idx_publication_title", columnList = "title"),
    @Index(name = "idx_publication_publisher", columnList = "publisher_id")
})
@Getter
@Setter
@NoArgsConstructor
public class PublicationEntity extends BaseEntity {

    @Column(length = 13, unique = true)
    private String isbn;

    @Column(nullable = false, length = 255)
    private String title;

    @Column(length = 255)
    private String subtitle;

    private Long publisherId;

    private Integer publicationYear;

    @Column(length = 100)
    private String edition;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(nullable = false, length = 50)
    private String language;

    private Integer numberOfPages;

    @Column(columnDefinition = "TEXT")
    private String aiSummary;

    @Column(columnDefinition = "TEXT")
    private String fileUrl;

    @Column(columnDefinition = "TEXT")
    private String aiTargetAudience;

    @Column(columnDefinition = "TEXT")
    private String coverImageUrl;

    @Column(length = 50)
    private String size; // e.g., "20x15x3 cm"

    @Column
    private Double weight; // in grams

    // Relationships - managed via junction tables
    @OneToMany(mappedBy = "publicationId", cascade = CascadeType.ALL, orphanRemoval = true)
    private Set<PublicationAuthorEntity> publicationAuthors = new HashSet<>();

    @OneToMany(mappedBy = "publicationId", cascade = CascadeType.ALL, orphanRemoval = true)
    private Set<PublicationCategoryEntity> publicationCategories = new HashSet<>();

    @OneToMany(mappedBy = "publicationId", cascade = CascadeType.ALL, orphanRemoval = true)
    private Set<PublicationTagEntity> publicationTags = new HashSet<>();

    // Helper methods for bidirectional relationships
    public void addAuthor(Long authorId) {
        publicationAuthors.add(new PublicationAuthorEntity(getId(), authorId));
    }

    public void removeAuthor(Long authorId) {
        publicationAuthors.removeIf(pa -> pa.getAuthorId().equals(authorId));
    }

    public void addCategory(Long categoryId) {
        publicationCategories.add(new PublicationCategoryEntity(getId(), categoryId));
    }

    public void removeCategory(Long categoryId) {
        publicationCategories.removeIf(pc -> pc.getCategoryId().equals(categoryId));
    }

    public void addTag(Long tagId) {
        publicationTags.add(new PublicationTagEntity(getId(), tagId));
    }

    public void removeTag(Long tagId) {
        publicationTags.removeIf(pt -> pt.getTagId().equals(tagId));
    }

    public void clearAuthors() {
        publicationAuthors.clear();
    }

    public void clearCategories() {
        publicationCategories.clear();
    }

    public void clearTags() {
        publicationTags.clear();
    }
}
