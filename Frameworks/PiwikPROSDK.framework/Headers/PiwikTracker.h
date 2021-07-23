//
//  PiwikTracker.h
//  PiwikTracker
//
//  Created by Mattias Levin on 3/12/13.
//  Copyright 2013 Mattias Levin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class PiwikTransaction;

/**
 The PiwikTracker is a framework for sending analytics to a Piwik server.

 How does it work

 1. Create and configure the tracker
 2. Track screen views, events, errors, social interaction, search, goals and more
 3. Let the SDK dispatch events to the Piwik server automatically, or dispatch events manually

 All events are persisted locally until they are dispatched and successfully received by the Piwik server.

 All methods are asynchronous and will return immediately.
 */
@interface PiwikTracker : NSObject

extern NSString *const PiwikSessionStartNotification;

typedef NS_ENUM(NSUInteger, CustomDimensionScope)
{
    CustomDimensionScopeVisit NS_SWIFT_NAME(visit) __deprecated,
    CustomDimensionScopeAction NS_SWIFT_NAME(action) __deprecated,
};

typedef NS_ENUM(NSUInteger, CustomVariableScope)
{
    CustomVariableScopeVisit NS_SWIFT_NAME(visit),
    CustomVariableScopeAction NS_SWIFT_NAME(action),
};

//MARK: - Tracker instance

/**
 Create and configure a shared Piwik tracker.

 A default dispatcher will be used.

 @param siteID The unique site id generated by the the Piwik server when a new site is created
 @param baseURL The base URL of the Piwik server. The URL should not include the tracking endpoint path component (/piwik.php)
 @return The newly created PiwikTracker
 */
+ (nullable instancetype)sharedInstanceWithSiteID:(NSString *)siteID baseURL:(NSURL *)baseURL NS_SWIFT_NAME(sharedInstance(siteID:baseURL:));

/**
 Create and configure a shared Piwik tracker.

 Developers can provide their own dispatchers when creating the tracker in order to implement specific security schemas, http client frameworks or network and server configurations.

 @param siteID The unique site id generated by the the Piwik server when the tracked application is created
 @param dispatcher The dispatcher that will perform the network request to the Piwik server
 @return The newly created PiwikTracker
 */
+ (nullable instancetype)sharedInstanceWithSiteID:(NSString *)siteID dispatcher:(id)dispatcher NS_SWIFT_NAME(sharedInstance(siteID:dispatcher:));

/**
 Return the shared Piwik tracker.

 The Piwik tracker must have been created and configured for this method to return the tracker.

 @return The existing PiwikTracker object
 @see sharedInstanceWithSiteID:baseURL:
 */
+ (nullable instancetype)sharedInstance;

/**
 Piwik site id.

 The value can be found in the Piwik server -> Settings -> Websites.
 */
@property (nullable, strong, nonatomic, readonly) NSString *siteID;

/**
 The dispatcher will execute the actual network request to the Piwik server.

 Developers can provide their own dispatchers when creating the tracker in order to implement specific security schemas, http client frameworks or network and server configurations.
 */
@property (nullable, strong, nonatomic, readonly) id dispatcher;

//MARK: - Tracker configuration

/**
 The user email address used for identifying the user in the app e.g. after the user signed in.
 If provided this is used by the server for user segmentation.

 It is important that the user email is saved locally in the app and set each time directly after the tracker is started. Otherwise tracked events sent before setting this property will not be attributed to the user email.

 The user email allow events from different platforms, e.g. iOS and Android, to be associated in the Piwik server to the same user as long as the same user email is used on all platforms.
 */
@property (nullable, nonatomic, strong) NSString *userEmail;

