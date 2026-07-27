# Gasto-p-blico-ejecutado-por-el-Estado-Peruano-cierre-2025---GMVC
Evaluando la distribución y eficiencia del gasto público en Perú
# EDA: Análisis del gasto público ejecutado por el Estado Peruano — cierre 2025

## Contexto

- **Institución:** [Ministerio de Economía y Finanzas (MEF) — Contabilidad Pública](https://datosabiertos.mef.gob.pe/dataset/clasificacion-funcional-del-gasto/resource/4649413a-63b5-4818-9232-3920cb53bc84)
- **Objetivo:** Registrar la ejecución del gasto público a nivel de pliego, departamento y servicio, tanto del presupuesto asignado como del monto efectivamente devengado, para fines de transparencia y control fiscal.

## Estructura del repositorio

```
Gasto-p-blico-ejecutado-por-el-Estado-Peruano-cierre-2025---GMVC/
├── README.md
└── PROYECTO FINAL/
    ├── DATA/
    │   └── gasto_público.csv         ← 24 137 registros (cierre 2025)
    ├── SCRIPTS/
    │   └── EDA.R                     ← Análisis exploratorio completo
    └── COLLAGE/
        ├── grafico.png               ← Collage con los 4 gráficos
        ├── grafico_1_departamentos.png
        ├── grafico_2_nivel_gobierno.png
        ├── grafico_3_presupuesto_ejecutado.png
        └── grafico_4_tipo_servicio.png
```

  **PARTE I**

  
- **Variables principales analizadas:**

| Variable | Descripción |
|---|---|
| `DEPARTAMENTO_EJECUTORA_NOMBRE` | Departamento donde se ejecuta el gasto |
| `NIVEL_GOBIERNO_NOMBRE` | Nivel de gobierno: Nacional, Regional o Local |
| `PLIEGO_NOMBRE` | Nombre del pliego presupuestal (ministerio, gobierno regional, etc.) |
| `SERVICIO_NOMBRE` | Tipo de servicio: generales, sociales, económicos |
| `FUNCION_NOMBRE` | Función del gasto (educación, salud, transporte, etc.) |
| `AFIN_AP3` | Monto asignado o Presupuesto Institucional Modificado (PIM) en S/ |
| `EJEC_AP3` | Monto ejecutado o devengado en S/ |


## Resumen del análisis

### Limpieza y transformaciones

- Renombrado de columnas a nombres más legibles (castellano descriptivo).
- Filtro de registros con monto asignado y ejecutado > 0 (se excluyen partidas sin movimiento).
- Creación de variables derivadas:
  - `avance_pct` = (ejecutado / asignado) × 100
  - `log_asignado` y `log_ejecutado` (transformación logarítmica para normalizar distribuciones).

### Estadísticas descriptivas

- Tablas de frecuencia por pliego, departamento, distrito, servicio y función.
- Medidas de tendencia central y dispersión del monto asignado (media, mediana, desviación estándar, asimetría).
- Las mismas métricas agrupadas por departamento para identificar diferencias regionales.

### Gráficos generados

| Gráfico | Tipo | ¿Qué muestra? |
|---|---|---|
| 1 | Boxplot + puntos | Distribución del monto asignado por departamento, con media etiquetada |
| 2 | Boxplot con muesca | Gasto ejecutado (escala log) según nivel de gobierno (Nacional, Regional, Local) |
| 3 | Dispersión + regresión lineal | Relación entre presupuesto asignado y gasto ejecutado (muestra del 50%) |
| 4 | Dispersión + facetas | Misma relación segmentada por tipo de servicio (generales, sociales, económicos) |

## Collage de gráficos

![Collage de gráficos](PROYECTO%20FINAL/COLLAGE/grafico.png)

  **PARTE II**
