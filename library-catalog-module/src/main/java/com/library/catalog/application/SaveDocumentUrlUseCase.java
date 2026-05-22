package com.library.catalog.application;

public interface SaveDocumentUrlUseCase {
    String execute(Long publicationId, String s3Key);
    void reprocessExistingDocument(Long publicationId);
    void reprocessExistingDocumentVectors(Long publicationId);
    void generateExistingDocumentMetadata(Long publicationId);
}
