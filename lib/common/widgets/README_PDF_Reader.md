# PDF Reader Widget and Downloader Utility

This package provides a comprehensive PDF reading solution with download capabilities for Flutter applications.

## Features

- **PDF Viewer**: Built with `pdfx` package for high-performance PDF rendering
- **Download Management**: Automatic file storage and retrieval
- **Offline Support**: Downloaded PDFs are stored locally for offline access
- **Progress Tracking**: Real-time download progress indication
- **Error Handling**: Comprehensive error handling with user-friendly messages
- **Flexible Configuration**: Multiple usage patterns and customization options

## Components

### 1. PdfDownloader Utility (`lib/common/utils/pdfDownloader.dart`)

A utility class that handles PDF downloading, storage, and management.

**Key Methods:**

- `downloadAndStorePdf()`: Downloads and stores PDF files
- `isPdfDownloaded()`: Checks if a PDF is already downloaded
- `getLocalPdfPath()`: Gets the local path of a downloaded PDF
- `deletePdf()`: Removes a downloaded PDF

### 2. CustomPdfReader Widget (`lib/common/widgets/custom_pdfReader.dart`)

A Flutter widget that provides PDF viewing capabilities with integrated download functionality.

**Key Features:**

- Automatic local file detection
- URL-based PDF loading
- Download progress indication
- Error handling and user feedback
- Configurable download behavior

## Usage Examples

### Basic Usage

```dart
import 'package:your_app/common/widgets/custom_pdfReader.dart';
import 'package:your_app/common/services/storage_service.dart';

// Simple PDF viewer with download button
CustomPdfReader(
  fileKey: 'your_file_key',
  fileName: 'document.pdf',
  fileId: 'doc_123',
  storageService: storageService, // Your StorageService instance
  showDownloadButton: true,
  autoDownload: false,
)
```

### Auto-Download PDF

```dart
// PDF that automatically downloads when widget is created
CustomPdfReader(
  fileKey: 'your_file_key',
  fileName: 'document.pdf',
  fileId: 'doc_123',
  storageService: storageService,
  showDownloadButton: false,
  autoDownload: true,
)
```

### Local PDF Only

```dart
// Display a previously downloaded PDF
CustomPdfReader(
  fileName: 'document.pdf',
  fileId: 'doc_123',
  showDownloadButton: false,
  autoDownload: false,
)
```

### Embedded in Card

```dart
Card(
  child: Column(
    children: [
      Text('Document Title'),
      SizedBox(
        height: 500,
        child: CustomPdfReader(
          fileKey: 'your_file_key',
          fileName: 'document.pdf',
          fileId: 'doc_123',
          storageService: storageService,
          showDownloadButton: true,
          autoDownload: false,
        ),
      ),
    ],
  ),
)
```

## Widget Parameters

| Parameter            | Type           | Required | Description                                           |
| -------------------- | -------------- | -------- | ----------------------------------------------------- |
| `fileKey`            | String?        | No       | File key to get download URL from StorageService      |
| `localPath`          | String?        | No       | Local file path (if already known)                    |
| `fileName`           | String         | Yes      | Name of the PDF file                                  |
| `fileId`             | String         | Yes      | Unique identifier for the file                        |
| `storageService`     | StorageService | Yes      | Your StorageService instance                          |
| `isEncrypted`        | bool           | No       | Whether the PDF is encrypted (default: false)         |
| `showDownloadButton` | bool           | No       | Show download button (default: true)                  |
| `autoDownload`       | bool           | No       | Auto-download when widget is created (default: false) |

## File Storage

PDFs are stored in the following directory structure:

- **Downloaded PDFs**: `{app_documents}/pdfs/`
- **Encrypted PDFs**: `{app_documents}/encrypted_pdfs/`

## Dependencies

The following packages are required:

- `pdfx: ^2.9.2` - PDF rendering
- `flutter_file_downloader: ^2.1.0` - File downloading
- `path_provider: ^2.1.5` - File system access

## Error Handling

The widget handles various error scenarios:

- Network errors during download
- File processing errors
- PDF loading errors
- Storage permission issues

All errors are displayed to the user with appropriate error messages and recovery options.

## Best Practices

1. **File Naming**: Use descriptive file names that include version or date information
2. **File IDs**: Use unique, consistent identifiers for file management
3. **Download Strategy**: Choose between manual download (user-triggered) and auto-download based on user experience requirements
4. **Error Recovery**: Provide fallback options when PDFs fail to load
5. **Storage Management**: Implement cleanup strategies for old or unused PDFs

## Integration with Existing Code

The PDF reader follows the same pattern as your existing video downloader:

- Similar directory structure
- Consistent error handling
- Progress tracking
- Local file management

You can easily integrate it into your existing screens by replacing video players with PDF readers where appropriate.
