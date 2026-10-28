import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web/web.dart' as web;

import '../../core/values/color_constants.dart';
import '../../core/values/lucide_icons.dart';
import 'app_tokens.dart';
import 'app_widgets.dart';

/// True when [url] points at a PDF (by path extension; query/fragment ignored).
bool isPdfUrl(String url) {
  final path = Uri.tryParse(url.trim())?.path ?? url;
  return path.toLowerCase().endsWith('.pdf');
}

/// Opens an uploaded document in a new browser tab.
void openDocumentInNewTab(String url) => web.window.open(url, '_blank');

/// Previews an uploaded document: images in a zoomable viewer, PDFs in the
/// browser's built-in PDF viewer. Phones get an "Open PDF" card instead,
/// because mobile browsers don't render PDFs inside an iframe.
void showAppDocumentViewer(String url, String title) {
  final pdf = isPdfUrl(url);
  final context = Get.context!;
  final size = MediaQuery.sizeOf(context);
  final narrow = size.width < 600;
  final bodyHeight = (size.height * 0.7).clamp(320.0, 760.0);

  final Widget body;
  if (pdf && narrow) {
    body = AppEmptyState(
      icon: LucideIcons.fileText,
      tone: AppTone.danger,
      title: 'PDF document',
      message: 'Open the PDF in a new tab to view it on this device.',
      actionLabel: 'Open PDF',
      actionIcon: LucideIcons.externalLink,
      onAction: () => openDocumentInNewTab(url),
    );
  } else if (pdf) {
    body = SizedBox(
      width: double.infinity,
      height: bodyHeight,
      child: _PdfFrame(url: url),
    );
  } else {
    body = SizedBox(
      width: double.infinity,
      height: narrow ? bodyHeight * 0.75 : 460,
      child: InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: Image.network(
          url,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: progress.expectedTotalBytes != null
                    ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => const AppEmptyState(
            icon: LucideIcons.imageOff,
            title: 'Image couldn\'t be loaded',
            message: 'The file may have been moved or the link is out of date.',
            compact: true,
          ),
        ),
      ),
    );
  }

  Get.dialog(
    AppDialog(
      title: title,
      subtitle: pdf ? 'PDF document' : null,
      icon: pdf ? LucideIcons.fileText : LucideIcons.image,
      maxWidth: pdf ? 960 : 640,
      onClose: () => Get.back(),
      // The PDF viewer brings its own chrome; let it run edge to edge.
      bodyPadding: pdf && !narrow ? EdgeInsets.zero : const EdgeInsets.all(16),
      actions: [
        OutlinedButton.icon(
          onPressed: () => openDocumentInNewTab(url),
          icon: const Icon(LucideIcons.externalLink, size: 18),
          label: const Text('Open in new tab'),
        ),
      ],
      child: body,
    ),
  );
}

/// Square thumbnail for an uploaded document: the image itself, or a PDF tile.
class AppDocumentThumb extends StatelessWidget {
  const AppDocumentThumb({
    super.key,
    required this.url,
    this.size = 56,
    this.fallbackIcon = LucideIcons.file,
  });

  final String url;
  final double size;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.md);
    Widget tile(IconData icon, AppTone tone, {String? label}) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: tone.soft,
            borderRadius: radius,
            border: Border.all(color: AppColor.divColor),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: size * 0.38, color: tone.color),
              if (label != null) ...[
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: size * 0.17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: tone.color,
                  ),
                ),
              ],
            ],
          ),
        );

    if (isPdfUrl(url)) return tile(LucideIcons.fileText, AppTone.danger, label: 'PDF');

    return ClipRRect(
      borderRadius: radius,
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => tile(fallbackIcon, AppTone.neutral),
      ),
    );
  }
}

/// Hosts the browser's native PDF viewer in an iframe.
class _PdfFrame extends StatelessWidget {
  const _PdfFrame({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return HtmlElementView.fromTagName(
      tagName: 'iframe',
      onElementCreated: (Object element) {
        final frame = element as web.HTMLIFrameElement;
        frame.src = url;
        frame.title = 'PDF document';
        frame.style.border = 'none';
        frame.style.width = '100%';
        frame.style.height = '100%';
      },
    );
  }
}
