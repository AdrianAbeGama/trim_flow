# ✅ RESUELTO — soporte de "acting barber" en el booking

> **Estado: RESUELTO por el backend. Verificado en la BD real
> (`uqhszqujcsmlmubeynfp`) el 2026-06-24.** `_finalize_booking` ya incluye el
> predicado `(p.role='barber' OR p.is_acting_barber=true)` en el STEP 1, así que
> agendar/walk-in de un acting barber ya **no** lanza `barber_not_in_branch`.
> No se requiere acción adicional. El texto de abajo se conserva como historial.

---

# Pendiente backend: completar soporte de "acting barber" en el booking

> Contexto para la IA/dev del backend. Proyecto Supabase `uqhszqujcsmlmubeynfp`.
> Todo es SQL (RPCs `SECURITY DEFINER`). Aplicar vía migración (`CREATE OR REPLACE FUNCTION`).

## 1. Resumen del problema

Las migraciones `acting_barber_*` (21 jun) agregaron soporte de **acting barbers**
(admins con `profiles.is_acting_barber = true` que también atienden) al lado de
**descubrimiento**, pero **NO al lado de reserva**. Resultado: el cliente **ve** a un
acting barber como reservable y ve sus horarios, pero **al intentar agendarlo la
reserva FALLA** con `barber_not_in_branch`. Mostrar algo reservable que no se puede
reservar es un bug de consistencia.

## 2. Causa raíz (definición inconsistente de "barbero reservable")

Hay DOS definiciones distintas en el código:

- **Descubrimiento (YA corregido, acepta acting):** en `get_public_barbers`,
  `get_available_slots`, `get_tenant_landing_data` el predicado es:
  ```sql
  (p.role = 'barber' OR p.is_acting_barber = true)
    AND p.is_active = true AND p.deleted_at IS NULL
    AND p.branch_id = p_branch_id AND p.tenant_id = p_tenant_id
  ```

- **Reserva (NO corregido, rechaza acting):** en `_finalize_booking` (la RPC que
  hace el INSERT real, llamada por `create_app_booking` Y `create_anonymous_booking`)
  el predicado sigue siendo:
  ```sql
  p.role = 'barber'    -- <-- le falta el OR is_acting_barber
    AND p.is_active = true AND p.deleted_at IS NULL
    AND p.branch_id = p_branch_id AND p.tenant_id = p_tenant_id
  ```

## 3. Fix mínimo (el importante)

En `public._finalize_booking`, en el STEP 1 de validación
(`IF NOT EXISTS (...) THEN RAISE EXCEPTION 'barber_not_in_branch'`), cambiar:

```sql
-- ANTES
AND p.role = 'barber'
```
```sql
-- DESPUES (igual que get_public_barbers / get_available_slots)
AND (p.role = 'barber' OR p.is_acting_barber = true)
```

Esto desbloquea **reservar acting barbers desde la app cliente Y los walk-ins**
(ambos pasan por `_finalize_booking`). Sin cambios en la app móvil.

**Recomendado (anti-drift):** extraer un helper para tener UNA sola definición y
no volver a desincronizar, p.ej.:
```sql
CREATE OR REPLACE FUNCTION public.is_bookable_barber(
  p_profile_id uuid, p_branch_id uuid, p_tenant_id uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path TO 'public' AS $$
  SELECT EXISTS (
    SELECT 1 FROM profiles p
    WHERE p.id = p_profile_id
      AND (p.role = 'barber' OR p.is_acting_barber = true)
      AND p.is_active = true AND p.deleted_at IS NULL
      AND p.branch_id = p_branch_id AND p.tenant_id = p_tenant_id);
$$;
```
…y usarlo en `_finalize_booking`, `get_available_slots`, `get_public_barbers`.

## 4. Otras funciones que referencian `role = 'barber'` — revisar si deben aceptar acting

Estas también filtran por `role = 'barber'` y **no** consideran `is_acting_barber`.
Decidir caso por caso si un acting barber debe contar:

| Función | ¿Debería aceptar acting? | Por qué |
|---|---|---|
| **`_finalize_booking`** | **SÍ (crítico)** | Es el bug principal: bloquea reservar/walk-in. |
| `get_dashboard_kpis` | Probable SÍ | Para que las métricas/ganancias del acting barber se vean. |
| `get_commissions_report` | Probable SÍ | Para que el acting barber salga en comisiones. |
| `cancel_reservation_blindada` | Revisar | El admin acting cancela por la rama `tenant_admin`, así que quizá ya funciona; verificar que pueda cancelar SUS citas. |
| `handle_new_auth_user` | Probable NO | Trigger de alta; revisar que no rompa nada, pero no es del flujo de reserva. |

## 5. Contexto del modelo

- Un **"acting barber"** = perfil con `profiles.role = 'tenant_admin'` (u otro admin)
  **y** `profiles.is_acting_barber = true`. O sea: un dueño/gerente que también corta.
  No es `role = 'barber'`, por eso los checks `role = 'barber'` lo excluyen.
- Caso real: el perfil `e51e7fc3-8421-4520-a8a6-867ac7b5d2e2` ("Adrián Barbero",
  tenant Barbería Ocean, `role='tenant_admin'`, `is_acting_barber=true`,
  branch "Sede Principal" `e7280f80-...`). Hoy NO se le puede agendar.

## 6. Cómo verificar el fix

1. Aplicar el cambio a `_finalize_booking`.
2. Probar `create_anonymous_booking(tenant=Ocean, branch=Sede Principal,
   barber=Adrián(e51e7fc3...), service=<activo>, start_time=futuro, ...)` →
   debe devolver `reservationId` (antes lanzaba `barber_not_in_branch`).
3. Confirmar que un `role='barber'` normal sigue funcionando (no regresión).
4. (Opcional) repetir para `get_dashboard_kpis` / `get_commissions_report` y validar
   que el acting barber aparece con sus números.