/**
 The user id is an additional non empty unique string identifying the user. If email address of the user is know you can set this property to user's email address, if not any additional string such as a unique username
 can be set here also.

 Set this value when you have a way of uniquely identifying the user in the app, e.g. after the user signed in. The user id will appear in the Piwik server and is available for segmentation reports.
 It is important that the user id is saved locally in the app and set each time directly after the tracker is started. Otherwise tracked events sent before setting this property will not be attributed to the user id.

 The user id allow events from different platforms, e.g. iOS and Android, to be associated in the Piwik server to the same user as long as the same user id is used on all platforms.

 To stop associating tracked events to a specific user set this property to nil, e.g. after user signs out.

 If no user id is provided, only an internal visitor id will be managed by the SDK to track unique users and visits. This visitor id will be persisted across app restarts. If the app is uninstalled/installed again or the user change device, a new visitor id will be generated and events tracked as a new unique user.
 */
@property (nullable, nonatomic, strong) NSString *userID;

/**
 Internal visitor identifier used when userID is not set. It's automatically generated, random string stored across app restarts. If the app is uninstalled/installed again or the user change device, a new visitor id will be generated and events tracked as a new unique user.
 */
@property (nonnull, nonatomic, readonly) NSString *visitorID;

/**
 The device ID is used to track the IDFA (identifier for advertising). IDFA is an additional non empty unique string identifying the device. If you want to use IDFA for tracking then you should set this property to IDFA by yourself (by default it is nil). You can read IDFA from the device as below:
 
 #import <AdSupport/ASIdentifierManager.h>
 
 NSString *idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
 [PiwikTracker sharedInstance].deviceID = idfa;
 
 Note that there are restrisctions in using IDFA in the App Store applications and apps that do not display ads might not pass the App Store review process.
 */
@property (nullable, nonatomic, strong) NSString *deviceID;

/**
 Views, exceptions and social tracking will be prefixed based on type.

 This will allow for logical separation and grouping of statistics in the Piwik web interface.
 Screen views will prefixed with "screen".
 Exceptions will be prefixed with "exception".
 Social interaction will be prefixed with "social".

 Default value is YES which would be the preferred option for most developers. Set to NO to avoid prefixing or implement a custom prefixing schema.
 */
@property (nonatomic, assign) BOOL isPrefixingEnabled;

/**
 Anonymization is a feature that allows tracking user's activity for aggregated data analysis even if the user doesn't consent on tracking the data. Key features of anonymization:
 - The user can't be identified as the same person across multiple sessions if he didn't consent on tracking,
 - Personal data cannot be tracked during the session (i.e. user ID, device ID, email)
 
 Default value is YES.
 */
@property (nonatomic, assign) BOOL isAnonymizationEnabled;

/**
 Run the tracker in debug mode.

 Instead of sending events to the Piwik server, events will be printed to the console. Useful during development.
 */
@property (nonatomic, assign) BOOL debug;

/**
 Opt out of tracking.

 No events will be sent to the Piwik server. This feature can be used to allow the user to opt out of tracking due to privacy. The value will be retained across app restart and upgrades.
 */
@property (nonatomic, assign) BOOL optOut;

/**
 The probability of an event actually being sampled and sent to the Piwik server. Value 1-100, default 100.

 Use the sample rate to only send a sample of all events generated by the app. This can be useful for applications that generate a lot of events.
 */
@property (nonatomic, assign) NSUInteger sampleRate;

/**
 If set to YES the SDK will use custom variable index 1-3 to provide default information about the app and users device (App version, OS version and HW) for each visit.
 Set to NO to free up additional custom variable indexes for your own reporting purpose.

 Default values it YES.
 */
@property (nonatomic, assign) BOOL includeDefaultCustomVariable;

/**
 The application name for custom visit variable.

 The application name will be sent as a custom variable (index 2). By default the application name stored in CFBundleDisplayName will be used.
 */
@property (nullable, nonatomic, strong) NSString *appName;

/**
 The application version for custom visit variable.

 The application version will be sent as a custom variable (index 3). By default the application version stored in CFBundleShortVersionString and CFBundleVersion will be used.
 */
@property (nullable, nonatomic, strong) NSString *appVersion;

/**
 Set this value to YES to force a new session start when the next event is sent to the Piwik server.

 By default a new session is started each time the application in launched.
 */
@property (nonatomic, assign) BOOL sessionStart;

/**
 A new session will be generated if the application spent longer time in the background then the session timeout value. Default value 1800 seconds.

 The Piwik server will also create a new session if the event is recorded 30 minutes after the previous received event.
 */
