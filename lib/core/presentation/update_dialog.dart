import 'dart:async';

import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../services/update_service.dart';

/// Shows the "Update Available" dialog for [info], handling the download
/// (with a progress dialog) and launching the installer on confirmation.
Future<void> showUpdateAvailableDialog(BuildContext context, UpdateService service, UpdateInfo info) async {
  final l10n = AppLocalizations.of(context);

  final shouldUpdate = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.updateAvailableTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.updateAvailableBody(info.version)),
          if (info.releaseNotes.isNotEmpty) ...[
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 160),
              child: SingleChildScrollView(
                child: Text(
                  info.releaseNotes,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.later)),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.updateNow)),
      ],
    ),
  );

  if (shouldUpdate != true || !context.mounted) return;
  await _downloadAndInstall(context, service, info);
}

Future<void> _downloadAndInstall(BuildContext context, UpdateService service, UpdateInfo info) async {
  final l10n = AppLocalizations.of(context);
  final progress = ValueNotifier<double>(0);

  unawaited(showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text(l10n.downloading),
      content: ValueListenableBuilder<double>(
        valueListenable: progress,
        builder: (context, value, _) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(value: value > 0 ? value : null),
            const SizedBox(height: 8),
            Text('${(value * 100).clamp(0, 100).toStringAsFixed(0)}%'),
          ],
        ),
      ),
    ),
  ));

  try {
    await service.downloadAndInstall(info, onProgress: (value) => progress.value = value);
    if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
  } catch (e) {
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.updateInstallFailed(e.toString()))),
    );
  }
}
