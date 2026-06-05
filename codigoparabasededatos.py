import psycopg2
from datetime import datetime

# =========================================================
# CONFIGURACION DE BASE DE DATOS
# =========================================================
DB_CONFIG = {
    "host": "localhost",
    "database": "ball8diego",  # Reemplaza con tu BD si es necesario
    "user": "postgres",
    "password": "golaso79",# Reemplaza con tu contrasena
    "port": 5432,
    "client_encoding": "utf8"
}

def conectar():
    return psycopg2.connect(**DB_CONFIG)

# =========================================================
# CARGA DE DATOS SINTETICOS (Adaptado a schema_v4)
# =========================================================
# =========================================================
# CARGA DE DATOS SINTETICOS (Adaptado a schema_v4)
# =========================================================
def cargar_datos_sinteticos():
    try:
        with conectar() as conn:
            with conn.cursor() as cur:
                # Regiones y Ciudades
                cur.execute("INSERT INTO REGION (id_region, nombre) VALUES (13, 'Metropolitana'), (14, 'Los Rios') ON CONFLICT DO NOTHING;")
                cur.execute("INSERT INTO CIUDAD (id_ciudad, nombre, id_region) OVERRIDING SYSTEM VALUE VALUES (1, 'Santiago', 13), (2, 'Valdivia', 14) ON CONFLICT DO NOTHING;")
                
                # Terminales y Rutas
                cur.execute("INSERT INTO TERMINAL (id_terminal, nombre, direccion, capacidad, id_ciudad) OVERRIDING SYSTEM VALUE VALUES (1, 'Terminal Sur', 'Alameda', 100, 1), (2, 'Terminal Valdivia', 'Anfion Munoz', 100, 2) ON CONFLICT DO NOTHING;")
                cur.execute("INSERT INTO RUTA (id_ruta, id_terminal_origen, id_terminal_destino) OVERRIDING SYSTEM VALUE VALUES (100, 1, 2) ON CONFLICT DO NOTHING;")
                
                # Flota unificada
                cur.execute("INSERT INTO BUS (id_bus, patente, modelo, marca, anio, total_asientos, clase_piso) OVERRIDING SYSTEM VALUE VALUES (10, 'AB1234', 'Paradiso', 'Marcopolo', 2022, 40, '1PISO') ON CONFLICT DO NOTHING;")
                cur.execute("INSERT INTO ASIENTO (numero, id_bus, tipo) VALUES (1, 10, 'Cama'), (2, 10, 'Cama') ON CONFLICT DO NOTHING;")
                
                # Viajes y Pasajeros
                cur.execute("INSERT INTO VIAJE (id_viaje, id_ruta, id_bus, fecha_hora_salida, fecha_hora_llegada_est, precio_base, estado) OVERRIDING SYSTEM VALUE VALUES (9999, 100, 10, '2026-06-01 20:00:00', '2026-06-02 05:00:00', 25000, 'Programado') ON CONFLICT DO NOTHING;")
                cur.execute("INSERT INTO PASAJERO (id_pasajero, rut, nombre, apellido) OVERRIDING SYSTEM VALUE VALUES (1, '11111111-1', 'Ana', 'Perez') ON CONFLICT DO NOTHING;")
                
                # ---> AQUÍ ESTÁ EL CAMBIO <---
                # Forzamos que 50 viajes de la base de datos masiva pasen a estado 'Programado'
                cur.execute("""
                    UPDATE VIAJE 
                    SET estado = 'Programado' 
                    WHERE id_viaje IN (SELECT id_viaje FROM VIAJE LIMIT 50);
                """)
                
                conn.commit()
                print("✔ Datos sinteticos cargados y 50 viajes actualizados a 'Programado' exitosamente.")
    except Exception as e:
        print(f"Error al cargar datos sinteticos: {e}")

# =========================================================
# 1. CREAR CLIENTE (Rubrica: Ingresar elemento central)
# =========================================================
def crear_pasajero():
    print("\n--- REGISTRAR NUEVO CLIENTE ---")
    rut = input("Ingrese RUT (Ej: 11111111-1): ")
    nombre = input("Ingrese Nombre: ")
    apellido = input("Ingrese Apellido: ")

    try:
        with conectar() as conn:
            with conn.cursor() as cur:
                # No insertamos el id_pasajero porque se genera solo
                cur.execute("""
                    INSERT INTO PASAJERO (rut, nombre, apellido) 
                    VALUES (%s, %s, %s);
                """, (rut, nombre, apellido))
                conn.commit()
                print("✔ Cliente registrado exitosamente en la BD.")
    except psycopg2.IntegrityError:
        print("Error: Ese RUT ya existe en la base de datos.")
    except Exception as e:
        print(f"Error inesperado: {e}")

