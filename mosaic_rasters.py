import rasterio
from rasterio.merge import merge
from rasterio.plot import show
import os 
import glob 


base_dir=r"gr_2025_271_lidar_restoration\work\lidr_outputs\20260107"
output=r'gr_2025_271_lidar_restoration\deliverables\data\mosaics\20260126'

folders={'chm_mean':'mean_height_10','dem':'slope','ground_denisty':'ground_density',
'vegetaion_denisty':'vegetation_density_2','midstory':'midstory_density','overstory':'overstory_density','understory':'understory_density'}


for f in folders:
    search_criteria=f"*{folders[f]}.tif"
    if f in ['overstory','understory','midstory']:
        q=os.path.join(base_dir,'vegetaion_denisty',f,search_criteria)
    else:
        q=os.path.join(base_dir,f,search_criteria)
    fps = glob.glob(q)
    src_files_to_mosaic = []
    for fp in fps:
        src=rasterio.open(fp)
        src_files_to_mosaic.append(src)
    
    mosaic, out_trans = merge(src_files_to_mosaic)
    out_meta = src.meta.copy()
    out_meta.update({"driver": "GTiff",
                "height": mosaic.shape[1],
                "width": mosaic.shape[2],
                "transform": out_trans
                # "crs": "+proj=utm +zone=35 +ellps=GRS80 +units=m +no_defs "
    })
    out_fp=os.path.join(output,f"{f}.tif")
    with rasterio.open(out_fp, "w", **out_meta) as dest:
        dest.write(mosaic)
    print(f"{f} mosaic-ed")


   


