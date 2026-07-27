## 04_analisis_final.R - SEDUNDA PARTE
## PREGUNTA DE ANÁLISIS:
## ¿Qué departamentos presentan la menor eficiencia en la ejecución del gasto público, y qué tipo de servicios explican las brechas más críticas?

#En el EDA se identificó que el presupuesto asignado y el gasto ejecutado varían fuertemente entre departamentos y entre niveles de gobierno. 
#Sin embargo, esa comparación solo describe montos: no dice si una entidad gastó bien o mal en relación a lo que le tocaba gastar. 
#Dos departamentos pueden manejar presupuestos muy distintos y aun así ser igual de eficientes o igual de ineficientes, si se mide en términos relativos. 
#Por eso el análisis se centra en la relación entre el presupuesto asignado y el presupuesto efectivamente ejecutado, resumida en un 
#indicador de avance (avance_pct = ejecutado / asignado × 100), y se cruza con tres variables clave — departamento, nivel de gobierno y tipo de servicio 
#para identificar dónde se concentra la baja ejecución y qué la explica.


library(dplyr)
library(ggplot2)
library(readr)
library(patchwork)
library(tidyverse)
library(ggtext)
df <- read_csv("../DATA/gasto_público.csv")
dim(df)
df %>% summary()
df %>% is.na() %>% colSums()
df %>% glimpse()
#Renombrar
df <- df %>% rename( Nombre_del_distrito = DISTRITO_EJECUTORA_NOMBRE, Código_de_departamento = DEPARTAMENTO_EJECUTORA, Nombre_del_departamento = DEPARTAMENTO_EJECUTORA_NOMBRE,Descripción_de_Servicio=SERVICIO_NOMBRE,Descripción_de_Función=FUNCION_NOMBRE, Nivel_de_Gobierno_de_la_Entidad = NIVEL_GOBIERNO_NOMBRE, Descripción_de_Pliego =PLIEGO_NOMBRE, Monto_asignado  = AFIN_AP3, Monto_ejecutado = EJEC_AP3, Código_de_Nivel_de_la_Entidad = NIVEL, Código_de_Pliego = PLIEGO, Código_de_Función =FUNCION)

#Observación
df <- df %>% filter(Monto_asignado > 0, Monto_ejecutado > 0)
#Creando nueva variable
df <- df %>% mutate(avance_pct    = (Monto_ejecutado / Monto_asignado) * 100, log_ejecutado = log(Monto_ejecutado), log_asignado  = log(Monto_asignado))

df_avance <- df %>% filter(avance_pct >= 0, avance_pct <= 150)
#Tablas

##ranking de departamentos por avance de ejecución
tabla_departamento <- df %>%
  group_by(Nombre_del_departamento) %>%
  summarise(
    n               = n(),
    avance_promedio = mean(avance_pct),
    avance_mediana  = median(avance_pct)
  ) %>%
  arrange(avance_mediana)

deptos_menor_avance <- tabla_departamento %>%
  slice_head(n = 5) %>%
  pull(Nombre_del_departamento)

deptos_menor_avance

##avance por nivel de gobierno

nivel <- df %>%
  group_by(Nivel_de_Gobierno_de_la_Entidad) %>%
  summarise(
    n               = n(),
    avance_promedio = mean(avance_pct),
    avance_mediana  = median(avance_pct),
    sd = sd(avance_pct, na.rm= T),
    asimetria = moments::skewness(avance_pct, na.rm= T),
    min = min(avance_pct, na.rm= T),
    max = max(avance_pct, na.rm= T)
  ) %>%
  arrange(desc(avance_mediana))
nivel

## cruce departamento x nivel de gobierno

D_N <- df %>%
  group_by(Nombre_del_departamento, Nivel_de_Gobierno_de_la_Entidad) %>%
  summarise(
    n               = n(),
    avance_promedio = mean(avance_pct),
    avance_mediana  = median(avance_pct),
    .groups = "drop"
  ) %>%
  filter(n >= 20) %>%   
  arrange(desc(avance_promedio))

