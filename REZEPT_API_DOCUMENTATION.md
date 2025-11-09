# Rezept API Dokumentation

Diese API ermöglicht es, Rezepte basierend auf verschiedenen Kriterien zu finden, insbesondere einfache Rezepte mit wenigen Zutaten.

## Hauptfunktion: Einfache Rezepte finden

### GET `/api/rezepte/einfach`
**Zweck**: Findet alle Rezepte mit weniger als 5 Zutaten - ideal für schnelle und einfache Gerichte.

**Response**: Array von Rezept-Objekten
```json
[
  {
    "rezeptNr": 1001,
    "rezeptName": "Einfacher Tomatensalat",
    "beschreibung": "Schneller und erfrischender Tomatensalat mit wenigen Zutaten",
    "zubereitungszeit": 10
  }
]
```

## Weitere API Endpoints

### GET `/api/rezepte/max-zutaten/{anzahl}`
**Zweck**: Findet alle Rezepte mit maximal der angegebenen Anzahl von Zutaten.

**Parameter**:
- `anzahl` (Pfad-Parameter): Maximale Anzahl der Zutaten (mindestens 1)

**Beispiel**: `/api/rezepte/max-zutaten/3` - Rezepte mit maximal 3 Zutaten

### GET `/api/rezepte/schnell-und-einfach`
**Zweck**: Findet Rezepte, die sowohl eine kurze Zubereitungszeit als auch wenige Zutaten haben.

**Parameter** (Query-Parameter):
- `maxZeit`: Maximale Zubereitungszeit in Minuten (Standard: 30)
- `maxZutaten`: Maximale Anzahl der Zutaten (Standard: 5)

**Beispiel**: `/api/rezepte/schnell-und-einfach?maxZeit=15&maxZutaten=3`

### GET `/api/rezepte`
**Zweck**: Gibt alle verfügbaren Rezepte zurück.

### GET `/api/rezepte/{id}`
**Zweck**: Gibt ein spezifisches Rezept anhand der ID zurück.

**Parameter**:
- `id` (Pfad-Parameter): Die Rezept-ID

## Rezept-Datenstruktur

```json
{
  "rezeptNr": "Integer - Eindeutige Rezept-ID",
  "rezeptName": "String - Name des Rezepts",
  "beschreibung": "String - Beschreibung der Zubereitung",
  "zubereitungszeit": "Integer - Zubereitungszeit in Minuten"
}
```

## Verwendung

### Frontend Integration
Die neue HTML-Seite unter `/src/main/resources/templates/einfache-rezepte.html` bietet eine benutzerfreundliche Oberfläche zum Testen der API.

### Direkte API-Aufrufe
```bash
# Einfache Rezepte (< 5 Zutaten)
curl http://localhost:8080/api/rezepte/einfach

# Rezepte mit maximal 3 Zutaten
curl http://localhost:8080/api/rezepte/max-zutaten/3

# Schnelle und einfache Rezepte (max 20 Min, max 4 Zutaten)
curl "http://localhost:8080/api/rezepte/schnell-und-einfach?maxZeit=20&maxZutaten=4"
```

## Implementierung

### Neue Dateien erstellt:
1. **Rezept.java** - JPA-Entität für Rezepte
2. **RezeptRepository.java** - Repository mit spezialisierten Abfragen
3. **RezeptService.java** - Service-Layer für Geschäftslogik
4. **RezeptController.java** - REST-Controller für API-Endpoints
5. **einfache-rezepte.html** - Frontend für Rezeptsuche

### Testdaten:
Die `dumpData.sql` wurde erweitert mit:
- 6 Beispielrezepten (einfache und komplexe)
- Entsprechenden RezeptZutat-Einträgen
- Verschiedene Zubereitungszeiten und Zutatenzahlen

### Datenbankabfragen:
Die Repository-Methoden verwenden JPQL-Queries, um Rezepte basierend auf der Anzahl ihrer Zutaten zu filtern:

```sql
SELECT r FROM Rezept r WHERE 
(SELECT COUNT(rz) FROM RezeptZutat rz WHERE rz.rezeptNr = r.rezeptNr) < 5
```

## Nutzen für Anwender

1. **Schnelle Rezeptsuche**: Nutzer können gezielt nach einfachen Rezepten suchen
2. **Flexible Filter**: Verschiedene Kombinationen von Zeit und Zutatenzahl
3. **Übersichtliche Darstellung**: Alle relevanten Informationen auf einen Blick
4. **REST-API**: Integration in externe Anwendungen möglich

Diese Funktionalität ist besonders nützlich für:
- Kochanfänger, die mit einfachen Rezepten beginnen möchten
- Personen mit wenig Zeit für die Zubereitung
- Nutzer mit begrenzten Zutaten im Haushalt
- Meal-Planning mit einfachen Gerichten