@property (nonatomic, assign) NSTimeInterval sessionTimeout;

//MARK: - Track screen views, events, goals and more

/**
 Track a single screen view.

 Screen views are prefixed with "screen" by default unless prefixing scheme is turned off.

 @param view The name of the screen to track.
 @return YES if the event was queued for dispatching.
 @see isPrefixingEnabled
 */
- (BOOL)sendView:(NSString *)view NS_SWIFT_NAME(sendView(view:));

/**
 Track a single hierarchical screen view specified as an array.

 Piwik support hierarchical screen names, e.g. screen/settings/register. Use this to create a hierarchical and logical grouping of screen views in the Piwik web interface.

 Screen views are prefixed with "screen" by default unless prefixing scheme is turned off.

 @param views An array of screen names to track.
 @return YES if the event was queued for dispatching.
 @see isPrefixingEnabled
 */
- (BOOL)sendViews:(NSArray<NSString *> *)views NS_SWIFT_NAME(sendViews(views:));

/**
 Track an user interaction as a custom event.

 @warning As of Piwik server 2.3 events are presented in a separate section and support sending a numeric value (float or integer). The Piwik tracker support this out of the box.

 @param category The category of the event
 @param action The name of the action, e.g Play, Pause, Download
 @param name Event name, e.g. song name, file name. Optional.
 @param value A numeric value, float or integer. Optional.
 @return YES if the event was queued for dispatching.
 */
- (BOOL)sendEventWithCategory:(NSString *)category action:(NSString *)action name:(nullable NSString *)name value:(nullable NSNumber *)value NS_SWIFT_NAME(sendEvent(category:action:name:value:));

/**
 Track a caught exception or error.

 Exception are prefixed with "exception" by default unless prefixing scheme is turned off.

 @param description A description of the exception. Maximum 50 characters
 @param isFatal YES if the exception will lead to a fatal application crash
 @return YES if the event was queued for dispatching.
 @see isPrefixingEnabled
 */
- (BOOL)sendExceptionWithDescription:(NSString *)description isFatal:(BOOL)isFatal NS_SWIFT_NAME(sendException(description:isFatal:));

/**
 Track a users interaction with social networks.

 Exception are prefixed with "social" by default unless prefixing scheme is turned off.

 @param action The action taken by the user, e.g. like, tweet
 @param target The target of the action, e.g. a comment, picture or video (often an unique id or name)
 @param network The social network the user is interacting with, e.g. Facebook
 @return YES if the event was queued for dispatching.
 @see isPrefixingEnabled
 */
- (BOOL)sendSocialInteractionWithAction:(NSString *)action target:(NSString *)target network:(NSString *)network NS_SWIFT_NAME(sendSocialInteraction(action:target:network:));

/**
 Track a goal conversion.

 @param goalID The unique goal ID as configured in the Piwik server.
 @param revenue The monetary value of the conversion. Optional.
 @return YES if the event was queued for dispatching.
 */
- (BOOL)sendGoalWithID:(NSUInteger)goalID revenue:(nullable NSNumber *)revenue NS_SWIFT_NAME(sendGoal(ID:revenue:));

/**
 Track a search performed in the application. The search could be local or towards a server.

 Searches will be presented as Site Search requests in the Piwik web interface.

 @param keyword The search keyword entered by the user.
 @param category An optional search category.
 @param numberOfHits The number of results found (optional).
 @return YES if the event was queued for dispatching.
 */
- (BOOL)sendSearchWithKeyword:(NSString *)keyword category:(nullable NSString *)category numberOfHits:(nullable NSNumber *)numberOfHits NS_SWIFT_NAME(sendSearch(keyword:category:numberOfHits:));

/**
 Track an ecommerce transaction.

 A transaction contains transaction information as well as an optional list of items included in the transaction.

 Use the transaction builder to create the transaction object.

 @param transaction The transaction.
 @return YES if the event was queued for dispatching.
 @see PiwikTransactionBuilder
 @see PiwikTransaction
 @see PiwikTransactionItem
 */
