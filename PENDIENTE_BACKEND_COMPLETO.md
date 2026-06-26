# Pendientes de backend — Resumen completo para Chavez

> Proyecto Supabase: `uqhszqujcsmlmubeynfp` (Postgres 17.6, sa-east-1)
> Actualizado: 2026-06-25
> La app movil ya esta adaptada y reacciona automaticamente a estos datos.

---

## URGENTE — La app no funciona bien sin esto

### 1. La SEDE no aparece en las citas del cliente

**Donde se ve:** Perfil > Citas Programadas > la tarjeta de cada cita dice
"Sede no disponible" en vez del nombre real de la sucursal.

**Causa:** la RPC `get_my_reservations` no hace JOIN a `branches`.

**Que hacer:** editar `get_my_reservations` para que devuelva estos 3 campos
en cada cita (tanto `upcoming` como `recent`):

```sql
-- Agregar en el jsonb_build_object:
'branchName',    b.name,
'branchId',      b.id,
'branchAddress', b.address_line

-- Agregar el JOIN:
LEFT JOIN branches b ON b.id = r.branch_id
```

| Campo JSON | Origen |
|---|---|
| `branchName` | `branches.name` |
| `branchId` | `branches.id` |
| `branchAddress` | `branches.address_line` |

---

### 2. URL del mapa de cada sucursal

**Donde se ve:** la app podria mostrar un boton "Como llegar" en cada cita,
pero la tabla `branches` no tiene columna para el link de Google Maps.

**Que hacer:**

```sql
ALTER TABLE branches ADD COLUMN maps_url text;
```

Luego llenar `maps_url` de cada sucursal con su link de Google Maps y
devolverlo en `get_my_reservations` como `branchMapsUrl`:

```sql
'branchMapsUrl', b.maps_url
```

---

## IMPORTANTE — Features que no funcionan sin backend

### 3. Datos de pago del negocio (Yape, BCP, etc.)

**Donde se ve:** cuando un cliente quiere pagar un pedido con Yape o BCP,
la app dice "Yape no configurado" / "BCP no configurado" porque no hay
donde guardar los datos de pago del negocio.

**Que hacer:** crear una forma de guardar los datos de pago por tenant.
Opcion recomendada: agregar un campo JSONB en `tenants.branding` o crear
una tabla `tenant_payment_methods`:

```sql
-- Opcion A: en tenants.branding (mas simple)
-- Agregar en el JSONB branding:
{
  "payment": {
    "yape": {
      "phone": "987654321",
      "holder": "Carlos Perez"
    },
    "bcp": {
      "account": "191-12345678-0-01",
      "holder": "Carlos Perez"
    }
  }
}

-- Opcion B: tabla dedicada (mas escalable)
CREATE TABLE tenant_payment_methods (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id uuid REFERENCES tenants(id) NOT NULL,
  method text NOT NULL,           -- 'yape', 'bcp', 'plin', etc.
  holder_name text,
  account_number text,
  phone text,
  qr_url text,                    -- URL de imagen QR (opcional)
  active boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);
```

La app necesita una RPC o query que devuelva los metodos de pago del tenant
para mostrar el QR, numero de cuenta, titular, etc.

---

### 4. WhatsApp y contacto de soporte

**Donde se ve:** Perfil > Configuracion > Soporte > "Contactar por WhatsApp"
dice "No configurado aun". Lo mismo "Reportar un problema".

**Que hacer:** guardar los numeros de contacto de soporte. Puede ir en
`tenants.branding.contact` (que ya existe) o agregar campos:

```json
{
  "contact": {
    "phone": "51987654321",
    "email": "soporte@barberia.com",
    "address_line": "Av. Principal 123",
    "whatsapp_support": "51987654321",
    "whatsapp_sales": "51999888777",
    "support_email": "soporte@trimflow.app",
    "complaints_email": "reclamos@trimflow.app"
  }
}
```

La app leeria estos campos de `tenants.branding.contact` para armar los
links de WhatsApp y correo.

---

### 5. Contenido del Home (hero, stories, productos)

**Donde se ve:** Inicio (tab principal del cliente). El hero, stories,
seccion "Sobre Nosotros" y productos destacados aparecen vacios porque
se eliminaron los datos de prueba.

**Que hacer:** crear una tabla o JSONB donde el admin del negocio pueda
configurar el contenido de su pagina de inicio:

```sql
-- Opcion: agregar en tenants.branding o crear tabla aparte
-- La app espera este formato en HomeContent:
{
  "heroTitle": "Mi Barberia",
  "heroSubtitle": "La mejor experiencia",
  "heroImageUrl": "https://...",
  "heroTag1": "PREMIUM",
  "heroTag2": "STUDIO",
  "stories": [
    {"label": "Look 1", "image": "https://..."}
  ],
  "products": [
    {"name": "Pomada", "desc": "...", "price": "S/ 45", "img": "https://..."}
  ],
  "aboutUsTitle": "Sobre Nosotros",
  "aboutUsText": "...",
  "aboutUsImageUrl": "https://...",
  "locations": [
    {"label": "Sede Central", "address": "...", "mapUrl": "https://maps..."}
  ]
}
```

