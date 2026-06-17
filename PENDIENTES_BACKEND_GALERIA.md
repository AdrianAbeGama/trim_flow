# Galería — 2 pendientes del backend (para el socio)

> Documento de handoff. Verificado contra la BD real (proyecto Supabase
> `uqhszqujcsmlmubeynfp`) el 2026-06-17. La app móvil ya está conectada y
> funcionando; estos 2 puntos los tiene que resolver el backend porque son de
> SQL/RLS/RPC, no de la app.
>
> **Regla que respetamos (ADR-0015):** la app NO hace INSERT/UPDATE/DELETE
> directo y NO modifica el SQL del socio. Por eso esto va como propuesta para
> que lo aplique el dueño del backend.

---

## Resumen en una línea

La galería del cliente debe mostrar las fotos de **toda la barbería** con el
**nombre del autor** y el **servicio + precio**. Hoy: (1) el nombre del autor
sale genérico ("Estilista") cuando lo subió alguien que no es `role='barber'`, y
(2) no existe una RPC que devuelva la galería del tenant completo, así que la app
está leyendo la tabla `gallery_items` directo. Ambos se arreglan con **una sola
RPC nueva** `get_tenant_gallery` (`SECURITY DEFINER`).

---

## Problema 1 — El nombre del autor sale "Estilista"

**Qué se ve en la app:** una foto de la galería se muestra bien, pero donde
debería ir el nombre del barbero/autor aparece el texto genérico "Estilista".

**Por qué pasa (lo que hay hoy):**
La app, para poner el nombre, necesita leer el perfil del autor en `profiles`.
La política RLS que deja a un cliente leer perfiles es:

```
profiles_select_public_barbers  (SELECT, roles anon/authenticated):
  role = 'barber' AND is_active = true AND deleted_at IS NULL AND branch_id IS NOT NULL
```

Es decir, un cliente **solo** puede ver perfiles que son barberos activos con
sucursal. Si una foto la subió el **dueño/administrador** (su perfil tiene
`role = 'tenant_admin'`, no `'barber'`), ese perfil es **invisible** para el
cliente → la app no encuentra el nombre y cae al fallback "Estilista".

**Evidencia real (hoy):** las 2 únicas fotos de la galería las subió un perfil
con `role = 'tenant_admin'`. Resultado de la consulta de verificación:

| autor_role     | fotos | visible_a_cliente |
|----------------|-------|-------------------|
| `tenant_admin` | 2     | **false**         |

Por eso, vistas como cliente, esas 2 fotos saldrían como "Estilista".

**Solución (backend):** el nombre del autor debe resolverse **en el servidor**,
dentro de una RPC `SECURITY DEFINER` (que se salta la RLS de forma controlada),
y devolverse ya listo en el JSON. Así la app no depende de poder leer `profiles`
del autor y el nombre sale siempre correcto, sin exponer la tabla `profiles` al
público. (Ver la RPC propuesta abajo: campo `authorName`.)

> Alternativa NO recomendada: ampliar la RLS para que el público pueda leer
> también perfiles de admins. Eso filtraría datos de perfiles que no son
> barberos a cualquiera. Mejor resolverlo en la RPC.

---

## Problema 2 — No hay RPC para la galería de TODA la barbería

**Qué falta:** el cliente debe ver el portafolio de **todos** los barberos de la
barbería (no solo de uno). No existe una RPC para eso.

**Lo que hay hoy:**
- Única RPC de lectura de galería: `get_barber_gallery(p_barber_id uuid, p_limit int)`
  → devuelve las fotos **de un solo barbero**. Hoy retorna:
  `id, imagePath, caption, isFeatured, serviceId`. (No trae nombre del autor,
  ni nombre/precio del servicio.)
- Como no hay RPC de tenant, la app **lee la tabla `gallery_items` directo**
  (lo permite la policy `gallery_select_public` que es `USING (true)`), filtra
  por `tenant_id`, y une a mano el servicio y el barbero usando el catálogo.

**Por qué no basta:** funciona para mostrar las imágenes, pero (a) arrastra el
Problema 1 (no resuelve el nombre del autor cuando no es barbero público) y
(b) depende de leer la tabla cruda en vez de tener un contrato estable de RPC.

