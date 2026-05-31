import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';

import '../core/values/size_configue.dart';

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
              backgroundColor: Colors.red.shade100,
              colorText: Colors.red.shade900,
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
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
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
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color getFileIconColor(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),

        // Upload Area
        Container(
          width: SizeConfig.blockSizeHorizontal * 90,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.blue.shade300,
              width: 2,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(12),
            color: Colors.blue.shade50.withOpacity(0.3),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: pickFiles,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                child: Column(
                  children: [
                    Icon(
                      Icons.upload_outlined,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.hint,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.supportedFormats,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton(
                      onPressed: pickFiles,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        side: BorderSide(color: Colors.grey.shade400),
                      ),
                      child: const Text('Choose Files'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Uploaded Files List
        Obx(() {
          if (uploadedFiles.isEmpty) {
            return const SizedBox.shrink();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                'Uploaded Documents (${uploadedFiles.length})',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 12),
              ...uploadedFiles.asMap().entries.map((entry) {
                final index = entry.key;
                final file = entry.value;
                final extension = file.extension ?? '';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: getFileIconColor(extension).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          getFileIcon(extension),
                          color: getFileIconColor(extension),
                          size: 24,
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
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade800,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formatFileSize(file.size),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => removeFile(index),
                        icon: Icon(
                          Icons.close,
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          );
        }),
      ],
    );
  }
}