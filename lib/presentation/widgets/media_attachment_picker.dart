import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kuliahku/core/constants/app_colors.dart';
import 'package:kuliahku/core/utils/file_vault_helper.dart';
import 'package:kuliahku/data/models/meeting_attachment_model.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class MediaAttachmentPicker extends StatelessWidget {
  final String meetingId;
  final List<MeetingAttachmentModel> attachments;
  final Function(MeetingAttachmentModel) onAttachmentAdded;
  final Function(MeetingAttachmentModel) onAttachmentRemoved;

  const MediaAttachmentPicker({
    super.key,
    required this.meetingId,
    required this.attachments,
    required this.onAttachmentAdded,
    required this.onAttachmentRemoved,
  });

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, imageQuality: 85);
      if (picked != null) {
        final savedPath = await FileVaultHelper.saveFileLocally(picked.path);
        final file = File(savedPath);
        final size = await file.length();
        final name = p.basename(picked.path);

        final attachment = MeetingAttachmentModel(
          id: const Uuid().v4(),
          meetingId: meetingId,
          filePath: savedPath,
          fileName: name,
          fileType: 'image',
          fileSize: size,
          createdAt: DateTime.now(),
        );

        onAttachmentAdded(attachment);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil gambar: $e')),
        );
      }
    }
  }

  Future<void> _pickDocument(BuildContext context) async {
    try {
      final result = await FilePicker.pickFiles();
      if (result.isNotEmpty && result.first.path != null) {
        final origPath = result.first.path!;
        final savedPath = await FileVaultHelper.saveFileLocally(origPath);
        final file = File(savedPath);
        final size = await file.length();
        final name = result.first.name;

        final isImg = FileVaultHelper.isImageFile(origPath);

        final attachment = MeetingAttachmentModel(
          id: const Uuid().v4(),
          meetingId: meetingId,
          filePath: savedPath,
          fileName: name,
          fileType: isImg ? 'image' : 'file',
          fileSize: size,
          createdAt: DateTime.now(),
        );

        onAttachmentAdded(attachment);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih file dokumen: $e')),
        );
      }
    }
  }

  void _previewImage(BuildContext context, String path, String title) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: InteractiveViewer(
                child: Image.file(
                  File(path),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    padding: const EdgeInsets.all(32),
                    color: Colors.black54,
                    child: const Text('Berkas foto tidak ditemukan', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Action Buttons Row
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(context, ImageSource.camera),
                icon: const Icon(Icons.camera_alt_outlined, size: 18),
                label: const Text('Kamera', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  side: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(context, ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined, size: 18),
                label: const Text('Galeri', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  side: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickDocument(context),
                icon: const Icon(Icons.upload_file_outlined, size: 18),
                label: const Text('Dokumen', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  side: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Attachment List
        if (attachments.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, style: BorderStyle.solid),
            ),
            child: const Column(
              children: [
                Icon(Icons.cloud_upload_outlined, size: 36, color: AppColors.textMuted),
                SizedBox(height: 6),
                Text(
                  'Belum ada foto slide atau dokumen yang diunggah.',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          )
        else
          Column(
            children: attachments.map((att) {
              final isImg = att.isImage;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    if (isImg)
                      GestureDetector(
                        onTap: () => _previewImage(context, att.filePath, att.fileName),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.file(
                            File(att.filePath),
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 44,
                              height: 44,
                              color: AppColors.surfaceVariant,
                              child: const Icon(Icons.broken_image, size: 20, color: AppColors.textMuted),
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.description_outlined, color: AppColors.primaryDark),
                      ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          if (isImg) {
                            _previewImage(context, att.filePath, att.fileName);
                          } else {
                            await FileVaultHelper.openFile(att.filePath);
                          }
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              att.fileName,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${isImg ? 'Foto Slide' : 'Dokumen'} • ${FileVaultHelper.formatFileSize(att.fileSize)}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.zoneDanger),
                      tooltip: 'Hapus Berkas',
                      onPressed: () => onAttachmentRemoved(att),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
