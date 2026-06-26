# Cambios pendientes en el backend (para Chavez)

> Proyecto Supabase: `uqhszqujcsmlmubeynfp`
> Verificado contra la BD real el 2026-06-24. Actualizado 2026-06-25.
> La app movil **ya esta lista** y se adapta sola en cuanto lleguen estos datos.

---

## 1. La SEDE no aparece en la cita del cliente

**Que pasa ahora:** cuando el cliente abre su cita en la app, la sucursal
aparece como **"Sede no disponible"** (texto gris, en italica). Esto es porque
la RPC `get_my_reservations` **no devuelve la sucursal**.

**Causa:** la funcion `get_my_reservations` no hace JOIN a la tabla `branches`.
Se verifico que la funcion ni siquiera referencia esa tabla. Por eso la app no
recibe el nombre de la sede.

**Que tienes que hacer:**

Editar la RPC `get_my_reservations` para que joinee `branches` por
`reservations.branch_id` y devuelva estos 3 campos en cada cita (tanto en
`upcoming` como en `recent`):

| Campo JSON que la app espera | De donde sale |
|---|---|
| `branchName` | `branches.name` |
| `branchId` | `branches.id` (= `reservations.branch_id`) |
| `branchAddress` | `branches.address_line` |

Ejemplo del SELECT que necesitas agregar dentro del `jsonb_build_object`:

```sql
-- Agregar estas lineas en el jsonb_build_object de cada reserva:
'branchName',    b.name,
'branchId',      b.id,
'branchAddress', b.address_line

-- Y agregar este JOIN:
LEFT JOIN branches b ON b.id = r.branch_id
```

**Resultado:** en cuanto la RPC devuelva estos campos, la app mostrara
automaticamente el nombre real de la sede (ej. "CERCADO-2") en vez del
placeholder. No hay que tocar la app.

---

## 2. URL del mapa de la sucursal

**Que pasa ahora:** la tabla `branches` NO tiene columna para guardar una URL de
Google Maps. Por eso no se puede mostrar un boton de "Como llegar".

**Que tienes que hacer:**

1. Agregar una columna a la tabla `branches`:
   ```sql
   ALTER TABLE branches ADD COLUMN maps_url text;
   ```

2. Llenar el `maps_url` de cada sucursal con su link de Google Maps. Ejemplo:
   - Cercado-2: `https://maps.google.com/...` (el link que compartirias por WhatsApp)

3. Devolver ese campo en `get_my_reservations` como `branchMapsUrl`:
   ```sql
   'branchMapsUrl', b.maps_url
   ```

**Si una sede no tiene `maps_url`:** la app simplemente no mostrara el boton de
mapa para esa sede. No se rompe nada.

---

## 3. (Opcional) Codigo de acceso numerico

**Hoy:** el `access_code` es alfanumerico (ej. `TRF-KS0E-3YN8` — tiene letras).

**Si quieres que sea solo numeros:** hay que cambiar el generador del
`access_code` para que los 8 caracteres despues de `TRF-` sean digitos (ej.
`TRF-1234-5678`).

**No es urgente:** la app ya tiene teclado numerico por defecto + un boton para
abrir teclado completo. Funciona con ambos formatos.

---

## Resumen rapido

| # | Que hacer | Urgencia | Donde |
|---|---|---|---|
| 1 | `get_my_reservations` devuelve `branchName` + `branchId` + `branchAddress` | ALTA — sin esto la sede no aparece | RPC en Supabase |
| 2 | Agregar `maps_url` a `branches` + devolver `branchMapsUrl` | MEDIA — para el boton de mapa | Tabla + RPC |
| 3 | Generador de `access_code` numerico | BAJA — opcional | Funcion generadora |

---

**La app ya esta lista.** Al recibir estos campos, la sede y el mapa aparecen
automaticamente sin ningun cambio en el codigo de Flutter.
