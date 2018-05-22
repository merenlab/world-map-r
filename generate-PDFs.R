#!/usr/bin/env Rscript

suppressMessages(library(ggplot2))
suppressMessages(library(reshape2))
suppressMessages(library(maps))
suppressMessages(library(plyr))
suppressMessages(library(gridExtra))

#############################################################################
# Feel free to edit the stuff below
#############################################################################

FONT_SIZE <- 2 # set it to 0 to see no labels
FONT_COLOR="BLACK"

POINT_COLOR="RED"

# scaling points
MIN_POINT_SIZE <- 0.2
MAX_POINT_SIZE <- 15

MARGIN_MIN_LAT <- -5
MARGIN_MAX_LAT <- 5
MARGIN_MIN_LON <- -5
MARGIN_MAX_LON <- 5

PDF_WIDTH <- 12
PDF_HEIGHT <- 5.5

#############################################################################

gen_blank_world_map <- function(df) {
  world_map <- map_data("world")

  min_lat <- min(df$Lat) + MARGIN_MIN_LAT
  max_lat <- max(df$Lat) + MARGIN_MAX_LAT
  min_lon <- min(df$Lon) + MARGIN_MIN_LON
  max_lon <- max(df$Lon) + MARGIN_MAX_LON

  p <- ggplot(data=world_map,aes(x=long, y=lat, group=group))
  p <- p + geom_polygon(fill = '#777777')
  p <- p + coord_cartesian(xlim = c(min_lon, max_lon),
                           ylim = c(min_lat, max_lat))

  return(p)
}

add_mag_abundances <- function(plot_object, df, mag, alpha=0.2, labels = TRUE){
  plot_object <- plot_object + geom_jitter(data = df,
                                           position=position_jitter(width=0, height=0),
                                           aes_string(x="Lon", y="Lat",
                                                      group=mag,
                                                      size=mag),
                                           color=POINT_COLOR)

  plot_object <- plot_object + geom_text(data = df,
                                         aes(x=Lon, y=Lat,
                                             group='text',
                                             label=samples),
                                         size=FONT_SIZE,
                                         color=FONT_COLOR,
                                         vjust=1,
                                         nudge_y=-1)

  plot_object <- plot_object + scale_size(range=c(MIN_POINT_SIZE,
                                                  MAX_POINT_SIZE))

  return(plot_object)
}

clean_map <- function(plot_object){
  plot_object <- plot_object +
    xlab(NULL) + ylab(NULL) +
    theme(panel.grid.major = element_blank()) +
    theme(panel.grid.minor = element_blank()) +
    theme(panel.background = element_rect(colour = "gray"))
  return(plot_object)
}

# get the data
df <- read.table(file = 'data.txt',
                 header = TRUE,
                 sep = "\t",
                 quote = "")

# learn about columns that show distribution of MAGs
MAGs <- names(df)[grepl("MAG_", names(df))]

# go through each MAG, and create a single image.
for (MAG in MAGs){
  cat(sprintf("Working on %s ...\n", MAG))

  # get a blank world map
  world_map <- gen_blank_world_map(df)

  # add mag abundances on the canvas
  world_map <- add_mag_abundances(world_map, df, MAG, alpha=1)

  # clean it up
  world_map <- clean_map(world_map)

  # save it
  pdf(paste(MAG, '.pdf', sep=''), width=PDF_WIDTH, height=PDF_HEIGHT)
  print(world_map)
  dev.off()
}