**Nota:** los SERVICIOS del Home ya vienen del catalogo real (tabla
`services`). Solo falta el contenido editorial (hero, stories, productos,
about us).

---

### 6. Historico de ingresos multi-dia (grafico del barbero)

**Donde se ve:** App Barbero > Historial > grafico "INGRESOS 7 DIAS".
Solo muestra el ingreso de hoy (los 6 dias anteriores estan en cero).

**Que hacer:** crear una RPC que devuelva los ingresos por dia de los
ultimos 7 dias para el barbero actual:

```sql
-- Ejemplo:
SELECT
  date_trunc('day', r.start_at) AS day,
  SUM(r.price_at_booking) AS total
FROM reservations r
WHERE r.barber_id = p_barber_id
  AND r.status = 'completed'
  AND r.start_at >= now() - interval '7 days'
GROUP BY 1
ORDER BY 1;
```

---

### 7. Catalogo de productos (tienda completa)

**Donde se ve:** Tab "Tienda" del cliente. Toda la tienda (productos,
carrito, pedidos, ofertas) funciona con datos en memoria que se pierden
al cerrar la app.

**Que hacer:** crear tablas para productos y pedidos:

```sql
-- Productos del tenant
CREATE TABLE tenant_products (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id uuid REFERENCES tenants(id) NOT NULL,
  name text NOT NULL,
  description text,
  price numeric(10,2) NOT NULL,
  image_url text,
  category text,
  active boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

-- Pedidos de clientes
CREATE TABLE product_orders (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id uuid REFERENCES tenants(id) NOT NULL,
  customer_id uuid REFERENCES customers(id),
  branch_id uuid REFERENCES branches(id),
  status text DEFAULT 'pending',  -- pending, paid, ready, completed, cancelled
  payment_method text,
  total numeric(10,2),
  created_at timestamptz DEFAULT now()
);

-- Items del pedido
CREATE TABLE product_order_items (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  order_id uuid REFERENCES product_orders(id) NOT NULL,
  product_id uuid REFERENCES tenant_products(id) NOT NULL,
  quantity int NOT NULL DEFAULT 1,
  unit_price numeric(10,2) NOT NULL
);
```

---

### 8. Permisos del barbero (panel admin)

**Donde se ve:** Admin > Staff > permisos de cada barbero. Los permisos
se guardan en el celular del admin (SharedPreferences), no en el servidor.

**Que hacer:** crear tabla de permisos o agregar columna JSONB en `profiles`:

```sql
-- Opcion simple: JSONB en profiles
ALTER TABLE profiles ADD COLUMN permissions jsonb DEFAULT '{}';
-- Ejemplo: {"can_view_cash": true, "can_manage_promotions": false, ...}
```

---

## OPCIONAL

### 9. Codigo de acceso numerico

El `access_code` actual es alfanumerico (ej. `TRF-KS0E-3YN8`). Si se
quiere numerico, cambiar el generador para que use solo digitos.

---

## Resumen de prioridades

| # | Que | Urgencia | Impacto |
|---|---|---|---|
| 1 | Sede en `get_my_reservations` (JOIN branches) | URGENTE | La cita dice "Sede no disponible" |
| 2 | `maps_url` en `branches` | ALTA | Sin boton "Como llegar" |
| 3 | Datos de pago por tenant (Yape/BCP) | ALTA | Pagos dicen "no configurado" |
| 4 | WhatsApp/contacto de soporte | MEDIA | Soporte dice "no configurado" |
| 5 | Contenido Home (hero, stories, about) | MEDIA | Home vacio sin contenido editorial |
| 6 | Historico ingresos 7 dias | MEDIA | Grafico solo muestra hoy |
| 7 | Catalogo de productos + pedidos | BAJA | Toda la tienda es local |
| 8 | Permisos barbero en BD | BAJA | Permisos solo viven en el celular |
| 9 | Codigo numerico | OPCIONAL | Funciona con alfanumerico |

---

**Infraestructura que YA existe y funciona:**
- Reservaciones (crear, cancelar, completar) via RPCs
- Catalogo (servicios, barberos, sucursales) via tablas
- Galeria (fotos con Supabase Storage)
- Reviews (calificar citas completadas) via RPCs
- Agenda barbero (realtime) via Postgres streaming
- Perfil (crear, editar, avatar) via RPCs
- Admin dashboard (KPIs, caja, comisiones) via RPCs
- Colores/branding del tenant via `tenants.branding` JSONB
