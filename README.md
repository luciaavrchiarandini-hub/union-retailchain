# RetailChain — Consolidación de Inventario con `UNION` y `UNION ALL`

Práctica de SQL aplicada a la consolidación de inventarios multisucursal en **RetailChain**, diferenciando el armado de un catálogo comercial único (`UNION`) frente a una auditoría completa de registros físicos de stock (`UNION ALL`).

## Estructura del repositorio

```text
union-retailchain/
├── schema.sql
├── soluciones.sql
└── README.md
```

---

## Análisis técnico y preguntas de negocio

### 1. ¿Cuántas filas devuelve cada consulta y por qué son distintas? Explicá con ejemplos concretos de los datos qué filas se eliminaron con `UNION`.

* **Consulta 1 (`UNION` — Catálogo Unificado):** Devuelve **11 filas**.
* **Consulta 2 (`UNION ALL` — Auditoría de Stock Total):** Devuelve **14 filas** (7 registros de `inventario_sucursal_norte` + 7 registros de `inventario_sucursal_sur`).

**Por qué son distintas:**
`UNION` compara la fila completa resultante de cada `SELECT` y elimina las filas exactamente idénticas, mientras que `UNION ALL` apila todos los registros sin filtrar repeticiones.

Al consultar `(id_producto, nombre_producto, categoria)` en la Consulta 1, existen **3 productos con datos idénticos en ambas sucursales** cuyas copias duplicadas fueron eliminadas por `UNION`:
1. **`103` — `Monitor 4K 27"` (`Computación`)**
2. **`104` — `Teclado Mecánico` (`Accesorios`)**
3. **`106` — `SSD Externo 1TB` (`Almacenamiento`)**

**Caso borde importante en los datos:** La **`Webcam HD 1080p`** aparece dos veces en el resultado final (`11` filas en total) porque en la Sucursal Norte está registrada con **`id_producto = 107`** y en la Sucursal Sur con **`id_producto = 111`**. Como `UNION` evalúa la igualdad de toda la fila y los IDs son distintos, no las considera duplicadas y conserva ambas. Asimismo, si se hubiera incluido la columna `stock` en el `UNION`, tampoco se habrían eliminado los productos `103`, `104` y `106` porque sus cantidades físicas difieren entre sucursales (`5 vs. 3`, `20 vs. 18` y `10 vs. 7`).

---

### 2. ¿Por qué `UNION ALL` es más eficiente que `UNION`? ¿Qué operación adicional realiza `UNION` internamente que consume más recursos?

`UNION ALL` es significativamente más rápido y liviano porque actúa como una operación de **concatenación directa (append)**: toma los bloques de resultados de cada `SELECT` y los entrega uno debajo del otro sin inspeccionar su contenido.

En cambio, para garantizar que no existan filas repetidas, **`UNION` debe ejecutar internamente una operación de deduplicación (`DISTINCT`)** sobre todo el conjunto combinado. Para lograrlo, el motor SQL necesita:
* Ordenar todas las filas en memoria o en disco (`Sort / Merge`) o construir tablas hash temporales (`Hash Match Aggregate`).
* Comparar columna por columna cada fila contra el resto del conjunto para descartar coincidencias exactas.

En tablas con millones de registros, ese paso extra de ordenamiento/hashing incrementa el uso de CPU, memoria RAM y tiempo de respuesta.

---

### 3. ¿En qué casos de negocio usarías cada uno? Dá al menos dos ejemplos reales distintos a los del ejercicio.

* **Casos de uso reales para `UNION` (deduplicación obligatoria):**
  1. **Base única de contactos para campañas de email marketing:** Unificar listas de suscriptores provenientes de distintos formularios web, eventos presenciales y descargas de ebooks; si un cliente se registró por dos canales distintos, `UNION` evita enviarle el mismo correo duplicado y previene inflar el conteo de audiencia única.
  2. **Padrón consolidado de proveedores activos:** Combinar los maestros de proveedores de distintas unidades de negocio o filiales de un grupo empresarial para obtener un listado maestro sin repetir razones sociales que facturan a más de una filial.

* **Casos de uso reales para `UNION ALL` (preservación total de eventos):**
  1. **Consolidación de logs de transacciones o facturación histórica y actual:** Unir la tabla de ventas archivadas de años anteriores (`ventas_historicas`) con la tabla operativa del año en curso (`ventas_2026`) para calcular ingresos totales; aquí cada transacción es un hecho independiente y `UNION ALL` evita el costo de deduplicación innecesaria.
  2. **Auditoría de movimientos bancarios o de caja diaria:** Apilar los extractos de movimientos de múltiples cuentas corrientes o terminales POS para calcular el flujo total de ingresos y egresos del día, donde dos cobros por el mismo monto y concepto son operaciones reales distintas que nunca deben eliminarse.

---

### 4. ¿Qué pasa si las columnas de ambas consultas no coinciden en número o tipo? ¿Qué error genera SQL?

Para que `UNION` o `UNION ALL` puedan apilar dos conjuntos de resultados, ambos `SELECT` deben respetar exactamente la misma estructura posicional. Si no se cumple, **el motor SQL aborta la ejecución en tiempo de compilación y devuelve un error de sintaxis/tipo**:

1. **Si difiere la cantidad de columnas:** Por ejemplo, si el primer `SELECT` pide 4 columnas y el segundo pide 3, SQL Server lanza el error:
   > `Msg 205, Level 16, State 1: All queries combined using a UNION, INTERSECT or EXCEPT operator must have an equal number of expressions in their target lists.` *(Todas las consultas combinadas mediante un operador UNION, INTERSECT o EXCEPT deben tener el mismo número de expresiones en sus listas de destino).*
2. **Si difieren los tipos de datos en la misma posición:** Por ejemplo, si la primera columna del primer `SELECT` es `INT` (`id_producto`) y la primera columna del segundo `SELECT` es `VARCHAR` (`nombre_producto`), SQL intenta realizar una conversión implícita según su jerarquía de precedencia de tipos y falla con el error:
   > `Msg 245, Level 16, State 1: Conversion failed when converting the varchar value '...' to data type int.` *(Error de conversión al convertir el valor varchar al tipo de datos int).*
