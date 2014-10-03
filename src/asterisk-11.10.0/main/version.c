/*
 * version.c
 * Automatically generated
 */

#include "asterisk.h"

#include "asterisk/ast_version.h"

static const char asterisk_version[] = "11.10.0";

static const char asterisk_version_num[] = "111000";

const char *ast_get_version(void)
{
	return asterisk_version;
}

const char *ast_get_version_num(void)
{
	return asterisk_version_num;
}

