#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

suppressMessages(library(ggplot2))
suppressMessages(library(scatterpie))

#############################################################################
# Feel free to edit the stuff below
#############################################################################
if (length(args)==1) {
    DATA_FILE = args[1]
    GRADIENT_FILE = NA
} else if (length(args)==2) {
    DATA_FILE = args[1]
    GRADIENT_FILE = args[2]
} else {
    # default file if one isn't passed through command line. you can edit this to be yours
    DATA_FILE = "./data.txt"
    GRADIENT_FILE = NA
}

CIRCLE_SIZE_PREFIX_IN_DATA_FILE="MAG_"
CIRCLE_DYNAMIC_COLOR_PREFIX_IN_DATA_FILE="COLOR_"
GRADIENT_COLUMN_NAME = ""

# shape file. if you have a shapefile to work with, describe it here. if you
# fill in this variable, the code will use your shape file instead of the
# low resolution default world map (please see the README if you are not sure
# what is going on and would like to learn more):
SHAPEFILE=""

# if you want to plot all the values in pie charts within a single map PDF,
# change this variable to TRUE
PLOT_AS_PIE_CHARTS=FALSE
# if you want the pie chart radius to be scaled according to max value per row, 
# change this variable to TRUE
ADJUST_PIE_RADIUS=FALSE
# if you want to set an exact pie chart radius, do it below
EXACT_PIE_RADIUS = NA

# size of sample points in pie chart mode
# set this so that the points are small enough to not obscure the pie charts
POINT_SIZE = 1

# Interface toys down below
FONT_SIZE <- 2 # set it to 0 to see no labels
FONT_COLOR="black"

# If you want each circle on the map to be colored according to a color gradient,
# provide low- and high-value colors. Otherwise, set CIRCLE_COLOR_LOW to your
# static color of interest (CIRCLE_COLOR_HIGH will be ignored).
CIRCLE_COLOR_LOW="red"
CIRCLE_COLOR_HIGH="yellow"

# If your COLOR columns contain literal color values (e.g., "#FF0000", "red"),
# set this to TRUE. When FALSE, color values are treated as numeric and mapped
# to the gradient defined by CIRCLE_COLOR_LOW and CIRCLE_COLOR_HIGH.
USE_LITERAL_COLORS=TRUE

# translucency of circles. 1 is opaque, 0 is transparent
ALPHA <- 0.90

# thickness of border around each circle. 0 for no border
CIRCLE_BORDER_WIDTH <- 0.1

# scaling points
MIN_POINT_SIZE <- 0.2
MAX_POINT_SIZE <- 15

MARGIN_MIN_LAT <- -5
MARGIN_MAX_LAT <- 5
MARGIN_MIN_LON <- -5
MARGIN_MAX_LON <- 5
MARGIN_LEGEND <- 1

# set this to TRUE if you want the plot to show the full map, regardless of min/max coordinates of samples
USE_FULL_MAP <- FALSE

PDF_WIDTH <- 12
PDF_HEIGHT <- 5.5

#############################################################################

gen_blank_world_map_simple <- function(df) {
  suppressMessages(library(maps))

  world_map <- map_data("world")

  min_lat <- min(df$Lat) + MARGIN_MIN_LAT
  max_lat <- max(df$Lat) + MARGIN_MAX_LAT
  min_lon <- min(df$Lon) + MARGIN_MIN_LON
  max_lon <- max(df$Lon) + MARGIN_MAX_LON
  
  if(USE_FULL_MAP){
    min_lat <- min(world_map$lat)
    max_lat <- max(world_map$lat)
    min_lon <- min(world_map$long)
    max_lon <- max(world_map$long)
  }

  p <- ggplot(data=world_map,aes(x=long, y=lat, group=group))
  p <- p + geom_polygon(fill = '#777777')
  p <- p + coord_cartesian(xlim = c(min_lon, max_lon),
                           ylim = c(min_lat, max_lat))

  return(p)
}

