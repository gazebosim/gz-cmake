gz_create_core_library(INTERFACE)

# Created here instead of being listed in the COMPONENTS of gz_configure_build,
# as gz-sensors and gz-sim do.
gz_add_component(from_src INTERFACE)
