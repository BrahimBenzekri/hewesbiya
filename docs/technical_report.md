# 7ewesbiya: Technical Architecture & Data Strategy Report

**Purpose:** This document outlines the technical foundation of the 7ewesbiya platform, addressing data integrity, system architecture, and future scalability. It is designed to answer critical questions from the jury regarding *how* the AI works and *where* the information comes from.

---

## 1. Data Strategy: The "Truth" Layer
**Q: "How do you ensure the AI doesn't hallucinate or invent history?"**

We do not rely on the general knowledge of Large Language Models (which can be inaccurate). Instead, we implement a **Retrieval-Augmented Generation (RAG)** architecture.

### 1.1 Data Sourcing (The Source of Truth)
*   **Partnerships:** We collaborate directly with the **Ministry of Culture**, **Heritage Preservation Agencies**, and **Site Managers**.
*   **Digitization:** We ingest official guidebooks, historical archives, and architectural blueprints provided by these entities.
*   **Validation:** All data is "stamped" as verified before entering our system.

### 1.2 The Knowledge Graph
*   **Vector Database:** We convert this verified text into vector embeddings (mathematical representations of meaning) stored in a dedicated Vector Database (e.g., Pinecone or Milvus).
*   **Retrieval Process:** When a user asks a question, we don't just ask the AI. We first search our Vector Database for the *exact* verified facts, then feed those facts to the AI to formulate the answer.
    *   *Result:* The AI acts as a "translator" of facts, not an "inventor" of facts.

---

## 2. MVP Architecture: The "Hands-Free" Engine
**Scope:** Location-Based Audio Guide (One-way flow).

### 2.1 Frontend (Flutter)
*   **Geolocation Engine:** Uses high-precision GPS fused with accelerometer data to detect when a user enters a specific "Zone of Interest" (Geofence).
*   **State Management:** Filters noisy GPS signals to prevent false triggers.

### 2.2 Backend (Node.js / Express)
*   **Spatial Indexing:** Efficiently queries "Which monument is at Lat X, Long Y?" using PostGIS or MongoDB Geospatial queries.
*   **Audio Pipeline:**
    1.  **Trigger:** User enters "Main Gate" zone.
    2.  **Fetch:** Backend retrieves the pre-generated audio or generates it on-the-fly using **ElevenLabs** (for high-fidelity, emotional narration).
    3.  **Stream:** Audio is streamed via **WebSockets** to ensure instant playback without long buffering times.

---

## 3. Extended Version: The "Cognitive" Engine
**Scope:** Conversational AI & Computer Vision.

### 3.1 Conversational AI (Voice Mode)
*   **STT (Speech-to-Text):** We use **OpenAI Whisper** (optimized for multiple accents/languages) to transcribe user questions in real-time.
*   **Context Window:** The backend maintains a "Session History". If the user says "Who built *it*?", the AI knows "*it*" refers to the fountain discussed 10 seconds ago.
*   **Latency Optimization:** We use full-duplex WebSockets to stream the AI's response *while it is still being generated*, reducing perceived wait time to under 1 second.

### 3.2 Computer Vision (The "Lens")
*   **Image Analysis:** When the user snaps a photo, it is sent to a Multimodal Model (e.g., **GPT-4o Vision** or **Gemini Pro Vision**).
*   **Object Detection:** The model identifies architectural elements (e.g., "Zellij tilework", "Kufic script").
*   **Contextual Mapping:** The system cross-references the visual identification with the user's GPS location to narrow down possibilities (e.g., "This is likely the inscription on the *North* wall").

### 3.3 Smart Recommendations
*   **User Profiling:** We analyze user behavior (dwell time, questions asked).
    *   *Example:* A user who asks 5 questions about food history is tagged as a "Gastronomy Enthusiast".
*   **Graph Database:** We map relationships between monuments and nearby amenities.
    *   *Query:* "Find highly-rated restaurants within 500m that serve traditional dishes."

---

## 4. Infrastructure & Scalability
*   **Cloud Provider:** AWS or Google Cloud Platform.
*   **CDN (Content Delivery Network):** Caches audio files at edge locations to ensure fast loading for tourists even with poor 4G connections.
*   **Offline Mode (Future):** We plan to allow "Tour Downloads" where the essential audio and vector data are stored locally on the device, allowing the app to work without any internet connection.
