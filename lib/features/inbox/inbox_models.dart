enum InboxSwipeAction {
  queue,
  remove,
  togglePlayed,
  download,
  playNext;

  static InboxSwipeAction parse(String? value) => values.firstWhere(
    (action) => action.name == value,
    orElse: () => InboxSwipeAction.remove,
  );
}

enum InboxFilter { all, downloaded }

enum InboxSort { newest, oldest, podcast }

class InboxSwipePreferences {
  const InboxSwipePreferences({
    this.left = InboxSwipeAction.remove,
    this.right = InboxSwipeAction.queue,
  });

  final InboxSwipeAction left;
  final InboxSwipeAction right;
}

class PodcastInboxOverride {
  const PodcastInboxOverride({this.left, this.right});

  final InboxSwipeAction? left;
  final InboxSwipeAction? right;

  bool get isEmpty => left == null && right == null;

  InboxSwipePreferences resolve(InboxSwipePreferences fallback) =>
      InboxSwipePreferences(
        left: left ?? fallback.left,
        right: right ?? fallback.right,
      );
}
