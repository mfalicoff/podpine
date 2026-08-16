enum LibraryArtworkSize {
  small('Small'),
  medium('Medium'),
  large('Large');

  const LibraryArtworkSize(this.label);

  final String label;

  static LibraryArtworkSize parse(String? value) => values.firstWhere(
    (size) => size.name == value,
    orElse: () => LibraryArtworkSize.medium,
  );
}

class LibraryPreferences {
  const LibraryPreferences({this.artworkSize = LibraryArtworkSize.medium});

  final LibraryArtworkSize artworkSize;
}
