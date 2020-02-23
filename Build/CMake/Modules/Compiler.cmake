ADD_DEFINITIONS(-DUNICODE -D_UNICODE)

IF(CMAKE_C_COMPILER_ID MATCHES MSVC)
	SET(KLAYGE_COMPILER_NAME "vc")
	SET(KLAYGE_COMPILER_MSVC TRUE)
	IF(MSVC_VERSION GREATER_EQUAL 1920)
		SET(KLAYGE_COMPILER_VERSION "142")
	ELSEIF(MSVC_VERSION GREATER_EQUAL 1910)
		SET(KLAYGE_COMPILER_VERSION "141")
	ELSE()
		SET(KLAYGE_COMPILER_VERSION "140")
	ENDIF()

	if(KLAYGE_PLATFORM_WINDOWS_STORE)
		if(MSVC_VERSION LESS 1911)
			message(FATAL_ERROR "You need VS2017 15.3+ to build UWP configurations.")
		endif()
	endif()

	SET(CMAKE_CXX_FLAGS "/W4 /WX /EHsc /MP /bigobj /Zc:throwingNew /Zc:strictStrings /Zc:rvalueCast /Gw")
	IF(MSVC_VERSION GREATER 1910)
		SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /std:c++17")
	ELSE()
		SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /std:c++14")
	ENDIF()
	IF(MSVC_VERSION GREATER 1900)
		SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /permissive-")

		IF(MSVC_VERSION GREATER 1910)
			IF(KLAYGE_PLATFORM_WINDOWS_STORE OR (KLAYGE_ARCH_NAME STREQUAL "arm64"))
				SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /Zc:twoPhase-")
			ENDIF()
			IF(MSVC_VERSION GREATER 1912)
				SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /Zc:externConstexpr")
			ENDIF()
		ENDIF()
	ENDIF()
	SET(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /DKLAYGE_SHIP /fp:fast /Ob2 /GL /Qpar")
	SET(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO} /fp:fast /Ob2 /GL /Qpar")
	SET(CMAKE_CXX_FLAGS_MINSIZEREL "${CMAKE_CXX_FLAGS_MINSIZEREL} /fp:fast /Ob1 /GL /Qpar")
	IF((MSVC_VERSION GREATER 1912) AND (KLAYGE_ARCH_NAME STREQUAL "x64"))
		#SET(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /Qspectre")
	ENDIF()
	if(MSVC_VERSION GREATER 1915)
		set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /JMC")
	endif()

	FOREACH(flag_var
		CMAKE_EXE_LINKER_FLAGS CMAKE_SHARED_LINKER_FLAGS CMAKE_MODULE_LINKER_FLAGS)
		SET(${flag_var} "/WX /pdbcompress")
	ENDFOREACH()
	FOREACH(flag_var
		CMAKE_EXE_LINKER_FLAGS_DEBUG CMAKE_SHARED_LINKER_FLAGS_DEBUG)
		SET(${flag_var} "/DEBUG:FASTLINK")
	ENDFOREACH()
	FOREACH(flag_var
		CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO)
		SET(${flag_var} "/DEBUG:FASTLINK /INCREMENTAL:NO /LTCG:incremental /OPT:REF /OPT:ICF")
	ENDFOREACH()
	FOREACH(flag_var
		CMAKE_EXE_LINKER_FLAGS_MINSIZEREL CMAKE_SHARED_LINKER_FLAGS_MINSIZEREL CMAKE_EXE_LINKER_FLAGS_RELEASE CMAKE_SHARED_LINKER_FLAGS_RELEASE)
		SET(${flag_var} "/INCREMENTAL:NO /LTCG /OPT:REF /OPT:ICF")
	ENDFOREACH()
	FOREACH(flag_var
		CMAKE_MODULE_LINKER_FLAGS_RELEASE CMAKE_MODULE_LINKER_FLAGS_MINSIZEREL)
		SET(${flag_var} "/INCREMENTAL:NO /LTCG")
	ENDFOREACH()
	FOREACH(flag_var
		CMAKE_STATIC_LINKER_FLAGS_RELEASE CMAKE_STATIC_LINKER_FLAGS_MINSIZEREL)
		SET(${flag_var} "${${flag_var}} /LTCG")
	ENDFOREACH()
	SET(CMAKE_STATIC_LINKER_FLAGS_RELWITHDEBINFO "${CMAKE_STATIC_LINKER_FLAGS_RELWITHDEBINFO} /LTCG:incremental")

	IF(KLAYGE_ARCH_NAME MATCHES "x86")
		FOREACH(flag_var
			CMAKE_CXX_FLAGS_RELEASE CMAKE_CXX_FLAGS_RELWITHDEBINFO CMAKE_CXX_FLAGS_MINSIZEREL)
			SET(${flag_var} "${${flag_var}} /arch:SSE")
		ENDFOREACH()
		FOREACH(flag_var
			CMAKE_EXE_LINKER_FLAGS CMAKE_SHARED_LINKER_FLAGS)
			SET(${flag_var} "${${flag_var}} /LARGEADDRESSAWARE")
		ENDFOREACH()
	ENDIF()

	ADD_DEFINITIONS(-DWIN32 -D_WINDOWS)
	IF(KLAYGE_ARCH_NAME MATCHES "arm")
		ADD_DEFINITIONS(-D_ARM_WINAPI_PARTITION_DESKTOP_SDK_AVAILABLE=1)

		IF(KLAYGE_PLATFORM_WINDOWS_DESKTOP)
			FOREACH(flag_var
				CMAKE_C_STANDARD_LIBRARIES CMAKE_CXX_STANDARD_LIBRARIES)
				SET(${flag_var} "${${flag_var}} gdi32.lib ole32.lib oleaut32.lib comdlg32.lib advapi32.lib shell32.lib")
			ENDFOREACH()
		ENDIF()
	ENDIF()

	IF(KLAYGE_PLATFORM_WINDOWS_STORE)
		FOREACH(flag_var
			CMAKE_EXE_LINKER_FLAGS_DEBUG CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO CMAKE_SHARED_LINKER_FLAGS_DEBUG CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO)
			SET(${flag_var} "${${flag_var}} /INCREMENTAL:NO")
		ENDFOREACH()
	ELSE()
		FOREACH(flag_var
			CMAKE_CXX_FLAGS_RELEASE CMAKE_CXX_FLAGS_RELWITHDEBINFO CMAKE_CXX_FLAGS_MINSIZEREL)
			SET(${flag_var} "${${flag_var}} /GS-")
		ENDFOREACH()

		SET(CMAKE_STATIC_LINKER_FLAGS "/WX")
	ENDIF()

	SET(CMAKE_C_FLAGS ${CMAKE_CXX_FLAGS})
ELSE()
	IF(CMAKE_C_COMPILER_ID MATCHES Clang)
		SET(KLAYGE_COMPILER_NAME "clang")
		SET(KLAYGE_COMPILER_CLANG TRUE)
	ELSEIF(MINGW)
		SET(KLAYGE_COMPILER_NAME "mgw")
		SET(KLAYGE_COMPILER_GCC TRUE)
	ELSE()
		SET(KLAYGE_COMPILER_NAME "gcc")
		SET(KLAYGE_COMPILER_GCC TRUE)
	ENDIF()
	IF((NOT MSVC) AND KLAYGE_PLATFORM_WINDOWS)
		ADD_DEFINITIONS(-D_WIN32_WINNT=0x0601 -DWINVER=_WIN32_WINNT)
	ENDIF()

	IF(KLAYGE_COMPILER_CLANG)
		EXECUTE_PROCESS(COMMAND ${CMAKE_C_COMPILER} --version OUTPUT_VARIABLE CLANG_VERSION)
		STRING(REGEX MATCHALL "[0-9]+" CLANG_VERSION_COMPONENTS ${CLANG_VERSION})
		LIST(GET CLANG_VERSION_COMPONENTS 0 CLANG_MAJOR)
		LIST(GET CLANG_VERSION_COMPONENTS 1 CLANG_MINOR)
		SET(KLAYGE_COMPILER_VERSION ${CLANG_MAJOR}${CLANG_MINOR})
	ELSE()
		EXECUTE_PROCESS(COMMAND ${CMAKE_C_COMPILER} -dumpfullversion OUTPUT_VARIABLE GCC_VERSION)
		STRING(REGEX MATCHALL "[0-9]+" GCC_VERSION_COMPONENTS ${GCC_VERSION})
		LIST(GET GCC_VERSION_COMPONENTS 0 GCC_MAJOR)
		LIST(GET GCC_VERSION_COMPONENTS 1 GCC_MINOR)
		SET(KLAYGE_COMPILER_VERSION ${GCC_MAJOR}${GCC_MINOR})
	ENDIF()

	FOREACH(flag_var
		CMAKE_C_FLAGS CMAKE_CXX_FLAGS)
		SET(${flag_var} "${${flag_var}} -W -Wall -Werror -fpic")
		IF(NOT (ANDROID OR IOS))
			SET(${flag_var} "${${flag_var}} -march=core2 -msse2")
		ENDIF()
		IF(KLAYGE_COMPILER_CLANG AND (KLAYGE_PLATFORM_DARWIN OR KLAYGE_PLATFORM_IOS))
			SET(${flag_var} "${${flag_var}} -fno-asm-blocks")
		ENDIF()
	ENDFOREACH()
	SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=c11")
	IF(KLAYGE_COMPILER_CLANG)
		IF(MSVC)
			SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++14")
		ELSE()
			SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++1z")
		ENDIF()
		SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-inconsistent-missing-override -Wno-missing-braces")
		IF(KLAYGE_PLATFORM_LINUX)
			SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libc++")
		ENDIF()
	ELSE()
		SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++1z")
		IF(MINGW)
			FOREACH(flag_var
				CMAKE_C_FLAGS CMAKE_CXX_FLAGS)
				SET(${flag_var} "${${flag_var}} -Wa,-mbig-obj")
			ENDFOREACH()
		ENDIF()
	ENDIF()
	SET(CMAKE_CXX_FLAGS_DEBUG "-DDEBUG -g -O0")
	SET(CMAKE_CXX_FLAGS_RELEASE "-DNDEBUG -O2 -DKLAYGE_SHIP")
	SET(CMAKE_CXX_FLAGS_RELWITHDEBINFO "-DNDEBUG -g -O2")
	SET(CMAKE_CXX_FLAGS_MINSIZEREL "-DNDEBUG -Os")
	IF(KLAYGE_ARCH_NAME STREQUAL "x86")
		FOREACH(flag_var
			CMAKE_C_FLAGS CMAKE_CXX_FLAGS)
			SET(${flag_var} "${${flag_var}} -m32")
		ENDFOREACH()
		IF(NOT MSVC)
			FOREACH(flag_var
				CMAKE_SHARED_LINKER_FLAGS CMAKE_MODULE_LINKER_FLAGS CMAKE_EXE_LINKER_FLAGS)
				SET(${flag_var} "${${flag_var}} -m32")
				IF(KLAYGE_PLATFORM_WINDOWS)
					SET(${flag_var} "${${flag_var}} -Wl,--large-address-aware")
				ENDIF()
			ENDFOREACH()
			IF(KLAYGE_PLATFORM_WINDOWS)
				SET(CMAKE_RC_FLAGS "${CMAKE_RC_FLAGS} --target=pe-i386")
			ELSE()
				SET(CMAKE_RC_FLAGS "${CMAKE_RC_FLAGS} --target=elf32-i386")
			ENDIF()
		ENDIF()
	ELSEIF((KLAYGE_ARCH_NAME STREQUAL "x64") OR (KLAYGE_ARCH_NAME STREQUAL "x86_64"))
		FOREACH(flag_var
			CMAKE_C_FLAGS CMAKE_CXX_FLAGS)
			SET(${flag_var} "${${flag_var}} -m64")
		ENDFOREACH()
		IF(NOT MSVC)
			FOREACH(flag_var
				CMAKE_SHARED_LINKER_FLAGS CMAKE_MODULE_LINKER_FLAGS CMAKE_EXE_LINKER_FLAGS)
				SET(${flag_var} "${${flag_var}} -m64")
			ENDFOREACH()
			IF(KLAYGE_PLATFORM_WINDOWS)
				SET(CMAKE_RC_FLAGS "${CMAKE_RC_FLAGS} --target=pe-x86-64")
			ELSE()
				SET(CMAKE_RC_FLAGS "${CMAKE_RC_FLAGS} --target=elf64-x86-64")
			ENDIF()
		ENDIF()
	ENDIF()
	IF((NOT MSVC) AND (NOT KLAYGE_HOST_PLATFORM_DARWIN))
		FOREACH(flag_var
			CMAKE_SHARED_LINKER_FLAGS_RELEASE CMAKE_SHARED_LINKER_FLAGS_MINSIZEREL
			CMAKE_MODULE_LINKER_FLAGS_RELEASE CMAKE_MODULE_LINKER_FLAGS_MINSIZEREL
			CMAKE_EXE_LINKER_FLAGS_RELEASE CMAKE_EXE_LINKER_FLAGS_MINSIZEREL)
			SET(${flag_var} "-s")
		ENDFOREACH()
	ENDIF()
ENDIF()

SET(CMAKE_C_FLAGS_DEBUG ${CMAKE_CXX_FLAGS_DEBUG})
SET(CMAKE_C_FLAGS_RELEASE ${CMAKE_CXX_FLAGS_RELEASE})
SET(CMAKE_C_FLAGS_RELWITHDEBINFO ${CMAKE_CXX_FLAGS_RELWITHDEBINFO})
SET(CMAKE_C_FLAGS_MINSIZEREL ${CMAKE_CXX_FLAGS_MINSIZEREL})
IF(KLAYGE_COMPILER_MSVC)
	SET(RTTI_FLAG "/GR")
	SET(NO_RTTI_FLAG "/GR-")
ELSE()
	SET(RTTI_FLAG "-frtti")
	SET(NO_RTTI_FLAG "-fno-rtti")
ENDIF()
SET(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} ${RTTI_FLAG}")
FOREACH(flag_var
	CMAKE_CXX_FLAGS_RELEASE CMAKE_CXX_FLAGS_RELWITHDEBINFO CMAKE_CXX_FLAGS_MINSIZEREL)
	SET(${flag_var} "${${flag_var}} ${NO_RTTI_FLAG}")
ENDFOREACH()
IF(KLAYGE_PLATFORM_ANDROID)
	FOREACH(flag_var
		CMAKE_C_FLAGS CMAKE_CXX_FLAGS)
		SET(${flag_var} "${${flag_var}} -D__ANDROID_API__=${ANDROID_NATIVE_API_LEVEL}")
	ENDFOREACH()

	# TODO: Figure out why LINK_DIRECTORIES doesn't work for ${ANDROID_STL_LIBRARY_DIRS}
	SET(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -L${ANDROID_STL_LIBRARY_DIRS}")
ENDIF()

SET(KLAYGE_OUTPUT_SUFFIX _${KLAYGE_COMPILER_NAME}${KLAYGE_COMPILER_VERSION})

IF(MSVC)
	# create vcproj.user file for Visual Studio to set debug working directory
	FUNCTION(CREATE_VCPROJ_USERFILE TARGETNAME)
		SET(SYSTEM_NAME $ENV{USERDOMAIN})
		SET(USER_NAME $ENV{USERNAME})

		CONFIGURE_FILE(
			${KLAYGE_CMAKE_MODULE_DIR}/VisualStudio2010UserFile.vcxproj.user.in
			${CMAKE_CURRENT_BINARY_DIR}/${TARGETNAME}.vcxproj.user
			@ONLY
		)
	ENDFUNCTION()
ENDIF()
IF(KLAYGE_PLATFORM_DARWIN OR KLAYGE_PLATFORM_IOS)
	# create .xcscheme file for Xcode to set debug working directory
	FUNCTION(CREATE_XCODE_USERFILE PROJECTNAME TARGETNAME)
		IF(KLAYGE_PLATFORM_DARWIN OR KLAYGE_PLATFORM_IOS)
			SET(SYSTEM_NAME $ENV{USERDOMAIN})
			SET(USER_NAME $ENV{USER})

			CONFIGURE_FILE(
				${KLAYGE_CMAKE_MODULE_DIR}/xcode.xcscheme.in
				${PROJECT_BINARY_DIR}/${PROJECTNAME}.xcodeproj/xcuserdata/${USER_NAME}.xcuserdatad/xcschemes/${TARGETNAME}.xcscheme
				@ONLY
			)
		ENDIF()
	ENDFUNCTION()
ENDIF()
	
FUNCTION(CREATE_PROJECT_USERFILE PROJECTNAME TARGETNAME)
	IF(MSVC)
		CREATE_VCPROJ_USERFILE(${TARGETNAME})
	ELSEIF(KLAYGE_PLATFORM_DARWIN OR KLAYGE_PLATFORM_IOS)
		CREATE_XCODE_USERFILE(${PROJECTNAME} ${TARGETNAME})
	ENDIF()
ENDFUNCTION()

FUNCTION(KLAYGE_ADD_PRECOMPILED_HEADER TARGET_NAME PRECOMPILED_HEADER)
	IF(KLAYGE_COMPILER_MSVC)
		IF(CMAKE_GENERATOR MATCHES "^Visual Studio")
			KLAYGE_ADD_MSVC_PRECOMPILED_HEADER(${TARGET_NAME} ${PRECOMPILED_HEADER})
		ENDIF()
	ELSEIF(KLAYGE_PLATFORM_DARWIN OR KLAYGE_PLATFORM_IOS)
		KLAYGE_ADD_XCODE_PRECOMPILED_HEADER(${TARGET_NAME} ${PRECOMPILED_HEADER})
	ELSE()
		KLAYGE_ADD_GCC_PRECOMPILED_HEADER(${TARGET_NAME} ${PRECOMPILED_HEADER})
	ENDIF()
ENDFUNCTION()

FUNCTION(KLAYGE_ADD_MSVC_PRECOMPILED_HEADER TARGET_NAME PRECOMPILED_HEADER)
	get_filename_component(pch_base_name ${PRECOMPILED_HEADER} NAME_WE)
	get_filename_component(pch_output "${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/${pch_base_name}.pch" ABSOLUTE)

	get_filename_component(pch_header "${PRECOMPILED_HEADER}" ABSOLUTE)

	get_target_property(source_list ${TARGET_NAME} SOURCES)
	set(cpp_source_list "")
	foreach(file_name ${source_list})
		string(TOLOWER ${file_name} lower_file_name)
		string(FIND "${lower_file_name}" ".cpp" is_cpp REVERSE)
		if(is_cpp LESS 0)
			set_source_files_properties(${file_name} PROPERTIES COMPILE_FLAGS "/Y-")
		else()
			list(APPEND cpp_source_list "${file_name}")
			set_source_files_properties(${file_name} PROPERTIES COMPILE_FLAGS "/FI\"${pch_header}\"")
		endif()
	endforeach()
	list(GET cpp_source_list 0 first_cpp_file)
	set_source_files_properties(${first_cpp_file} PROPERTIES COMPILE_FLAGS "/Yc\"${pch_header}\" /FI\"${pch_header}\""
		OBJECT_OUTPUTS "${pch_output}")
	set_target_properties(${TARGET_NAME} PROPERTIES COMPILE_FLAGS "/Yu\"${pch_header}\" /Fp\"${pch_output}\""
		OBJECT_DEPENDS "${pch_output}")
ENDFUNCTION()

FUNCTION(KLAYGE_ADD_GCC_PRECOMPILED_HEADER TARGET_NAME PRECOMPILED_HEADER)
	SET(CXX_COMPILE_FLAGS ${CMAKE_CXX_FLAGS})
	IF(CMAKE_BUILD_TYPE)
		STRING(TOUPPER ${CMAKE_BUILD_TYPE} UPPER_CMAKE_BUILD_TYPE)
		LIST(APPEND CXX_COMPILE_FLAGS ${CMAKE_CXX_FLAGS_${UPPER_CMAKE_BUILD_TYPE}})
	ENDIF()

	GET_FILENAME_COMPONENT(PRECOMPILED_HEADER_NAME ${PRECOMPILED_HEADER} NAME)

	SET(PCH_OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${PRECOMPILED_HEADER_NAME}.gch")

	set(include_dirs "$<TARGET_PROPERTY:${TARGET_NAME},INCLUDE_DIRECTORIES>")
	set(comp_defs "$<TARGET_PROPERTY:${TARGET_NAME},COMPILE_DEFINITIONS>")
	set(comp_flags "$<TARGET_PROPERTY:${TARGET_NAME},COMPILE_FLAGS>")
	set(comp_options "$<TARGET_PROPERTY:${TARGET_NAME},COMPILE_OPTIONS>")
	set(include_dirs "$<$<BOOL:${include_dirs}>:-I$<JOIN:${include_dirs},\n-I>\n>")
	set(comp_defs "$<$<BOOL:${comp_defs}>:-D$<JOIN:${comp_defs},\n-D>\n>")
	set(comp_flags "$<$<BOOL:${comp_flags}>:$<JOIN:${comp_flags},\n>\n>")
	set(comp_options "$<$<BOOL:${comp_options}>:$<JOIN:${comp_options},\n>\n>")
	set(pch_flags_file "${CMAKE_CURRENT_BINARY_DIR}/compile_flags.rsp")
	file(GENERATE OUTPUT "${pch_flags_file}" CONTENT "${comp_defs}${include_dirs}${comp_flags}${comp_options}\n")
	set(pch_compile_flags "@${pch_flags_file}")

	GET_TARGET_PROPERTY(PIC_OPTION ${TARGET_NAME} POSITION_INDEPENDENT_CODE)
	IF(PIC_OPTION AND CMAKE_CXX_COMPILE_OPTIONS_PIC)
		LIST(APPEND CXX_COMPILE_FLAGS "${CMAKE_CXX_COMPILE_OPTIONS_PIC}")
	ENDIF()

	list(APPEND CXX_COMPILE_FLAGS "-Wno-error -x c++-header")
	if(KLAYGE_COMPILER_CLANG)
		list(APPEND CXX_COMPILE_FLAGS "-Wno-pragma-once-outside-header")
	endif()

	SEPARATE_ARGUMENTS(CXX_COMPILE_FLAGS)

	ADD_CUSTOM_COMMAND(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${PRECOMPILED_HEADER_NAME}
		COMMAND ${CMAKE_COMMAND} -E copy ${PRECOMPILED_HEADER} ${CMAKE_CURRENT_BINARY_DIR}/${PRECOMPILED_HEADER_NAME}
	)

	SET(PCHOUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${PRECOMPILED_HEADER_NAME})

	ADD_CUSTOM_COMMAND(OUTPUT ${PCH_OUTPUT}
		COMMAND ${CMAKE_CXX_COMPILER} ${pch_compile_flags} ${CXX_COMPILE_FLAGS} -o ${PCH_OUTPUT} ${PRECOMPILED_HEADER}
		DEPENDS ${PRECOMPILED_HEADER} ${CMAKE_CURRENT_BINARY_DIR}/${PRECOMPILED_HEADER_NAME}
	)
	ADD_CUSTOM_TARGET(${TARGET_NAME}_gch
		DEPENDS ${PCH_OUTPUT}
	)
	ADD_DEPENDENCIES(${TARGET_NAME} ${TARGET_NAME}_gch)

	get_property(source_list TARGET ${TARGET_NAME} PROPERTY SOURCES)
	foreach(file_name ${source_list})
		string(TOLOWER ${file_name} lower_file_name)
		string(FIND "${lower_file_name}" ".cpp" is_cpp REVERSE)
		if(is_cpp GREATER 0)
			set_source_files_properties(${_source} PROPERTIES
				COMPILE_FLAGS "-include ${CMAKE_CURRENT_BINARY_DIR}/${PRECOMPILED_HEADER_NAME} -Winvalid-pch"
				OBJECT_DEPENDS "${PCHOUTPUT}")
		endif()
	endforeach()
ENDFUNCTION()

FUNCTION(KLAYGE_ADD_XCODE_PRECOMPILED_HEADER TARGET_NAME PRECOMPILED_HEADER)
	SET_TARGET_PROPERTIES(${TARGET_NAME} PROPERTIES XCODE_ATTRIBUTE_GCC_PRECOMPILE_PREFIX_HEADER YES)
	SET_TARGET_PROPERTIES(${TARGET_NAME} PROPERTIES XCODE_ATTRIBUTE_GCC_PREFIX_HEADER "${PRECOMPILED_HEADER}")
ENDFUNCTION()

function(GenerateLibFileName lib_name is_static_lib result_name)
	if(KLAYGE_COMPILER_MSVC)
		set(prefix "")
		if(${is_static_lib})
			set(extension "dll")
		else()
			set(extension "lib")
		endif()
	else()
		set(prefix "lib")
		if(${is_static_lib})
			set(extension "a")
		else()
			if(KLAYGE_PLATFORM_WINDOWS)
				set(extension "dll.a")
			elseif(KLAYGE_PLATFORM_DARWIN)
				set(extension "dylib")
			else()
				set(extension "so")
			endif()
		endif()
	endif()
	set(${result_name} "${prefix}${lib_name}.${extension}" PARENT_SCOPE)
endfunction()
