execute_process(
  COMMAND hg id --id
  WORKING_DIRECTORY ${repository_root}
  OUTPUT_VARIABLE HG_GLOBAL_REVISION
  OUTPUT_STRIP_TRAILING_WHITESPACE
)
execute_process(
  COMMAND hg id --num
  WORKING_DIRECTORY ${repository_root}
  OUTPUT_VARIABLE HG_REVISION_NUM
  OUTPUT_STRIP_TRAILING_WHITESPACE
)
execute_process(
  COMMAND hg id --branch
  WORKING_DIRECTORY ${repository_root}
  OUTPUT_VARIABLE HG_BRANCH
  OUTPUT_STRIP_TRAILING_WHITESPACE
)

string(TIMESTAMP build_time)

cmake_host_system_information(RESULT NUM_LOGICAL QUERY NUMBER_OF_LOGICAL_CORES)
cmake_host_system_information(RESULT NUM_PHYSICAL QUERY NUMBER_OF_PHYSICAL_CORES)
cmake_host_system_information(RESULT HOST QUERY HOSTNAME)
cmake_host_system_information(RESULT FQDN QUERY FQDN)
cmake_host_system_information(RESULT TOTAL_VIRTUAL QUERY TOTAL_VIRTUAL_MEMORY)
cmake_host_system_information(RESULT AVAILABLE_VIRTUAL QUERY AVAILABLE_VIRTUAL_MEMORY)
cmake_host_system_information(RESULT TOTAL_PHYSICAL QUERY TOTAL_PHYSICAL_MEMORY)
cmake_host_system_information(RESULT AVAILABLE_PHYSICAL QUERY AVAILABLE_PHYSICAL_MEMORY)
cmake_host_system_information(RESULT PROC_NAME QUERY PROCESSOR_NAME)
cmake_host_system_information(RESULT PROC_DESC QUERY PROCESSOR_DESCRIPTION)
cmake_host_system_information(RESULT PROC_SERIAL QUERY PROCESSOR_SERIAL_NUMBER)
cmake_host_system_information(RESULT OS_NAME QUERY OS_NAME)
cmake_host_system_information(RESULT OS_RELEASE QUERY OS_RELEASE)
cmake_host_system_information(RESULT OS_VERSION QUERY OS_VERSION)
cmake_host_system_information(RESULT OS_PLATFORM QUERY OS_PLATFORM)


configure_file(${input_file} ${output_file})