# =========================================================
# 2. VENDER PASAJE (Rubrica: Transaccional / Prestar)
# =========================================================
# =========================================================
# 2. VENDER PASAJE (Rubrica: Transaccional / Prestar)
# =========================================================
def vender_pasaje():
    print("\n--- VENDER PASAJE (Transaccion) ---")
    try:
        with conectar() as conn:
            with conn.cursor() as cur:
                # Modificado: Agregamos múltiples JOINs para sacar el nombre de la ciudad de origen y destino
                cur.execute("""
                    SELECT 
                        v.id_viaje, 
                        v.fecha_hora_salida, 
                        b.patente, 
                        v.precio_base, 
                        v.id_bus,
                        c_origen.nombre AS ciudad_origen,
                        c_destino.nombre AS ciudad_destino
                    FROM VIAJE v
                    JOIN BUS b ON v.id_bus = b.id_bus
                    JOIN RUTA r ON v.id_ruta = r.id_ruta
                    JOIN TERMINAL t_origen ON r.id_terminal_origen = t_origen.id_terminal
                    JOIN CIUDAD c_origen ON t_origen.id_ciudad = c_origen.id_ciudad
                    JOIN TERMINAL t_destino ON r.id_terminal_destino = t_destino.id_terminal
                    JOIN CIUDAD c_destino ON t_destino.id_ciudad = c_destino.id_ciudad
                    WHERE v.estado ILIKE '%Programado%'
                    ORDER BY v.fecha_hora_salida DESC
                    LIMIT 15;
                """)
                viajes = cur.fetchall()
                
                if not viajes:
                    print("Atencion: No hay viajes programados disponibles.")
                    print("-> SUGERENCIA: Vuelve al menu principal y ejecuta la opcion '2. Cargar datos sinteticos' primero.")
                    return
                
                print("\nVIAJES DISPONIBLES (Mostrando maximo 15):")
                for v in viajes:
                    # v[0]=id, v[1]=fecha, v[2]=patente, v[3]=precio, v[4]=id_bus, v[5]=origen, v[6]=destino
                    print(f"ID Viaje: {v[0]:<4} | {v[5]:<15} -> {v[6]:<15} | Salida: {v[1].strftime('%Y-%m-%d %H:%M')} | Bus: {v[2]} | Precio: ${v[3]}")
                
                id_viaje = int(input("\nIngrese el ID del viaje: "))
                asiento = int(input("Ingrese numero de asiento: "))
                rut = input("Ingrese RUT del comprador registrado: ")
                
                # Obtener el ID del comprador a traves de su RUT
                cur.execute("SELECT id_pasajero FROM PASAJERO WHERE rut = %s;", (rut,))
                pasajero_data = cur.fetchone()
                if not pasajero_data:
                    print("Error: RUT no encontrado en el sistema. Registre al cliente primero.")
                    return
                id_comprador = pasajero_data[0]

                # Obtener datos del viaje para la transaccion
                cur.execute("SELECT id_bus, precio_base FROM VIAJE WHERE id_viaje = %s;", (id_viaje,))
                viaje_data = cur.fetchone()
                if not viaje_data:
                    print("Error: ID de viaje invalido.")
                    return
                    
                id_bus, precio_final = viaje_data
                fecha_actual = datetime.now()
                
                # Generamos la compra usando el id_comprador
                cur.execute("""
                    INSERT INTO COMPRA (id_comprador, fecha_hora, monto_total, metodo_pago, estado_pago)
                    VALUES (%s, %s, %s, 'Efectivo', 'Pagado')
                    RETURNING id_compra;
                """, (id_comprador, fecha_actual, precio_final))
                
                id_compra = cur.fetchone()[0]

                # Generamos el pasaje usando id_bus y estado 'Reservado'
                cur.execute("""
                    INSERT INTO PASAJE (id_compra, id_viaje, numero_asiento, id_bus, precio_final, estado)
                    VALUES (%s, %s, %s, %s, %s, 'Reservado');
                """, (id_compra, id_viaje, asiento, id_bus, precio_final))
                
                conn.commit()
                print(f"✔ Compra exitosa. ID de Boleta generada: {id_compra}")

    except psycopg2.errors.ForeignKeyViolation:
        print("Error de Integridad: El Asiento no existe en el bus indicado.")
    except psycopg2.errors.UniqueViolation:
        print("Error: Ese asiento ya se encuentra vendido u ocupado para este viaje.")
    except ValueError:
        print("Error: Por favor, ingrese numeros validos para el ID del viaje y el asiento.")
    except Exception as e:
        print(f"Error en la base de datos: {e}")
