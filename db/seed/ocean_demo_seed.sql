-- ============================================================================
-- TrimFlow · Parte B · Datos demo EXAGERADOS para Barbería Ocean
-- ----------------------------------------------------------------------------
-- Pega TODO esto en el SQL Editor de Supabase y dale "Run".
-- Es seguro: si ya se sembró, no duplica nada (sale solo).
-- No toca migraciones ni datos de otros tenants. Solo agrega datos a Ocean.
--
-- Crea: 5 sucursales, 10 barberos, 20 clientes, ~57 reservas (pasadas+futuras),
--       4 promociones y ~14 cupones. Asigna reservas/cupones a TU barbero
--       (Adrián) y a TU cliente (Abel) para que veas datos en ambas apps.
-- ============================================================================

do $$
declare
  v_tenant    uuid := '06360503-c8c4-49cc-b81f-43f8665a1fec'; -- Barbería Ocean
  v_adrian    uuid := 'e51e7fc3-8421-4520-a8a6-867ac7b5d2e2'; -- tu barbero
  v_abel      uuid := 'f073087e-2ca4-448b-a791-58d9387bb3bd'; -- tu cliente

  v_branches  uuid[];
  v_services  uuid[];
  v_svc_price numeric[];
  v_barbers   uuid[];   -- 10 nuevos + Adrián al final
  v_customers uuid[];   -- 20 nuevos + Abel al final
  v_promos    uuid[];

  v_uid    uuid;
  v_branch uuid;
  v_barber uuid;
  v_cust   uuid;
  v_svc    uuid;
  v_price  numeric;
  v_start  timestamptz;
  v_status text;
  i        int;
  rec      record;
