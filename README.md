# casino-backend

Backend principal del proyecto **VidalCasino**, desarrollado para la asignatura  
**Introducción a Herramientas DevOps (ISY1101)**.

Este repositorio contiene la API principal del sistema, la configuración de base de datos y los manifiestos de Kubernetes asociados al **backend** y a la **BD**.  
Los demás componentes del sistema, como frontend, bonos, apuestas y estadísticas, se gestionan en repositorios separados con su propia carpeta `k8s/`. 

---

## Descripción

`casino-backend` expone la API REST principal del sistema, encargada de autenticación, gestión de usuarios, operaciones base y comunicación con PostgreSQL.  
Su despliegue está pensado para ejecutarse en contenedores y ser orquestado con Kubernetes, siguiendo prácticas de configuración por variables de entorno, health checks, secrets y despliegue automatizado.

---

## Alcance del repositorio

Este repositorio incluye únicamente:

- Código fuente del backend.
- Configuración e inicialización de la base de datos.
- Manifiestos de Kubernetes del backend y la base de datos.
- Archivos de apoyo para despliegue y desarrollo.

Este repositorio **no** incluye los manifiestos Kubernetes de los demás microservicios.  
Cada servicio complementario del sistema mantiene su propio repositorio y su propia estructura de despliegue.

---

## Stack

- Node.js 20
- Express 4
- PostgreSQL 16
- JWT para autenticación
- bcryptjs para hash de contraseñas
- `pg` como cliente PostgreSQL
- Kubernetes
- Docker
- GitHub Actions
- Amazon ECR / Amazon EKS

---

## Estructura

```text
casino-backend/
├── src/
│   ├── server.js
│   ├── db/
│   │   ├── pool.js
│   │   └── seed.js
│   ├── middleware/
│   │   └── auth.js
│   ├── routes/
│   │   ├── auth.js
│   │   ├── users.js
│   │   ├── games.js
│   │   └── transactions.js
│   └── games/
│       ├── slots.js
│       ├── roulette.js
│       └── blackjack.js
├── db/
│   └── init.sql
├── k8s/
│   ├── backend/
│   └── db/
├── package.json
├── .gitignore
├── .env.example
└── README.md
```

> Los manifiestos `k8s/` incluidos aquí corresponden solo al backend y la base de datos.

---

## Variables de entorno

| Variable | Default | Descripción |
|---|---|---|
| `PORT` | `3000` | Puerto HTTP del servidor |
| `JWT_SECRET` | `cambiame` | Secreto de firma JWT |
| `JWT_EXPIRES_IN` | `8h` | Vigencia del token |
| `DB_HOST` | `localhost` | Host de PostgreSQL |
| `DB_PORT` | `5432` | Puerto de PostgreSQL |
| `DB_USER` | `casino` | Usuario de base de datos |
| `DB_PASSWORD` | `casino` | Contraseña de base de datos |
| `DB_NAME` | `casino_db` | Nombre de la base de datos |
| `CORS_ORIGIN` | `*` | Orígenes permitidos |

---

## Endpoints

### Autenticación

| Método | Ruta | Descripción |
|---|---|---|
| POST | `/api/auth/register` | Registro de usuario |
| POST | `/api/auth/login` | Inicio de sesión |

### Usuario autenticado

| Método | Ruta | Descripción |
|---|---|---|
| GET | `/api/usuarios/me` | Obtiene datos del usuario |
| POST | `/api/usuarios/me/depositar` | Recarga saldo demo |
| GET | `/api/transacciones?limit=50` | Historial del usuario |

### Juegos

| Método | Ruta | Descripción |
|---|---|---|
| GET | `/api/juegos` | Catálogo de juegos |
| POST | `/api/juegos/slots/jugar` | Ejecuta partida de slots |
| POST | `/api/juegos/roulette/jugar` | Ejecuta jugada de ruleta |
| POST | `/api/juegos/blackjack/iniciar` | Inicia sesión de blackjack |
| POST | `/api/juegos/blackjack/accion` | Ejecuta acción sobre blackjack |

### Salud

| Método | Ruta | Descripción |
|---|---|---|
| GET | `/health` | Estado del servidor y BD |
| GET | `/` | Mensaje de bienvenida |

---

## Usuarios demo

| username | password | rol | saldo inicial |
|---|---|---|---:|
| `demo` | `demo1234` | jugador | $5.000 |
| `jugador1` | `demo1234` | jugador | $1.000 |
| `admin` | `admin1234` | admin | $99.999 |

---

## Ejecución local

Requisitos:

- Node.js 20
- PostgreSQL accesible
- Variables de entorno configuradas

```bash
cp .env.example .env
npm install
npm start
```

API disponible en:

```bash
http://localhost:3000
```

---

## Kubernetes

El backend se despliega con un **Deployment** y un **Service**, mientras que la base de datos se define con su manifiesto correspondiente según la arquitectura del proyecto.  
La configuración sensible se inyecta mediante variables de entorno y secretos, evitando credenciales hardcodeadas y facilitando el despliegue reproducible.

Además, el servicio puede incorporar sondas de salud para distinguir entre estado vivo y estado listo, permitiendo mejor integración con Kubernetes y mejor comportamiento ante fallos.

---

## Conceptos DevOps aplicados

### 1. Configuración por entorno
Toda la configuración importante se resuelve mediante variables de entorno.  
Esto permite mover el backend entre desarrollo, pruebas y producción sin modificar el código fuente.

### 2. Health checks
El endpoint `/health` permite verificar disponibilidad del proceso y conectividad con la base de datos.  
Esto facilita el uso de liveness/readiness y ayuda a automatizar recuperación y balanceo.

### 3. Reintento de conexión a BD
El backend considera escenarios en que PostgreSQL aún no está listo al momento del arranque.  
Por eso se usa una lógica de espera/reintentos antes de iniciar completamente la aplicación.

### 4. Seed idempotente
La carga de usuarios demo está diseñada para no duplicarse en reinicios.  
Esto facilita pruebas repetibles sin dañar el estado base.

### 5. Seguridad
Los secretos no deben quedar escritos en el código, commits o capturas.  
En despliegue, deben inyectarse desde Secret de Kubernetes o desde el pipeline de CI/CD.

---

## Pipeline CI/CD

El flujo de integración y despliegue continuo considera:

1. Build de imagen Docker.
2. Push de imagen a Amazon ECR.
3. Despliegue en Amazon EKS.

La automatización se ejecuta mediante GitHub Actions y permite mantener trazabilidad entre commit, imagen publicada y versión desplegada. 

---

## Relación con otros repositorios

Este backend forma parte de una solución distribuida más grande.  
Los siguientes componentes viven en repositorios separados:

- `casino-frontend`
- `casino-bonos`
- `casino-apuestas`
- `casino-estadisticas`

Cada uno mantiene su propio código fuente y sus propios manifiestos de Kubernetes.

---

## Evidencias asociadas

Este repositorio puede utilizarse para respaldar evidencias como:

- README del repositorio
- historial de commits con prefijos
- manifiestos Kubernetes del backend y BD
- configuración por variables de entorno
- integración con CI/CD
- despliegue y operación del backend en clúster