# =========================================================
# 3. ANULAR PASAJE (Rubrica: Devolver)
# =========================================================
def anular_pasaje():
    print("\n--- ANULAR PASAJE (Devolucion) ---")
    try:
        id_pasaje = int(input("Ingrese el ID del pasaje a anular: "))
        with conectar() as conn:
            with conn.cursor() as cur:
                cur.execute("UPDATE PASAJE SET estado = 'Cancelado' WHERE id_pasaje = %s;", (id_pasaje,))
                if cur.rowcount > 0:
                    conn.commit()
                    print("✔ Pasaje anulado y asiento liberado exitosamente.")
                else:
                    print("Atencion: No se encontro un pasaje con ese ID.")
    except ValueError:
        print("Error: Debe ingresar un numero entero valido.")
    except Exception as e:
        print(f"Error: {e}")

# =========================================================
# 4. LISTAR PASAJES (Rubrica: Ver elementos solicitados)
# =========================================================
def listar_pasajes_cliente():
    print("\n--- HISTORIAL DE PASAJES POR CLIENTE ---")
    rut = input("Ingrese el RUT del cliente: ")

    try:
        with conectar() as conn:
            with conn.cursor() as cur:
                cur.execute("""
                    SELECT p.id_pasaje, v.fecha_hora_salida, b.patente, p.numero_asiento, p.estado
                    FROM PASAJE p
                    JOIN COMPRA c ON p.id_compra = c.id_compra
                    JOIN VIAJE v ON p.id_viaje = v.id_viaje
                    JOIN BUS b ON p.id_bus = b.id_bus
                    JOIN PASAJERO pas ON c.id_comprador = pas.id_pasajero
                    WHERE pas.rut = %s;
                """, (rut,))
                
                registros = cur.fetchall()
                if registros:
                    for r in registros:
                        print(f"Ticket ID: {r[0]} | Salida: {r[1].strftime('%Y-%m-%d %H:%M')} | Bus: {r[2]} | Asiento: {r[3]} | Estado: {r[4]}")
                else:
                    print("Este cliente no tiene compras asociadas en el sistema.")
    except Exception as e:
        print(f"Error: {e}")

# =========================================================
# 5. ELIMINAR REGISTRO (Rubrica: Borrar error)
# =========================================================
def eliminar_registro_erroneo():
    print("\n--- ELIMINAR REGISTRO MAL INGRESADO ---")
    try:
        id_pasaje = int(input("Ingrese el ID del pasaje a eliminar fisicamente de la BD: "))
        with conectar() as conn:
            with conn.cursor() as cur:
                cur.execute("DELETE FROM PASAJE WHERE id_pasaje = %s;", (id_pasaje,))
                if cur.rowcount > 0:
                    conn.commit()
                    print("✔ Registro eliminado fisicamente de la base de datos.")
                else:
                    print("Atencion: No se encontro ese ID.")
    except ValueError:
         print("Error: Debe ingresar un numero entero valido.")
    except Exception as e:
        print(f"Error: {e}")

# =========================================================
# MENU PRINCIPAL
# =========================================================
def menu_principal():
    while True:
        print("\n===== SISTEMA DE PASAJES (PostgreSQL Schema v4) =====")
        print("1. Menu Operaciones Centrales")
        print("2. Cargar datos sinteticos (Obligatorio si la BD esta vacia)")
        print("0. Salir")
        
        opcion = input("Seleccione una opcion: ")
        
        if opcion == "1":
            while True:
                print("\n--- MENU OPERACIONES ---")
                print("1. Crear un cliente")
                print("2. Vender pasaje (Transaccional)")
                print("3. Anular pasaje (Devolver)")
                print("4. Ver historial de cliente")
                print("5. Borrar registro mal ingresado")
                print("0. Volver")
                sub_op = input("Seleccione accion: ")
                
                if sub_op == "1": crear_pasajero()
                elif sub_op == "2": vender_pasaje()
                elif sub_op == "3": anular_pasaje()
                elif sub_op == "4": listar_pasajes_cliente()
                elif sub_op == "5": eliminar_registro_erroneo()
                elif sub_op == "0": break
                else: print("Opcion no valida.")
        elif opcion == "2":
            cargar_datos_sinteticos()
        elif opcion == "0":
            print("Programa finalizado.")
            break
        else:
            print("Opcion no valida.")

if __name__ == "__main__":
    menu_principal()
