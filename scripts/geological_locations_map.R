############################################################################
### Plot geographic location of isotypes for three caenorhabditis species ###
############################################################################

# code adapted from Nikita

rm(list = ls())

library(readxl)
library(dplyr)
library(ggplot2)
library(ggthemes)
library(maps)
library(ggpubr)
library(maps)
library(readr)
library(RColorBrewer) #palette
display.brewer.all()
display.brewer.pal(8,"Set2")
brewer.pal(8, "Set2")
display.brewer.pal(10, "Set3")
brewer.pal(10, "Set3")
display.brewer.pal(8,"Dark2")
brewer.pal(8, "Dark2")
display.brewer.pal(8,"Paired")

##Open the briggsae file
all_data_C.briggsae_Strains <- readxl::read_excel("/home/njhaver4/vast-eande106/projects/Nikita/briggsae_GWAS_2025/Fecundity_allstrains_A3_A4_A5_A6/Publication/raw_data/20260430_C. briggsae WI strain info.xlsx")
all_data_C.briggsae_Strains$latitude<-ifelse(all_data_C.briggsae_Strains$latitude == "NA",NA,all_data_C.briggsae_Strains$latitude)
 
## Open the elegans file
all_data_C.elegans_Strains <- read_csv("/home/rrunyan1/Rose/isotype_reference_strains_lists/strain_data/20250625_c_elegans_strain_data.csv")
all_data_C.elegans_Strains$latitude<-ifelse(all_data_C.elegans_Strains$latitude == "NA",NA,all_data_C.elegans_Strains$latitude)

##Open the tropicalis file
all_data_C.tropicalis_Strains <- readxl::read_excel("/home/rrunyan1/Rose/isotype_reference_strains_lists/strain_data/C_tropicalis_WI_strain_info.xlsx")
all_data_C.tropicalis_Strains$latitude<-ifelse(all_data_C.tropicalis_Strains$latitude == "NA",NA,all_data_C.tropicalis_Strains$latitude)

all_isotypes_cb <- all_data_C.briggsae_Strains %>%
  dplyr::filter(strain == isotype)  %>% 
  dplyr::select(isotype,latitude,longitude)%>%
  dplyr::filter(!is.na(latitude) & !is.na(longitude)) %>%
  dplyr::rename("lat"="latitude", "long"="longitude", "strain"="isotype") 
colnames(all_isotypes_cb)

all_isotypes_ce <- all_data_C.elegans_Strains %>%
  dplyr::filter(strain == isotype)  %>% 
  dplyr::select(isotype,latitude,longitude)%>%
  dplyr::filter(!is.na(latitude) & !is.na(longitude)) %>%
  dplyr::rename("lat"="latitude", "long"="longitude", "strain"="isotype") 
colnames(all_isotypes_ce)

all_isotypes_ct <- all_data_C.tropicalis_Strains %>%
  dplyr::filter(strain == isotype)  %>% 
  dplyr::select(isotype,latitude,longitude)%>%
  dplyr::filter(!is.na(latitude) & !is.na(longitude)) %>%
  dplyr::rename("lat"="latitude", "long"="longitude", "strain"="isotype") 
colnames(all_isotypes_ct)


all_isotypes_cb$lat<-as.numeric(all_isotypes_cb$lat)
all_isotypes_cb$long<-as.numeric(all_isotypes_cb$long)

all_isotypes_ce$lat<-as.numeric(all_isotypes_ce$lat)
all_isotypes_ce$long<-as.numeric(all_isotypes_ce$long)

all_isotypes_ct$lat<-as.numeric(all_isotypes_ct$lat)
all_isotypes_ct$long<-as.numeric(all_isotypes_ct$long)

############# Geographic distribution of all isotypes########
world <- map_data('world')
world <- world[world$region != "Antarctica",] # intercourse antarctica

plot_world_all_isotypes <-ggplot2::ggplot() + 
  geom_map(data=world, map=world,
           aes(x=long, y=lat, map_id=region),
           color="black", fill="#F7F7F7", size=0.2)+
  geom_point(data = all_isotypes_ce, 
             aes(x= long, y=lat, color = "C. elegans"),
             shape =16, size = 2, alpha = 0.8) +
  geom_point(data = all_isotypes_cb, 
             aes(x= long, y=lat, color = "C. briggsae"),
             shape =16, size = 2, alpha = 0.8) +
  geom_point(data = all_isotypes_ct, 
             aes(x= long, y=lat, color = "C. tropicalis"),
             shape =16, size = 2, alpha = 0.8) +
  scale_color_manual(
    name = "Species",
    values = c(
    "C. elegans" = "#005AB5",
    "C. briggsae" = "#E66100",
    "C. tropicalis" = "#8F2D7A"
    ),
    guide = guide_legend(
      override.aes = list(size = 3)  # increase legend dot size
    )
  ) +
  lims(x=c(-180,191),y=c(-58,84)) +
  theme_void() +
  theme(
    axis.text = element_blank(),    # Conceal Tick Marks
    axis.title = element_blank(),   # Conceal Tick Marks
    legend.position = c(0.05, 0.05), # legend position
    legend.justification = c(0, 0),
    legend.title = element_text(size = 20),
    legend.text = element_text(size = 17),
    legend.key.size = unit(0.5, "cm")
  )

plot_world_all_isotypes
# legend and dots may seem large, but they look much smaller once saved

ggsave("/home/rrunyan1/Rose/plots/all_isotypes_all_species_map.png",
       plot = plot_world_all_isotypes,  width = 15, height = 8, units = "in", bg = "white")

