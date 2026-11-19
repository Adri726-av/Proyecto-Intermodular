# API y elección del backend

Proyecto: **Asignador de mazos de Magic** · Equipo: Ismael y Adrián · Sprint 1, tarea 5

## 1. Elección del backend

| Opción | Lenguaje | A favor | En contra |
|---|---|---|---|
| Node.js + Express | JavaScript | Mismo lenguaje que el frontend (HTML/CSS/JS, y Angular/React si se usa). Se arranca en minutos y encaja con lo visto en clase. | Hay que decidir a mano la estructura, la validación y el acceso a datos. |
| Spring Boot | Java | Era la opción del Sprint 0. Es robusto y lo conocemos de Programación. | Más configuración inicial y más código para una API pequeña. |
| Laravel | PHP | Trae casi todo hecho (rutas, ORM, validación). | Lenguaje nuevo para los dos; no da tiempo a aprenderlo en 4 sprints. |

**Decisión: Node.js + Express** con MySQL (paquete `mysql2`).

**Cambio respecto al Sprint 0.** En la primera entrega el backend era Java, con la nota "modificable a Node". Lo cambiamos porque:

1. Con Node todo el proyecto usa un solo lenguaje, y somos solo dos personas.
2. La API es pequeña (5 entidades, un cálculo de puntos) y Express la resuelve con menos código y configuración que Spring Boot.
3. Podemos revisar el código del otro sin cambiar de lenguaje.

La base de datos sigue siendo MySQL, y el cambio no afecta al modelo E/R.

## 2. Convenciones de la API

- Base: `/api`. Formato de datos: JSON (`Content-Type: application/json`).
- Errores: `{ "error": "mensaje claro" }`; si hay detalle, se añade un campo extra (por ejemplo `pendientes`).
- Códigos: `200` OK · `201` creado · `400` datos no válidos · `401` falta o es incorrecto el token de administrador · `404` no existe · `409` conflicto (duplicado).
- **Rutas públicas** (`/api/...`): las usa el cuestionario. No necesitan cuenta, porque la primera versión no tiene usuarios.
- **Rutas de administración** (`/api/admin/...`): exigen la cabecera `X-Admin-Token` con el valor de `ADMIN_TOKEN` del fichero `.env`. Así evitamos el riesgo "acceso no autorizado al panel" del apartado 3.2 sin montar un sistema de cuentas.
- **Las respuestas del usuario no se guardan** (apartado 3.1). La recomendación se calcula en una sola petición y no se escribe nada en la base de datos.
- **Bajas lógicas.** `DELETE` de pregunta y de mazo los pone como inactivos (`activa = 0` / `activo = 0`) en lugar de borrarlos. Así se cumplen RN-006 y HU-14 y no se rompen las puntuaciones.

## 3. Rutas públicas

| Método | Ruta | Qué hace | Recibe | Devuelve | HU / RN |
|---|---|---|---|---|---|
| GET | `/api/estado` | Comprueba que el servidor responde | — | 200 `{ "ok": true }` | — |
| GET | `/api/formatos` | Lista los formatos disponibles | — | 200 + lista | HU-02 |
| GET | `/api/formatos/:id` | Muestra un formato | — | 200 o 404 | HU-02 |
| GET | `/api/formatos/:id/preguntas` | Preguntas **activas** del formato, cada una con sus respuestas y el total de preguntas | — | 200 o 404 | HU-03, HU-04, HU-05, RN-006 |
| POST | `/api/recomendaciones` | Calcula el mazo recomendado a partir de las respuestas elegidas | `id_formato` y lista de `id_respuesta` | 200, 400 o 404 | HU-06, HU-07, HU-08, HU-09, RN-001, RN-002, RN-003, RN-004, RN-007 |
| GET | `/api/mazos/:id` | Detalle de un mazo **activo** con su enlace a la lista | — | 200 o 404 | HU-10, RN-005 |

