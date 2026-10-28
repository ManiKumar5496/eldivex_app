import 'package:flutter/material.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';

import '../core/values/size_configue.dart';
import 'ui/app_tokens.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class CommonFileUpload extends StatefulWidget {
  final String label;
  final String hint;
  final String supportedFormats;
  final int maxFileSizeMB;
  final bool allowMultiple;
  final List<String> allowedExtensions;
  final Function(List<PlatformFile>)? onFilesSelected;
  final Function(PlatformFile)? onFileRemoved;

  const CommonFileUpload({
    Key? key,
    this.label = 'Documents Upload',
    this.hint = 'Click to upload or drag and drop',
    this.supportedFormats = 'PDF, DOC, JPG or PNG (Max 10MB each)',
    this.maxFileSizeMB = 10,
    this.allowMultiple = true,
    this.allowedExtensions = const ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
    this.onFilesSelected,
    this.onFileRemoved,
  }) : super(key: key);

  @override
  State<CommonFileUpload> createState() => _CommonFileUploadState();
}

class _CommonFileUploadState extends State<CommonFileUpload> {
  final RxList<PlatformFile> uploadedFiles = <PlatformFile>[].obs;
  final RxBool isUploading = false.obs;

  Future<void> pickFiles() async {
    try {
      isUploading.value = true;

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: widget.allowedExtensions,
        allowMultiple: widget.allowMultiple,
        withData: true,
      );

      if (result != null) {
        List<PlatformFile> validFiles = [];

        for (var file in result.files) {
          // Check file size
          if (file.size <= widget.maxFileSizeMB * 1024 * 1024) {
            validFiles.add(file);
          } else {
            Get.snackbar(
              'File Too Large',
              '${file.name} exceeds ${widget.maxFileSizeMB}MB limit',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Color.alphaBlend(
                  AppColor.dangerSoft, AppColor.whiteColor),
              colorText: AppColor.textPrimary,
            );
          }
        }

        if (validFiles.isNotEmpty) {
          uploadedFiles.addAll(validFiles);
          widget.onFilesSelected?.call(validFiles);
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick files: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor:
            Color.alphaBlend(AppColor.dangerSoft, AppColor.whiteColor),
        colorText: AppColor.textPrimary,
      );
    } finally {
      isUploading.value = false;
    }
  }

  void removeFile(int index) {
    final file = uploadedFiles[index];
    uploadedFiles.removeAt(index);
    widget.onFileRemoved?.call(file);
  }

  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  IconData getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return LucideIcons.fileText;
      case 'doc':
      case 'docx':
        return LucideIcons.fileText;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return LucideIcons.image;
      default:
        return LucideIcons.file;
    }
  }

  Color getFileIconColor(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return AppColor.danger;
      case 'doc':
      case 'docx':
        return AppColor.info;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return AppColor.success;
      default:
        return AppColor.fontColorGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final radius = BorderRadius.circular(AppRadius.lg);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: AppColor.textSecondary,
          ),
        ),
        const SizedBox(height: 8),

        // Upload Area — dashed drop-zone card. Fills the available width
        // (falls back to the old 90%-of-screen width in unbounded rows).
        LayoutBuilder(builder: (context, constraints) {
          final width = constraints.hasBoundedWidth
              ? constraints.maxWidth
              : SizeConfig.blockSizeHorizontal * 90;
          return SizedBox(
            width: width,
            child: CustomPaint(
              foregroundPainter: _DashedBorderPainter(
                color: AppColor.borderStrong,
                radius: AppRadius.lg,
              ),
              child: Material(
                color: AppColor.surfaceMuted,
                borderRadius: radius,
                child: InkWell(
                  onTap: pickFiles,
                  borderRadius: radius,
                  hoverColor: AppColor.primarySoft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 28, horizontal: 20),
                    child: Column(
                      children: [
                        Obx(() => Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColor.primarySoft,
                                shape: BoxShape.circle,
                              ),
                              child: isUploading.value
                                  ? Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColor.cAppPrimaryColor,
                                      ),
                                    )
                                  : Icon(
                                      LucideIcons.cloudUpload,
                                      size: 22,
                                      color: AppColor.cAppPrimaryColor,
                                    ),
                            )),
                        const SizedBox(height: 12),
                        Text(
                          widget.hint,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColor.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.supportedFormats,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColor.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: pickFiles,
                          icon: const Icon(LucideIcons.paperclip, size: 18),
                          label: const Text('Choose Files'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),

        // Uploaded Files List
        Obx(() {
          if (uploadedFiles.isEmpty) {
            return const SizedBox.shrink();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'Uploaded Documents (${uploadedFiles.length})',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColor.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              ...uploadedFiles.asMap().entries.map((entry) {
                final index = entry.key;
                final file = entry.value;
                final extension = file.extension ?? '';
                final tint = getFileIconColor(extension);

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
                  decoration: BoxDecoration(
                    color: AppColor.whiteColor,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColor.divColor),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: tint.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Icon(
                          getFileIcon(extension),
                          color: tint,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              file.name,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: AppColor.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              formatFileSize(file.size),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColor.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Remove',
                        onPressed: () => removeFile(index),
                        icon: Icon(
                          LucideIcons.x,
                          color: AppColor.textTertiary,
                          size: 18,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                );
              }),
            ],
          );
        }),
      ],
    );
  }
}

/// Dashed rounded-rectangle outline for the drop zone.
class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    const dash = 6.0;
    const gap = 4.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    ).deflate(0.6);
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + dash), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}