- (BOOL)sendTransaction:(PiwikTransaction *)transaction NS_SWIFT_NAME(sendTransaction(transaction:));

/**
 Track an outlink to an external website or app.

 @param url The url which leads to an external website or app.
 @return YES if the event was queued for dispatching.
 */
- (BOOL)sendOutlink:(NSString *)url NS_SWIFT_NAME(sendOutlink(url:));

/**
 Track installation of current app version. This will only trigger once per app version.

 @return YES if the event was queued for dispatching. NO if current app version was already tracked.
 */
- (BOOL)sendApplicationDownload;

/**
 Track a download initiated by the app.

 @param url The url of the downloaded content.
 @return YES if the event was queued for dispatching.
 */
- (BOOL)sendDownload:(NSString *)url NS_SWIFT_NAME(sendDownload(url:));

/**
 Track that the app was launched from a Piwik campaign URL.
 The campaign information will be sent to the server with the next Piwik event.

 A Piwik campaign URL contains one or two special parameters for tracking campaigns.
 * pk_campaign - The name of the campaign
 * pk_keyword - A specific call to action within a campaign
 Example URL http://example.org/landing.html?pk_campaign=Email-Nov2011&pk_kwd=LearnMore

 1. Register a custom URL schema in your app info.plist file. This is needed to launch your app when tapping on the campaign link
 2. Detect app launches coming from your campaign links in the `AppDelegate`
 3. Generate Piwik campaigns urls using the [Piwik URL builder tool]
     (http://piwik.org/docs/tracking-campaigns-url-builder/)
 4. Distribute your urls

 If no Piwik campaign parameters are detected in the URL will be ignored and no tracking performed.

 Experimental feature. Not fully applicable in app context.

 @param campaignURLString A custom app URL containing campaign parameters.
 @return YES if URL was detected to contain Piwik campaign parameter.
 */
- (BOOL)sendCampaign:(NSString *)campaignURLString NS_SWIFT_NAME(sendCampaign(url:));

/**
 Track how often a specific ad or banner is displayed in the app.

 Check out the content tracking user guide at Piwik (http://piwik.org/docs/content-tracking/) for additional details.

 @param name A human readable display name of the content.
 @param piece A more technical name/id of the content, e.g. the image name or ads id. Optional.
 @param target The outgoing target, e.g. an URL. Optional.
 @return YES if the event was queued for dispatching.
 @see sendContentInteractionWithName:piece:target:
 */
- (BOOL)sendContentImpressionWithName:(NSString *)name piece:(nullable NSString *)piece target:(nullable NSString *)target NS_SWIFT_NAME(sendContentImpression(name:piece:target:));

/**
 Track when a user interact with an ad or banner.

 When used together with content impression the conversion rate can be calculated. Make sure the same name and piece is used to accuratly calculate the conversion rate.

 @param name A human readable display name of the content.
 @param piece A more technical name/id of the content, e.g. the image name or ads id. Optional.
 @param target The outgoing target, e.g. an URL. Optional.
 @return YES if the event was queued for dispatching.
 @see sendContentImpressionWithName:piece:target:
 */
- (BOOL)sendContentInteractionWithName:(NSString *)name piece:(nullable NSString *)piece target:(nullable NSString *)target NS_SWIFT_NAME(sendContentInteraction(name:piece:target:));

/**
 Track custom attributes configured in Piwik PRO data manager.
 Beside attributes at least one of userId or userMail is required.

 @param name A name of the attribute.
 @param value Value of the attribute
 @return YES if the attribute was queued for dispatching.
 */
- (BOOL)sendProfileAttributeWithName:(NSString *)name value:(NSString *)value NS_SWIFT_NAME(sendAudienceManagerAttribute(name:value:));

/**
 Check audience membership for current user with given audience ID.

 @param audienceID Audience identifier.
 @param completionBlock Block called after checking the membership. If checking membership succeeded and user is a member of given audience then isMember will return YES.
 */
- (void)checkMembershipWithAudienceID:(NSString *)audienceID completionBlock:(void (^)(BOOL isMember, NSError * _Nullable error))completionBlock;

