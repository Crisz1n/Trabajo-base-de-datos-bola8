-- ============================================================
--  Script SQL: Sistema Empresa de Buses — Versión Final + CASCADE
--  ON DELETE CASCADE ON UPDATE CASCADE en todas las FK
--
--  Cambios respecto a versión anterior:
--    · RUTA ya NO tiene distancia_km ni duracion_estimada
--    · CIUDAD solo tiene id_ciudad y nombre (FK a REGION por relación)
--    · Se incluye tabla COMUNA con todas las comunas de Chile
--
--  Contenido geográfico:
--    16 Regiones | 56 Provincias (CIUDAD) | 348 Comunas
-- ============================================================

-- ============================================================
-- LIMPIEZA PREVIA (evita errores si las tablas ya existen)
-- Elimina en orden inverso respetando las FK
-- ============================================================
DROP TABLE IF EXISTS PASAJE          CASCADE;
DROP TABLE IF EXISTS COMPRA          CASCADE;
DROP TABLE IF EXISTS CUENTA_USUARIO  CASCADE;
DROP TABLE IF EXISTS PASAJERO        CASCADE;
DROP TABLE IF EXISTS VIAJE           CASCADE;
DROP TABLE IF EXISTS RUTA            CASCADE;
DROP TABLE IF EXISTS ASIENTO         CASCADE;
DROP TABLE IF EXISTS BUS_2PISO       CASCADE;
DROP TABLE IF EXISTS BUS_1PISO       CASCADE;
DROP TABLE IF EXISTS TERMINAL        CASCADE;
DROP TABLE IF EXISTS COMUNA          CASCADE;
DROP TABLE IF EXISTS CIUDAD          CASCADE;
DROP TABLE IF EXISTS REGION          CASCADE;

-- ============================================================
-- 1. REGION  (16 regiones oficiales de Chile)
-- ============================================================
CREATE TABLE IF NOT EXISTS REGION (
    id_region   INT             NOT NULL,
    nombre      VARCHAR(100)    NOT NULL,
    CONSTRAINT pk_region PRIMARY KEY (id_region)
);

INSERT INTO REGION (id_region, nombre) VALUES
    (1, 'Arica y Parinacota'),
    (2, 'Tarapacá'),
    (3, 'Antofagasta'),
    (4, 'Atacama'),
    (5, 'Coquimbo'),
    (6, 'Valparaíso'),
    (7, 'Metropolitana de Santiago'),
    (8, 'O''Higgins'),
    (9, 'Maule'),
    (10, 'Ñuble'),
    (11, 'Biobío'),
    (12, 'La Araucanía'),
    (13, 'Los Ríos'),
    (14, 'Los Lagos'),
    (15, 'Aysén del Gral. Carlos Ibáñez del Campo'),
    (16, 'Magallanes y Antártica Chilena')
ON CONFLICT DO NOTHING;

