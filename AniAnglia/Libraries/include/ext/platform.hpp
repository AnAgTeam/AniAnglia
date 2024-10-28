/*
	https://stackoverflow.com/questions/142508/how-do-i-check-os-with-a-preprocessor-directive
*/
#include <stdio.h>

/**
 * Determination a platform of an operation system
 * Fully supported supported only GNU GCC/G++, partially on Clang/LLVM
 */

#if defined(_WIN32)
    #define PLATFORM_NAME "Windows" // Windows
#elif defined(__CYGWIN__) && !defined(_WIN32)
    #define PLATFORM_NAME "Windows" // Windows (Cygwin POSIX under Microsoft Window)
#elif defined(__ANDROID__)
    #define PLATFORM_NAME "Android" // Android (implies Linux, so it must come first)
#elif defined(__linux__)
    #define PLATFORM_NAME "Linux" // Debian, Ubuntu, Gentoo, Fedora, openSUSE, RedHat, Centos and other
#elif defined(__unix__) || !defined(__APPLE__) && defined(__MACH__)
    #include <sys/param.h>
    #if defined(BSD)
        #define PLATFORM_NAME "BSD" // FreeBSD, NetBSD, OpenBSD, DragonFly BSD
    #endif
#elif defined(__hpux)
    #define PLATFORM_NAME "HP-UX" // HP-UX
#elif defined(_AIX)
    #define PLATFORM_NAME "AIX" // IBM AIX
#elif defined(__APPLE__) && defined(__MACH__) // Apple OSX and iOS (Darwin)
    #include <TargetConditionals.h>
    #if TARGET_IPHONE_SIMULATOR == 1
        #define PLATFORM_NAME "iOS" // Apple iOS
    #elif TARGET_OS_IPHONE == 1
        #define PLATFORM_NAME "iOS" // Apple iOS
    #elif TARGET_OS_MAC == 1
        #define PLATFORM_NAME "OSX" // Apple OSX
    #endif
#elif defined(__sun) && defined(__SVR4)
    #define PLATFORM_NAME "Solaris" // Oracle Solaris, Open Indiana
#else
    #define PLATFORM_NAME NULL
#endif

// Return a name of platform, if determined, otherwise - an empty string
const char* get_platform_name() {
    return (PLATFORM_NAME == NULL) ? "" : PLATFORM_NAME;
}


/* */
#if defined(__x86_64__) || defined(_M_X64)
    #define ARCH_NAME "x86_64"
#elif defined(i386) || defined(__i386__) || defined(__i386) || defined(_M_IX86)
    #define ARCH_NAME "x86_32"
#elif defined(__ARM_ARCH_2__)
    #define ARCH_NAME "ARM2"
#elif defined(__ARM_ARCH_3__) || defined(__ARM_ARCH_3M__)
    #define ARCH_NAME "ARM3"
#elif defined(__ARM_ARCH_4T__) || defined(__TARGET_ARM_4T)
    #define ARCH_NAME "ARM4T"
#elif defined(__ARM_ARCH_5_) || defined(__ARM_ARCH_5E_)
    #define ARCH_NAME "ARM5"
#elif defined(__ARM_ARCH_6T2_) || defined(__ARM_ARCH_6T2_)
    #define ARCH_NAME "ARM6T2"
#elif defined(__ARM_ARCH_6__) || defined(__ARM_ARCH_6J__) || defined(__ARM_ARCH_6K__) || defined(__ARM_ARCH_6Z__) || defined(__ARM_ARCH_6ZK__)
    #define ARCH_NAME "ARM6"
#elif defined(__ARM_ARCH_7__) || defined(__ARM_ARCH_7A__) || defined(__ARM_ARCH_7R__) || defined(__ARM_ARCH_7M__) || defined(__ARM_ARCH_7S__)
    #define ARCH_NAME "ARM7"
#elif defined(__ARM_ARCH_7A__) || defined(__ARM_ARCH_7R__) || defined(__ARM_ARCH_7M__) || defined(__ARM_ARCH_7S__)
    #define ARCH_NAME "ARM7A"
#elif defined(__ARM_ARCH_7R__) || defined(__ARM_ARCH_7M__) || defined(__ARM_ARCH_7S__)
    #define ARCH_NAME "ARM7R"
#elif defined(__ARM_ARCH_7M__)
    #define ARCH_NAME "ARM7M"
#elif defined(__ARM_ARCH_7S__)
    #define ARCH_NAME "ARM7S"
#elif defined(__aarch64__) || defined(_M_ARM64)
    #define ARCH_NAME "ARM64"
#elif defined(mips) || defined(__mips__) || defined(__mips)
    #define ARCH_NAME "MIPS"
#elif defined(__sh__)
    #define ARCH_NAME "SUPERH"
#elif defined(__powerpc) || defined(__powerpc__) || defined(__powerpc64__) || defined(__POWERPC__) || defined(__ppc__) || defined(__PPC__) || defined(_ARCH_PPC)
    #define ARCH_NAME "POWERPC"
#elif defined(__PPC64__) || defined(__ppc64__) || defined(_ARCH_PPC64)
    #define ARCH_NAME "POWERPC64"
#elif defined(__sparc__) || defined(__sparc)
    #define ARCH_NAME "SPARC"
#elif defined(__m68k__)
    #define ARCH_NAME "M68K"
#else
    #define ARCH_NAME "UNKNOWN"
#endif