# marine_app

App Flutter para explorar las 1,505 especies marinas de la API pública speCies.blue, con búsqueda, filtros y favoritos guardados en el dispositivo.

## Cómo funciona

### Arquitectura por capas

Las flechas van de quien depende hacia lo que usa. Las cajas punteadas están pendientes.

```mermaid
flowchart TB
    ENV[".env<br/>API_BASE_URL"]
    API[("API speCies.blue<br/>HTTPS + JSON")]
    ISAR[("Isar local<br/>favoritos")]:::pending

    subgraph presentation["presentation"]
        SCREENS["screens<br/>shell · inicio<br/>explorar, favoritos, acerca de (temporales)<br/>detalle (pendiente)"]
        PROVIDERS["provider (Riverpod)<br/>repositorio · detalle · destacadas<br/>lista paginada · filtros · zonas"]
        WIDGETS["widgets/shared"]
    end

    subgraph domain["domain (Dart puro)"]
        ENT["entities"]
        REPO["repositories abstractos"]
        DS["datasources abstractos"]
    end

    subgraph infrastructure["infrastructure"]
        REPOIMPL["SpeciesRepositoryImpl"]
        DSIMPL["SpeciesDatasourcesImpl<br/>(Dio)"]
        MAP["mapper + models *_response"]
        FAVIMPL["favoritos impl"]:::pending
    end

    subgraph config["config"]
        CONST["constants<br/>ApiConstants · rutas · categorías"]
        ROUTER["router (go_router)"]
        THEME["theme (Material 3)"]
    end

    SCREENS --> PROVIDERS
    SCREENS --> WIDGETS
    PROVIDERS --> REPO
    PROVIDERS -->|"solo speciesRepositoryProvider"| REPOIMPL
    REPOIMPL -.->|implementa| REPO
    DSIMPL -.->|implementa| DS
    REPOIMPL --> DSIMPL
    DSIMPL --> MAP
    MAP --> ENT
    REPO --> ENT
    DSIMPL --> CONST
    CONST -->|lee| ENV
    DSIMPL -->|HTTPS| API
    FAVIMPL -.-> ISAR
    ROUTER --> SCREENS
    PROVIDERS --> CONST

    classDef pending stroke-dasharray: 5 5
```

Reglas: `domain` no depende de nada; `presentation` solo conoce `domain` (con una excepción: el provider que construye el repositorio); `infrastructure` solo conoce `domain` y `config`.

### Petición de una página de `/species`

Así se carga una página de especies, con el camino de error. Hoy lo recorre Inicio con las destacadas; Explorar usará el mismo camino (pendiente).

```mermaid
sequenceDiagram
    autonumber
    actor U as Usuario
    participant S as Pantalla
    participant P as SpeciesListNotifier
    participant R as SpeciesRepositoryImpl
    participant D as SpeciesDatasourcesImpl (Dio)
    participant A as API speCies.blue
    participant M as SpeciesMapper

    U->>S: abre la pantalla, cambia un filtro o llega al final
    S->>P: ref.watch / loadNextPage()
    P->>R: getSpecies(lang, page, perPage, filtros)
    R->>D: getSpecies(...)
    D->>A: GET /species?lang=es&page=1&per_page=20
    alt 200 OK
        A-->>D: JSON con data y pagination
        D->>D: SpeciesListResponse.fromJson
        D->>M: pageToEntity
        M-->>D: SpeciesPage (entidad de domain)
        D-->>R: (SpeciesPage, "")
        R-->>P: (SpeciesPage, "")
        P-->>S: AsyncData con items acumulados y hasNextPage
    else error: 500, tiempo agotado, sin red o formato inesperado
        A-->>D: respuesta de error o DioException
        D-->>R: (null, "mensaje en español")
        R-->>P: (null, "mensaje en español")
        P-->>S: throw del mensaje, AsyncError
        S-->>U: AsyncValue.when muestra el mensaje
    end
```

## Ejecutar

```bash
flutter pub get
cp .env.example .env    # en PowerShell: Copy-Item .env.example .env
flutter run
```

Completa `API_BASE_URL` en el `.env` con `https://skfqeznlqqprmvamwyrf.supabase.co/functions/v1/public-api/v1`. El `.env` no se versiona.

## Atribución

Datos de [speCies.blue](https://species.blue), bajo licencia [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/).
