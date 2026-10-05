# CRUDL de usuarios con arquitectura hexagonal

API básica en Java 21 y Spring Boot para crear, consultar, listar, actualizar y eliminar usuarios. La información se almacena en una caché local de Spring basada en `ConcurrentMapCacheManager`; por ello es volátil y se pierde cuando se reinicia la aplicación.

## Arquitectura

Las dependencias apuntan hacia el dominio:

```text
entrypoint/rest/v1  ──>  domain/ports/in  <──  domain/services
                                                 │
                                                 v
adapter/cache/local ──> domain/ports/out <────────┘
```

La estructura implementada es:

```text
src/main/java/com/jcaa/udec
├── entrypoint
│   └── rest/v1
│       ├── docs
│       ├── dto/request
│       ├── dto/response
│       ├── errors/handler
│       └── mappers
├── domain
│   ├── enums
│   ├── exceptions
│   ├── models
│   ├── ports/in
│   ├── ports/out
│   ├── services
│   │   ├── dto/commands
│   │   ├── dto/queries
│   │   ├── dto/response
│   │   └── mappers
│   └── valueobjects
├── adapter
│   └── cache/local
└── common
    ├── configuration
    └── helpers
```

Las ramas para mensajería, bases de datos, archivos y clientes REST no contienen implementaciones porque este ejemplo no usa proveedores externos. Se pueden añadir después como adaptadores de los puertos de salida sin modificar el dominio.

## Endpoints

| Método | Ruta | Resultado |
|---|---|---|
| `POST` | `/api/v1/users` | Crea un usuario (`201`) |
| `GET` | `/api/v1/users/{userId}` | Consulta un usuario (`200`) |
| `GET` | `/api/v1/users` | Lista los usuarios y el total (`200`) |
| `PUT` | `/api/v1/users/{userId}` | Actualiza nombre y correo (`200`) |
| `DELETE` | `/api/v1/users/{userId}` | Elimina un usuario (`204`) |

El correo debe ser válido y único, sin distinguir mayúsculas. El nombre se recorta y los espacios repetidos se normalizan. Los errores tienen un contrato uniforme con código técnico, estado HTTP, mensaje, ruta y errores de validación.

Con la aplicación iniciada, la documentación OpenAPI está en `http://localhost:8080/api-docs` y Swagger UI en `http://localhost:8080/swagger-ui.html`.

Ejemplo de creación:

```bash
curl --request POST http://localhost:8080/api/v1/users \
  --header "Content-Type: application/json" \
  --data '{"name":"Ada Lovelace","email":"ada.lovelace@example.com"}'
```

## Ejecución local

Requiere JDK 21 o posterior y Maven 3.9 o posterior:

```bash
mvn clean install
java -jar target/api-rest-crud-basic-spring-boot-1.0.0-SNAPSHOT.jar
```

## Ejecución con Docker

No requiere Java ni Maven instalados en el host:

```bash
docker compose up --build
```

Para detener el contenedor:

```bash
docker compose down
```

En Windows, Docker Desktop necesita la característica **Virtual Machine Platform**. Si Docker indica que está deshabilitada, actívala desde una PowerShell administrativa y reinicia el equipo antes de construir la imagen:

```powershell
Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
```

## Pruebas y cobertura

Las pruebas cubren invariantes del dominio, casos de uso, el adaptador de caché y el contrato REST completo, incluida la documentación OpenAPI:

```bash
mvn clean verify
```

El reporte de JaCoCo se genera en `target/site/jacoco/index.html`.

# Guía de Ejecución con Docker

Puedes ejecutar la imagen que ya construyó Docker Compose directamente con `docker run`.

## 1. Confirmar que la imagen existe

Verifica que la imagen esté disponible en tu sistema:

```bash
docker images
```

El nombre de la imagen generada por Docker Compose es:
`crud-example-spring-without-db-user-api:latest`

## 2. Ejecutar el contenedor

Inicia el contenedor en segundo plano (PowerShell):

```powershell
docker run -d `
  --name user-api `
  -p 8080:8080 `
  crud-example-spring-without-db-user-api:latest
```

*(Nota: Si usas Bash o Linux, cambia el acento grave `` ` `` por una barra invertida `\` para los saltos de línea).*

## 3. Verificar estado y logs

Comprueba que el contenedor esté corriendo y revisa su salida:

```bash
docker ps
docker logs -f user-api
```

## 4. Acceder a la aplicación

Una vez iniciado, puedes ingresar a las siguientes rutas en tu navegador:

* [Swagger UI](http://localhost:8080/swagger-ui.html)
* [API Docs](http://localhost:8080/api-docs)

## 5. Control del Contenedor

### Detener y volver a iniciar
```bash
docker stop user-api
docker start user-api
```

### Eliminar el contenedor
```bash
docker rm -f user-api
```

---

## Opciones Alternativas

### Construir la imagen sin usar Compose desde el principio
Si prefieres construir la imagen manualmente con Dockerfile:

```bash
docker build -t user-api:latest .
docker run -d --name user-api -p 8080:8080 user-api:latest
```

### Usar un puerto diferente
Si el puerto `8080` está ocupado en tu equipo, puedes publicar otro puerto asignado al contenedor (por ejemplo, el `8081`):

```bash
docker run -d --name user-api -p 8081:8080 user-api:latest
```

En este caso, Swagger quedará disponible en [http://localhost:8081/swagger-ui.html](http://localhost:8081/swagger-ui.html).