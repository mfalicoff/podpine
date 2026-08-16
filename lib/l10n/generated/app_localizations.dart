import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Podpine'**
  String get appName;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @inbox.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get inbox;

  /// No description provided for @library.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get library;

  /// No description provided for @queue.
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get queue;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @navigationLabel.
  ///
  /// In en, this message translates to:
  /// **'Primary navigation'**
  String get navigationLabel;

  /// No description provided for @openPlayer.
  ///
  /// In en, this message translates to:
  /// **'Open player for {title}'**
  String openPlayer(String title);

  /// No description provided for @skipBack.
  ///
  /// In en, this message translates to:
  /// **'Skip back 15 seconds'**
  String get skipBack;

  /// No description provided for @skipForward.
  ///
  /// In en, this message translates to:
  /// **'Skip forward 30 seconds'**
  String get skipForward;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @dismissPlaybackError.
  ///
  /// In en, this message translates to:
  /// **'Dismiss playback error'**
  String get dismissPlaybackError;

  /// No description provided for @playbackPosition.
  ///
  /// In en, this message translates to:
  /// **'Playback position'**
  String get playbackPosition;

  /// No description provided for @speed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get speed;

  /// No description provided for @silence.
  ///
  /// In en, this message translates to:
  /// **'Silence'**
  String get silence;

  /// No description provided for @timer.
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get timer;

  /// No description provided for @showNotes.
  ///
  /// In en, this message translates to:
  /// **'Show notes'**
  String get showNotes;

  /// No description provided for @noShowNotes.
  ///
  /// In en, this message translates to:
  /// **'No show notes were provided for this episode.'**
  String get noShowNotes;

  /// No description provided for @playbackSpeed.
  ///
  /// In en, this message translates to:
  /// **'Playback speed'**
  String get playbackSpeed;

  /// No description provided for @skipSilence.
  ///
  /// In en, this message translates to:
  /// **'Skip silence'**
  String get skipSilence;

  /// No description provided for @recommendedNaturalSpeech.
  ///
  /// In en, this message translates to:
  /// **'Recommended for natural speech'**
  String get recommendedNaturalSpeech;

  /// No description provided for @onlyForPodcast.
  ///
  /// In en, this message translates to:
  /// **'Only for {podcast}'**
  String onlyForPodcast(String podcast);

  /// No description provided for @globalDefaultExplanation.
  ///
  /// In en, this message translates to:
  /// **'Otherwise this becomes the global default.'**
  String get globalDefaultExplanation;

  /// No description provided for @useGlobal.
  ///
  /// In en, this message translates to:
  /// **'Use global'**
  String get useGlobal;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @sleepTimer.
  ///
  /// In en, this message translates to:
  /// **'Sleep timer'**
  String get sleepTimer;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 minute} other{{count} minutes}}'**
  String minutes(int count);

  /// No description provided for @endOfEpisode.
  ///
  /// In en, this message translates to:
  /// **'End of episode'**
  String get endOfEpisode;

  /// No description provided for @cancelTimer.
  ///
  /// In en, this message translates to:
  /// **'Cancel timer'**
  String get cancelTimer;

  /// No description provided for @chapters.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 chapter} other{{count} chapters}}'**
  String chapters(int count);

  /// No description provided for @chapter.
  ///
  /// In en, this message translates to:
  /// **'Chapter'**
  String get chapter;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'Use device setting'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose theme'**
  String get themeDialogTitle;

  /// No description provided for @backgroundSyncStatus.
  ///
  /// In en, this message translates to:
  /// **'Background sync status'**
  String get backgroundSyncStatus;

  /// No description provided for @leaveDemo.
  ///
  /// In en, this message translates to:
  /// **'Leave demo'**
  String get leaveDemo;

  /// No description provided for @disconnectServer.
  ///
  /// In en, this message translates to:
  /// **'Disconnect server'**
  String get disconnectServer;

  /// No description provided for @goodListening.
  ///
  /// In en, this message translates to:
  /// **'Good listening.'**
  String get goodListening;

  /// No description provided for @continueListening.
  ///
  /// In en, this message translates to:
  /// **'Continue listening'**
  String get continueListening;

  /// No description provided for @allEpisodes.
  ///
  /// In en, this message translates to:
  /// **'All episodes'**
  String get allEpisodes;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @selectEpisodes.
  ///
  /// In en, this message translates to:
  /// **'Select episodes'**
  String get selectEpisodes;

  /// No description provided for @libraryUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Library unavailable'**
  String get libraryUnavailable;

  /// No description provided for @pullToRetry.
  ///
  /// In en, this message translates to:
  /// **'Pull down to try loading it again.'**
  String get pullToRetry;

  /// No description provided for @libraryReady.
  ///
  /// In en, this message translates to:
  /// **'Your library is ready'**
  String get libraryReady;

  /// No description provided for @discoverFirstSubscription.
  ///
  /// In en, this message translates to:
  /// **'Use Search to add your first subscription.'**
  String get discoverFirstSubscription;

  /// No description provided for @noMatchingEpisodes.
  ///
  /// In en, this message translates to:
  /// **'No matching episodes'**
  String get noMatchingEpisodes;

  /// No description provided for @chooseAnotherFilter.
  ///
  /// In en, this message translates to:
  /// **'Choose another filter or refresh your subscriptions.'**
  String get chooseAnotherFilter;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterUnplayed.
  ///
  /// In en, this message translates to:
  /// **'Unplayed'**
  String get filterUnplayed;

  /// No description provided for @filterPlayed.
  ///
  /// In en, this message translates to:
  /// **'Played'**
  String get filterPlayed;

  /// No description provided for @filterDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Downloaded'**
  String get filterDownloaded;

  /// No description provided for @filterQueued.
  ///
  /// In en, this message translates to:
  /// **'Queued'**
  String get filterQueued;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Your podcasts,\nwherever you listen.'**
  String get onboardingTitle;

  /// No description provided for @onboardingBody.
  ///
  /// In en, this message translates to:
  /// **'Connect Podpine to your Pinepods server. Your library stays available when the server doesn’t.'**
  String get onboardingBody;

  /// No description provided for @pinepodsServer.
  ///
  /// In en, this message translates to:
  /// **'Pinepods server'**
  String get pinepodsServer;

  /// No description provided for @serverHint.
  ///
  /// In en, this message translates to:
  /// **'https://podcasts.example.com'**
  String get serverHint;

  /// No description provided for @serverRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your server address.'**
  String get serverRequired;

  /// No description provided for @apiKey.
  ///
  /// In en, this message translates to:
  /// **'API key'**
  String get apiKey;

  /// No description provided for @apiKeyHint.
  ///
  /// In en, this message translates to:
  /// **'Paste a key from Pinepods settings'**
  String get apiKeyHint;

  /// No description provided for @apiKeyRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your API key.'**
  String get apiKeyRequired;

  /// No description provided for @connectSecurely.
  ///
  /// In en, this message translates to:
  /// **'Connect securely'**
  String get connectSecurely;

  /// No description provided for @exploreDemo.
  ///
  /// In en, this message translates to:
  /// **'Explore with a demo library'**
  String get exploreDemo;

  /// No description provided for @secureStorageExplanation.
  ///
  /// In en, this message translates to:
  /// **'Your key is stored in this device’s secure storage.'**
  String get secureStorageExplanation;

  /// No description provided for @showApiKey.
  ///
  /// In en, this message translates to:
  /// **'Show API key'**
  String get showApiKey;

  /// No description provided for @hideApiKey.
  ///
  /// In en, this message translates to:
  /// **'Hide API key'**
  String get hideApiKey;

  /// No description provided for @episodeActions.
  ///
  /// In en, this message translates to:
  /// **'Episode actions'**
  String get episodeActions;

  /// No description provided for @markPlayed.
  ///
  /// In en, this message translates to:
  /// **'Mark played'**
  String get markPlayed;

  /// No description provided for @markUnplayed.
  ///
  /// In en, this message translates to:
  /// **'Mark unplayed'**
  String get markUnplayed;

  /// No description provided for @addToQueue.
  ///
  /// In en, this message translates to:
  /// **'Add to queue'**
  String get addToQueue;

  /// No description provided for @removeFromQueue.
  ///
  /// In en, this message translates to:
  /// **'Remove from queue'**
  String get removeFromQueue;

  /// No description provided for @playNext.
  ///
  /// In en, this message translates to:
  /// **'Play next'**
  String get playNext;

  /// No description provided for @removeFromInboxKeepUnplayed.
  ///
  /// In en, this message translates to:
  /// **'Remove from Inbox (keep unplayed)'**
  String get removeFromInboxKeepUnplayed;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @pauseDownload.
  ///
  /// In en, this message translates to:
  /// **'Pause download'**
  String get pauseDownload;

  /// No description provided for @cancelDownload.
  ///
  /// In en, this message translates to:
  /// **'Cancel download'**
  String get cancelDownload;

  /// No description provided for @resumeDownload.
  ///
  /// In en, this message translates to:
  /// **'Resume download'**
  String get resumeDownload;

  /// No description provided for @retryDownload.
  ///
  /// In en, this message translates to:
  /// **'Retry download'**
  String get retryDownload;

  /// No description provided for @deleteDownload.
  ///
  /// In en, this message translates to:
  /// **'Delete download'**
  String get deleteDownload;

  /// No description provided for @downloaded.
  ///
  /// In en, this message translates to:
  /// **'Downloaded'**
  String get downloaded;

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String minutesShort(int count);

  /// No description provided for @exitSelection.
  ///
  /// In en, this message translates to:
  /// **'Exit selection'**
  String get exitSelection;

  /// No description provided for @selectedCount.
  ///
  /// In en, this message translates to:
  /// **'{selected} of {total} selected'**
  String selectedCount(int selected, int total);

  /// No description provided for @expandSelection.
  ///
  /// In en, this message translates to:
  /// **'Expand selection'**
  String get expandSelection;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get selectAll;

  /// No description provided for @selectAllAbove.
  ///
  /// In en, this message translates to:
  /// **'Select all above'**
  String get selectAllAbove;

  /// No description provided for @selectAllBelow.
  ///
  /// In en, this message translates to:
  /// **'Select all below'**
  String get selectAllBelow;

  /// No description provided for @selectedActions.
  ///
  /// In en, this message translates to:
  /// **'Actions for selected items'**
  String get selectedActions;

  /// No description provided for @deleteFromDevice.
  ///
  /// In en, this message translates to:
  /// **'Delete from device'**
  String get deleteFromDevice;

  /// No description provided for @removeFromInbox.
  ///
  /// In en, this message translates to:
  /// **'Remove from Inbox'**
  String get removeFromInbox;

  /// No description provided for @bulkActionResult.
  ///
  /// In en, this message translates to:
  /// **'{action}: {succeeded} updated.{failure}'**
  String bulkActionResult(String action, int succeeded, String failure);

  /// No description provided for @bulkFailures.
  ///
  /// In en, this message translates to:
  /// **' {count} failed.'**
  String bulkFailures(int count);

  /// No description provided for @podcast.
  ///
  /// In en, this message translates to:
  /// **'Podcast'**
  String get podcast;

  /// No description provided for @episode.
  ///
  /// In en, this message translates to:
  /// **'Episode'**
  String get episode;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @episodes.
  ///
  /// In en, this message translates to:
  /// **'Episodes'**
  String get episodes;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @feedUrl.
  ///
  /// In en, this message translates to:
  /// **'Feed URL'**
  String get feedUrl;

  /// No description provided for @subscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscribe;

  /// No description provided for @subscribed.
  ///
  /// In en, this message translates to:
  /// **'Subscribed'**
  String get subscribed;

  /// No description provided for @unsubscribe.
  ///
  /// In en, this message translates to:
  /// **'Unsubscribe'**
  String get unsubscribe;

  /// No description provided for @unsubscribeQuestion.
  ///
  /// In en, this message translates to:
  /// **'Unsubscribe?'**
  String get unsubscribeQuestion;

  /// No description provided for @unsubscribeBody.
  ///
  /// In en, this message translates to:
  /// **'Remove {podcast} and its locally cached episodes from your library?'**
  String unsubscribeBody(String podcast);

  /// No description provided for @podcastDownloadSettings.
  ///
  /// In en, this message translates to:
  /// **'Podcast download settings'**
  String get podcastDownloadSettings;

  /// No description provided for @refreshDetails.
  ///
  /// In en, this message translates to:
  /// **'Refresh details'**
  String get refreshDetails;

  /// No description provided for @noEpisodesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No episodes available'**
  String get noEpisodesAvailable;

  /// No description provided for @feedUpdating.
  ///
  /// In en, this message translates to:
  /// **'This feed may still be updating. Pull down to try again.'**
  String get feedUpdating;

  /// No description provided for @totalCount.
  ///
  /// In en, this message translates to:
  /// **'{count} total'**
  String totalCount(int count);

  /// No description provided for @episodeCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 episode} other{{count} episodes}}'**
  String episodeCount(int count);

  /// No description provided for @explicit.
  ///
  /// In en, this message translates to:
  /// **'Explicit'**
  String get explicit;

  /// No description provided for @untitledPodcast.
  ///
  /// In en, this message translates to:
  /// **'Untitled podcast'**
  String get untitledPodcast;

  /// No description provided for @untitledEpisode.
  ///
  /// In en, this message translates to:
  /// **'Untitled episode'**
  String get untitledEpisode;

  /// No description provided for @publicationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Publication date unavailable'**
  String get publicationUnavailable;

  /// No description provided for @played.
  ///
  /// In en, this message translates to:
  /// **'Played'**
  String get played;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get inProgress;

  /// No description provided for @queued.
  ///
  /// In en, this message translates to:
  /// **'Queued'**
  String get queued;

  /// No description provided for @podcastOffline.
  ///
  /// In en, this message translates to:
  /// **'Podcast details are unavailable while offline.'**
  String get podcastOffline;

  /// No description provided for @savedOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline — showing saved details.'**
  String get savedOffline;

  /// No description provided for @openLink.
  ///
  /// In en, this message translates to:
  /// **'Open {url}'**
  String openLink(String url);

  /// No description provided for @linkLaunchFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t open this link.'**
  String get linkLaunchFailed;

  /// No description provided for @findSomething.
  ///
  /// In en, this message translates to:
  /// **'Find something worth hearing'**
  String get findSomething;

  /// No description provided for @discover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discover;

  /// No description provided for @searchBody.
  ///
  /// In en, this message translates to:
  /// **'Search through the discovery provider configured on your Pinepods server.'**
  String get searchBody;

  /// No description provided for @offlineSavedSearch.
  ///
  /// In en, this message translates to:
  /// **'Offline — showing saved search results.'**
  String get offlineSavedSearch;

  /// No description provided for @searchPodcasts.
  ///
  /// In en, this message translates to:
  /// **'Search podcasts'**
  String get searchPodcasts;

  /// No description provided for @searchProvider.
  ///
  /// In en, this message translates to:
  /// **'Pinepods search provider'**
  String get searchProvider;

  /// No description provided for @podcastIndex.
  ///
  /// In en, this message translates to:
  /// **'Podcast Index'**
  String get podcastIndex;

  /// No description provided for @itunes.
  ///
  /// In en, this message translates to:
  /// **'iTunes'**
  String get itunes;

  /// No description provided for @noPodcastsFound.
  ///
  /// In en, this message translates to:
  /// **'No podcasts found'**
  String get noPodcastsFound;

  /// No description provided for @tryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try another title, author, or search provider.'**
  String get tryDifferentSearch;

  /// No description provided for @upNext.
  ///
  /// In en, this message translates to:
  /// **'Up next'**
  String get upNext;

  /// No description provided for @queueFollowsDevices.
  ///
  /// In en, this message translates to:
  /// **'This queue follows you across devices.'**
  String get queueFollowsDevices;

  /// No description provided for @nothingQueued.
  ///
  /// In en, this message translates to:
  /// **'Nothing queued'**
  String get nothingQueued;

  /// No description provided for @queueEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Open an episode menu and choose Add to queue.'**
  String get queueEmptyBody;

  /// No description provided for @playQueue.
  ///
  /// In en, this message translates to:
  /// **'Play queue'**
  String get playQueue;

  /// No description provided for @clearQueue.
  ///
  /// In en, this message translates to:
  /// **'Clear queue'**
  String get clearQueue;

  /// No description provided for @clearQueueQuestion.
  ///
  /// In en, this message translates to:
  /// **'Clear queue?'**
  String get clearQueueQuestion;

  /// No description provided for @clearQueueBody.
  ///
  /// In en, this message translates to:
  /// **'This removes every queued episode on all connected devices. Anything already playing will keep playing.'**
  String get clearQueueBody;

  /// No description provided for @queueUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t open the queue'**
  String get queueUnavailable;

  /// No description provided for @queueUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'Try again in a moment.'**
  String get queueUnavailableBody;

  /// No description provided for @subscriptionsSaved.
  ///
  /// In en, this message translates to:
  /// **'Your subscriptions, saved on this device.'**
  String get subscriptionsSaved;

  /// No description provided for @selectPodcasts.
  ///
  /// In en, this message translates to:
  /// **'Select podcasts'**
  String get selectPodcasts;

  /// No description provided for @automaticDownloadSettings.
  ///
  /// In en, this message translates to:
  /// **'Automatic download settings'**
  String get automaticDownloadSettings;

  /// No description provided for @lowStorage.
  ///
  /// In en, this message translates to:
  /// **'Device storage is low'**
  String get lowStorage;

  /// No description provided for @lowStorageBody.
  ///
  /// In en, this message translates to:
  /// **'Clean up downloads before saving more episodes.'**
  String get lowStorageBody;

  /// No description provided for @noSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'No subscriptions yet'**
  String get noSubscriptions;

  /// No description provided for @noSubscriptionsBody.
  ///
  /// In en, this message translates to:
  /// **'Use Search to find and subscribe to a podcast.'**
  String get noSubscriptionsBody;

  /// No description provided for @libraryUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'Try again in a moment.'**
  String get libraryUnavailableBody;

  /// No description provided for @unsubscribeSelectedQuestion.
  ///
  /// In en, this message translates to:
  /// **'Unsubscribe from {count, plural, =1{1 podcast} other{{count} podcasts}}?'**
  String unsubscribeSelectedQuestion(int count);

  /// No description provided for @unsubscribeSelectedBody.
  ///
  /// In en, this message translates to:
  /// **'Their locally cached episodes will be removed from the library.'**
  String get unsubscribeSelectedBody;

  /// No description provided for @unsubscribedResult.
  ///
  /// In en, this message translates to:
  /// **'Unsubscribed from {count}.{failure}'**
  String unsubscribedResult(int count, String failure);

  /// No description provided for @keyboardNavigationHint.
  ///
  /// In en, this message translates to:
  /// **'Use Alt plus 1 through 5 to switch sections.'**
  String get keyboardNavigationHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
