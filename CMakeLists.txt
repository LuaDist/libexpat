# Copyright (C) 2007-2009 LuaDist.
# Created by Peter Kapec
# Redistribution and use of this file is allowed according to the terms of the MIT license.
# For details see the COPYRIGHT file distributed with LuaDist.
# Please note that the package source code is licensed under its own license.

PROJECT(libexpat C)
CMAKE_MINIMUM_REQUIRED(VERSION 2.6)
INCLUDE(dist.cmake)

# Generating expat_config.h file:
MESSAGE("Configure: Expat - generating expat_config.h:")
	INCLUDE (CheckIncludeFiles)
	INCLUDE (CheckFunctionExists)
	INCLUDE (CheckSymbolExists)
	INCLUDE (TestBigEndian)
	INCLUDE (CheckTypeSize)

	TEST_BIG_ENDIAN(ENDIAN_TEST)
	IF(ENDIAN_TEST)
		SET(BYTEORDER 4321)
	ELSE()
		SET(BYTEORDER 1234)
	ENDIF()

	CHECK_FUNCTION_EXISTS(bcopy HAVE_BCOPY)
	CHECK_INCLUDE_FILES (dlfcn.h HAVE_DLFCN_H)
	CHECK_INCLUDE_FILES (fcntl.h HAVE_FCNTL_H)
	CHECK_FUNCTION_EXISTS(getpagesize HAVE_GETPAGESIZE)
	CHECK_INCLUDE_FILES (inttypes.h HAVE_INTTYPES_H)
	CHECK_FUNCTION_EXISTS(memmove HAVE_MEMMOVE)
	CHECK_INCLUDE_FILES (memory.h HAVE_MEMORY_H)
	CHECK_FUNCTION_EXISTS(mmap HAVE_MMAP)
	CHECK_INCLUDE_FILES (stdint.h HAVE_STDINT_H)
	CHECK_INCLUDE_FILES (stdlib.h HAVE_STDLIB_H)
	CHECK_INCLUDE_FILES (strings.h HAVE_STRINGS_H)
	CHECK_INCLUDE_FILES (string.h HAVE_STRING_H)
	CHECK_INCLUDE_FILES ("sys/stat.h" HAVE_SYS_STAT_H)
	CHECK_INCLUDE_FILES ("sys/types.h" HAVE_SYS_TYPES_H)
	CHECK_INCLUDE_FILES (unistd.h HAVE_UNISTD_H)
	SET(PACKAGE_BUGREPORT "expat-bugs@libexpat.org")
	SET(PACKAGE_NAME "expat")
	SET(PACKAGE_STRING "expat 2.0.0")
	SET(PACKAGE_TARNAME "expat")
	SET(PACKAGE_VERSION "2.0.0")
	CHECK_INCLUDE_FILES("stdlib.h;stdarg.h;string.h;float.h" STDC_HEADERS)

	#WARNING: Following tests might NOT be the original test as found in original ./configure script!
	#TODO: Someone has to check it, pliz (I'm not an automake guru).

	# how to check WORDS_BIGENDIAN ? maybe:
	SET(WORDS_BIGENDIAN ${ENDIAN_TEST})

	# TODO:
	#/* Define to __FUNCTION__ or "" if `__func__' does not conform to ANSI C. */
	#cmakedefine __func__

	# TODO:
	#/* Define to empty if `const' does not conform to ANSI C. */
	#cmakedefine const

	#/* Define to `long' if <sys/types.h> does not define. */
	CHECK_TYPE_SIZE("off_t" SIZEOF_OFF_T)
	IF(HAVE_SIZEOF_OFF_T)
		SET (HAVE_OFF_T 1)
	ELSE(HAVE_SIZEOF_OFF_T)
		SET (HAVE_OFF_T 0)
		SET (off_t "long")
	ENDIF(HAVE_SIZEOF_OFF_T)

	#/* Define to `unsigned' if <sys/types.h> does not define. */
	CHECK_TYPE_SIZE("size_t" SIZEOF_SIZE_T)
	IF(HAVE_SIZEOF_SIZE_T)
		SET (HAVE_SIZE_T 1)
	ELSE(HAVE_SIZEOF_SIZE_T)
		SET (HAVE_SIZE_T 0)
		SET (size_t "unsigned")
	ENDIF(HAVE_SIZEOF_SIZE_T)

	CONFIGURE_FILE(${CMAKE_CURRENT_SOURCE_DIR}/expat_config.h.cmake ${CMAKE_CURRENT_BINARY_DIR}/expat_config.h)