D_N

## tipo de servicio dentro de los departamentos más críticos

tabla_servicio_criticos <- df %>%
  filter(Nombre_del_departamento %in% deptos_menor_avance) %>%
  group_by(Nombre_del_departamento, Descripción_de_Servicio) %>% 
  summarise(
    n = n(),
    avance_promedio = mean(avance_pct, na.rm = TRUE),
    avance_mediana = median(avance_pct, na.rm = TRUE),
    sd = sd(avance_pct, na.rm = TRUE),
    asimetria = moments::skewness(avance_pct, na.rm = TRUE),
    min = min(avance_pct, na.rm = TRUE),
    max = max(avance_pct, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(Nombre_del_departamento, desc(avance_mediana))

tabla_servicio_criticos

# comparación: avance por servicio a nivel nacional
tabla_servicio_nacional <- df %>%
  group_by(Descripción_de_Servicio) %>%
  summarise(avance_mediana_nacional = median(avance_pct))

tabla_servicio_nacional


## Gráfico 1: ranking de departamentos según avance de ejecución

p_ranking_departamentos <- tabla_departamento %>%
  mutate(critico = Nombre_del_departamento %in% deptos_menor_avance) %>%
  ggplot(aes(x = reorder(Nombre_del_departamento, -avance_mediana),
             y = avance_mediana, fill = critico)) +
  geom_col(width = 0.7, color = "white") +
  geom_text(aes(label = round(avance_mediana, 1)), vjust = -1.2, size = 2.6, fontface = "bold",angle = 90) +
  geom_hline(yintercept = 100, linetype = "dashed", colour = "gray40") +
  scale_y_continuous(limits = c(0, 115)) +
  scale_fill_manual(
    values = c("TRUE" = "#C44E92", "FALSE" = "#6C72B7"), 
    labels = c("TRUE" = "Deptos. Más rezagados", "FALSE" = "Resto") ) +
  ggthemes::theme_fivethirtyeight() +
  labs(title = "Avance mediano de ejecución presupuestal por departamento", subtitle = "Cierre presupuestal 2025",
    x = "Departamento",
    y = "% ejecutado (mediana)",
    fill = "") +
  theme(legend.position = "bottom",plot.title = element_text(hjust = 0.5, size = 11, face = "bold"),plot.subtitle = element_text(hjust = 0.5, size = 9), axis.text.x = element_text(angle = 45, hjust = 1, size = 7.5), axis.text.y = element_text(size = 8), panel.grid.major.x = element_blank())

p_ranking_departamentos

#5 departamentos ejecutan claramente menos que el resto: Tumbes, Ancash, Moquegua, Ica y Madre de Dios, todos por debajo de 90% (el resto está entre 90% y 95%).



## Gráfico 2: avance % por nivel de gobierno

p_nivel <- df %>%
  mutate(Nivel_de_Gobierno_de_la_Entidad = factor(
    Nivel_de_Gobierno_de_la_Entidad, 
    levels = nivel$Nivel_de_Gobierno_de_la_Entidad
  )) %>%
  ggplot(aes(x = avance_pct, fill = Nivel_de_Gobierno_de_la_Entidad, color = Nivel_de_Gobierno_de_la_Entidad)) +
  geom_density(alpha = 0.3, size = 0.8) +
  geom_vline(xintercept = 100, linetype = "dashed", colour = "gray40") +
  scale_fill_brewer(palette = "Set1") +
  scale_color_brewer(palette = "Set1") +
  ggthemes::theme_fivethirtyeight() +
  labs(title = "Distribución del avance (%) según nivel de gobierno", subtitle = "Cierre presupuestal 2025 - MEF",
       x = "% ejecutado",
       fill = "Nivel de gobierno",
       color = "Nivel de gobierno") +
  theme(
    legend.position = "right",  
    legend.direction = "vertical",         
    legend.title = element_text(size = 6, face = "bold"),
    legend.text = element_text(size = 5),
    plot.title = element_text(size = 9, face = "bold", hjust = 0),
    plot.subtitle = element_text(size = 7, hjust = 0),
    axis.text = element_text(size = 6),
    axis.title = element_text(size = 7)
  )
p_nivel


#Los Gobiernos Regionales ejecutan de forma más consistente, casi todos cerca del 100%. Empresas del Estado y Otras Entidades son las más irregulares. 
#Ancash destaca porque su bajo avance se repite tanto en sus municipalidades como en las entidades del Gobierno Nacional que operan ahí.


## Gráfico 3: tipo de servicio, solo en los departamentos más críticos
p_servicio_criticos <- df %>%
  filter(Nombre_del_departamento %in% deptos_menor_avance) %>%
  group_by(Nombre_del_departamento, Descripción_de_Servicio) %>%
  summarise(avance_pct = mean(avance_pct, na.rm = TRUE), .groups = "drop") %>%
  ggplot(aes(x = Descripción_de_Servicio, y = avance_pct, fill = Descripción_de_Servicio)) +
  geom_col(width = 0.6) +
  geom_text(aes(label = paste0(round(avance_pct, 1), "%")), vjust = -0.4, size = 2.8, fontface = "bold") +
  geom_hline(yintercept = 100, linetype = "dashed", colour = "gray40") +
  facet_wrap(~ Nombre_del_departamento, ncol = 3) +
  scale_fill_brewer(palette = "Set2") +
  scale_y_continuous(limits = c(0, 115)) + 
  ggthemes::theme_fivethirtyeight() +
  labs(
    title = "Avance (%) por tipo de servicio en los 5 departamentos más rezagados",
    subtitle = paste("Departamentos:", paste(deptos_menor_avance, collapse = ", ")),
    x = "Tipo de servicio",
    y = "% ejecutado",
    fill = "Tipo de Servicio" ) +
  theme(
    legend.position = "bottom",
    legend.title = element_text(size = 8, face = "bold"),
    legend.text = element_text(size = 7.5),
    plot.title = element_text(size = 10, face = "bold"),
    plot.subtitle = element_text(size = 8),
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    axis.text.y = element_text(size = 7.5),
    strip.text = element_text(size = 8, face = "bold")  )

p_servicio_criticos

#En los cinco departamentos, Servicios Económicos es siempre el peor o más crítico: Ancash 70.1%, Ica 74%.


## GRÁFICO GENERAL: ¿qué departamentos tienen menor avance y qué tipo de servicio explica esa brecha?

orden_deptos <- tabla_departamento %>% 
  arrange(avance_mediana) %>% 
  pull(Nombre_del_departamento)
tabla_heatmap <- df %>%
  group_by(Nombre_del_departamento, Descripción_de_Servicio) %>%
  summarise(avance_prom = mean(avance_pct, na.rm = TRUE), .groups = "drop") %>%
  mutate(  Nombre_del_departamento = factor(Nombre_del_departamento, levels = rev(orden_deptos)), label_val = sprintf("%.1f", avance_prom)  )
vector_y_pantalla <- levels(tabla_heatmap$Nombre_del_departamento)
colores_eje_y <- ifelse(vector_y_pantalla %in% deptos_menor_avance, "#800000", "#111111")
face_eje_y    <- ifelse(vector_y_pantalla %in% deptos_menor_avance, "bold", "plain")

map_calor <- tabla_heatmap %>%
  ggplot(aes(x = Descripción_de_Servicio, y = Nombre_del_departamento, fill = avance_prom)) +
  geom_tile(colour = "white", linewidth = 0.3) +
  # Todos los números en color negro y con tamaño adaptado para que entren bien
  geom_text(aes(label = label_val), color = "black", size = 2.8, fontface = "bold"  ) +
  scale_y_discrete(guide = guide_axis(n.dodge = 1)) +
  
  # Paleta de colores ajustada
  scale_fill_gradientn(colors = c("#A50026", "#D73027", "#F46D43", "#FDAE61", "#FEE08B", "#E6F598", "#A6D96A", "#1B7837", "#006837"),
    guide = guide_colorbar(title = "% de avance de ejecución (promedio)", title.position = "right", title.theme = element_text(angle = -90, hjust = 0.5, size = 8.5),
      barwidth = unit(0.5, "cm"),barheight = unit(9, "cm"),frame.colour = "black",ticks.colour = "black"  )
  ) +
  theme_minimal(base_family = "sans") +
  labs(title = "¿Dónde y en qué servicios está la menor eficiencia de ejecución del gasto?", subtitle = "Cierre presupuestal 2025 - MEF / departamentos ordenados de menor a mayor avance global",
    x = NULL,
    y = NULL  ) +
  theme(
    plot.title = element_text(hjust = 0.5, size = 11, face = "bold", color = "black"),
    plot.subtitle = element_text(hjust = 0.5, size = 8, color = "gray40"),
    axis.text.x = element_text(angle = 20, hjust = 1, vjust = 1, size = 8.5, face = "bold", color = "black"),
    axis.text.y = element_text(color = colores_eje_y, face = face_eje_y, size = 8.5),
    panel.border = element_rect(color = "black", fill = NA, linewidth = 0.8),
    panel.grid = element_blank(),
    legend.position = "right"
  )

map_calor

#Nos confirma el patrón a nivel nacional, ya que la columna de Servicios Económicos es la más baja en casi todos los departamentos, no solo en los críticos.


ggsave(
  filename = "../FIGURES/PARTE 2/grafico_final.png",
  plot = map_calor, 
  width = 12,
  height = 14,
  dpi = 300,
  units = "in"
)
# Gráficos individuales
ggsave(
  filename = "../FIGURES/PARTE 2/grafico_1_ranking_departamentos.png", 
  plot = p_ranking_departamentos, 
  width = 8, height = 6, dpi = 300, units = "in"
)

ggsave(
  filename = "../FIGURES/PARTE 2/grafico_2_distribucion_del_avance.png", 
  plot = p_nivel, 
  width = 8, height = 6, dpi = 300, units = "in"
)

ggsave(
  filename = "../FIGURES/PARTE 2/grafico_3_deptos_rezagados.png", 
  plot = p_servicio_criticos, 
  width = 8, height = 6, dpi = 300, units = "in"
)

#CONCLUSIÓN

#Si bien los departamentos menos eficientes en la ejecución del gasto público son Ancash, Tumbes, Moquegua, Ica y Madre de Dios, 
#todos por debajo del 90% de avance, frente a un rango de 90-95% en el resto del país. Esa brecha no se explica por una mala gestión generalizada, 
#sino por un tipo de gasto específico, como son los Servicios Económicos (obras, transporte, energía, agro) que están sistemáticamente más atrasados.
#Ancash llega solo a 70.1%, Ica a 74%, mientras que Servicios Generales y Sociales rondan 80-85% en esos mismos departamentos.

#El gráfico final (map_calor) confirma que este patrón se repite a nivel nacional: la inversión en infraestructura es, en general, 
#el tipo de gasto que peor se ejecuta en todo el Perú. Además, el problema de Ancash aparece tanto en sus municipalidades como en las 
#entidades del Gobierno Nacional que operan ahí, lo que sugiere una dificultad ligada al territorio, no a una sola entidad.

# En resumen, la baja eficiencia de estos cinco departamentos se debe principalmente a su dificultad para ejecutar proyectos de 
#inversión pública (obras, infraestructura), no por una debilidad generalizada en toda su gestión presupuestal. 
#Esto sugiere que las políticas de mejora en estos departamentos deberían enfocarse puntualmente en agilizar la 
#ejecución de obras públicas, más que en reformas generales de gestión del gasto.






