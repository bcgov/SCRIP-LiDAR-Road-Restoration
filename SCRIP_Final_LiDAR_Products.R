# Script for SCRIP Caribou restoration 
#final products agreed on by working group include
#-slope % raster
#-Polygonised mean canopy height 
#-Vegetation density classes 
#-Ground point density

#install if needed
# install.packages("lidR")
# install.packages("raster")
# install.packages("terra")
# install.packages("lidaRtRee")
# install.packages("glue")

library(lidR)
library(raster)
library(lidaRtRee)
library(glue)

#output File Path
dem_out_path<-"/gr_2025_271_lidar_restoration/work/lidr_outputs/20260107/dem"
chm_out_path<-"/gr_2025_271_lidar_restoration/work/lidr_outputs/20260107/chm_mean"
veg_out_path<-"/gr_2025_271_lidar_restoration/work/lidr_outputs/20260107/vegetaion_denisty"
gnd_out_path<-"/gr_2025_271_lidar_restoration/work/lidr_outputs/20260107/ground_denisty"
canopy_out_path<-"/gr_2025_271_lidar_restoration/work/lidr_outputs/20260107/canopy"
under_out_path<- file.path(veg_out_path,'understory')
mid_out_path<- file.path(veg_out_path,'midstory')
over_out_path<- file.path(veg_out_path,'overstory')


#year of data collection
datar_year=2021

# # liDAR map tiles to loop over
pc_list<- list("093p003_1_2_1","093p003_1_2_2","093p003_1_2_3","093p003_1_2_4",
"093p003_1_4_1","093p003_1_4_2","093p003_1_4_4","093p003_2_1_3","093p003_2_3_1","093p003_2_3_2",
"093p003_2_3_3","093p003_2_3_4","093p003_2_4_3","093p003_3_1_4","093p003_3_2_1","093p003_3_2_2",
"093p003_3_2_3","093p003_3_2_4","093p003_3_3_2","093p003_3_3_4","093p003_3_4_1","093p003_3_4_2",
"093p003_3_4_3","093p003_3_4_4","093p003_4_1_1","093p003_4_1_2","093p003_4_1_3","093p003_4_1_4",
"093p003_4_2_1","093p003_4_2_3","093p003_4_2_4","093p003_4_3_1","093p003_4_3_2","093p003_4_3_3",
"093p003_4_3_4","093p003_4_4_1","093p003_4_4_2","093p003_4_4_3","093p003_4_4_4","093p013_1_1_1",
"093p013_1_1_2","093p013_1_1_3","093p013_1_1_4","093p013_1_2_1","093p013_1_2_2","093p013_1_2_3",
"093p013_1_2_4","093p013_1_3_1","093p013_1_3_2","093p013_1_3_3","093p013_1_3_4","093p013_1_4_1",
"093p013_1_4_2","093p013_1_4_3","093p013_1_4_4","093p013_2_1_1","093p013_2_1_2","093p013_2_1_3",
"093p013_2_1_4","093p013_2_2_1","093p013_2_2_3","093p013_2_2_4","093p013_2_3_1","093p013_2_3_2",
"093p013_2_3_3","093p013_2_3_4","093p013_2_4_1","093p013_2_4_2","093p013_2_4_3","093p013_2_4_4",
"093p013_3_1_1","093p013_3_1_2","093p013_3_1_3","093p013_3_1_4","093p013_3_2_1","093p013_3_2_2",
"093p013_3_2_3","093p013_3_2_4","093p013_3_4_1","093p013_3_4_2","093p013_3_4_3","093p013_3_4_4",
"093p013_4_1_1","093p013_4_1_2","093p013_4_1_3","093p013_4_1_4","093p013_4_2_1","093p013_4_2_2",
"093p013_4_2_3","093p013_4_2_4","093p013_4_3_1","093p013_4_3_2","093p013_4_3_3","093p013_4_3_4",
"093p013_4_4_1","093p013_4_4_2","093p013_4_4_3","093p013_4_4_4","093p014_1_3_1","093p014_1_3_3",
"093p014_1_3_4","093p014_1_4_3","093p014_1_4_4","093p014_3_1_1","093p014_3_1_2","093p014_3_1_3",
"093p014_3_1_4","093p014_3_2_1","093p014_3_2_2","093p014_3_2_3","093p014_3_2_4","093p014_3_3_1",
"093p014_3_3_2","093p014_3_3_3","093p014_3_3_4","093p014_3_4_1","093p014_3_4_2","093p014_3_4_3",
"093p014_3_4_4","093p014_4_1_1","093p014_4_1_2","093p014_4_1_3","093p014_4_1_4","093p014_4_2_3",
"093p014_4_2_4","093p014_4_3_1","093p014_4_3_2","093p014_4_3_3","093p014_4_3_4","093p014_4_4_1",
"093p014_4_4_2","093p014_4_4_3","093p014_4_4_4","093p015_3_3_3","093p015_3_3_4","093p015_3_4_1",
"093p015_3_4_2","093p015_3_4_3","093p015_3_4_4","093p015_4_3_1","093p015_4_3_3","093p015_4_3_4",
"093p023_1_2_1","093p023_1_2_2","093p023_2_1_1","093p023_2_1_2","093p023_2_1_4","093p023_2_2_1",
"093p023_2_2_2","093p023_2_2_3","093p023_2_2_4","093p023_2_4_1","093p023_2_4_2","093p024_1_1_1",
"093p024_1_1_2","093p024_1_1_3","093p024_1_1_4","093p024_1_2_1","093p024_1_2_2","093p024_1_2_3",
"093p024_1_2_4","093p024_1_3_1","093p024_1_3_2","093p024_2_1_1","093p024_2_1_2","093p024_2_1_3",
"093p024_2_1_4","093p024_2_2_1","093p024_2_2_2","093p024_2_2_3","093p024_2_2_4","093p024_2_3_1",
"093p024_2_4_1","093p024_2_4_2","093p025_1_1_1","093p025_1_1_2","093p025_1_1_3","093p025_1_1_4",
"093p025_1_2_1","093p025_1_2_2","093p025_1_2_3","093p025_1_3_1","093p025_1_3_2","093p025_2_1_1")


