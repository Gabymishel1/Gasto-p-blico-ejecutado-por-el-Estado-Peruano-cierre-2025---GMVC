# Proyecto Final - Análisis Exploratorio de Datos en R
## Gasto público ejecutado por el Estado Peruano — Cierre 2025

## 1. Contexto

**Institución:** Ministerio de Economía y Finanzas del Perú (MEF), a través
de su [Portal de Datos Abiertos - Clasificación Funcional del Gasto](https://datosabiertos.mef.gob.pe/dataset/clasificacion-funcional-del-gasto/resource/4649413a-63b5-4818-9232-3920cb53bc84).

**Objetivo:** analizar cómo se distribuye y cómo se ejecuta el gasto público del Estado peruano al cierre del año fiscal 2025, ya que se pudo observar grandes diferencias en montos de presupuesto y gasto entre departamentos y niveles de gobierno, pero eso no revela qué tan bien se usó ese dinero. Este análisis busca justamente eso, medir la eficiencia de ejecución y compararla con departamento, nivel de gobierno y tipo de servicio, para ubicar dónde falla más la ejecución y saber exactamente la razón del problema.

**Principales variables:**

| Variable (original)             | Variable (renombrada)              |
|----------------------------------|--------------------------------------|
| `NIVEL_GOBIERNO_NOMBRE`          | `Nivel_de_Gobierno_de_la_Entidad`   |
| `PLIEGO_NOMBRE`                  | `Descripción_de_Pliego`             |
| `DEPARTAMENTO_EJECUTORA_NOMBRE`  | `Nombre_del_departamento`           |
| `DISTRITO_EJECUTORA_NOMBRE`      | `Nombre_del_distrito`               |
| `SERVICIO_NOMBRE`                | `Descripción_de_Servicio`           |
| `FUNCION_NOMBRE`                 | `Descripción_de_Función`            |
| `AFIN_AP3`                       | `Monto_asignado`                    |
| `EJEC_AP3`                       | `Monto_ejecutado`                   |

Variable derivada: `avance_pct = Monto_ejecutado / Monto_asignado * 100`
(% de ejecución del presupuesto).

## 2. Estructura del repositorio

```
Proyecto_Final/
├── DATA/
│   └── gasto_público.csv
├── FIGURES/
│   ├── PARTE 1/
│   │   ├── COLLAGE.png
│   │   ├── grafico_1_departamentos.png
│   │   ├── grafico_2_nivel_gobierno.png
│   │   ├── grafico_3_presupuesto_ejecutado.png
│   │   └── grafico_4_tipo_servicio.png
│   └── PARTE 2/
│       ├── grafico_final.png
│       ├── grafico_1_ranking_departamentos.png
│       ├── grafico_2_distribucion_del_avance.png
│       └── grafico_3_deptos_rezagados.png
├── SCRIPTS/
│   ├── EDA.R
│   └── 04_analisis_final.R
└── README.md
```

## 3. Parte 1 - EDA (`SCRIPTS/EDA.R`)

Importación, limpieza (renombrado + filtrado), estadísticas descriptivas
(tablas de frecuencia y `summary()`/`summarise()`) y 4 visualizaciones:

- **Gráfico 1:** presupuesto asignado por departamento.
- **Gráfico 2:** gasto ejecutado (log) según nivel de gobierno.
- **Gráfico 3:** relación entre presupuesto asignado y ejecutado (log-log).
- **Gráfico 4:** la misma relación, separada por tipo de servicio.

Todo se junta en `FIGURES/PARTE 1/COLLAGE.png`.

--

## 4. Parte 2 - Análisis final (`SCRIPTS/04_analisis_final.R`)

**Pregunta de análisis:** ¿Qué departamentos presentan la menor eficiencia en la ejecución del gasto público, y qué tipo de servicios explican las brechas más críticas?

### Análisis

- **Gráfico 1:** 5 departamentos ejecutan claramente menos que el resto - Tumbes, Ancash, Moquegua, Ica y Madre de Dios, todos por debajo de 90% (el resto está entre 90% y 95%).
- **Gráfico 2:** los Gobiernos Regionales ejecutan de forma más consistente, con la mayoría de casos concentrados cerca del 100%. Empresas del Estado y Otras Entidades muestran la distribución más dispersa e irregular.
- **Gráfico 3:** en los cinco departamentos, Servicios Económicos (obras, transporte, energía, agro) es siempre el peor: Ancash 70%, Ica 74%, frente a ~80-85% en Generales y Sociales.
- **Gráfico final:** confirma el patrón a nivel nacional, la columna de Servicios Económicos es la más baja en casi todos los departamentos, no solo en los críticos.

### Conclusiones

Si bien los departamentos menos eficientes en la ejecución del gasto público son Ancash, Tumbes, Moquegua, Ica y Madre de Dios, todos por debajo del 90% de avance, frente a un rango de 90-95% en el resto del país. Esa brecha no se explica por una mala gestión generalizada, sino por un tipo de gasto específico, como son los Servicios Económicos (obras, transporte, energía, agro) que están sistemáticamente más atrasados. Ancash llega solo a 70.1%, Ica a 74%, mientras que Servicios Generales y Sociales rondan 80-85% en esos mismos departamentos.
El gráfico final confirma que este patrón se repite a nivel nacional: la inversión en infraestructura es, en general, el tipo de gasto que peor se ejecuta en todo el Perú. Además, el problema de Ancash aparece tanto en sus municipalidades como en las entidades del Gobierno Nacional que operan ahí, lo que sugiere una dificultad ligada al territorio, no a una sola entidad.
En resumen, la baja eficiencia de estos cinco departamentos se debe principalmente a su dificultad para ejecutar proyectos de inversión pública (obras, infraestructura,...), no por una debilidad generalizada en toda su gestión presupuestal. Esto sugiere que las políticas de mejora en estos departamentos deberían enfocarse puntualmente en agilizar la ejecución de obras públicas, más que en reformas generales de gestión del gasto.