HU-01, HU-04 (la barra de progreso), HU-05, HU-11 y HU-15 se resuelven en el frontend. Para HU-04 y HU-05 solo necesitan los datos de `GET /api/formatos/:id/preguntas`. Y RN-008 (reiniciar) es solo cliente, porque el servidor no guarda nada.

## 4. Rutas de administración

Todas requieren `X-Admin-Token`; sin él o con un valor incorrecto devuelven `401`.

### Mazos (HU-14, RN-005)

| Método | Ruta | Qué hace | Recibe | Devuelve | HU / RN |
|---|---|---|---|---|---|
| GET | `/api/admin/mazos` | Lista todos los mazos, también inactivos. Filtro opcional `?id_formato=` | — | 200 + lista | HU-14 |
| GET | `/api/admin/mazos/:id` | Muestra un mazo | — | 200 o 404 | HU-14 |
| POST | `/api/admin/mazos` | Crea un mazo | `nombre`, `id_formato`, `colores`, `estilo`, `descripcion`, `enlace`, `activo` | 201 o 400 | HU-14, RN-005 |
| PUT | `/api/admin/mazos/:id` | Modifica los campos de un mazo | Los campos a cambiar | 200, 400 o 404 | HU-14, RN-005 |
| DELETE | `/api/admin/mazos/:id` | Da de baja el mazo (`activo = 0`); deja de recomendarse | — | 200 o 404 | HU-14 |

### Preguntas (HU-12, RN-006)

| Método | Ruta | Qué hace | Recibe | Devuelve | HU / RN |
|---|---|---|---|---|---|
| GET | `/api/admin/preguntas` | Lista las preguntas, también inactivas. Filtro opcional `?id_formato=` | — | 200 + lista | HU-12 |
| GET | `/api/admin/preguntas/:id` | Muestra una pregunta con sus respuestas | — | 200 o 404 | HU-12 |
| POST | `/api/admin/preguntas` | Crea una pregunta | `texto`, `id_formato`, `obligatoria`, `activa` | 201 o 400 | HU-12 |
| PUT | `/api/admin/preguntas/:id` | Modifica texto, obligatoriedad o estado | Los campos a cambiar | 200, 400 o 404 | HU-12, RN-006 |
| DELETE | `/api/admin/preguntas/:id` | Desactiva la pregunta (`activa = 0`); deja de mostrarse | — | 200 o 404 | HU-12, RN-006 |

### Respuestas (HU-12)

| Método | Ruta | Qué hace | Recibe | Devuelve | HU / RN |
|---|---|---|---|---|---|
| POST | `/api/admin/preguntas/:id/respuestas` | Añade una respuesta a una pregunta | `texto` | 201, 400 o 404 | HU-12 |
| PUT | `/api/admin/respuestas/:id` | Cambia el texto de una respuesta | `texto` | 200, 400 o 404 | HU-12 |
| DELETE | `/api/admin/respuestas/:id` | Borra la respuesta y sus puntuaciones (`ON DELETE CASCADE`) | — | 200 o 404 | HU-12 |

### Puntuaciones: respuesta ↔ mazo (HU-13, RN-002)

| Método | Ruta | Qué hace | Recibe | Devuelve | HU / RN |
|---|---|---|---|---|---|
| GET | `/api/admin/respuestas/:id/puntuaciones` | Lista los mazos que puntúan con esa respuesta y cuántos puntos | — | 200 o 404 | HU-13 |
| PUT | `/api/admin/respuestas/:id/puntuaciones/:idMazo` | Crea o actualiza los puntos de la pareja respuesta–mazo | `puntos` (entero ≥ 0) | 200, 201, 400 o 404 | HU-13, RN-002 |
| DELETE | `/api/admin/respuestas/:id/puntuaciones/:idMazo` | Quita la puntuación | — | 200 o 404 | HU-13 |

