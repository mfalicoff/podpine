// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Podpine';

  @override
  String get home => 'Home';

  @override
  String get inbox => 'Inbox';

  @override
  String get library => 'Library';

  @override
  String get queue => 'Queue';

  @override
  String get search => 'Search';

  @override
  String get navigationLabel => 'Primary navigation';

  @override
  String openPlayer(String title) {
    return 'Open player for $title';
  }

  @override
  String get skipBack => 'Skip back 15 seconds';

  @override
  String get skipForward => 'Skip forward 30 seconds';

  @override
  String get play => 'Play';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Resume';

  @override
  String get retry => 'Retry';

  @override
  String get dismissPlaybackError => 'Dismiss playback error';

  @override
  String get playbackPosition => 'Playback position';

  @override
  String get speed => 'Speed';

  @override
  String get silence => 'Silence';

  @override
  String get timer => 'Timer';

  @override
  String get showNotes => 'Show notes';

  @override
  String get noShowNotes => 'No show notes were provided for this episode.';

  @override
  String get playbackSpeed => 'Playback speed';

  @override
  String get skipSilence => 'Skip silence';

  @override
  String get recommendedNaturalSpeech => 'Recommended for natural speech';

  @override
  String onlyForPodcast(String podcast) {
    return 'Only for $podcast';
  }

  @override
  String get globalDefaultExplanation =>
      'Otherwise this becomes the global default.';

  @override
  String get useGlobal => 'Use global';

  @override
  String get cancel => 'Cancel';

  @override
  String get apply => 'Apply';

  @override
  String get sleepTimer => 'Sleep timer';

  @override
  String minutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes',
      one: '1 minute',
    );
    return '$_temp0';
  }

  @override
  String get endOfEpisode => 'End of episode';

  @override
  String get cancelTimer => 'Cancel timer';

  @override
  String chapters(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count chapters',
      one: '1 chapter',
    );
    return '$_temp0';
  }

  @override
  String get chapter => 'Chapter';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'Use device setting';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeDialogTitle => 'Choose theme';

  @override
  String get backgroundSyncStatus => 'Background sync status';

  @override
  String get leaveDemo => 'Leave demo';

  @override
  String get disconnectServer => 'Disconnect server';

  @override
  String get goodListening => 'Good listening.';

  @override
  String get continueListening => 'Continue listening';

  @override
  String get allEpisodes => 'All episodes';

  @override
  String get refresh => 'Refresh';

  @override
  String get selectEpisodes => 'Select episodes';

  @override
  String get libraryUnavailable => 'Library unavailable';

  @override
  String get pullToRetry => 'Pull down to try loading it again.';

  @override
  String get libraryReady => 'Your library is ready';

  @override
  String get discoverFirstSubscription =>
      'Use Search to add your first subscription.';

  @override
  String get noMatchingEpisodes => 'No matching episodes';

  @override
  String get chooseAnotherFilter =>
      'Choose another filter or refresh your subscriptions.';

  @override
  String get filterAll => 'All';

  @override
  String get filterUnplayed => 'Unplayed';

  @override
  String get filterPlayed => 'Played';

  @override
  String get filterDownloaded => 'Downloaded';

  @override
  String get filterQueued => 'Queued';

  @override
  String get onboardingTitle => 'Your podcasts,\nwherever you listen.';

  @override
  String get onboardingBody =>
      'Connect Podpine to your Pinepods server. Your library stays available when the server doesn’t.';

  @override
  String get pinepodsServer => 'Pinepods server';

  @override
  String get serverHint => 'https://podcasts.example.com';

  @override
  String get serverRequired => 'Enter your server address.';

  @override
  String get apiKey => 'API key';

  @override
  String get apiKeyHint => 'Paste a key from Pinepods settings';

  @override
  String get apiKeyRequired => 'Enter your API key.';

  @override
  String get connectSecurely => 'Connect securely';

  @override
  String get exploreDemo => 'Explore with a demo library';

  @override
  String get secureStorageExplanation =>
      'Your key is stored in this device’s secure storage.';

  @override
  String get showApiKey => 'Show API key';

  @override
  String get hideApiKey => 'Hide API key';

  @override
  String get episodeActions => 'Episode actions';

  @override
  String get markPlayed => 'Mark played';

  @override
  String get markUnplayed => 'Mark unplayed';

  @override
  String get addToQueue => 'Add to queue';

  @override
  String get removeFromQueue => 'Remove from queue';

  @override
  String get playNext => 'Play next';

  @override
  String get removeFromInboxKeepUnplayed => 'Remove from Inbox (keep unplayed)';

  @override
  String get download => 'Download';

  @override
  String get pauseDownload => 'Pause download';

  @override
  String get cancelDownload => 'Cancel download';

  @override
  String get resumeDownload => 'Resume download';

  @override
  String get retryDownload => 'Retry download';

  @override
  String get deleteDownload => 'Delete download';

  @override
  String get downloaded => 'Downloaded';

  @override
  String minutesShort(int count) {
    return '$count min';
  }

  @override
  String get exitSelection => 'Exit selection';

  @override
  String selectedCount(int selected, int total) {
    return '$selected of $total selected';
  }

  @override
  String get expandSelection => 'Expand selection';

  @override
  String get selectAll => 'Select all';

  @override
  String get selectAllAbove => 'Select all above';

  @override
  String get selectAllBelow => 'Select all below';

  @override
  String get selectedActions => 'Actions for selected items';

  @override
  String get deleteFromDevice => 'Delete from device';

  @override
  String get removeFromInbox => 'Remove from Inbox';

  @override
  String bulkActionResult(String action, int succeeded, String failure) {
    return '$action: $succeeded updated.$failure';
  }

  @override
  String bulkFailures(int count) {
    return ' $count failed.';
  }

  @override
  String get podcast => 'Podcast';

  @override
  String get episode => 'Episode';

  @override
  String get about => 'About';

  @override
  String get episodes => 'Episodes';

  @override
  String get website => 'Website';

  @override
  String get feedUrl => 'Feed URL';

  @override
  String get subscribe => 'Subscribe';

  @override
  String get subscribed => 'Subscribed';

  @override
  String get unsubscribe => 'Unsubscribe';

  @override
  String get unsubscribeQuestion => 'Unsubscribe?';

  @override
  String unsubscribeBody(String podcast) {
    return 'Remove $podcast and its locally cached episodes from your library?';
  }

  @override
  String get podcastDownloadSettings => 'Podcast download settings';

  @override
  String get refreshDetails => 'Refresh details';

  @override
  String get noEpisodesAvailable => 'No episodes available';

  @override
  String get feedUpdating =>
      'This feed may still be updating. Pull down to try again.';

  @override
  String totalCount(int count) {
    return '$count total';
  }

  @override
  String episodeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episodes',
      one: '1 episode',
    );
    return '$_temp0';
  }

  @override
  String get explicit => 'Explicit';

  @override
  String get untitledPodcast => 'Untitled podcast';

  @override
  String get untitledEpisode => 'Untitled episode';

  @override
  String get publicationUnavailable => 'Publication date unavailable';

  @override
  String get played => 'Played';

  @override
  String get inProgress => 'In progress';

  @override
  String get queued => 'Queued';

  @override
  String get podcastOffline => 'Podcast details are unavailable while offline.';

  @override
  String get savedOffline => 'Offline — showing saved details.';

  @override
  String openLink(String url) {
    return 'Open $url';
  }

  @override
  String get linkLaunchFailed => 'Couldn’t open this link.';

  @override
  String get findSomething => 'Find something worth hearing';

  @override
  String get discover => 'Discover';

  @override
  String get searchBody =>
      'Search through the discovery provider configured on your Pinepods server.';

  @override
  String get offlineSavedSearch => 'Offline — showing saved search results.';

  @override
  String get searchPodcasts => 'Search podcasts';

  @override
  String get searchProvider => 'Pinepods search provider';

  @override
  String get podcastIndex => 'Podcast Index';

  @override
  String get itunes => 'iTunes';

  @override
  String get noPodcastsFound => 'No podcasts found';

  @override
  String get tryDifferentSearch =>
      'Try another title, author, or search provider.';

  @override
  String get upNext => 'Up next';

  @override
  String get queueFollowsDevices => 'This queue follows you across devices.';

  @override
  String get nothingQueued => 'Nothing queued';

  @override
  String get queueEmptyBody => 'Open an episode menu and choose Add to queue.';

  @override
  String get playQueue => 'Play queue';

  @override
  String get clearQueue => 'Clear queue';

  @override
  String get clearQueueQuestion => 'Clear queue?';

  @override
  String get clearQueueBody =>
      'This removes every queued episode on all connected devices. Anything already playing will keep playing.';

  @override
  String get queueUnavailable => 'Couldn’t open the queue';

  @override
  String get queueUnavailableBody => 'Try again in a moment.';

  @override
  String get subscriptionsSaved => 'Your subscriptions, saved on this device.';

  @override
  String get selectPodcasts => 'Select podcasts';

  @override
  String get automaticDownloadSettings => 'Automatic download settings';

  @override
  String get lowStorage => 'Device storage is low';

  @override
  String get lowStorageBody =>
      'Clean up downloads before saving more episodes.';

  @override
  String get noSubscriptions => 'No subscriptions yet';

  @override
  String get noSubscriptionsBody =>
      'Use Search to find and subscribe to a podcast.';

  @override
  String get libraryUnavailableBody => 'Try again in a moment.';

  @override
  String unsubscribeSelectedQuestion(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count podcasts',
      one: '1 podcast',
    );
    return 'Unsubscribe from $_temp0?';
  }

  @override
  String get unsubscribeSelectedBody =>
      'Their locally cached episodes will be removed from the library.';

  @override
  String unsubscribedResult(int count, String failure) {
    return 'Unsubscribed from $count.$failure';
  }

  @override
  String get keyboardNavigationHint =>
      'Use Alt plus 1 through 5 to switch sections.';
}