/**
 Data manager get profile attributes for current user.
 
 @param completionBlock Block called after getting profile attributes. If request was succeeded then profileAttributes will return set of attributes name-value pairs.
 */
- (void)audienceManagerGetProfileAttributes: (void (^)(NSDictionary *profileAttributes, NSError * _Nullable error))completionBlock;

/**
 Assign a custom dimension.

 A custom dimension is a index-value pair that you can assign to your visits or individual actions.

 @param index Custom dimension index.
 @param value Custom dimension value.
 @param scope Using visit scope will associate the custom dimension with the current session. Action scope will limit the custom dimension to a single action.
 */
- (BOOL)setCustomDimensionForIndex:(NSUInteger)index value:(NSString *)value scope:(CustomDimensionScope)scope NS_SWIFT_NAME(setCustomDimension(index:value:scope:)) __deprecated_msg("Use setCustomDimensionForID:value: instead.");

/**
 Assign a custom dimension.

 A custom dimension is a id-value pair that you can assign to your visits or individual actions.

 @param identifier Custom dimension identifier.
 @param value Custom dimension value.
 */
- (BOOL)setCustomDimensionForID:(NSUInteger)identifier value:(NSString *)value NS_SWIFT_NAME(setCustomDimension(identifier:value:));

//MARK: - Custom variables

/**
 Assign a custom variable.

 A custom variable is a name-value pair that you can assign to your visits or individual screen views. The Piwik server will visualise how many visits, conversions, etc. occurred for each custom variable.
 You can track by default up to 5 custom variables per visit and/or up to 5 custom variables per page view. It is possible to configure the Piwik server to accept additional number of custom variables.

 Keep the name and value short to ensure that the URL length doesn’t go over the URL limit for the web server or http client.

 Please note that the iOS SDK by default will use index 1-3 to report information about your app and users device at each visit (leaving index 4-5 available to the app developer). You can turn this off if you prefer to use index 1-3 for your own reporting purpose.

 @param index Custom variable index. You should only use unique index numbers unless you want to overwrite your data.
 @param name Custom variable name.
 @param value Custom variable value.
 @param scope Using visit scope will associate the custom variable with the current session. Create a new session before and after setting a visit custom variable to limit the actions associated with the custom variable. Screen scope will limit the custom variable to a single screen view.
 @see includeDefaultCustomVariable
 */
- (BOOL)setCustomVariableForIndex:(NSUInteger)index name:(NSString *)name value:(NSString *)value scope:(CustomVariableScope)scope NS_SWIFT_NAME(setCustomVariable(index:name:value:scope:));

//MARK: - Dispatch pending events

/**
 The tracker will automatically dispatch all pending events on a timer. Default value 30 seconds.

 If a negative value is set the dispatch timer will never run and manual dispatch must be used. If 0 is set the event is dispatched as as quick as possible after it has been queued.

 @see dispatch
 */
@property (nonatomic, assign) NSTimeInterval dispatchInterval;

/**
 Specifies if gzip compression should be used for communication with server.
 */
@property (nonatomic, assign) BOOL useGzip;

/**
 Specifies the maximum number of events queued in local storage. Default 500.

 If the number of queued events exceed this value events will no longer be queued.
 */
@property (nonatomic, assign) NSUInteger maxNumberOfQueuedEvents;

/**
 Specifies the maximum age in seconds of events queued in local storage. Default is 0 which mean there is no age limit.

 If the age of queued events exceed this value event will no longer be queued.
 */
@property (nonatomic, assign) NSUInteger maxAgeOfQueuedEvents;

/**
 Specifies limit of events that should be sent to the Piwik server in each request. Default 20 events per request.

 The Piwik server support sending one event at the time or in bulk mode.
 */
@property (nonatomic, assign) NSUInteger eventsPerRequest;

/**
 Manually start a dispatch of all pending events.

 @return YES if the dispatch process was started.
 */
- (BOOL)dispatch;

/**
 Delete all pending events.
 */
- (void)deleteQueuedEvents;

@end

NS_ASSUME_NONNULL_END