#point cloud locations
lidar_root_dir<-'Location where all .laz files are located'

#defined epsg, if only running part of script
epsg_in=26910
#define size of cells for stats
cell_sz=10
#resolution for density
resolution = 2
cell_area <- resolution^2
veg_height_threshold = 0.5
#empty list for existing DEMS
existing_dem_list <- list()
create_visualizations = TRUE

for (pc in pc_list){
  #check for last point density processed 
  gnd_den_file<-file.path(gnd_out_path, glue("{pc}ground_density.tif"))
  if (file.exists(gnd_den_file)){
    print(glue("{pc} exists, skipping"))
    next
  }
      
  map_grid=substr(pc, 1,3)
  map_grid_letter=substr(pc, 1,4)
  dem_file_=substr(pc, 1,7)
  dem_path<- file.path(lidar_root_dir,map_grid,map_grid_letter,datar_year,'dem')
  pc_path<- file.path(lidar_root_dir,map_grid,map_grid_letter,datar_year,'pointcloud')

  pc_file_path <- list.files(
    pc_path,
    pattern = paste0(pc, ".*\\.laz$"),
    full.names = TRUE,
    ignore.case = TRUE
  )
  print(pc_file_path)
   # Read LAS
   las <- readLAS(pc_file_path)
   # crs(las) <- epsg_in
   print('laz read in to memory')
   
   #~~~ Step 1 DEM
   dtm <- rasterize_terrain(las = las, res = 1, algorithm = tin())
   dtm_path<- file.path(dem_out_path,glue("{pc}_slope.tif"))
   slope <- terrain(dtm, v = "slope", unit = "degrees")
   slope_percent <- tan(slope * pi / 180) * 100
   crs(slope_percent)<-st_crs(epsg_in)$wkt
   writeRaster(slope_percent, filename = dtm_path, filetype = "GTiff", overwrite = TRUE)

 ## ~~~~ Step 2: Polygonised mean canopy height ~~~~
 #normalize point cloud
   nlas_dtm <- normalize_height(las = las, algorithm = dtm)
   print('normalized')
 #   #create chm
   chm <- rasterize_canopy(las = nlas_dtm, res = 0.5, algorithm = p2r(subcircle = 0.15))
   #calculate mean height in 10x10 pixel
   las_first <- filter_first(nlas_dtm)
   mean_height <- pixel_metrics(las = las_first, func = ~mean(Z), res = cell_sz)
   mean_height_path<- file.path(chm_out_path,glue("{pc}_mean_height_{cell_sz}.tif"))
   crs(mean_height)<-st_crs(epsg_in)$wkt
   writeRaster(mean_height, filename = mean_height_path, filetype = "GTiff", overwrite = TRUE)

 # #~~~ Step3 Vegetation density classes  ~~~
 #   #For very large datasets, use simplified calculations
   if (length(las$X) > 50000000) {
     cat("Processing vegetation metrics in chunks for memory efficiency...\n")

     # Create processing chunks based on extent
     las_extent <- extent(las)
     x_range <- las_extent@xmax - las_extent@xmin
     y_range <- las_extent@ymax - las_extent@ymin

     # Determine number of chunks (aim for ~20M points per chunk)
     n_chunks_x <- ceiling(sqrt(length(las$X) / 20000000))
     n_chunks_y <- n_chunks_x
     chunk_x_size <- x_range / n_chunks_x
     chunk_y_size <- y_range / n_chunks_y
     cat(paste("Processing in", n_chunks_x, "x", n_chunks_y, "chunks\n"))

     # Initialize result rasters
     canopy_cover_list <- list()
     veg_density_list <- list()

     for (i in 1:n_chunks_x) {
       for (j in 1:n_chunks_y) {
         # Define chunk extent
         chunk_xmin <- las_extent@xmin + (i-1) * chunk_x_size
         chunk_xmax <- las_extent@xmin + i * chunk_x_size
         chunk_ymin <- las_extent@ymin + (j-1) * chunk_y_size
         chunk_ymax <- las_extent@ymin + j * chunk_y_size

         chunk_extent <- extent(chunk_xmin, chunk_xmax, chunk_ymin, chunk_ymax)

         # Clip point cloud to chunk
         chunk_las <- clip_roi(las, chunk_extent)

         if (length(chunk_las$X) > 0) {
           # Process chunk
           chunk_canopy <- grid_metrics(chunk_las, as.formula(paste0("~sum(Z > ", veg_height_threshold, ")/length(Z)*100")),
                                        res = resolution)
           chunk_veg_density <- grid_metrics(chunk_las, as.formula(paste0("~sum(Z > ", veg_height_threshold, ")/", cell_area)),
           res = resolution)

           canopy_cover_list[[length(canopy_cover_list) + 1]] <- chunk_canopy
           veg_density_list[[length(veg_density_list) + 1]] <- chunk_veg_density
         }

         # Clean up chunk
         rm(chunk_las)
         gc()
       }
     }

     # Merge chunks with better error handling
     if (length(canopy_cover_list) > 1) {
       tryCatch({
         canopy_cover <- do.call(merge, canopy_cover_list)
         veg_density <- do.call(merge, veg_density_list)
       }, error = function(e) {
         cat("Warning: Could not merge all chunks, using mosaic approach...\n")

         # Alternative mosaic approach
         canopy_cover_list$fun <- mean
         veg_density_list$fun <- mean
         canopy_cover <- do.call(mosaic, canopy_cover_list)
         veg_density <- do.call(mosaic, veg_density_list)
       })
     } else if (length(canopy_cover_list) == 1) {
       canopy_cover <- canopy_cover_list[[1]]
       veg_density <- veg_density_list[[1]]
     } else {
       stop("No valid chunks processed")
     }

   } else {
     # Process normally for smaller datasets
     canopy_cover <- grid_metrics(nlas_dtm, as.formula(paste0("~sum(Z > ", veg_height_threshold, ")/length(Z)*100")),
                                  res = resolution)

   #   # Point density above threshold (points per square meter)
     veg_density <- grid_metrics(nlas_dtm, as.formula(paste0("~sum(Z > ", veg_height_threshold, ")/", cell_area)), res = resolution)
   }

   # canopy_cover_path<- file.path(canopy_out_path,glue("{pc}_canopy_cover_{resolution}.tif"))
   # crs(canopy_cover)<-epsg_in
   # terra::writeRaster(canopy_cover, filename = canopy_cover_path, filetype = "GTiff", overwrite = TRUE)
   veg_desnity_path<- file.path(veg_out_path,glue("{pc}_vegetation_density_{resolution}.tif"))
   crs(veg_density)<-st_crs(epsg_in)$wkt
   writeRaster(veg_density, veg_desnity_path, overwrite = TRUE)

   # Force garbage collection after major operations
   gc()

   # Stratified density metrics (simplified for memory efficiency)
   cat("Calculating stratified density metrics...\n")

   # For very large datasets, use simplified calculations
   if (length(nlas_dtm$X) > 50000000) {
     cat("Using simplified stratified calculations for large dataset...\n")

     # Use a sample of points for stratified analysis to save memory
     sample_size <- min(10000000, length(nlas_dtm$X))  # Use max 10M points for stratification
     sample_indices <- sample(1:length(nlas_dtm$X), sample_size)
     las_sample <- nlas_dtm[sample_indices]

     # Understory (0.5m - 2m)
     understory_density <- grid_metrics(nlas_dtm, as.formula(paste0("~sum(Z > ", veg_height_threshold, " & Z <= 2)/length(Z)*100")),
                                        res = resolution * 2)  # Lower resolution for memory
     understory_density <- resample(understory_density, canopy_cover)  # Resample to match main grid

     # Midstory (2m - 10m)
     midstory_density <- grid_metrics(nlas_dtm, as.formula("~sum(Z > 2 & Z <= 10)/length(Z)*100"),
                                      res = resolution * 2)
     midstory_density <- resample(midstory_density, canopy_cover)

     # Overstory (>10m)
     overstory_density <- grid_metrics(nlas_dtm, as.formula("~sum(Z > 10)/length(Z)*100"),
                                       res = resolution * 2)
     overstory_density <- resample(overstory_density, canopy_cover)

     rm(las_sample)
     gc()

   } else {
     # Full resolution for smaller datasets
     # Understory (0.5m - 2m)
     understory_density <- grid_metrics(nlas_dtm, as.formula(paste0("~sum(Z > ", veg_height_threshold, " & Z <= 2)/length(Z)*100")), res = resolution)

     # Midstory (2m - 10m)
     midstory_density <- grid_metrics(nlas_dtm, as.formula("~sum(Z > 2 & Z <= 10)/length(Z)*100"), res = resolution)

     # Overstory (>10m)
     overstory_density <- grid_metrics(nlas_dtm, as.formula("~sum(Z > 10)/length(Z)*100"), res = resolution)
   }
   crs(understory_density)<-st_crs(epsg_in)$wkt
   writeRaster(understory_density, file.path(under_out_path, glue("{pc}understory_density.tif")), overwrite = TRUE)
   crs(midstory_density)<-st_crs(epsg_in)$wkt
   writeRaster(midstory_density, file.path(mid_out_path, glue("{pc}_midstory_density.tif")), overwrite = TRUE)
   crs(overstory_density)<-st_crs(epsg_in)$wkt
   writeRaster(overstory_density, file.path(over_out_path, glue("{pc}_overstory_density.tif")), overwrite = TRUE)

 #~~~ Step 4 Ground point density ~~~~
   cat("Calculating ground point density...\n")
   ground_las <- filter_poi(nlas_dtm, Classification == 2)
   ground_density <- grid_metrics(ground_las, as.formula(paste0("~length(Z)/", cell_area)), res = resolution)
   crs(ground_density)<-st_crs(epsg_in)$wkt
   writeRaster(ground_density, file.path(gnd_out_path, glue("{pc}ground_density.tif")), overwrite = TRUE)
  }

