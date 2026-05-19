# Protein3D Viewer

A Flutter mobile application for visualizing protein 3D structures and extracting physicochemical properties using the RCSB Protein Data Bank API.

## Features

- **Authentication**: JWT-based login/register with secure token storage
- **3D Visualization**: Interactive protein structure viewer powered by NGL.js via WebView
- **RCSB PDB Integration**: Search and fetch real protein data from the Protein Data Bank
- **Physicochemical Analysis**: Molecular weight, pI, GRAVY, aliphatic index, amino acid composition
- **Interactive Charts**: Bar charts and radar charts via fl_chart
- **Local Persistence**: Hive-based favorites and search history (offline access)
- **Offline Handling**: Graceful connectivity detection with user-friendly errors
- **Clean Architecture**: Domain/Data/Presentation layers with Riverpod state management

## Architecture

```
lib/
├── core/
│   ├── constants/     # API endpoints, app constants
│   ├── errors/        # Exceptions and Failure types
│   ├── network/       # Dio client, network info, router
│   ├── theme/         # Material 3 theme, color palette
│   └── utils/         # Form validators
└── features/
    ├── auth/          # Login, Register, JWT persistence
    └── protein/       # Search, Detail, Favorites, 3D viewer
```

## Tech Stack

| Concern | Library |
|---|---|
| State Management | flutter_riverpod ^2.5.1 |
| Navigation | go_router ^13.2.0 |
| HTTP Client | dio ^5.4.3+1 |
| Local DB | hive ^2.2.3 |
| Secure Storage | flutter_secure_storage ^9.0.0 |
| 3D Visualization | webview_flutter + NGL.js |
| Charts | fl_chart ^0.68.0 |
| Animations | flutter_animate ^4.5.0 |

## Getting Started

```bash
flutter pub get
flutter run
```

**Demo credentials**: `eve.holt@reqres.in` / `cityslicka`  
(Tap "Use demo credentials" on the login screen)

## API Integration

- **RCSB PDB REST API**: `https://data.rcsb.org/rest/v1/core/entry/{pdbId}`
- **RCSB Search API**: `https://search.rcsb.org/rcsbsearch/v2/query`
- **Mock Auth API**: `https://reqres.in/api` (for demo purposes)

## Featured Proteins

| PDB ID | Name | Relevance |
|--------|------|-----------|
| 1TUP | p53 Tumor Suppressor | DNA damage response |
| 4HHB | Hemoglobin | Oxygen transport |
| 1MBO | Myoglobin | Muscle oxygen storage |
| 2LYZ | Lysozyme | Antimicrobial enzyme |
| 1CRN | Crambin | Small plant protein |
