# Arsitektur & Integrasi Flow

Berikut adalah visualisasi alur data dan komunikasi antar layer dalam aplikasi Suara Kampus menggunakan Clean Architecture dan integrasinya dengan Firebase/Supabase.

## 1. Clean Architecture Layer Flow
Diagram ini menunjukkan bagaimana UI berkomunikasi dengan Logic tanpa tahu detail teknis (Database).

```mermaid
graph TD
    subgraph Presentation["Presentation Layer UI-State"]
        UI["Page / Screen"]
        Provider["Provider / State Management"]
    end

    subgraph Domain["Domain Layer Business-Logic"]
        Entity["Entity (Pure Dart Object)"]
        RepoInterface["Repository Interface (Contract)"]
    end

    subgraph Data["Data Layer Implement"]
        RepoImpl["Repository Implementation"]
        Model["Model (JSON / DTO)"]
        Service["Remote Service (Firebase / Supabase)"]
        Cloud["Firebase / Supabase"]
    end

    %% Flow Interactions
    UI -->|1. User Action| Provider
    Provider -->|2. Call Method| RepoInterface

    %% Implementation relation
    RepoImpl -.->|implements| RepoInterface

    %% Data fetching
    RepoImpl -->|3. Request Data| Service
    Service -->|4. Fetch / Send| Cloud

    %% Returning Data
    Service -->|5. Return JSON / Raw| Model
    Model -->|6. Convert to Entity| RepoImpl
    RepoImpl -->|7. Return Entity| Provider
    Provider -->|8. Update State| UI

```

## 2. Detail Integrasi Firebase Code Flow
Contoh spesifik untuk fitur **Login & Register**.

```mermaid
sequenceDiagram
    participant User
    participant UI as Login Page
    participant Prov as Auth Provider
    participant Repo as Auth Repository
    participant Serv as Auth Service
    participant FB as Firebase Auth
    participant FS as Firestore

    %% Login Flow
    User->>UI: Input Email & Password, Click Login
    UI->>Prov: login(email, pass)
    Prov->>Prov: setLoading(true)
    Prov->>Repo: login(email, pass)
    Repo->>Serv: login(email, pass)
    
    alt Success
        Serv->>FB: signInWithEmailAndPassword()
        FB-->>Serv: UserCredential (UID, Token)
        Serv-->>Repo: UserCredential
        Repo->>Repo: Convert to UserEntity
        Repo-->>Prov: UserEntity
        Prov-->>UI: Success
        UI->>User: Navigate to Dashboard
    else Failure
        FB-->>Serv: Error (Wrong Password)
        Serv-->>Repo: Throw Exception
        Repo-->>Prov: Catch Error
        Prov->>Prov: errorMessage = "Wrong Pass"
        Prov-->>UI: Error State
        UI->>User: Show Snackbar Error
    end

    %% Register Flow with Firestore Sync
    Note over User, FS: Register Flow (Auth + DB)
    
    User->>UI: Input User Data, Click Register
    UI->>Prov: register(email, pass, name)
    Prov->>Repo: register(email, pass, name)
    Repo->>Serv: register(email, pass, name)
    
    Serv->>FB: createUserWithEmailAndPassword()
    FB-->>Serv: New User UID
    
    Note right of Serv: Simpan data tambahan ke Firestore
    Serv->>FS: collection('users').doc(uid).set({name, email...})
    FS-->>Serv: Success
    
    Serv-->>Repo: UserCredential
    Repo-->>Prov: UserEntity
    Prov-->>UI: Success
```

## 3. Struktur Folder vs Architecture

```mermaid
classDiagram
    class Presentation {
        +Pages (UI)
        +Widgets (Components)
        +Providers (State)
    }
    class Domain {
        +Entities (Pure Objects)
        +Repositories (Interfaces)
    }
    class Data {
        +Models (JSON Parsers)
        +Services (API Calls)
        +Repositories (Implementations)
    }

    Presentation --> Domain : Uses
    Data ..|> Domain : Implements
    Presentation --> Data : Injected via Dependency Injection
```
