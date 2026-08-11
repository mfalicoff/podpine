import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../core/metadata_sanitizer.dart';

class Artwork extends StatelessWidget {
  const Artwork({
    super.key,
    required this.id,
    required this.title,
    this.url = '',
    this.size = 58,
    this.radius = 14,
  });

  final int id;
  final String title;
  final String url;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final safeUrl = MetadataSanitizer.safeHttpUrl(url);
    final palette = [
      const [Color(0xFF173F35), Color(0xFF6EA58C)],
      const [Color(0xFF653C43), Color(0xFFE58B79)],
      const [Color(0xFF27415D), Color(0xFF769FC7)],
      const [Color(0xFF64501F), Color(0xFFE0B654)],
    ];
    final colors = palette[id.abs() % palette.length];
    final placeholder = Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Text(
        title.trim().isEmpty ? 'P' : title.trim()[0].toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: size * .36,
        ),
      ),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: size,
        height: size,
        child: safeUrl.isEmpty
            ? placeholder
            : Image.network(
                safeUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => placeholder,
              ),
      ),
    );
  }
}

class SectionHeading extends StatelessWidget {
  const SectionHeading(this.title, {super.key, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 22, 12, 10),
    child: Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        ?trailing,
      ],
    ),
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: Color(0xFFDDE7E0),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: PodpineTheme.pine),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            body,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    ),
  );
}
