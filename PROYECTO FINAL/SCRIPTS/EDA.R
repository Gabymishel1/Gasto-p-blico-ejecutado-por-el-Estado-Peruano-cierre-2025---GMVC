
## Gasto público ejecutado por el Estado Peruano (cierre 2025) - PRIMERA PARTE
library(dplyr)
library(ggplot2)
library(readr)
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

#Estadísticas descriptivas
     # variables categoricas
df %>% 
  select(Descripción_de_Pliego) %>%
  table() %>% 
  as_tibble() %>% 
  arrange(desc(n) ) 

df %>% 
  select(Nombre_del_departamento) %>%
  table() %>% 
  as_tibble() %>% 
  arrange(desc(n) ) 

df %>% 
  select(Nombre_del_distrito) %>%
  table() %>% 
  as_tibble() %>% 
  arrange(desc(n) ) 


df %>% 
  select(Descripción_de_Servicio) %>%
  table() %>% 
  as_tibble() %>% 
  arrange(desc(n) ) 

df %>% 
  select(Descripción_de_Función) %>%
  table() %>% 
  as_tibble() %>% 
  arrange(desc(n) ) 


   # variables numericas

df %>% 
  select(Monto_asignado) %>% 
  summary()

df %>% 
  select(Monto_asignado) %>% 
  summarise( 
    promedio = mean(Monto_asignado, na.rm= T),
    mediana = median(Monto_asignado, na.rm= T),
    sd = sd(Monto_asignado, na.rm= T),
    asimetria = moments::skewness(Monto_asignado, na.rm= T),
    min = min(Monto_asignado, na.rm= T),
    max = max(Monto_asignado, na.rm= T)
  )

# 1 variable categoria y 1 numerica


df %>% 
  group_by(Nombre_del_departamento) %>%
  summarise( 
    promedio = mean(Monto_asignado, na.rm= T),
    mediana = median(Monto_asignado, na.rm= T),
    sd = sd(Monto_asignado, na.rm= T),
    asimetria = moments::skewness(Monto_asignado, na.rm= T),
    min = min(Monto_asignado, na.rm= T),
    max = max(Monto_asignado, na.rm= T)
  )%>% 
  arrange(desc(promedio) )

    # FIGURES
  #1
plot1 <- df %>% 
  ggplot(aes(x=Monto_asignado, y =Nombre_del_departamento, fill=factor(Nombre_del_departamento) ))+ 
  geom_boxplot(outliers = F, width=0.5)+
  
  stat_summary(
    fun = mean, 
    geom = "text", 
    aes(label = round(after_stat(x), 0)), 
    hjust = -7.8,
    vjust = -0.7,                         
    size = 2.5,                           
    fontface = "bold"
  ) +
  
  geom_jitter(size=1,shape=21,alpha=0.1 )+
  scale_x_continuous(limits = c(0,1e+06))+
  stat_summary(fun=mean, col = "black", shape=1 )+
  ggthemes::theme_fivethirtyeight()+
  theme(legend.position = "none")

plot1

  #2

plot2 <- df_avance %>%
  ggplot(aes(x = Nivel_de_Gobierno_de_la_Entidad, y = log_ejecutado, fill = Nivel_de_Gobierno_de_la_Entidad)) +
  geom_boxplot(notch = TRUE) +
  stat_summary(aes(colour = "promedio"), fun = mean) +
  
  scale_fill_brewer(palette = "Pastel1")+
  
  theme_minimal() +
  labs(
    title = "Gasto ejecutado (log) según nivel de gobierno",
    subtitle = "Cierre presupuestal 2025",
    x = "Nivel de gobierno",
    y = "log(monto devengado, S/)",
    fill = "Nivel de gobierno",
    colour = ""
  ) +
  theme(axis.text.x = element_text(angle = 20, hjust = 1),
        legend.position = "none")

plot2

#3

set.seed(123)
plot3 <- df %>%
  slice_sample(prop = 0.5) %>%
  ggplot(aes(x = log_asignado, y = log_ejecutado)) +
  geom_point(pch = 21, alpha = 0.5, colour = "#4C72B0") +
  geom_smooth(method = "lm", colour = "red") +
  theme_light() +
  labs(
    title = "Relación entre presupuesto asignado y gasto ejecutado",
    subtitle = "Cierre presupuestal 2025 (muestra del 50% de los registros)",
    x = "log(presupuesto asignado, S/)",
    y = "log(monto devengado, S/)"
  )
plot3

#4
set.seed(123)
plot4 <- df %>%
  slice_sample(prop = 0.5) %>%
  ggplot(aes(x = log_asignado, y = log_ejecutado)) +
  geom_point(pch = 21, aes(colour = Descripción_de_Servicio), alpha = 0.5) +
  geom_smooth(method = "lm", colour = "red") +
  facet_grid(~Descripción_de_Servicio) +
  theme_minimal() +
  labs(
    title = "Relación presupuesto-ejecución según tipo de servicio",
    subtitle = "Cierre presupuestal 2025",
    x = "log(presupuesto asignado, S/)",
    y = "log(monto devengado, S/)",
    colour = "Tipo de servicio"
  )+
    theme(legend.position = "none"
  )
plot4

###

library(patchwork)

pjoin <- ((plot1 + plot2) / (plot3 + plot4)) + 
  plot_layout(widths = c(1, 0.1,1),guides = "collect") & 
  theme(
    text = element_text(size = 8),
    axis.text.x = element_text(size = 7),
    axis.text.y = element_text(size = 7),
    plot.title = element_text(size = 10, face = "bold")
  )
ggsave(
  filename = "../FIGURES/PARTE 1/COLLAGE.png", 
  plot = pjoin, 
  width = 16, height = 10, dpi = 300, units = "in"
)

# Gráficos individuales 
ggsave(
  filename = "../FIGURES/PARTE 1/grafico_1_departamentos.png", 
  plot = plot1, 
  width = 8, height = 6, dpi = 300, units = "in"
)

ggsave(
  filename = "../FIGURES/PARTE 1/grafico_2_nivel_gobierno.png", 
  plot = plot2, 
  width = 8, height = 6, dpi = 300, units = "in"
)

ggsave(
  filename = "../FIGURES/PARTE 1/grafico_3_presupuesto_ejecutado.png", 
  plot = plot3, 
  width = 8, height = 6, dpi = 300, units = "in"
)

ggsave(
  filename = "../FIGURES/PARTE 1/grafico_4_tipo_servicio.png", 
  plot = plot4, 
  width = 8, height = 6, dpi = 300, units = "in"
)

