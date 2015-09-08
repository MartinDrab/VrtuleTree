#ifndef __PREPROCESSOR_H_
#define __PREPROCESSOR_H_

/*
 * Thanks for these macros:
 * http://www.decompile.com/cpp/faq/file_and_line_error_string.htm
 */
#define STRINGIFY(x) #x
#define TOSTRING(x) STRINGIFY(x)

#define AT_FUNCTION __FILE__ ":" __FUNCTION__
#define AT_LINE AT_FUNCTION ":" TOSTRING(__LINE__)

#ifdef _DEBUG

#define DEBUG_TRACE_ENABLED 1

/*
 * Prints the source file and function name. Determined for non-parametric
 * functions.
 */
#define DEBUG_ENTER_FUNCTION_NO_ARGS() \
   if (DEBUG_TRACE_ENABLED) { \
      KdPrintEx((DPFLTR_DEFAULT_ID, DPFLTR_TRACE_LEVEL, AT_FUNCTION "()\n")); \
   } \

/*
 * Prints the source file, function name and parameters.
 */
#define DEBUG_ENTER_FUNCTION(paramsFormat,...) \
   if (DEBUG_TRACE_ENABLED) { \
      KdPrintEx((DPFLTR_DEFAULT_ID, DPFLTR_TRACE_LEVEL, AT_FUNCTION "(" paramsFormat ")\n", __VA_ARGS__)); \
   } \

/*
 * Prints the source file, function name and the return value.
 */
#define DEBUG_EXIT_FUNCTION(returnValueFormat,...) \
   if (DEBUG_TRACE_ENABLED) { \
      KdPrintEx((DPFLTR_DEFAULT_ID, DPFLTR_TRACE_LEVEL, AT_FUNCTION "(-):" returnValueFormat "\n", __VA_ARGS__)); \
   } \

/*
 * Prints the source file and function name. Determined for ending a function
 * without a return value.
 */
#define DEBUG_EXIT_FUNCTION_VOID() \
   if (DEBUG_TRACE_ENABLED) { \
      KdPrintEx((DPFLTR_DEFAULT_ID, DPFLTR_TRACE_LEVEL, AT_FUNCTION "(-):void\n")); \
   }

/*
 * Prints the source file, function name and the number of the line.
 */
#define DEBUG_PRINT_LOCATION_VOID() \
   KdPrintEx((DPFLTR_DEFAULT_ID, DPFLTR_TRACE_LEVEL, AT_LINE "\n"))

/*
 * Prints the source file, function name and the number of the line.
 */
#define DEBUG_PRINT_LOCATION(format,...) \
   KdPrintEx((DPFLTR_DEFAULT_ID, DPFLTR_TRACE_LEVEL, AT_LINE format "\n", __VA_ARGS__))

#else // ifdef _DEBUG

#define DEBUG_ENTER_FUNCTION_NO_ARGS() { }
#define DEBUG_ENTER_FUNCTION(paramsFormat,...) { }
#define DEBUG_EXIT_FUNCTION(returnValueFormat,...) { }
#define DEBUG_EXIT_FUNCTION_VOID() { }
#define DEBUG_PRINT_LOCATION_VOID() { }
#define DEBUG_PRINT_LOCATION(format,...) { }

#endif // ifdef _DEBUG

/*
 * Macro for reporting error conditions.
 */
#define DEBUG_ERROR(format,...) \
   DEBUG_PRINT_LOCATION(" ERROR:" format, __VA_ARGS__)

#endif // ifndef __PREPROCESSOR_H_

