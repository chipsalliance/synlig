create_project -in_memory -part xc7a200tsbg484-1 xx

read_edif top_earlgrey_nexysvideo.edif
read_xdc lowrisc_systems_top_earlgrey_nexysvideo_0.1/src/lowrisc_systems_top_earlgrey_nexysvideo_0.1/data/pins_nexysvideo.xdc
link_design -top top_earlgrey_nexysvideo -part xc7a200tsbg484-1

opt_design

place_design
route_design

write_bitstream -force top.bit
