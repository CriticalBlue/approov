/*****************************************************************************
 * Project:     Approov
 * File:        ApproovAttestee.h
 * Original:    Created on 25 April 2016 by Simon Rigg
 * Copyright(c) 2002 - 2016 by CriticalBlue Ltd.
 *
 * The "Attestee" performs the actual client app attestations via the Approov
 * cloud service in order to access a remote "Attester" and retrieve a time-
 * limited Approov token.
 ****************************************************************************/

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

/* The key for the User-Agent Approov token string */
#define ApproovTokenUserAgentKey                "Approov"

/* The name of the notification posted by the ApproovAttestee when an Approov token is fetched */
#define FetchApproovTokenNotificationName       "ApproovTokenFetched"
/* The name of the user info "result" key for FetchApproovToken notifications (value is NSNumber for ApproovTokenFetchResult enum ordinal) */
#define FetchApproovTokenNotificationResultKey  "ApproovTokenFetchResult"
/* The name of the user info "token" key for FetchApproovToken notifications (value is NSString) */
#define FetchApproovTokenNotificationTokenKey   "ApproovToken"


/*
 * This ApproovAttestee public class interface.
 */
__attribute__((visibility("default"))) @interface ApproovAttestee : NSObject

/* Enumeration of Approov token fetch results in the "ApproovTokenFetched" notification's user info "ApproovTokenFetchResult" entry */
typedef NS_ENUM(NSUInteger, ApproovTokenFetchResult)
{
    ApproovTokenFetchResultSuccessful,
    ApproovTokenFetchResultFailed
};

/**
 * Get the singleton shared ApproovAttestee instance.
 *
 * @result the singleton shared ApproovAttestee instance
 */
+ (_Nullable instancetype)sharedAttestee;

/* The current Approov token which is automatically updated when an attestation operation is performed with the Approov cloud service.
 * This result should not be cached as the value may change since Approov tokens have a limited valid lifetime. Instead, the
 * "ApproovTokenFetched" notification should be observed and the Approov token retreived from the notificaton user info "ApproovToken"
 * entry. This property is provided simply as a convenience and for JSContext integration.
 */
@property (readonly, copy, nonnull) NSString *approovToken;

/* The flag for whether Approov tokens should be automatically appended to "User-Agent" request headers
   used by web views and NSURLRequests. The default value is set in cbconfig.plist by the value of the
   "attestation-update-user-agents" attribute.
 */
@property BOOL appendApproovTokenToUserAgentStrings;

/**
 * Initiates an asynchronous request to perform an attestation of the running app and fetch an Approov token from the Approov cloud service. 
 *
 * When the fetch token operation is complete, an "ApproovTokenFetched" notification is posted through the system
 * notification centre for the shared ApproovAttestee instance. The notification's user info contains:
 *
 *    1. An "ApproovTokenFetchResult" with NSNumber value corresponding to the "ApproovTokenFetchResult" enum in this interface
 *    2. An "ApproovToken" with NSString value corresponding to the fetched Approov token
 */
- (void)fetchApproovToken;

/**
 * Register the given UIWebView with Approov to provide Javascript interaction services.
 * When finished, it is important to call unregisterUIWebView() with the UIWebView instance.
 *
 * Currently, the only supported Javascript interface is for manually fetching Approov tokens.
 * This can be achieved by invoking the following function from Javascript in the UIWebView's main frame:
 *
 *     approov.fetchApproovToken("mySuccessCallback", "myFailureCallback");
 *
 * This will asynchronously perform an attestation of the running app and fetch an Approov token from the Approov cloud service.
 * When complete, the success or failure Javascript callback function will be invoked from the Approov framework as appropriate.
 * The success callback function should accept a single parameter: the Approov token string.
 *
 * @param webView the UIWebView instance to register
 * @result true/YES if the UIWebView was successfully registered, false/NO otherwise
 */
- (BOOL)registerUIWebView:(UIWebView * _Nonnull)webView;

/**
 * Unregister the given UIWebView with Approov.
 * This method has no effect for an unregistered UIWebView.
 *
 * @param webView the UIWebView instance to unregister
 */
- (void)unregisterUIWebView:(UIWebView * _Nonnull)webView;

/**
 * Register the given WKWebView with Approov to provide Javascript interaction services.
 * When finished, it is important to call unregisterWKWebView() with the WKWebView instance.
 *
 * Currently, the only supported Javascript interface is for manually fetching Approov tokens.
 * This can be achieved by invoking the following function from Javascript in the WKWebView's main frame:
 *
 *     approov.fetchApproovToken("mySuccessCallback", "myFailureCallback");
 *
 * This will asynchronously perform an attestation of the running app and fetch an Approov token from the Approov cloud service.
 * When complete, the success or failure Javascript callback function will be invoked from the Approov framework as appropriate.
 * The success callback function should accept a single parameter: the Approov token string.
 *
 * @param webView the WKWebView instance to register
 * @result true/YES if the WKWebView was successfully registered, false/NO otherwise
 */
- (BOOL)registerWKWebView:(WKWebView * _Nonnull)webView;

/**
 * Unregister the given WKWebView with Approov.
 * This method has no effect for an unregistered WKWebView.
 *
 * @param webView the WKWebView instance to unregister
 */
- (void)unregisterWKWebView:(WKWebView * _Nonnull)webView;

@end