MESSAGE("Configure: Expat - done.")
# end of generating expat_config.h file:

###########################################################################################

# Expat library
INCLUDE_DIRECTORIES (${CMAKE_CURRENT_SOURCE_DIR}/lib ${CMAKE_CURRENT_BINARY_DIR})

IF(MSVC)
	SET(DEF_FILE lib/libexpat.def)
ENDIF()

SET(SRC_EXPATLIB lib/xmlparse.c lib/xmlrole.c lib/xmltok.c)

ADD_DEFINITIONS(-DHAVE_EXPAT_CONFIG_H )

ADD_LIBRARY(expat SHARED ${SRC_EXPATLIB} ${DEF_FILE})

# Install library
INSTALL(TARGETS expat RUNTIME DESTINATION ${INSTALL_BIN} LIBRARY DESTINATION ${INSTALL_LIB} ARCHIVE DESTINATION ${INSTALL_LIB})

# Install headers
INSTALL(FILES lib/expat.h lib/expat_external.h DESTINATION ${INSTALL_INC})

# Install docs
INSTALL(FILES COPYING Changes README DESTINATION ${INSTALL_DATA})
INSTALL(DIRECTORY doc/ DESTINATION ${INSTALL_DOC})

# IMPROVE: install xmlwf utility too? (see below test suite)

# Tests
include(CTest)
if(BUILD_TESTING)
	ADD_EXECUTABLE(runtests tests/runtests.c tests/chardata.c tests/minicheck.c)
	TARGET_LINK_LIBRARIES(runtests expat)
	ADD_TEST(runtests runtests)
	ADD_EXECUTABLE(runtestspp tests/runtestspp.cpp tests/runtests.c tests/chardata.c tests/minicheck.c)
	TARGET_LINK_LIBRARIES(runtestspp expat)
	ADD_TEST(runtestspp runtestspp)

	IF(WIN32 OR MINGW OR CYGWIN)
		SET(FILEMAP win32filemap)
	ELSE()
		SET(FILEMAP unixfilemap)
	ENDIF()

	ADD_EXECUTABLE(xmlwf/xmlwf xmlwf/xmlwf.c xmlwf/xmlfile.c xmlwf/codepage.c xmlwf/${FILEMAP}.c)
	TARGET_LINK_LIBRARIES(xmlwf/xmlwf expat)
	# These optional tests are normally disabled.
	# They don't seem to complete work using the GNU makefiles either.
	# Similer errors as seen in http://mail.libexpat.org/pipermail/expat-checkins/2006-August.txt
	IF(0 AND UNIX) # IMPROVE: shell script only runs on *nix.
		IF(NOT EXISTS xmlts.zip)
			FILE(DOWNLOAD http://www.w3.org/XML/Test/xmlts20020606.zip ./xmlts.zip)
		ENDIF()
		IF(NOT EXISTS XML-Test-Suite)
			EXECUTE_PROCESS(COMMAND unzip -q xmlts.zip) # IMPROVE: unzip might not exist
		ENDIF()
		IF(NOT EXISTS ${CMAKE_CURRENT_BINARY_DIR}/xmltest.sh)
			FILE(READ ${CMAKE_CURRENT_SOURCE_DIR}/tests/xmltest.sh _data)
			STRING(REGEX REPLACE "XMLWF=[^\n]*" "XMLWF=\$MYDIR/xmlwf" _data "${_data}")
			FILE(WRITE ${CMAKE_CURRENT_BINARY_DIR}/xmltest.sh "${_data}")
		ENDIF()
		ADD_TEST(xmltest sh ${CMAKE_CURRENT_BINARY_DIR}/xmltest.sh)
		SET_PROPERTY(TEST xmltest PROPERTY PASS_REGULAR_EXPRESSION "Failed: 0")
	ENDIF()
endif()