gen_blank_world_map_with_shape_file <- function(df) {
  suppressMessages(library(rgdal))
  suppressMessages(library(raster))

  world_map <- fortify(shapefile(SHAPEFILE))

  min_lat <- min(df$Lat) + MARGIN_MIN_LAT
  max_lat <- max(df$Lat) + MARGIN_MAX_LAT
  min_lon <- min(df$Lon) + MARGIN_MIN_LON
  max_lon <- max(df$Lon) + MARGIN_MAX_LON
  
  if(USE_FULL_MAP){
    min_lat <- min(world_map$lat)
    max_lat <- max(world_map$lat)
    min_lon <- min(world_map$long)
    max_lon <- max(world_map$long)
  }

  p <- ggplot()
  p <- ggplot(data=world_map,aes(x=long, y=lat, group=group))
  p <- p + geom_polygon(fill = '#777777', size = 10)
  p <- p + coord_map(projection = "mercator", xlim = c(min_lon, max_lon),
  ylim = c(min_lat, max_lat))

  return(p)
}

add_mag_abundances <- function(plot_object, df, mag, mag_color=NULL, color_low=NULL, color_high=NULL, alpha=0.2, labels = TRUE){
  if (!is.null(mag_color)) {
    if (USE_LITERAL_COLORS) {
      plot_object <- plot_object + geom_point(data = df,
                                              aes(x=Lon, y=Lat,
                                                  group=.data[[mag]],
                                                  size=.data[[mag]],
                                                  color=.data[[mag_color]]),
                                              stroke = 0,
                                              alpha=ALPHA)

      plot_object <- plot_object + scale_colour_identity()
    } else {
      plot_object <- plot_object + geom_point(data = df,
                                              aes(x=Lon, y=Lat,
                                                  group=.data[[mag]],
                                                  size=.data[[mag]],
                                                  color=.data[[mag_color]]),
                                              stroke = 0,
                                              alpha=ALPHA)

      plot_object <- plot_object + scale_colour_gradient(low = color_low, high = color_high)
    }

  } else {
    plot_object <- plot_object + geom_point(data = df,
                                            aes(x=Lon, y=Lat,
                                                group=.data[[mag]],
                                                size=.data[[mag]]),
                                            color=CIRCLE_COLOR_LOW,
                                            stroke = 0,
                                            alpha=ALPHA)
  }

  if (CIRCLE_BORDER_WIDTH == 0) {
    # borders have lower limit stroke thickness
    alpha_for_border = 0
  } else {
    alpha_for_border = ALPHA
  }
  plot_object <- plot_object + geom_point(data = df,
                                          shape = 21,
                                          colour = "black",
                                          aes(x=Lon, y=Lat,
                                              group=.data[[mag]],
                                              size=.data[[mag]]),
                                          stroke = CIRCLE_BORDER_WIDTH,
                                          alpha=alpha_for_border)

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

add_mag_pie_charts <- function(plot_object, df, columns_to_plot){
  # add a dot in the center of each sample
  plot_object <- plot_object + geom_point(data=df,
                                          aes(x=Lon, y=Lat, group=NA),
                                          size = POINT_SIZE)
  
  if (ADJUST_PIE_RADIUS){
    df$radius = apply(df[,4:ncol(df)], 1, max)
    legend_lat <- min(df$Lat) + MARGIN_MIN_LAT + MARGIN_LEGEND
    legend_lon <- min(df$Lon) + MARGIN_MIN_LON + MARGIN_LEGEND
    
    plot_object <- plot_object + geom_scatterpie(data=df,
                                                 aes(x=Lon, y=Lat, r=radius), 
                                                 cols=columns_to_plot,
                                                 alpha=0.8) +
                                 geom_scatterpie_legend(df$radius, x=legend_lon , y=legend_lat)
  } else if (!is.na(EXACT_PIE_RADIUS)) {
    plot_object <- plot_object + geom_scatterpie(data=df,
                                                 aes(x=Lon, y=Lat, r=EXACT_PIE_RADIUS), 
                                                 cols=columns_to_plot,
                                                 alpha=0.8)
  } else {
    plot_object <- plot_object + geom_scatterpie(data=df,
                                                 aes(x=Lon, y=Lat), 
                                                 cols=columns_to_plot,
                                                 alpha=0.8)
  }
  
  return(plot_object)
}

add_raster_data <- function(plot_object, raster_df){
  
  if (GRADIENT_COLUMN_NAME == "") {
    GRADIENT_COLUMN_NAME = colnames(raster_df)[3]
  }
  
  plot_object <- plot_object + 
    geom_raster(data=raster_df, aes(x=Lon, y=Lat, fill=.data[[GRADIENT_COLUMN_NAME]], group=NA)) +
    scale_fill_viridis_c(name=GRADIENT_COLUMN_NAME)
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
df <- read.table(file = DATA_FILE,
                 header = TRUE,
                 sep = "\t",
                 quote = "",
                 comment.char = '!')

# remove rows with all NAs
pre_ncol <- ncol(df)
df <- df[,which(unlist(lapply(df, function(x)!all(is.na(x)))))]
post_ncol <- ncol(df)
diff_ncol <- pre_ncol - post_ncol
cat(sprintf("Removed %s columns containing only NA values\n", diff_ncol))


# learn about columns that show distribution of MAGs
MAGs <- names(df)[startsWith(names(df), CIRCLE_SIZE_PREFIX_IN_DATA_FILE)]

# go through each MAG, and create a single image.
if (!PLOT_AS_PIE_CHARTS){
  for (MAG in MAGs){
    cat(sprintf("Working on %s", MAG))
  
    # sort out the colors
    if (CIRCLE_DYNAMIC_COLOR_PREFIX_IN_DATA_FILE == "") {
      # no color columns. just use static color
      color_column = NULL
      cat(sprintf(" ... dynamic color [-]", MAG))
    } else {
      # search for corresponding color column for MAG
      suffix <- gsub(CIRCLE_SIZE_PREFIX_IN_DATA_FILE, "", MAG)
      color_column <- paste(CIRCLE_DYNAMIC_COLOR_PREFIX_IN_DATA_FILE, suffix, sep="")
  
      if (!(color_column %in% colnames(df))) {
        color_column <- NULL
        cat(sprintf(" ... dynamic color [-]"))
      } else {
        cat(sprintf(" ... dynamic color [+]"))
      }
    }
  
    # get a blank world map
    if (is.na(SHAPEFILE) || SHAPEFILE == '')
      world_map <- gen_blank_world_map_simple(df)
    else
      world_map <- gen_blank_world_map_with_shape_file(df)
    
    # add underlying gradient
    if (!is.na(GRADIENT_FILE)) {
      raster_file <- read.table(GRADIENT_FILE, header=TRUE, sep="\t")
      world_map <- add_raster_data(world_map, raster_file)
    }
  
    # add mag abundances on the canvas
    world_map <- add_mag_abundances(world_map, df, MAG, mag_color=color_column, color_low=CIRCLE_COLOR_LOW, color_high=CIRCLE_COLOR_HIGH, alpha=ALPHA)
    
    # clean it up
    world_map <- clean_map(world_map)
  
    # save it
    cat(sprintf(" ... generating the figure"))
    pdf(paste(MAG, '.pdf', sep=''), width=PDF_WIDTH, height=PDF_HEIGHT)
    print(world_map)
    dev.off()
    cat(sprintf(" ... OK\n"))
  }
} else {
  # convert any remaining NAs to 0s
  num_na = sum(is.na(df))
  cat(sprintf("There are %s NAs in the data. These will be replaced by 0s.\n", num_na))
  df[is.na(df)] <- 0.0
  
  # get a blank world map
  if (is.na(SHAPEFILE) || SHAPEFILE == '')
    world_map <- gen_blank_world_map_simple(df)
  else
    world_map <- gen_blank_world_map_with_shape_file(df)
  
  # add underlying gradient
  if (!is.na(GRADIENT_FILE)) {
    raster_file <- read.table(GRADIENT_FILE, header=TRUE, sep="\t")
    world_map <- add_raster_data(world_map, raster_file)
  }
  
  # add the pie charts
  world_map <- add_mag_pie_charts(world_map, df, MAGs)
  
  # clean it up
  world_map <- clean_map(world_map)
  
  # save it
  cat(sprintf(" ... generating the figure"))
  pdf(paste('ALL_', CIRCLE_SIZE_PREFIX_IN_DATA_FILE, 'PIE_CHARTS.pdf', sep=''), width=PDF_WIDTH, height=PDF_HEIGHT)
  print(world_map)
  dev.off()
  cat(sprintf(" ... OK\n"))
}

