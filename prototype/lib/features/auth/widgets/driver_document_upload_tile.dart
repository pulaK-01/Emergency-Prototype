import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:medirapid/features/auth/models/driver_verification_document.dart';

class DriverDocumentUploadTile extends StatelessWidget {
  const DriverDocumentUploadTile({
    required this.document,
    required this.file,
    required this.onTap,
    required this.onRemove,
    super.key,
  });

  final DriverVerificationDocument document;
  final PlatformFile? file;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final isUploaded = file != null;

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          isUploaded ? Icons.description_outlined : document.icon,
          color: isUploaded ? Colors.green : Colors.blueAccent,
        ),
        title: Text(
          document.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          isUploaded ? file!.name : document.subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: isUploaded
            ? IconButton(
                tooltip: 'Remove ${document.title}',
                onPressed: onRemove,
                icon: const Icon(Icons.close, color: Colors.redAccent),
              )
            : const Icon(Icons.upload_file_outlined),
      ),
    );
  }
}