-- ============================================================
-- 2. CIUDAD  (provincias de Chile — 56 nodos geográficos)
--    Atributos según ER: id_ciudad, nombre
--    FK a REGION por relación 'contiene'
-- ============================================================
CREATE TABLE IF NOT EXISTS CIUDAD (
    id_ciudad   SERIAL          NOT NULL,
    nombre      VARCHAR(100)    NOT NULL,
    id_region   INT             NOT NULL,
    CONSTRAINT pk_ciudad PRIMARY KEY (id_ciudad),
    CONSTRAINT fk_ciudad_region FOREIGN KEY (id_region)
        REFERENCES REGION(id_region)
        ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO CIUDAD (nombre, id_region) VALUES
    ('Arica', 1),
    ('Parinacota', 1),
    ('Iquique', 2),
    ('Tamarugal', 2),
    ('Antofagasta', 3),
    ('El Loa', 3),
    ('Tocopilla', 3),
    ('Copiapó', 4),
    ('Chañaral', 4),
    ('Huasco', 4),
    ('Elqui', 5),
    ('Choapa', 5),
    ('Limarí', 5),
    ('Valparaíso', 6),
    ('Isla de Pascua', 6),
    ('Los Andes', 6),
    ('Petorca', 6),
    ('Quillota', 6),
    ('San Antonio', 6),
    ('San Felipe de Aconcagua', 6),
    ('Marga Marga', 6),
    ('Santiago', 7),
    ('Cordillera', 7),
    ('Chacabuco', 7),
    ('Maipo', 7),
    ('Melipilla', 7),
    ('Talagante', 7),
    ('Cachapoal', 8),
    ('Cardenal Caro', 8),
    ('Colchagua', 8),
    ('Talca', 9),
    ('Cauquenes', 9),
    ('Curicó', 9),
    ('Linares', 9),
    ('Diguillín', 10),
    ('Itata', 10),
    ('Punilla', 10),
    ('Concepción', 11),
    ('Arauco', 11),
    ('Biobío', 11),
    ('Cautín', 12),
    ('Malleco', 12),
    ('Valdivia', 13),
    ('Ranco', 13),
    ('Llanquihue', 14),
    ('Chiloé', 14),
    ('Osorno', 14),
    ('Palena', 14),
    ('Coyhaique', 15),
    ('Aysén', 15),
    ('Capitán Prat', 15),
    ('General Carrera', 15),
    ('Magallanes', 16),
    ('Antártica Chilena', 16),
    ('Tierra del Fuego', 16),
    ('Última Esperanza', 16)
ON CONFLICT DO NOTHING;

-- ============================================================
-- 3. COMUNA  (todas las comunas de Chile — ~348 registros)
--    Tabla adicional no en ER original, necesaria para
--    representar la división político-administrativa completa
-- ============================================================
CREATE TABLE IF NOT EXISTS COMUNA (
    id_comuna   SERIAL          NOT NULL,
    nombre      VARCHAR(150)    NOT NULL,
    id_ciudad   INT             NOT NULL,
    CONSTRAINT pk_comuna PRIMARY KEY (id_comuna),
    CONSTRAINT fk_comuna_ciudad FOREIGN KEY (id_ciudad)
        REFERENCES CIUDAD(id_ciudad)
        ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO COMUNA (nombre, id_ciudad) VALUES
    ('Arica', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Arica' AND id_region = 1 LIMIT 1)),
    ('Camarones', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Arica' AND id_region = 1 LIMIT 1)),
    ('Putre', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Parinacota' AND id_region = 1 LIMIT 1)),
    ('General Lagos', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Parinacota' AND id_region = 1 LIMIT 1)),
    ('Iquique', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Iquique' AND id_region = 2 LIMIT 1)),
    ('Alto Hospicio', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Iquique' AND id_region = 2 LIMIT 1)),
    ('Pozo Almonte', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Tamarugal' AND id_region = 2 LIMIT 1)),
    ('Camiña', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Tamarugal' AND id_region = 2 LIMIT 1)),
    ('Colchane', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Tamarugal' AND id_region = 2 LIMIT 1)),
    ('Huara', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Tamarugal' AND id_region = 2 LIMIT 1)),
    ('Pica', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Tamarugal' AND id_region = 2 LIMIT 1)),
    ('Antofagasta', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Antofagasta' AND id_region = 3 LIMIT 1)),
    ('Mejillones', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Antofagasta' AND id_region = 3 LIMIT 1)),
    ('Sierra Gorda', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Antofagasta' AND id_region = 3 LIMIT 1)),
    ('Taltal', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Antofagasta' AND id_region = 3 LIMIT 1)),
    ('Calama', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'El Loa' AND id_region = 3 LIMIT 1)),
    ('Ollagüe', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'El Loa' AND id_region = 3 LIMIT 1)),
    ('San Pedro de Atacama', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'El Loa' AND id_region = 3 LIMIT 1)),
    ('Tocopilla', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Tocopilla' AND id_region = 3 LIMIT 1)),
    ('María Elena', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Tocopilla' AND id_region = 3 LIMIT 1)),
    ('Copiapó', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Copiapó' AND id_region = 4 LIMIT 1)),
    ('Caldera', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Copiapó' AND id_region = 4 LIMIT 1)),
    ('Tierra Amarilla', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Copiapó' AND id_region = 4 LIMIT 1)),
    ('Chañaral', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Chañaral' AND id_region = 4 LIMIT 1)),
    ('Diego de Almagro', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Chañaral' AND id_region = 4 LIMIT 1)),
    ('Vallenar', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Huasco' AND id_region = 4 LIMIT 1)),
    ('Alto del Carmen', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Huasco' AND id_region = 4 LIMIT 1)),
    ('Freirina', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Huasco' AND id_region = 4 LIMIT 1)),
    ('Huasco', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Huasco' AND id_region = 4 LIMIT 1)),
    ('La Serena', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Elqui' AND id_region = 5 LIMIT 1)),
    ('Coquimbo', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Elqui' AND id_region = 5 LIMIT 1)),
    ('Andacollo', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Elqui' AND id_region = 5 LIMIT 1)),
    ('La Higuera', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Elqui' AND id_region = 5 LIMIT 1)),
    ('Paiguano', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Elqui' AND id_region = 5 LIMIT 1)),
    ('Vicuña', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Elqui' AND id_region = 5 LIMIT 1)),
    ('Illapel', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Choapa' AND id_region = 5 LIMIT 1)),
    ('Canela', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Choapa' AND id_region = 5 LIMIT 1)),
    ('Los Vilos', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Choapa' AND id_region = 5 LIMIT 1)),
    ('Salamanca', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Choapa' AND id_region = 5 LIMIT 1)),
    ('Ovalle', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Limarí' AND id_region = 5 LIMIT 1)),
    ('Combarbalá', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Limarí' AND id_region = 5 LIMIT 1)),
    ('Monte Patria', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Limarí' AND id_region = 5 LIMIT 1)),
    ('Punitaqui', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Limarí' AND id_region = 5 LIMIT 1)),
    ('Río Hurtado', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Limarí' AND id_region = 5 LIMIT 1)),
    ('Valparaíso', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Valparaíso' AND id_region = 6 LIMIT 1)),
    ('Casablanca', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Valparaíso' AND id_region = 6 LIMIT 1)),
    ('Concón', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Valparaíso' AND id_region = 6 LIMIT 1)),
    ('Juan Fernández', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Valparaíso' AND id_region = 6 LIMIT 1)),
    ('Puchuncaví', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Valparaíso' AND id_region = 6 LIMIT 1)),
    ('Quintero', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Valparaíso' AND id_region = 6 LIMIT 1)),
    ('Viña del Mar', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Valparaíso' AND id_region = 6 LIMIT 1)),
    ('Isla de Pascua', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Isla de Pascua' AND id_region = 6 LIMIT 1)),
    ('Los Andes', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Los Andes' AND id_region = 6 LIMIT 1)),
    ('Calle Larga', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Los Andes' AND id_region = 6 LIMIT 1)),
    ('Rinconada', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Los Andes' AND id_region = 6 LIMIT 1)),
    ('San Esteban', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Los Andes' AND id_region = 6 LIMIT 1)),
    ('La Ligua', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Petorca' AND id_region = 6 LIMIT 1)),
    ('Cabildo', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Petorca' AND id_region = 6 LIMIT 1)),
    ('Papudo', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Petorca' AND id_region = 6 LIMIT 1)),
    ('Petorca', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Petorca' AND id_region = 6 LIMIT 1)),
    ('Zapallar', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Petorca' AND id_region = 6 LIMIT 1)),
    ('Quillota', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Quillota' AND id_region = 6 LIMIT 1)),
    ('Calera', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Quillota' AND id_region = 6 LIMIT 1)),
    ('Hijuelas', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Quillota' AND id_region = 6 LIMIT 1)),
    ('La Cruz', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Quillota' AND id_region = 6 LIMIT 1)),
    ('Nogales', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Quillota' AND id_region = 6 LIMIT 1)),
    ('San Antonio', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'San Antonio' AND id_region = 6 LIMIT 1)),
    ('Algarrobo', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'San Antonio' AND id_region = 6 LIMIT 1)),
    ('Cartagena', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'San Antonio' AND id_region = 6 LIMIT 1)),
    ('El Quisco', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'San Antonio' AND id_region = 6 LIMIT 1)),
    ('El Tabo', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'San Antonio' AND id_region = 6 LIMIT 1)),
    ('Santo Domingo', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'San Antonio' AND id_region = 6 LIMIT 1)),
    ('San Felipe', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'San Felipe de Aconcagua' AND id_region = 6 LIMIT 1)),
    ('Catemu', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'San Felipe de Aconcagua' AND id_region = 6 LIMIT 1)),
    ('Llaillay', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'San Felipe de Aconcagua' AND id_region = 6 LIMIT 1)),
    ('Panquehue', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'San Felipe de Aconcagua' AND id_region = 6 LIMIT 1)),
    ('Putaendo', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'San Felipe de Aconcagua' AND id_region = 6 LIMIT 1)),
    ('Santa María', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'San Felipe de Aconcagua' AND id_region = 6 LIMIT 1)),
    ('Quilpué', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Marga Marga' AND id_region = 6 LIMIT 1)),
    ('Limache', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Marga Marga' AND id_region = 6 LIMIT 1)),
    ('Olmué', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Marga Marga' AND id_region = 6 LIMIT 1)),
    ('Villa Alemana', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Marga Marga' AND id_region = 6 LIMIT 1)),
    ('Santiago', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Santiago' AND id_region = 7 LIMIT 1)),
    ('Cerrillos', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Santiago' AND id_region = 7 LIMIT 1)),
    ('Cerro Navia', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Santiago' AND id_region = 7 LIMIT 1)),
    ('Conchalí', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Santiago' AND id_region = 7 LIMIT 1)),
    ('El Bosque', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Santiago' AND id_region = 7 LIMIT 1)),
    ('Estación Central', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Santiago' AND id_region = 7 LIMIT 1)),
    ('Huechuraba', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Santiago' AND id_region = 7 LIMIT 1)),
    ('Independencia', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Santiago' AND id_region = 7 LIMIT 1)),
    ('La Cisterna', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Santiago' AND id_region = 7 LIMIT 1)),
    ('La Florida', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Santiago' AND id_region = 7 LIMIT 1)),
    ('La Granja', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Santiago' AND id_region = 7 LIMIT 1)),
    ('La Pintana', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Santiago' AND id_region = 7 LIMIT 1)),
    ('La Reina', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Santiago' AND id_region = 7 LIMIT 1)),
    ('Las Condes', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Santiago' AND id_region = 7 LIMIT 1)),
    ('Lo Barnechea', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Santiago' AND id_region = 7 LIMIT 1)),
    ('Lo Espejo', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Santiago' AND id_region = 7 LIMIT 1)),
    ('Lo Prado', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Santiago' AND id_region = 7 LIMIT 1)),
    ('Macul', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Santiago' AND id_region = 7 LIMIT 1)),
    ('Maipú', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Santiago' AND id_region = 7 LIMIT 1)),
    ('Ñuñoa', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Santiago' AND id_region = 7 LIMIT 1)),
    ('Pedro Aguirre Cerda', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Santiago' AND id_region = 7 LIMIT 1)),
    ('Peñalolén', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Santiago' AND id_region = 7 LIMIT 1)),
    ('Providencia', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Santiago' AND id_region = 7 LIMIT 1)),
    ('Pudahuel', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Santiago' AND id_region = 7 LIMIT 1)),
    ('Quilicura', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Santiago' AND id_region = 7 LIMIT 1)),
    ('Quinta Normal', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Santiago' AND id_region = 7 LIMIT 1)),
    ('Recoleta', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Santiago' AND id_region = 7 LIMIT 1)),
    ('Renca', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Santiago' AND id_region = 7 LIMIT 1)),
    ('San Joaquín', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Santiago' AND id_region = 7 LIMIT 1)),
    ('San Miguel', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Santiago' AND id_region = 7 LIMIT 1)),
    ('San Ramón', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Santiago' AND id_region = 7 LIMIT 1)),
    ('Vitacura', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Santiago' AND id_region = 7 LIMIT 1)),
    ('Puente Alto', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Cordillera' AND id_region = 7 LIMIT 1)),
    ('Pirque', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Cordillera' AND id_region = 7 LIMIT 1)),
    ('San José de Maipo', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Cordillera' AND id_region = 7 LIMIT 1)),
    ('Colina', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Chacabuco' AND id_region = 7 LIMIT 1)),
    ('Lampa', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Chacabuco' AND id_region = 7 LIMIT 1)),
    ('Tiltil', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Chacabuco' AND id_region = 7 LIMIT 1)),
    ('San Bernardo', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Maipo' AND id_region = 7 LIMIT 1)),
    ('Buin', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Maipo' AND id_region = 7 LIMIT 1)),
    ('Calera de Tango', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Maipo' AND id_region = 7 LIMIT 1)),
    ('Paine', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Maipo' AND id_region = 7 LIMIT 1)),
    ('Melipilla', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Melipilla' AND id_region = 7 LIMIT 1)),
    ('Alhué', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Melipilla' AND id_region = 7 LIMIT 1)),
    ('Curacaví', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Melipilla' AND id_region = 7 LIMIT 1)),
    ('María Pinto', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Melipilla' AND id_region = 7 LIMIT 1)),
    ('San Pedro', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Melipilla' AND id_region = 7 LIMIT 1)),
    ('Talagante', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Talagante' AND id_region = 7 LIMIT 1)),
    ('El Monte', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Talagante' AND id_region = 7 LIMIT 1)),
    ('Isla de Maipo', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Talagante' AND id_region = 7 LIMIT 1)),
    ('Padre Hurtado', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Talagante' AND id_region = 7 LIMIT 1)),
    ('Peñaflor', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Talagante' AND id_region = 7 LIMIT 1)),
    ('Rancagua', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Cachapoal' AND id_region = 8 LIMIT 1)),
    ('Codegua', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Cachapoal' AND id_region = 8 LIMIT 1)),
    ('Coinco', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Cachapoal' AND id_region = 8 LIMIT 1)),
    ('Coltauco', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Cachapoal' AND id_region = 8 LIMIT 1)),
    ('Doñihue', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Cachapoal' AND id_region = 8 LIMIT 1)),
    ('Graneros', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Cachapoal' AND id_region = 8 LIMIT 1)),
    ('Las Cabras', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Cachapoal' AND id_region = 8 LIMIT 1)),
    ('Machalí', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Cachapoal' AND id_region = 8 LIMIT 1)),
    ('Malloa', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Cachapoal' AND id_region = 8 LIMIT 1)),
    ('Mostazal', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Cachapoal' AND id_region = 8 LIMIT 1)),
    ('Olivar', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Cachapoal' AND id_region = 8 LIMIT 1)),
    ('Peumo', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Cachapoal' AND id_region = 8 LIMIT 1)),
    ('Pichidegua', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Cachapoal' AND id_region = 8 LIMIT 1)),
    ('Quinta de Tilcoco', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Cachapoal' AND id_region = 8 LIMIT 1)),
    ('Rengo', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Cachapoal' AND id_region = 8 LIMIT 1)),
    ('Requínoa', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Cachapoal' AND id_region = 8 LIMIT 1)),
    ('San Vicente', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Cachapoal' AND id_region = 8 LIMIT 1)),
    ('Pichilemu', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Cardenal Caro' AND id_region = 8 LIMIT 1)),
    ('La Estrella', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Cardenal Caro' AND id_region = 8 LIMIT 1)),
    ('Litueche', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Cardenal Caro' AND id_region = 8 LIMIT 1)),
    ('Marchihue', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Cardenal Caro' AND id_region = 8 LIMIT 1)),
    ('Navidad', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Cardenal Caro' AND id_region = 8 LIMIT 1)),
    ('Paredones', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Cardenal Caro' AND id_region = 8 LIMIT 1)),
    ('San Fernando', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Colchagua' AND id_region = 8 LIMIT 1)),
    ('Chépica', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Colchagua' AND id_region = 8 LIMIT 1)),
    ('Chimbarongo', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Colchagua' AND id_region = 8 LIMIT 1)),
    ('Lolol', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Colchagua' AND id_region = 8 LIMIT 1)),
    ('Nancagua', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Colchagua' AND id_region = 8 LIMIT 1)),
    ('Palmilla', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Colchagua' AND id_region = 8 LIMIT 1)),
    ('Peralillo', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Colchagua' AND id_region = 8 LIMIT 1)),
    ('Placilla', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Colchagua' AND id_region = 8 LIMIT 1)),
    ('Pumanque', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Colchagua' AND id_region = 8 LIMIT 1)),
    ('Santa Cruz', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Colchagua' AND id_region = 8 LIMIT 1)),
    ('Talca', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Talca' AND id_region = 9 LIMIT 1)),
    ('Constitución', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Talca' AND id_region = 9 LIMIT 1)),
    ('Curepto', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Talca' AND id_region = 9 LIMIT 1)),
    ('Empedrado', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Talca' AND id_region = 9 LIMIT 1)),
    ('Maule', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Talca' AND id_region = 9 LIMIT 1)),
    ('Pelarco', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Talca' AND id_region = 9 LIMIT 1)),
    ('Pencahue', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Talca' AND id_region = 9 LIMIT 1)),
    ('Río Claro', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Talca' AND id_region = 9 LIMIT 1)),
    ('San Clemente', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Talca' AND id_region = 9 LIMIT 1)),
    ('San Rafael', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Talca' AND id_region = 9 LIMIT 1)),
    ('Cauquenes', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Cauquenes' AND id_region = 9 LIMIT 1)),
    ('Chanco', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Cauquenes' AND id_region = 9 LIMIT 1)),
    ('Pelluhue', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Cauquenes' AND id_region = 9 LIMIT 1)),
    ('Curicó', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Curicó' AND id_region = 9 LIMIT 1)),
    ('Hualañé', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Curicó' AND id_region = 9 LIMIT 1)),
    ('Licantén', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Curicó' AND id_region = 9 LIMIT 1)),
    ('Molina', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Curicó' AND id_region = 9 LIMIT 1)),
    ('Rauco', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Curicó' AND id_region = 9 LIMIT 1)),
    ('Romeral', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Curicó' AND id_region = 9 LIMIT 1)),
    ('Sagrada Familia', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Curicó' AND id_region = 9 LIMIT 1)),
    ('Teno', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Curicó' AND id_region = 9 LIMIT 1)),
    ('Vichuquén', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Curicó' AND id_region = 9 LIMIT 1)),
    ('Linares', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Linares' AND id_region = 9 LIMIT 1)),
    ('Colbún', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Linares' AND id_region = 9 LIMIT 1)),
    ('Longaví', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Linares' AND id_region = 9 LIMIT 1)),
    ('Parral', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Linares' AND id_region = 9 LIMIT 1)),
    ('Retiro', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Linares' AND id_region = 9 LIMIT 1)),
    ('San Javier', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Linares' AND id_region = 9 LIMIT 1)),
    ('Villa Alegre', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Linares' AND id_region = 9 LIMIT 1)),
    ('Yerbas Buenas', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Linares' AND id_region = 9 LIMIT 1)),
    ('Chillán', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Diguillín' AND id_region = 10 LIMIT 1)),
    ('Bulnes', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Diguillín' AND id_region = 10 LIMIT 1)),
    ('Chillán Viejo', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Diguillín' AND id_region = 10 LIMIT 1)),
    ('El Carmen', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Diguillín' AND id_region = 10 LIMIT 1)),
    ('Pemuco', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Diguillín' AND id_region = 10 LIMIT 1)),
    ('Pinto', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Diguillín' AND id_region = 10 LIMIT 1)),
    ('Quillón', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Diguillín' AND id_region = 10 LIMIT 1)),
    ('San Ignacio', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Diguillín' AND id_region = 10 LIMIT 1)),
    ('Yungay', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Diguillín' AND id_region = 10 LIMIT 1)),
    ('Coelemu', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Itata' AND id_region = 10 LIMIT 1)),
    ('Ninhue', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Itata' AND id_region = 10 LIMIT 1)),
    ('Portezuelo', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Itata' AND id_region = 10 LIMIT 1)),
    ('Quirihue', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Itata' AND id_region = 10 LIMIT 1)),
    ('Ránquil', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Itata' AND id_region = 10 LIMIT 1)),
    ('Trehuaco', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Itata' AND id_region = 10 LIMIT 1)),
    ('San Carlos', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Punilla' AND id_region = 10 LIMIT 1)),
    ('Coihueco', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Punilla' AND id_region = 10 LIMIT 1)),
    ('Ñiquén', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Punilla' AND id_region = 10 LIMIT 1)),
    ('San Fabián', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Punilla' AND id_region = 10 LIMIT 1)),
    ('San Nicolás', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Punilla' AND id_region = 10 LIMIT 1)),
    ('Concepción', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Concepción' AND id_region = 11 LIMIT 1)),
    ('Coronel', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Concepción' AND id_region = 11 LIMIT 1)),
    ('Chiguayante', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Concepción' AND id_region = 11 LIMIT 1)),
    ('Florida', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Concepción' AND id_region = 11 LIMIT 1)),
    ('Hualpén', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Concepción' AND id_region = 11 LIMIT 1)),
    ('Hualqui', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Concepción' AND id_region = 11 LIMIT 1)),
    ('Lota', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Concepción' AND id_region = 11 LIMIT 1)),
    ('Penco', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Concepción' AND id_region = 11 LIMIT 1)),
    ('San Pedro de la Paz', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Concepción' AND id_region = 11 LIMIT 1)),
    ('Santa Juana', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Concepción' AND id_region = 11 LIMIT 1)),
    ('Talcahuano', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Concepción' AND id_region = 11 LIMIT 1)),
    ('Tomé', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Concepción' AND id_region = 11 LIMIT 1)),
    ('Lebu', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Arauco' AND id_region = 11 LIMIT 1)),
    ('Arauco', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Arauco' AND id_region = 11 LIMIT 1)),
    ('Cañete', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Arauco' AND id_region = 11 LIMIT 1)),
    ('Contulmo', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Arauco' AND id_region = 11 LIMIT 1)),
    ('Curanilahue', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Arauco' AND id_region = 11 LIMIT 1)),
    ('Los Álamos', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Arauco' AND id_region = 11 LIMIT 1)),
    ('Tirúa', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Arauco' AND id_region = 11 LIMIT 1)),
    ('Los Ángeles', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Biobío' AND id_region = 11 LIMIT 1)),
    ('Antuco', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Biobío' AND id_region = 11 LIMIT 1)),
    ('Cabrero', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Biobío' AND id_region = 11 LIMIT 1)),
    ('Laja', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Biobío' AND id_region = 11 LIMIT 1)),
    ('Mulchén', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Biobío' AND id_region = 11 LIMIT 1)),
    ('Nacimiento', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Biobío' AND id_region = 11 LIMIT 1)),
    ('Negrete', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Biobío' AND id_region = 11 LIMIT 1)),
    ('Quilaco', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Biobío' AND id_region = 11 LIMIT 1)),
    ('Quilleco', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Biobío' AND id_region = 11 LIMIT 1)),
    ('San Rosendo', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Biobío' AND id_region = 11 LIMIT 1)),
    ('Santa Bárbara', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Biobío' AND id_region = 11 LIMIT 1)),
    ('Tucapel', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Biobío' AND id_region = 11 LIMIT 1)),
    ('Yumbel', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Biobío' AND id_region = 11 LIMIT 1)),
    ('Temuco', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Cautín' AND id_region = 12 LIMIT 1)),
    ('Carahue', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Cautín' AND id_region = 12 LIMIT 1)),
    ('Cunco', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Cautín' AND id_region = 12 LIMIT 1)),
    ('Curarrehue', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Cautín' AND id_region = 12 LIMIT 1)),
    ('Freire', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Cautín' AND id_region = 12 LIMIT 1)),
    ('Galvarino', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Cautín' AND id_region = 12 LIMIT 1)),
    ('Gorbea', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Cautín' AND id_region = 12 LIMIT 1)),
    ('Lautaro', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Cautín' AND id_region = 12 LIMIT 1)),
    ('Loncoche', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Cautín' AND id_region = 12 LIMIT 1)),
    ('Melipeuco', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Cautín' AND id_region = 12 LIMIT 1)),
    ('Nueva Imperial', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Cautín' AND id_region = 12 LIMIT 1)),
    ('Padre Las Casas', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Cautín' AND id_region = 12 LIMIT 1)),
    ('Perquenco', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Cautín' AND id_region = 12 LIMIT 1)),
    ('Pitrufquén', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Cautín' AND id_region = 12 LIMIT 1)),
    ('Pucón', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Cautín' AND id_region = 12 LIMIT 1)),
    ('Saavedra', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Cautín' AND id_region = 12 LIMIT 1)),
    ('Teodoro Schmidt', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Cautín' AND id_region = 12 LIMIT 1)),
    ('Toltén', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Cautín' AND id_region = 12 LIMIT 1)),
    ('Vilcún', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Cautín' AND id_region = 12 LIMIT 1)),
    ('Villarrica', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Cautín' AND id_region = 12 LIMIT 1)),
    ('Cholchol', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Cautín' AND id_region = 12 LIMIT 1)),
    ('Angol', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Malleco' AND id_region = 12 LIMIT 1)),
    ('Collipulli', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Malleco' AND id_region = 12 LIMIT 1)),
    ('Curacautín', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Malleco' AND id_region = 12 LIMIT 1)),
    ('Ercilla', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Malleco' AND id_region = 12 LIMIT 1)),
    ('Lonquimay', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Malleco' AND id_region = 12 LIMIT 1)),
    ('Los Sauces', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Malleco' AND id_region = 12 LIMIT 1)),
    ('Lumaco', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Malleco' AND id_region = 12 LIMIT 1)),
    ('Purén', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Malleco' AND id_region = 12 LIMIT 1)),
    ('Renaico', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Malleco' AND id_region = 12 LIMIT 1)),
    ('Traiguén', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Malleco' AND id_region = 12 LIMIT 1)),
    ('Victoria', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Malleco' AND id_region = 12 LIMIT 1)),
    ('Valdivia', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Valdivia' AND id_region = 13 LIMIT 1)),
    ('Corral', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Valdivia' AND id_region = 13 LIMIT 1)),
    ('Futrono', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Valdivia' AND id_region = 13 LIMIT 1)),
    ('La Unión', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Valdivia' AND id_region = 13 LIMIT 1)),
    ('Lago Ranco', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Valdivia' AND id_region = 13 LIMIT 1)),
    ('Lanco', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Valdivia' AND id_region = 13 LIMIT 1)),
    ('Los Lagos', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Valdivia' AND id_region = 13 LIMIT 1)),
    ('Máfil', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Valdivia' AND id_region = 13 LIMIT 1)),
    ('Mariquina', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Valdivia' AND id_region = 13 LIMIT 1)),
    ('Paillaco', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Valdivia' AND id_region = 13 LIMIT 1)),
    ('Panguipulli', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Valdivia' AND id_region = 13 LIMIT 1)),
    ('Río Bueno', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Valdivia' AND id_region = 13 LIMIT 1)),
    ('La Unión', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Ranco' AND id_region = 13 LIMIT 1)),
    ('Futrono', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Ranco' AND id_region = 13 LIMIT 1)),
    ('Lago Ranco', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Ranco' AND id_region = 13 LIMIT 1)),
    ('Río Bueno', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Ranco' AND id_region = 13 LIMIT 1)),
    ('Puerto Montt', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Llanquihue' AND id_region = 14 LIMIT 1)),
    ('Calbuco', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Llanquihue' AND id_region = 14 LIMIT 1)),
    ('Cochamó', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Llanquihue' AND id_region = 14 LIMIT 1)),
    ('Fresia', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Llanquihue' AND id_region = 14 LIMIT 1)),
    ('Frutillar', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Llanquihue' AND id_region = 14 LIMIT 1)),
    ('Los Muermos', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Llanquihue' AND id_region = 14 LIMIT 1)),
    ('Llanquihue', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Llanquihue' AND id_region = 14 LIMIT 1)),
    ('Maullín', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Llanquihue' AND id_region = 14 LIMIT 1)),
    ('Puerto Varas', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Llanquihue' AND id_region = 14 LIMIT 1)),
    ('Castro', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Chiloé' AND id_region = 14 LIMIT 1)),
    ('Ancud', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Chiloé' AND id_region = 14 LIMIT 1)),
    ('Chonchi', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Chiloé' AND id_region = 14 LIMIT 1)),
    ('Curaco de Vélez', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Chiloé' AND id_region = 14 LIMIT 1)),
    ('Dalcahue', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Chiloé' AND id_region = 14 LIMIT 1)),
    ('Puqueldón', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Chiloé' AND id_region = 14 LIMIT 1)),
    ('Queilén', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Chiloé' AND id_region = 14 LIMIT 1)),
    ('Quellón', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Chiloé' AND id_region = 14 LIMIT 1)),
    ('Quemchi', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Chiloé' AND id_region = 14 LIMIT 1)),
    ('Quinchao', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Chiloé' AND id_region = 14 LIMIT 1)),
    ('Osorno', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Osorno' AND id_region = 14 LIMIT 1)),
    ('Puerto Octay', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Osorno' AND id_region = 14 LIMIT 1)),
    ('Purranque', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Osorno' AND id_region = 14 LIMIT 1)),
    ('Puyehue', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Osorno' AND id_region = 14 LIMIT 1)),
    ('Río Negro', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Osorno' AND id_region = 14 LIMIT 1)),
    ('San Juan de la Costa', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Osorno' AND id_region = 14 LIMIT 1)),
    ('San Pablo', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Osorno' AND id_region = 14 LIMIT 1)),
    ('Chaitén', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Palena' AND id_region = 14 LIMIT 1)),
    ('Futaleufú', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Palena' AND id_region = 14 LIMIT 1)),
    ('Hualaihué', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Palena' AND id_region = 14 LIMIT 1)),
    ('Palena', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Palena' AND id_region = 14 LIMIT 1)),
    ('Coyhaique', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Coyhaique' AND id_region = 15 LIMIT 1)),
    ('Lago Verde', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Coyhaique' AND id_region = 15 LIMIT 1)),
    ('Aysén', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Aysén' AND id_region = 15 LIMIT 1)),
    ('Cisnes', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Aysén' AND id_region = 15 LIMIT 1)),
    ('Guaitecas', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Aysén' AND id_region = 15 LIMIT 1)),
    ('Cochrane', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Capitán Prat' AND id_region = 15 LIMIT 1)),
    ('O''Higgins', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Capitán Prat' AND id_region = 15 LIMIT 1)),
    ('Tortel', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Capitán Prat' AND id_region = 15 LIMIT 1)),
    ('Chile Chico', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'General Carrera' AND id_region = 15 LIMIT 1)),
    ('Río Ibáñez', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'General Carrera' AND id_region = 15 LIMIT 1)),
    ('Punta Arenas', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Magallanes' AND id_region = 16 LIMIT 1)),
    ('Laguna Blanca', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Magallanes' AND id_region = 16 LIMIT 1)),
    ('Río Verde', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Magallanes' AND id_region = 16 LIMIT 1)),
    ('San Gregorio', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Magallanes' AND id_region = 16 LIMIT 1)),
    ('Cabo de Hornos', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Antártica Chilena' AND id_region = 16 LIMIT 1)),
    ('Antártica', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Antártica Chilena' AND id_region = 16 LIMIT 1)),
    ('Porvenir', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Tierra del Fuego' AND id_region = 16 LIMIT 1)),
    ('Primavera', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Tierra del Fuego' AND id_region = 16 LIMIT 1)),
    ('Timaukel', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Tierra del Fuego' AND id_region = 16 LIMIT 1)),
    ('Puerto Natales', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Última Esperanza' AND id_region = 16 LIMIT 1)),
    ('Torres del Paine', (SELECT id_ciudad FROM CIUDAD WHERE nombre = 'Última Esperanza' AND id_region = 16 LIMIT 1))
ON CONFLICT DO NOTHING;

-- ============================================================
-- 4. TERMINAL  (atributos según ER: ID_terminal, Nombre,
--               Dirección, Fk_ID_ciudad)
-- ============================================================
CREATE TABLE IF NOT EXISTS TERMINAL (
    id_terminal SERIAL          NOT NULL,
    nombre      VARCHAR(150)    NOT NULL,
    direccion   VARCHAR(255)    NOT NULL,
    id_ciudad   INT             NOT NULL,
    CONSTRAINT pk_terminal PRIMARY KEY (id_terminal),
    CONSTRAINT fk_terminal_ciudad FOREIGN KEY (id_ciudad)
        REFERENCES CIUDAD(id_ciudad)
        ON DELETE CASCADE ON UPDATE CASCADE
);

DO $$
DECLARE
    prefijos TEXT[] := ARRAY[
        'Terminal','Estación de Buses','Terminal Central',
        'Bus Terminal','Terminal Sur','Terminal Norte'
    ];
    calles TEXT[] := ARRAY[
        'Av. Bernardo O''Higgins','Calle Maipú','Av. Arturo Prat',
        'Calle Balmaceda','Av. España','Calle San Martín',
        'Av. Colón','Av. Bulnes','Calle Portales','Av. Argentina',
        'Av. Caupolican','Av. Alemania','Calle Freire'
    ];
    nums     INT[]  := ARRAY[100,200,350,480,520,640,750,810,920,1050,1120,1300,1450,1600];
    v_id     INT;
    v_nombre TEXT;
    i        INT;
BEGIN
    FOR i IN 1..30 LOOP
        SELECT id_ciudad, nombre INTO v_id, v_nombre
        FROM CIUDAD ORDER BY random() LIMIT 1;

        INSERT INTO TERMINAL (nombre, direccion, id_ciudad) VALUES (
            prefijos[1 + floor(random()*array_length(prefijos,1))::INT] || ' ' || v_nombre,
            calles[1 + floor(random()*array_length(calles,1))::INT]
                || ' ' || nums[1 + floor(random()*array_length(nums,1))::INT]::TEXT,
            v_id
        );
    END LOOP;
    RAISE NOTICE '✔ TERMINAL: 30 registros insertados.';
END;
$$;

-- ============================================================
-- 5. BUS_1PISO  (atributos: patente PK, modelo, marca, año,
--                total_asientos)
-- ============================================================
CREATE TABLE IF NOT EXISTS BUS_1PISO (
    patente         VARCHAR(10)     NOT NULL,
    modelo          VARCHAR(100)    NOT NULL,
    marca           VARCHAR(100)    NOT NULL,
    anio            SMALLINT        NOT NULL CHECK (anio > 1990),
    total_asientos  SMALLINT        NOT NULL,
    CONSTRAINT pk_bus1piso PRIMARY KEY (patente)
);

DO $$
DECLARE
    total   INT := 40;
    marcas  TEXT[] := ARRAY['Mercedes-Benz','Volvo','Scania','Irizar','Marcopolo','King Long'];
    modelos TEXT[] := ARRAY['OH-1621','B12B','K124','i6','Paradiso 1200','XMQ6127'];
    letras  TEXT[] := ARRAY['AB','BC','CD','DE','EF','FG','GH','HJ','JK','KL','LM','MN','NP'];
    pat     TEXT;
    i       INT;
BEGIN
    FOR i IN 1..total LOOP
        pat := letras[1 + floor(random()*array_length(letras,1))::INT]
               || lpad((1000+floor(random()*8999)::INT)::TEXT,4,'0');
        INSERT INTO BUS_1PISO (patente,modelo,marca,anio,total_asientos)
        VALUES (pat,
                modelos[1+floor(random()*array_length(modelos,1))::INT],
                marcas[1+floor(random()*array_length(marcas,1))::INT],
                1991+floor(random()*33)::INT,
                40+floor(random()*11)::INT)
        ON CONFLICT DO NOTHING;
    END LOOP;
    RAISE NOTICE '✔ BUS_1PISO: hasta 40 registros insertados.';
END;
$$;

-- ============================================================
-- 6. BUS_2PISO  (atributos: patente PK, modelo, marca, año,
--                total_asientos)
-- ============================================================
CREATE TABLE IF NOT EXISTS BUS_2PISO (
    patente         VARCHAR(10)     NOT NULL,
    modelo          VARCHAR(100)    NOT NULL,
    marca           VARCHAR(100)    NOT NULL,
    anio            SMALLINT        NOT NULL CHECK (anio > 1990),
    total_asientos  SMALLINT        NOT NULL,
    CONSTRAINT pk_bus2piso PRIMARY KEY (patente)
);

DO $$
DECLARE
    total   INT := 30;
    marcas  TEXT[] := ARRAY['Mercedes-Benz','Volvo','Scania','Irizar','Marcopolo','Yutong'];
    modelos TEXT[] := ARRAY['Tourismo RHD','9700','Touring','i8S','Paradiso 1800 DD','ZK6148HQA'];
    letras  TEXT[] := ARRAY['PA','PB','PC','PD','PE','PF','PG','PH','PJ','PK','PL','PM'];
    pat     TEXT;
    i       INT;
BEGIN
    FOR i IN 1..total LOOP
        pat := letras[1+floor(random()*array_length(letras,1))::INT]
               || lpad((1000+floor(random()*8999)::INT)::TEXT,4,'0');
        INSERT INTO BUS_2PISO (patente,modelo,marca,anio,total_asientos)
        VALUES (pat,
                modelos[1+floor(random()*array_length(modelos,1))::INT],
                marcas[1+floor(random()*array_length(marcas,1))::INT],
                1995+floor(random()*29)::INT,
                70+floor(random()*21)::INT)
        ON CONFLICT DO NOTHING;
    END LOOP;
    RAISE NOTICE '✔ BUS_2PISO: hasta 30 registros insertados.';
END;
$$;

-- ============================================================
-- 7. ASIENTO  (atributos según ER: numero, tipo, Fk_patente_bus)
--    PK compuesta: (numero, patente_bus)
--    tipo_bus discrimina a qué tabla de bus pertenece
-- ============================================================
CREATE TABLE IF NOT EXISTS ASIENTO (
    numero      SMALLINT        NOT NULL,
    patente_bus VARCHAR(10)     NOT NULL,
    tipo        VARCHAR(50)     NOT NULL DEFAULT 'Estándar',
    tipo_bus    VARCHAR(6)      NOT NULL CHECK (tipo_bus IN ('1PISO','2PISO')),
    CONSTRAINT pk_asiento PRIMARY KEY (numero, patente_bus)
);

DO $$
DECLARE
    tipos TEXT[] := ARRAY['Estándar','Semi-cama','Cama','Premium'];
    rec   RECORD;
    j     INT;
BEGIN
    FOR rec IN SELECT patente, total_asientos FROM BUS_1PISO LOOP
        FOR j IN 1..rec.total_asientos LOOP
            INSERT INTO ASIENTO (numero, patente_bus, tipo, tipo_bus)
            VALUES (j, rec.patente,
                    tipos[1+floor(random()*array_length(tipos,1))::INT], '1PISO')
            ON CONFLICT DO NOTHING;
        END LOOP;
    END LOOP;
    FOR rec IN SELECT patente, total_asientos FROM BUS_2PISO LOOP
        FOR j IN 1..rec.total_asientos LOOP
            INSERT INTO ASIENTO (numero, patente_bus, tipo, tipo_bus)
            VALUES (j, rec.patente,
                    tipos[1+floor(random()*array_length(tipos,1))::INT], '2PISO')
            ON CONFLICT DO NOTHING;
        END LOOP;
    END LOOP;
    RAISE NOTICE '✔ ASIENTO: registros generados para todos los buses.';
END;
$$;

-- ============================================================
-- 8. RUTA  (atributos según ER: ID_Ruta, Fk_ID_terminal_destino,
--           Fk_ID_terminal_origen)
--    SIN distancia_km ni duracion_estimada (eliminados del ER)
-- ============================================================
CREATE TABLE IF NOT EXISTS RUTA (
    id_ruta             SERIAL  NOT NULL,
    id_terminal_origen  INT     NOT NULL,
    id_terminal_destino INT     NOT NULL,
    CONSTRAINT pk_ruta PRIMARY KEY (id_ruta),
    CONSTRAINT fk_ruta_origen  FOREIGN KEY (id_terminal_origen)
        REFERENCES TERMINAL(id_terminal)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_ruta_destino FOREIGN KEY (id_terminal_destino)
        REFERENCES TERMINAL(id_terminal)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_ruta_terminales CHECK (id_terminal_origen <> id_terminal_destino)
);

DO $$
DECLARE
    total  INT := 50;
    v_orig INT;
    v_dest INT;
    i      INT;
BEGIN
    FOR i IN 1..total LOOP
        SELECT id_terminal INTO v_orig FROM TERMINAL ORDER BY random() LIMIT 1;
        SELECT id_terminal INTO v_dest FROM TERMINAL
        WHERE id_terminal <> v_orig ORDER BY random() LIMIT 1;
        INSERT INTO RUTA (id_terminal_origen, id_terminal_destino)
        VALUES (v_orig, v_dest);
    END LOOP;
    RAISE NOTICE '✔ RUTA: % registros insertados.', total;
END;
$$;

-- ============================================================
-- 9. VIAJE  (atributos según ER: ID_viaje, fecha_hora_salida,
--            fecha_hora_llegada, precio_base, Fk_patente_bus,
--            Fk_ID_ruta, estado)
--    2021-01-01 → 2024-12-31  (4 años)
-- ============================================================
CREATE TABLE IF NOT EXISTS VIAJE (
    id_viaje                SERIAL          NOT NULL,
    id_ruta                 INT             NOT NULL,
    patente_bus             VARCHAR(10)     NOT NULL,
    tipo_bus                VARCHAR(6)      NOT NULL CHECK (tipo_bus IN ('1PISO','2PISO')),
    fecha_hora_salida       TIMESTAMP       NOT NULL,
    fecha_hora_llegada_est  TIMESTAMP,
    precio_base             NUMERIC(10,2)   NOT NULL CHECK (precio_base >= 0),
    estado                  VARCHAR(30)     NOT NULL DEFAULT 'Programado',
    CONSTRAINT pk_viaje PRIMARY KEY (id_viaje),
    CONSTRAINT fk_viaje_ruta  FOREIGN KEY (id_ruta) REFERENCES RUTA(id_ruta)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_viaje_estado CHECK (estado IN ('Programado','En curso','Completado','Cancelado')),
    CONSTRAINT chk_viaje_fechas CHECK (
        fecha_hora_llegada_est IS NULL OR fecha_hora_llegada_est > fecha_hora_salida)
);

DO $$
DECLARE
    total        INT := 2000;
    estados      TEXT[]  := ARRAY['Programado','En curso','Completado','Cancelado'];
    pesos        FLOAT[] := ARRAY[0.05,0.05,0.80,0.10];
    tipo_bus     TEXT;
    v_patente    TEXT;
    v_ruta       INT;
    v_salida     TIMESTAMP;
    v_llegada    TIMESTAMP;
    v_estado     TEXT;
    v_precio     NUMERIC(10,2);
    rand_val     FLOAT;
    acum         FLOAT;
    k            INT;
    i            INT;
BEGIN
    FOR i IN 1..total LOOP
        IF random() < 0.57 THEN
            tipo_bus  := '1PISO';
            SELECT patente INTO v_patente FROM BUS_1PISO ORDER BY random() LIMIT 1;
        ELSE
            tipo_bus  := '2PISO';
            SELECT patente INTO v_patente FROM BUS_2PISO ORDER BY random() LIMIT 1;
        END IF;
        SELECT id_ruta INTO v_ruta FROM RUTA ORDER BY random() LIMIT 1;
        v_salida  := TIMESTAMP '2021-01-01 00:00:00'
                     + floor(random()*1461)::INT * INTERVAL '1 day'
                     + floor(random()*24)::INT  * INTERVAL '1 hour'
                     + floor(random()*60)::INT  * INTERVAL '1 minute';
        v_llegada := v_salida + make_interval(hours => 1+floor(random()*23)::INT,
                                              mins  => floor(random()*59)::INT);
        v_precio  := CASE tipo_bus
                        WHEN '1PISO' THEN 3000+floor(random()*25000)::INT
                        ELSE              8000+floor(random()*45000)::INT
                     END;
        rand_val := random(); acum := 0;
        v_estado := estados[array_length(estados,1)];
        FOR k IN 1..array_length(estados,1) LOOP
            acum := acum + pesos[k];
            IF rand_val <= acum THEN v_estado := estados[k]; EXIT; END IF;
        END LOOP;
        INSERT INTO VIAJE (id_ruta,patente_bus,tipo_bus,fecha_hora_salida,
                           fecha_hora_llegada_est,precio_base,estado)
        VALUES (v_ruta,v_patente,tipo_bus,v_salida,v_llegada,v_precio,v_estado);
    END LOOP;
    RAISE NOTICE '✔ VIAJE: 2000 registros insertados (2021-2024).';
END;
$$;

-- ============================================================
-- 10. PASAJERO  (atributos según ER: Rut, Nombre, Apellido,
--                telefono, email, facha_nac)
-- ============================================================
CREATE TABLE IF NOT EXISTS PASAJERO (
    rut              VARCHAR(12)  NOT NULL,
    nombre           VARCHAR(100) NOT NULL,
    apellido         VARCHAR(100) NOT NULL,
    telefono         VARCHAR(20),
    email            VARCHAR(150),
    fecha_nacimiento DATE,
    CONSTRAINT pk_pasajero PRIMARY KEY (rut)
);

DO $$
DECLARE
    total    INT := 500;
    nombres  TEXT[] := ARRAY[
        'Gabriel','Isabel','Jorge','María','Carlos','Ana','Luis','Rosa',
        'Diego','Elena','Andrés','Lucía','Martín','Sofía','Pedro','Valentina',
        'Tomás','Camila','Nicolás','Paula','Sebastián','Daniela','Emilio',
        'Natalia','Ricardo','Claudia','Fernando','Patricia','Alejandro','Mónica',
        'Rodrigo','Javiera','Felipe','Constanza','Ignacio','Bárbara','Matías',
        'Francisca','Cristóbal','Verónica','Agustín','Marcela','Maximiliano','Lorena'
    ];
    apellidos TEXT[] := ARRAY[
        'García','Martínez','López','Sánchez','Rodríguez','Fernández','González',
        'Pérez','Torres','Ramírez','Flores','Vargas','Morales','Castillo','Herrera',
        'Medina','Reyes','Gutiérrez','Ortiz','Mendoza','Rojas','Alvarado','Ríos',
        'Vega','Cabrera','Navarro','Soto','Paredes','Fuentes','Miranda','Bravo',
        'Muñoz','Sepúlveda','Silva','Tapia','Ibáñez','Aguirre','Cáceres','Jara'
    ];
    dominios  TEXT[] := ARRAY['gmail.com','hotmail.com','yahoo.com','outlook.com','uc.cl','udec.cl'];
    v_rut     TEXT;
    v_nom     TEXT;
    v_ap1     TEXT;
    v_ap2     TEXT;
    i         INT;
BEGIN
    FOR i IN 1..total LOOP
        v_rut := (10000000+floor(random()*9000000)::INT)::TEXT || '-'
                 || (floor(random()*10)::INT)::TEXT;
        v_nom := nombres[1+floor(random()*array_length(nombres,1))::INT];
        v_ap1 := apellidos[1+floor(random()*array_length(apellidos,1))::INT];
        v_ap2 := apellidos[1+floor(random()*array_length(apellidos,1))::INT];
        INSERT INTO PASAJERO (rut,nombre,apellido,telefono,email,fecha_nacimiento)
        VALUES (v_rut, v_nom, v_ap1||' '||v_ap2,
                '+569'||lpad((10000000+floor(random()*89999999)::INT)::TEXT,8,'0'),
                lower(v_nom)||'.'||lower(v_ap1)||floor(random()*999)::INT
                    ||'@'||dominios[1+floor(random()*array_length(dominios,1))::INT],
                DATE '1960-01-01' + floor(random()*16436)::INT)
        ON CONFLICT DO NOTHING;
    END LOOP;
    RAISE NOTICE '✔ PASAJERO: hasta 500 registros insertados.';
END;
$$;

-- ============================================================
-- 11. CUENTA_USUARIO  (atributos según ER: ID_viaje [sic ID_cuenta],
--                      Fk_rut_pasajero, username, password, fecha_registro)
-- ============================================================
CREATE TABLE IF NOT EXISTS CUENTA_USUARIO (
    id_cuenta       SERIAL          NOT NULL,
    rut_pasajero    VARCHAR(12)     NOT NULL UNIQUE,
    username        VARCHAR(80)     NOT NULL UNIQUE,
    password_hash   VARCHAR(255)    NOT NULL,
    fecha_registro  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_cuenta_usuario PRIMARY KEY (id_cuenta),
    CONSTRAINT fk_cuenta_pasajero FOREIGN KEY (rut_pasajero)
        REFERENCES PASAJERO(rut)
        ON DELETE CASCADE ON UPDATE CASCADE
);

DO $$
DECLARE
    rec    RECORD;
    sufijo INT;
BEGIN
    FOR rec IN
        SELECT rut, nombre, apellido FROM PASAJERO
        ORDER BY random()
        LIMIT (SELECT COUNT(*)*0.6 FROM PASAJERO)::INT
    LOOP
        sufijo := floor(random()*9999)::INT;
        INSERT INTO CUENTA_USUARIO (rut_pasajero,username,password_hash,fecha_registro)
        VALUES (rec.rut,
                lower(split_part(rec.nombre,' ',1))||'_'
                    ||lower(split_part(rec.apellido,' ',1))||sufijo,
                md5(rec.rut||sufijo::TEXT||random()::TEXT),
                TIMESTAMP '2020-01-01' + floor(random()*1826)::INT * INTERVAL '1 day')
        ON CONFLICT DO NOTHING;
    END LOOP;
    RAISE NOTICE '✔ CUENTA_USUARIO: ~60%% de pasajeros con cuenta.';
END;
$$;

-- ============================================================
-- 12. COMPRA  (atributos según ER: ID_compra, Fk_rut_pasajero,
--              fecha_hora_compra, metodo_pago, monto_total, estado_pago)
-- ============================================================
CREATE TABLE IF NOT EXISTS COMPRA (
    id_compra       SERIAL          NOT NULL,
    rut_pasajero    VARCHAR(12)     NOT NULL,
    fecha_hora      TIMESTAMP       NOT NULL,
    monto_total     NUMERIC(10,2)   NOT NULL DEFAULT 0 CHECK (monto_total >= 0),
    metodo_pago     VARCHAR(50)     NOT NULL,
    estado_pago     VARCHAR(30)     NOT NULL DEFAULT 'Pendiente',
    CONSTRAINT pk_compra PRIMARY KEY (id_compra),
    CONSTRAINT fk_compra_pasajero FOREIGN KEY (rut_pasajero)
        REFERENCES PASAJERO(rut)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_compra_estado CHECK
        (estado_pago IN ('Pendiente','Pagado','Rechazado','Reembolsado'))
);

DO $$
DECLARE
    total    INT := 3000;
    metodos  TEXT[]  := ARRAY['Débito','Crédito','Transferencia','Efectivo','Webpay'];
    estados  TEXT[]  := ARRAY['Pendiente','Pagado','Rechazado','Reembolsado'];
    pesos    FLOAT[] := ARRAY[0.05,0.85,0.05,0.05];
    v_rut    TEXT;
    v_estado TEXT;
    rand_val FLOAT;
    acum     FLOAT;
    k        INT;
    i        INT;
BEGIN
    FOR i IN 1..total LOOP
        SELECT rut INTO v_rut FROM PASAJERO ORDER BY random() LIMIT 1;
        rand_val := random(); acum := 0;
        v_estado := estados[array_length(estados,1)];
        FOR k IN 1..array_length(estados,1) LOOP
            acum := acum + pesos[k];
            IF rand_val <= acum THEN v_estado := estados[k]; EXIT; END IF;
        END LOOP;
        INSERT INTO COMPRA (rut_pasajero,fecha_hora,monto_total,metodo_pago,estado_pago)
        VALUES (v_rut,
                TIMESTAMP '2021-01-01' + floor(random()*1461)::INT * INTERVAL '1 day'
                    + floor(random()*24)::INT * INTERVAL '1 hour',
                0,
                metodos[1+floor(random()*array_length(metodos,1))::INT],
                v_estado);
    END LOOP;
    RAISE NOTICE '✔ COMPRA: 3000 registros insertados.';
END;
$$;

-- ============================================================
-- 13. PASAJE  (atributos según ER: Fk_ID_pasaje, Fk_ID_viaje,
--              Fk_ID_compra, Fk_numero_asiento, Fk_patente_bus,
--              precio_final, estado)
-- ============================================================
CREATE TABLE IF NOT EXISTS PASAJE (
    id_pasaje       SERIAL          NOT NULL,
    id_compra       INT             NOT NULL,
    id_viaje        INT             NOT NULL,
    numero_asiento  SMALLINT        NOT NULL,
    patente_bus     VARCHAR(10)     NOT NULL,
    precio_final    NUMERIC(10,2)   NOT NULL CHECK (precio_final >= 0),
    estado          VARCHAR(30)     NOT NULL DEFAULT 'Reservado',
    CONSTRAINT pk_pasaje PRIMARY KEY (id_pasaje),
    CONSTRAINT fk_pasaje_compra  FOREIGN KEY (id_compra)  REFERENCES COMPRA(id_compra)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_pasaje_viaje   FOREIGN KEY (id_viaje)   REFERENCES VIAJE(id_viaje)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_pasaje_asiento FOREIGN KEY (numero_asiento, patente_bus)
        REFERENCES ASIENTO(numero, patente_bus)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_pasaje_estado CHECK
        (estado IN ('Reservado','Embarcado','Cancelado','Completado')),
    CONSTRAINT uq_asiento_por_viaje UNIQUE (id_viaje, numero_asiento, patente_bus)
);

DO $$
DECLARE
    total        INT := 5000;
    estados      TEXT[]  := ARRAY['Reservado','Embarcado','Cancelado','Completado'];
    pesos        FLOAT[] := ARRAY[0.05,0.05,0.10,0.80];
    v_compra     INT;
    v_viaje      INT;
    v_patente    TEXT;
    v_asiento    SMALLINT;
    v_precio     NUMERIC(10,2);
    v_estado     TEXT;
    rand_val     FLOAT;
    acum         FLOAT;
    k            INT;
    i            INT;
BEGIN
    FOR i IN 1..total LOOP
        SELECT id_compra INTO v_compra FROM COMPRA  ORDER BY random() LIMIT 1;
        SELECT id_viaje  INTO v_viaje  FROM VIAJE   ORDER BY random() LIMIT 1;
        SELECT patente_bus INTO v_patente FROM VIAJE WHERE id_viaje = v_viaje;
        SELECT a.numero INTO v_asiento
        FROM ASIENTO a
        WHERE a.patente_bus = v_patente
          AND NOT EXISTS (
              SELECT 1 FROM PASAJE p
              WHERE p.id_viaje = v_viaje
                AND p.numero_asiento = a.numero
                AND p.patente_bus = a.patente_bus)
        ORDER BY random() LIMIT 1;
        CONTINUE WHEN v_asiento IS NULL;
        v_precio := (SELECT precio_base FROM VIAJE WHERE id_viaje = v_viaje)
                    * (0.85 + random()*0.30);
        rand_val := random(); acum := 0;
        v_estado := estados[array_length(estados,1)];
        FOR k IN 1..array_length(estados,1) LOOP
            acum := acum + pesos[k];
            IF rand_val <= acum THEN v_estado := estados[k]; EXIT; END IF;
        END LOOP;
        INSERT INTO PASAJE
            (id_compra,id_viaje,numero_asiento,patente_bus,precio_final,estado)
        VALUES (v_compra,v_viaje,v_asiento,v_patente,round(v_precio,-2),v_estado)
        ON CONFLICT ON CONSTRAINT uq_asiento_por_viaje DO NOTHING;
    END LOOP;
    RAISE NOTICE '✔ PASAJE: hasta 5000 registros insertados.';
END;
$$;

-- ============================================================
-- 14. Actualizar COMPRA.monto_total según sus pasajes
-- ============================================================
UPDATE COMPRA c
SET monto_total = (
    SELECT COALESCE(SUM(precio_final), 0)
    FROM PASAJE p WHERE p.id_compra = c.id_compra
);

-- ============================================================
-- VERIFICACIÓN FINAL
-- ============================================================
SELECT 'REGION'         AS tabla, COUNT(*) AS registros FROM REGION
UNION ALL SELECT 'CIUDAD',         COUNT(*) FROM CIUDAD
UNION ALL SELECT 'COMUNA',         COUNT(*) FROM COMUNA
UNION ALL SELECT 'TERMINAL',       COUNT(*) FROM TERMINAL
UNION ALL SELECT 'BUS_1PISO',      COUNT(*) FROM BUS_1PISO
UNION ALL SELECT 'BUS_2PISO',      COUNT(*) FROM BUS_2PISO
UNION ALL SELECT 'ASIENTO',        COUNT(*) FROM ASIENTO
UNION ALL SELECT 'RUTA',           COUNT(*) FROM RUTA
UNION ALL SELECT 'VIAJE',          COUNT(*) FROM VIAJE
UNION ALL SELECT 'PASAJERO',       COUNT(*) FROM PASAJERO
UNION ALL SELECT 'CUENTA_USUARIO', COUNT(*) FROM CUENTA_USUARIO
UNION ALL SELECT 'COMPRA',         COUNT(*) FROM COMPRA
UNION ALL SELECT 'PASAJE',         COUNT(*) FROM PASAJE
ORDER BY tabla;

-- ============================================================
-- FIN DEL SCRIPT
-- ============================================================