## 5. Lógica de `POST /api/recomendaciones`

1. Comprueba que el formato existe (si no, `404`).
2. Comprueba que cada `id_respuesta` pertenece a una pregunta **activa** de ese formato (si no, `400`).
3. Comprueba que hay al menos una respuesta por cada pregunta **obligatoria** activa. Si falta alguna, devuelve `400` con la lista `pendientes` y **no calcula nada** (RN-001, HU-06).
4. Suma, para cada mazo **activo** de ese formato, los puntos de las respuestas elegidas (RN-002).
5. Ordena por puntos. El mazo con más puntos es la recomendación (RN-003). Si varios tienen la misma puntuación máxima, se devuelven todos con `"empate": true` (RN-004, HU-09).
6. Para cada mazo devuelto incluye los `motivos`: las respuestas que más puntos le han dado (RN-007, HU-08).

## 6. Ejemplos de JSON

*Los nombres de mazos, formatos y preguntas son ejemplos.*

### `POST /api/recomendaciones`

Petición:

```json
{
  "id_formato": 1,
  "respuestas": [3, 7, 12, 15]
}
```

Respuesta `200`:

```json
{
  "formato": { "id_formato": 1, "nombre": "Commander" },
  "empate": false,
  "recomendaciones": [
    {
      "id_mazo": 4,
      "nombre": "Control Azul-Negro",
      "colores": "Azul, Negro",
      "estilo": "Control",
      "descripcion": "Mazo que juega con calma y responde a lo que hace el rival.",
      "enlace": "https://ejemplo.com/lista-control-azul-negro",
      "puntos": 9,
      "motivos": [
        {
          "id_respuesta": 3,
          "pregunta": "¿Cómo te gusta ganar?",
          "respuesta": "Controlando la partida",
          "puntos": 4
        },
        {
          "id_respuesta": 12,
          "pregunta": "¿Cuánto te gusta planificar?",
          "respuesta": "Mucho, prefiero pensar cada jugada",
          "puntos": 3
        }
      ]
    }
  ]
}
```

Respuesta `400` (faltan preguntas obligatorias):

```json
{
  "error": "Faltan preguntas obligatorias por contestar",
  "pendientes": [
    { "id_pregunta": 5, "texto": "¿Prefieres partidas rápidas o largas?" }
  ]
}
```

### `POST /api/admin/mazos`

Cabecera: `X-Admin-Token: <valor de ADMIN_TOKEN>`

Petición:

```json
{
  "nombre": "Tempo Azul-Roja",
  "id_formato": 1,
  "colores": "Azul, Roja",
  "estilo": "Tempo",
  "descripcion": "Mazo rápido que combina criaturas pequeñas con hechizos instantáneos.",
  "enlace": "https://ejemplo.com/lista-tempo-azul-roja",
  "activo": true
}
```

Respuesta `201`:

```json
{
  "id_mazo": 5,
  "nombre": "Tempo Azul-Roja",
  "id_formato": 1,
  "colores": "Azul, Roja",
  "estilo": "Tempo",
  "descripcion": "Mazo rápido que combina criaturas pequeñas con hechizos instantáneos.",
  "enlace": "https://ejemplo.com/lista-tempo-azul-roja",
  "activo": true
}
```

Respuesta `400` (faltan campos obligatorios):

```json
{ "error": "Los campos nombre, id_formato, colores y estilo son obligatorios" }
```

### `PUT /api/admin/respuestas/12/puntuaciones/4`

```json
{ "puntos": 3 }
```

Respuesta `200`: `{ "id_respuesta": 12, "id_mazo": 4, "puntos": 3 }`

## 7. Backend de prueba

El proyecto vacío está en `backend/`. Arranca y responde en `GET /api/estado`:

```bash
cd backend
npm install
cp ../.env.example ../.env   # y rellenar los valores
npm start
curl http://localhost:3000/api/estado   # -> { "ok": true }
```
