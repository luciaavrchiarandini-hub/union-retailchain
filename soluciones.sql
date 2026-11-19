-- ══════════════════════════════════════════
-- RetailChain — UNION y UNION ALL
-- Motor: SQL Server (SSMS)
-- Autor: Lucía Chiarandini
-- Fecha: 19/11/2026
-- ══════════════════════════════════════════


-- ── CONSULTA 1: UNION ────────────────────
-- Reporte de Catálogo Unificado
-- Pregunta de negocio: ¿Qué productos únicos comercializa
-- la empresa en toda su red de sucursales?
-- Operador: UNION (elimina filas completamente duplicadas -> devuelve 11 filas)

SELECT
    id_producto,
    nombre_producto,
    categoria
FROM inventario_sucursal_norte
UNION
SELECT
    id_producto,
    nombre_producto,
    categoria
FROM inventario_sucursal_sur
ORDER BY id_producto;


-- ── CONSULTA 2: UNION ALL ────────────────
-- Auditoría de Stock Total
-- Pregunta de negocio: ¿Cuántos registros físicos de stock
-- existen en total entre ambas sucursales?
-- Operador: UNION ALL (mantiene todos los registros incluyendo duplicados -> devuelve 14 filas)

SELECT
    'Norte' AS sucursal,
    id_producto,
    nombre_producto,
    categoria,
    stock
FROM inventario_sucursal_norte
UNION ALL
SELECT
    'Sur' AS sucursal,
    id_producto,
    nombre_producto,
    categoria,
    stock
FROM inventario_sucursal_sur
ORDER BY id_producto, sucursal;


-- ── CONSULTA 3: COMPARACIÓN DE RESULTADOS ─
-- Ejecutá estas dos consultas para comparar cuántas filas
-- devuelve cada operador y explicá la diferencia en tu README

-- 3A. Conteo de filas con UNION (11 productos únicos en el catálogo)
SELECT COUNT(*) AS filas_union
FROM (
    SELECT id_producto, nombre_producto, categoria
    FROM inventario_sucursal_norte
    UNION
    SELECT id_producto, nombre_producto, categoria
    FROM inventario_sucursal_sur
) AS resultado_union;

-- 3B. Conteo de filas con UNION ALL (14 registros físicos de inventario)
SELECT COUNT(*) AS filas_union_all
FROM (
    SELECT id_producto, nombre_producto, categoria, stock
    FROM inventario_sucursal_norte
    UNION ALL
    SELECT id_producto, nombre_producto, categoria, stock
    FROM inventario_sucursal_sur
) AS resultado_union_all;
