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

CREATE TABLE REGION (
    id_region   INT             NOT NULL,
    nombre      VARCHAR(100)    NOT NULL,
    CONSTRAINT pk_region PRIMARY KEY (id_region)
);

CREATE TABLE CIUDAD (
    id_ciudad   SERIAL          NOT NULL,
    nombre      VARCHAR(100)    NOT NULL,
    id_region   INT             NOT NULL,
    CONSTRAINT pk_ciudad PRIMARY KEY (id_ciudad),
    CONSTRAINT fk_ciudad_region FOREIGN KEY (id_region)
        REFERENCES REGION(id_region) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE COMUNA (
    id_comuna   SERIAL          NOT NULL,
    nombre      VARCHAR(150)    NOT NULL,
    id_ciudad   INT             NOT NULL,
    CONSTRAINT pk_comuna PRIMARY KEY (id_comuna),
    CONSTRAINT fk_comuna_ciudad FOREIGN KEY (id_ciudad)
        REFERENCES CIUDAD(id_ciudad) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE TERMINAL (
    id_terminal SERIAL          NOT NULL,
    nombre      VARCHAR(150)    NOT NULL,
    direccion   VARCHAR(255)    NOT NULL,
    id_ciudad   INT             NOT NULL,
    CONSTRAINT pk_terminal PRIMARY KEY (id_terminal),
    CONSTRAINT fk_terminal_ciudad FOREIGN KEY (id_ciudad)
        REFERENCES CIUDAD(id_ciudad) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE BUS_1PISO (
    patente         VARCHAR(10)     NOT NULL,
    modelo          VARCHAR(100)    NOT NULL,
    marca           VARCHAR(100)    NOT NULL,
    anio            SMALLINT        NOT NULL CHECK (anio > 1990),
    total_asientos  SMALLINT        NOT NULL,
    CONSTRAINT pk_bus1piso PRIMARY KEY (patente)
);

CREATE TABLE BUS_2PISO (
    patente         VARCHAR(10)     NOT NULL,
    modelo          VARCHAR(100)    NOT NULL,
    marca           VARCHAR(100)    NOT NULL,
    anio            SMALLINT        NOT NULL CHECK (anio > 1990),
    total_asientos  SMALLINT        NOT NULL,
    CONSTRAINT pk_bus2piso PRIMARY KEY (patente)
);


CREATE TABLE ASIENTO (
    numero              SMALLINT        NOT NULL,
    patente_bus_1piso   VARCHAR(10),
    patente_bus_2piso   VARCHAR(10),
    tipo                VARCHAR(50)     NOT NULL DEFAULT 'Estándar',
    
    CONSTRAINT chk_asiento_exclusivo CHECK (
        (patente_bus_1piso IS NOT NULL AND patente_bus_2piso IS NULL) OR 
        (patente_bus_1piso IS NULL AND patente_bus_2piso IS NOT NULL)
    ),
    
    CONSTRAINT pk_asiento UNIQUE (numero, patente_bus_1piso, patente_bus_2piso),
    
    CONSTRAINT fk_asiento_bus1 FOREIGN KEY (patente_bus_1piso) REFERENCES BUS_1PISO(patente) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_asiento_bus2 FOREIGN KEY (patente_bus_2piso) REFERENCES BUS_2PISO(patente) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE RUTA (
    id_ruta             SERIAL  NOT NULL,
    id_terminal_origen  INT     NOT NULL,
    id_terminal_destino INT     NOT NULL,
    CONSTRAINT pk_ruta PRIMARY KEY (id_ruta),
    CONSTRAINT fk_ruta_origen  FOREIGN KEY (id_terminal_origen) REFERENCES TERMINAL(id_terminal) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_ruta_destino FOREIGN KEY (id_terminal_destino) REFERENCES TERMINAL(id_terminal) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_ruta_terminales CHECK (id_terminal_origen <> id_terminal_destino)
);


CREATE TABLE VIAJE (
    id_viaje                SERIAL          NOT NULL,
    id_ruta                 INT             NOT NULL,
    patente_bus_1piso       VARCHAR(10),
    patente_bus_2piso       VARCHAR(10),
    fecha_hora_salida       TIMESTAMP       NOT NULL,
    fecha_hora_llegada_est  TIMESTAMP,
    precio_base             NUMERIC(10,2)   NOT NULL CHECK (precio_base >= 0),
    estado                  VARCHAR(30)     NOT NULL DEFAULT 'Programado',
    CONSTRAINT pk_viaje PRIMARY KEY (id_viaje),
    CONSTRAINT fk_viaje_ruta FOREIGN KEY (id_ruta) REFERENCES RUTA(id_ruta) ON DELETE CASCADE ON UPDATE CASCADE,
    
    CONSTRAINT chk_viaje_exclusivo CHECK (
        (patente_bus_1piso IS NOT NULL AND patente_bus_2piso IS NULL) OR 
        (patente_bus_1piso IS NULL AND patente_bus_2piso IS NOT NULL)
    ),
    CONSTRAINT fk_viaje_bus1 FOREIGN KEY (patente_bus_1piso) REFERENCES BUS_1PISO(patente) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_viaje_bus2 FOREIGN KEY (patente_bus_2piso) REFERENCES BUS_2PISO(patente) ON DELETE CASCADE ON UPDATE CASCADE,
    
    CONSTRAINT chk_viaje_estado CHECK (estado IN ('Programado','En curso','Completado','Cancelado')),
    CONSTRAINT chk_viaje_fechas CHECK (fecha_hora_llegada_est IS NULL OR fecha_hora_llegada_est > fecha_hora_salida)
);

CREATE TABLE PASAJERO (
    rut              VARCHAR(12)  NOT NULL,
    nombre           VARCHAR(100) NOT NULL,
    apellido         VARCHAR(100) NOT NULL,
    telefono         VARCHAR(20),
    email            VARCHAR(150),
    fecha_nacimiento DATE,
    CONSTRAINT pk_pasajero PRIMARY KEY (rut)
);

CREATE TABLE CUENTA_USUARIO (
    id_cuenta       SERIAL          NOT NULL,
    rut_pasajero    VARCHAR(12)     NOT NULL UNIQUE,
    username        VARCHAR(80)     NOT NULL UNIQUE,
    password_hash   VARCHAR(255)    NOT NULL,
    fecha_registro  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_cuenta_usuario PRIMARY KEY (id_cuenta),
    CONSTRAINT fk_cuenta_pasajero FOREIGN KEY (rut_pasajero) REFERENCES PASAJERO(rut) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE COMPRA (
    id_compra       SERIAL          NOT NULL,
    rut_pasajero    VARCHAR(12)     NOT NULL,
    fecha_hora      TIMESTAMP       NOT NULL,
    monto_total     NUMERIC(10,2)   NOT NULL DEFAULT 0 CHECK (monto_total >= 0),
    metodo_pago     VARCHAR(50)     NOT NULL,
    estado_pago     VARCHAR(30)     NOT NULL DEFAULT 'Pendiente',
    CONSTRAINT pk_compra PRIMARY KEY (id_compra),
    CONSTRAINT fk_compra_pasajero FOREIGN KEY (rut_pasajero) REFERENCES PASAJERO(rut) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_compra_estado CHECK (estado_pago IN ('Pendiente','Pagado','Rechazado','Reembolsado'))
);

CREATE TABLE PASAJE (
    id_pasaje       SERIAL          NOT NULL,
    id_compra       INT             NOT NULL,
    id_viaje        INT             NOT NULL,
    numero_asiento  SMALLINT        NOT NULL,
    patente_bus_1piso VARCHAR(10),
    patente_bus_2piso VARCHAR(10),
    precio_final    NUMERIC(10,2)   NOT NULL CHECK (precio_final >= 0),
    estado          VARCHAR(30)     NOT NULL DEFAULT 'Reservado',
    CONSTRAINT pk_pasaje PRIMARY KEY (id_pasaje),
    CONSTRAINT fk_pasaje_compra  FOREIGN KEY (id_compra) REFERENCES COMPRA(id_compra) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_pasaje_viaje   FOREIGN KEY (id_viaje) REFERENCES VIAJE(id_viaje) ON DELETE CASCADE ON UPDATE CASCADE,
    
    CONSTRAINT chk_pasaje_exclusivo CHECK (
        (patente_bus_1piso IS NOT NULL AND patente_bus_2piso IS NULL) OR 
        (patente_bus_1piso IS NULL AND patente_bus_2piso IS NOT NULL)
    ),
    
    CONSTRAINT fk_pasaje_asiento FOREIGN KEY (numero_asiento, patente_bus_1piso, patente_bus_2piso)
        REFERENCES ASIENTO(numero, patente_bus_1piso, patente_bus_2piso) ON DELETE CASCADE ON UPDATE CASCADE,
        
    CONSTRAINT chk_pasaje_estado CHECK (estado IN ('Reservado','Embarcado','Cancelado','Completado'))
);