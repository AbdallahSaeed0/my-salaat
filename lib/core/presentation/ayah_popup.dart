import 'dart:math';

import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../models/quran_ayah.dart';

const _bismillah = 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ';
const _sadaqaAllah = 'صَدَقَ اللَّهُ الْعَظِيمُ';

Future<void> showRandomAyahDialog(BuildContext context) {
  final ayah = quranAyahPool[Random().nextInt(quranAyahPool.length)];
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _bismillah,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            ayah.arabic,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(height: 1.6),
          ),
          const SizedBox(height: 12),
          Text(
            _sadaqaAllah,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            ayah.reference,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
      actions: [
        Center(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).ameen),
          ),
        ),
      ],
      actionsAlignment: MainAxisAlignment.center,
    ),
  );
}
