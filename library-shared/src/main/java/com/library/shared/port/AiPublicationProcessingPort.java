package com.library.shared.port;

public interface AiPublicationProcessingPort {

    void processPublication(Long publicationId, String pdfUrl, boolean forceReprocess);
}
