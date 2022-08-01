#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "LaunchexternalappPlugin.h"
#import "LaunchVpnPlugin.h"

FOUNDATION_EXPORT double external_app_launcherVersionNumber;
FOUNDATION_EXPORT const unsigned char external_app_launcherVersionString[];