begin
  -- Idempotencia: si ya existe la primera sucursal demo, no repetir
  if exists (select 1 from branches where tenant_id = v_tenant and slug = 'ocean-miraflores') then
    raise notice 'Datos demo de Ocean ya existen. No se vuelve a sembrar.';
    return;
  end if;

  -- 1) SUCURSALES (5)
  with ins as (
    insert into branches (tenant_id, name, slug, address_line, timezone, display_order) values
      (v_tenant,'Ocean Miraflores','ocean-miraflores','Av. Larco 345, Miraflores','America/Lima',1),
      (v_tenant,'Ocean Los Olivos','ocean-los-olivos','Av. Universitaria 1200, Los Olivos','America/Lima',2),
      (v_tenant,'Ocean Surco','ocean-surco','Av. Benavides 2100, Surco','America/Lima',3),
      (v_tenant,'Ocean La Molina','ocean-la-molina','Av. La Molina 500, La Molina','America/Lima',4),
      (v_tenant,'Ocean Centro','ocean-centro','Jr. de la Union 800, Cercado de Lima','America/Lima',5)
    returning id, display_order
  )
  select array_agg(id order by display_order) into v_branches from ins;

  -- 2) SERVICIOS (10)
  with ins as (
    insert into services (tenant_id, name, description, duration_minutes, price_pen,
                          commission_type, commission_value, is_featured, is_active, display_order) values
      (v_tenant,'Corte Clasico','Corte a tijera y maquina',30,35,'percentage',40,true,true,1),
      (v_tenant,'Corte + Barba','Corte completo con perfilado de barba',45,55,'percentage',40,true,true,2),
      (v_tenant,'Barba Premium','Perfilado con toalla caliente',20,25,'percentage',40,false,true,3),
      (v_tenant,'Fade / Degradado','Degradado profesional',40,45,'percentage',40,true,true,4),
      (v_tenant,'Diseno / Lineas','Lineas y disenos personalizados',25,30,'percentage',40,false,true,5),
      (v_tenant,'Corte Nino','Corte para ninos',25,25,'percentage',40,false,true,6),
      (v_tenant,'Platinado','Decoloracion y matiz',90,120,'percentage',35,false,true,7),
      (v_tenant,'Facial Express','Limpieza facial',20,30,'percentage',40,false,true,8),
      (v_tenant,'Ritual Premium','Corte + barba + facial + bebida',75,99,'percentage',35,true,true,9),
      (v_tenant,'Cejas','Perfilado de cejas',10,15,'percentage',40,false,true,10)
    returning id, price_pen, display_order
  )
  select array_agg(id order by display_order),
         array_agg(price_pen order by display_order)
  into v_services, v_svc_price
  from ins;

  -- 3) BARBEROS (10) via auth.users -> el trigger handle_new_auth_user crea el profile
  for rec in
    select * from (values
      (1,'Marco Salas','Especialista en fades','987100101'),
      (2,'Diego Ramos','Barbas y disenos','987100102'),
      (3,'Luis Quispe','Cortes clasicos','987100103'),
      (4,'Jorge Nunez','Color y platinados','987100104'),
      (5,'Andres Vega','Cortes modernos','987100105'),
      (6,'Piero Castro','Fade y lineas','987100106'),
      (7,'Renzo Flores','Estilo ejecutivo','987100107'),
      (8,'Bruno Diaz','Barba premium','987100108'),
      (9,'Ivan Soto','Cortes urbanos','987100109'),
      (10,'Hugo Leon','Todo terreno','987100110')
    ) as b(n, full_name, specialty, phone)
  loop
    v_uid    := gen_random_uuid();
    v_branch := v_branches[1 + ((rec.n - 1) % array_length(v_branches,1))];
    insert into auth.users (id, instance_id, aud, role, email,
                            email_confirmed_at, created_at, updated_at,
                            raw_app_meta_data, raw_user_meta_data)
    values (
      v_uid,
      '00000000-0000-0000-0000-000000000000',
      'authenticated','authenticated',
      'seed.barber.' || rec.n || '@ocean.test',
      now(), now(), now(),
      jsonb_build_object(
        'provider','email','providers', jsonb_build_array('email'),
        'user_type','staff','role','barber',
        'tenant_id', v_tenant::text,
        'branch_id', v_branch::text
      ),
      jsonb_build_object('full_name', rec.full_name)
    );
    update profiles
       set specialty = rec.specialty,
           phone     = rec.phone,
           hired_at  = (current_date - (rec.n * 37))
     where id = v_uid;
    v_barbers := array_append(v_barbers, v_uid);
  end loop;

  -- Adrian al final del pool (para asignarle reservas)
  v_barbers := array_append(v_barbers, v_adrian);

  -- 4) CLIENTES (20)
  with ins as (
    insert into customers (tenant_id, full_name, whatsapp, email, birth_date, points, is_app_user, last_visit_at)
    select
      v_tenant,
      n.full_name,
      '+519' || lpad((87200000 + n.g)::text, 8, '0'),
      'cliente' || n.g || '@correo.com',
      (date '1990-01-01' + (n.g * 97)),
      (n.g % 6),
      false,
      case when n.g % 3 = 0 then now() - (n.g || ' days')::interval else null end
    from (values
      (1,'Mateo Rojas'),(2,'Sergio Pinto'),(3,'Alvaro Mejia'),(4,'Nicolas Rios'),
      (5,'Fabian Cano'),(6,'Gabriel Luna'),(7,'Tomas Vera'),(8,'Emilio Paz'),
      (9,'Rodrigo Naupa'),(10,'Joaquin Vidal'),(11,'Samuel Ortiz'),(12,'Daniel Lara'),
      (13,'Cristian Lazo'),(14,'Manuel Sosa'),(15,'Felipe Arce'),(16,'Oscar Ruiz'),
      (17,'Pablo Ferrer'),(18,'Adrian Mora'),(19,'Vicente Gil'),(20,'Martin Acosta')
    ) as n(g, full_name)
    returning id
  )
  select array_agg(id) into v_customers from ins;

  -- Abel al final del pool
  v_customers := array_append(v_customers, v_abel);

  -- 5) RESERVAS
  -- 5a) Pasadas (completadas / canceladas / no_show). Estas no chocan con la regla de solapamiento.
  for i in 1..45 loop
    v_barber := v_barbers[1 + (i % array_length(v_barbers,1))];
    v_cust   := v_customers[1 + (i % array_length(v_customers,1))];
    v_svc    := v_services[1 + (i % 10)];
    v_price  := v_svc_price[1 + (i % 10)];
    v_start  := date_trunc('hour', now())
                  - ((1 + (i % 12)) || ' days')::interval
                  - ((i % 9) || ' hours')::interval;
    if    i % 9 = 0 then v_status := 'no_show';
    elsif i % 5 = 0 then v_status := 'cancelled';
    else                 v_status := 'completed';
    end if;
    insert into reservations (tenant_id, barber_id, customer_id, service_id, start_time, status, channel, price_at_booking)
    values (v_tenant, v_barber, v_cust, v_svc, v_start, v_status,
            (array['walk_in','whatsapp','web','mobile_app'])[1 + (i % 4)], v_price);
  end loop;

  -- 5b) Futuras CONFIRMADAS (manana). Una por barbero -> nunca se solapan.
  for i in 0..(array_length(v_barbers,1) - 1) loop
    v_barber := v_barbers[i + 1];
    v_cust   := v_customers[1 + (i % array_length(v_customers,1))];
    v_svc    := v_services[1 + (i % 10)];
    v_price  := v_svc_price[1 + (i % 10)];
    v_start  := date_trunc('day', now()) + interval '1 day' + ((9 + i) || ' hours')::interval;
    insert into reservations (tenant_id, barber_id, customer_id, service_id, start_time, status, channel, price_at_booking)
    values (v_tenant, v_barber, v_cust, v_svc, v_start, 'confirmed', 'mobile_app', v_price);
  end loop;

  -- 5c) Futuras PENDIENTES (en 3 dias). Primeros 6 barberos, otro dia -> sin solape.
  for i in 0..5 loop
    v_barber := v_barbers[i + 1];
    v_cust   := v_customers[1 + ((i + 7) % array_length(v_customers,1))];
    v_svc    := v_services[1 + ((i + 3) % 10)];
    v_price  := v_svc_price[1 + ((i + 3) % 10)];
    v_start  := date_trunc('day', now()) + interval '3 days' + ((10 + i) || ' hours')::interval;
    insert into reservations (tenant_id, barber_id, customer_id, service_id, start_time, status, channel, price_at_booking)
    values (v_tenant, v_barber, v_cust, v_svc, v_start, 'pending', 'web', v_price);
  end loop;

  -- 5d) Reservas de TU cliente (Abel) con TU barbero (Adrian)
  -- Pasadas completadas:
  for i in 1..4 loop
    v_svc   := v_services[1 + (i % 10)];
    v_price := v_svc_price[1 + (i % 10)];
    v_start := date_trunc('hour', now()) - ((i * 6) || ' days')::interval - interval '3 hours';
    insert into reservations (tenant_id, barber_id, customer_id, service_id, start_time, status, channel, price_at_booking)
    values (v_tenant, v_adrian, v_abel, v_svc, v_start, 'completed', 'mobile_app', v_price);
  end loop;
  -- Futuras (dia +2 confirmada y dia +4 pendiente; dias distintos a la de Adrian en 5b):
  insert into reservations (tenant_id, barber_id, customer_id, service_id, start_time, status, channel, price_at_booking)
  values (v_tenant, v_adrian, v_abel, v_services[2],
          date_trunc('day', now()) + interval '2 days' + interval '11 hours', 'confirmed', 'mobile_app', v_svc_price[2]);
  insert into reservations (tenant_id, barber_id, customer_id, service_id, start_time, status, channel, price_at_booking)
  values (v_tenant, v_adrian, v_abel, v_services[9],
          date_trunc('day', now()) + interval '4 days' + interval '16 hours', 'pending', 'mobile_app', v_svc_price[9]);

  -- 6) PROMOCIONES (4)
  with ins as (
    insert into promotions (tenant_id, code, name, description, discount_type, discount_value,
                            trigger_type, is_active, is_app_only, days_before_birthday, days_after_birthday, valid_until) values
      (v_tenant,'OCEAN10','Bienvenida 10%','10% en tu primer corte','percentage',10,'manual',true,false,0,7, now() + interval '120 days'),
      (v_tenant,'CUMPLE20','Cumpleanos 20%','Regalo en tu mes','percentage',20,'birthday',true,false,7,7, null),
      (v_tenant,'VUELVE15','Te extranamos S/15','Vuelve y ahorra','fixed',15,'inactivity_15d',true,false,0,7, now() + interval '120 days'),
      (v_tenant,'RITUAL25','Ritual 25%','25% en Ritual Premium','percentage',25,'manual',true,true,0,7, now() + interval '60 days')
    returning id, code
  )
  select array_agg(id order by code) into v_promos from ins;

  -- 7) CUPONES (12 + 2 de Abel). El trigger genera el codigo y la validez.
  for i in 0..11 loop
    insert into customer_coupons (tenant_id, customer_id, promotion_id, channel_emitted)
    values (v_tenant, v_customers[1 + (i % array_length(v_customers,1))], v_promos[1 + (i % 4)], 'system');
  end loop;
  insert into customer_coupons (tenant_id, customer_id, promotion_id, channel_emitted)
  values (v_tenant, v_abel, v_promos[1], 'system');
  insert into customer_coupons (tenant_id, customer_id, promotion_id, channel_emitted)
  values (v_tenant, v_abel, v_promos[2], 'system');

  raise notice 'OK: Ocean sembrado (5 sucursales, 10 barberos, 20 clientes, ~57 reservas, 4 promos, 14 cupones).';
end $$;