**Solución (backend):** crear `get_tenant_gallery(p_tenant_id uuid, ...)`
`SECURITY DEFINER` que devuelva la galería completa del tenant con todo resuelto:
foto + servicio (nombre y precio) + autor (nombre). Con eso la app deja de leer
la tabla directo y se arregla el nombre de una.

---

## Solución recomendada (una sola RPC resuelve los 2)

Crear esta RPC nueva. Resuelve `authorName` y los datos del servicio en el
servidor, así que arregla el Problema 1 y el Problema 2 a la vez.

> ⚠️ PROPUESTA — la revisa/aplica el dueño del backend. No la ejecutó la app.
> Nombres de tablas/columnas verificados: `services.price_pen`,
> `services.name`, `profiles.full_name`, `gallery_items(tenant_id, barber_id,
> service_id, image_path, caption, is_featured, created_at)`.

```sql
create or replace function public.get_tenant_gallery(
  p_tenant_id uuid,
  p_limit int default 200
)
returns jsonb
language plpgsql
stable
security definer
set search_path to 'public'
as $$
declare
  v_items jsonb;
  v_lim int := greatest(1, least(coalesce(p_limit, 200), 500));
begin
  select jsonb_agg(x) into v_items
  from (
    select jsonb_build_object(
             'id',           gi.id,
             'imagePath',    gi.image_path,
             'caption',      gi.caption,
             'isFeatured',   gi.is_featured,
             'serviceId',    gi.service_id,
             'serviceName',  s.name,
             'servicePrice', s.price_pen,
             'barberId',     gi.barber_id,
             'authorName',   coalesce(p.full_name, 'Estilista')
           ) as x
    from gallery_items gi
    left join services s on s.id = gi.service_id
    left join profiles p on p.id = gi.barber_id
    where gi.tenant_id = p_tenant_id
    order by gi.is_featured desc, gi.created_at desc
    limit v_lim
  ) q;

  return coalesce(v_items, '[]'::jsonb);
end;
$$;

-- Necesario para que la app (rol authenticated) pueda llamarla:
grant execute on function public.get_tenant_gallery(uuid, int) to authenticated, anon;
```

**Opcional (mejora menor):** agregar también `serviceName`, `servicePrice` y
`authorName` a `get_barber_gallery`, para que la vista "portafolio de un barbero"
sea consistente sin que la app tenga que cruzar datos.

---

## Qué cambia en la app cuando exista la RPC

Una vez creada `get_tenant_gallery`, en la app:
- `gallery_supabase_repository.dart` dejará de leer la tabla `gallery_items`
  directo y llamará a `get_tenant_gallery(p_tenant_id)`.
- El nombre del autor vendrá de `authorName` (ya no del fallback "Estilista").
- El servicio (nombre/precio) vendrá de `serviceName`/`servicePrice` (ya no se
  cruza con el catálogo a mano).

Mientras tanto la app sigue funcionando con la lectura directa; estos cambios son
mejora de robustez + el arreglo del nombre.

---

## Anexo — Datos verificados (referencia rápida)

**RLS relevante:**
- `gallery_items.gallery_select_public` → `SELECT` para anon/authenticated, `USING (true)`.
- `profiles.profiles_select_public_barbers` → `SELECT` anon/authenticated,
  `USING (role='barber' AND is_active AND deleted_at IS NULL AND branch_id IS NOT NULL)`.

**RPCs de galería existentes:**
- `add_gallery_item(p_image_path text, p_service_id uuid, p_caption text default null)` → jsonb. `SECURITY DEFINER`. Valida dueño del path, que el servicio sea del tenant, y cuota máx. 30 fotos por barbero.
- `delete_gallery_item(p_item_id uuid)` → void.
- `toggle_gallery_featured(p_item_id uuid, p_featured boolean)` → jsonb.
- `get_barber_gallery(p_barber_id uuid, p_limit int default 12)` → jsonb `[{id, imagePath, caption, isFeatured, serviceId}]`.
- **No existe** ninguna RPC de galería a nivel de tenant.

**Columnas clave:** `services(id, tenant_id, name, price_pen, duration_minutes, is_active, is_featured)` · `profiles(id, tenant_id, full_name, role, specialty, branch_id, is_active, deleted_at)` · `gallery_items(id, tenant_id, branch_id, barber_id, service_id, image_path, caption, is_featured, created_at)`.
