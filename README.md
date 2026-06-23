<p align="center">
  <img src="https://github.com/mirham/ImageGenerator/blob/main/Images/AppLogo.png" width="420"/>
</p>

<p align="center" style="text-align: center">
  <a href="https://github.com/mirham/ImageGenerator/tags" rel="nofollow">
    <img alt="GitHub tag (latest SemVer pre-release)" src="https://img.shields.io/github/v/tag/mirham/ImageGenerator?include_prereleases&label=version"/>
  </a>
  <a href="https://github.com/mirham/ImageGenerator/blob/main/LICENSE">
    <img alt="License" src="https://img.shields.io/github/license/mirham/ImageGenerator"/>
  </a>
  <img alt="macOS" src="https://img.shields.io/badge/macOS-blue?logo=apple"/>
  <img alt="Swift" src="https://img.shields.io/badge/Swift-grey?logo=swift"/>
  <img alt="GitHub" src="https://img.shields.io/badge/Pet project-purple?logo=github"/>
</p>

## Introduction
MirHam ImageGenerator is a macOS application built for QA engineers to rapidly generate massive image and video datasets to stress-test applications and validate media processing pipelines.

> [!WARNING]
> This application works eagerly with your computer's hardware resources (CPU, RAM, and SSD) to achieve maximum performance and speed. Consequently, if you queue a massive number of files or select extreme resolutions (such as 8K or above), the application may consume **all** available system resources. In extreme cases, this intense resource load could cause your system to **freeze** or **shut down** unexpectedly. Please use the application responsibly and remain mindful of your hardware capabilities.

## Features
- Fast generation of images or videos from scratch
- Fast duplication of existing images
- Supports scale up to 1,000,000 images or videos
- Supports resolutions up to 16,350 pixels in width/height for both images and videos
- Generates videos up to 10 hours in duration or 200 GB in file size
- Predefined resolution presets for images and videos
- Generates videos by target duration or byte-perfect file size (excluding WMV)
- Supports both base-2 (binary) and base-10 (decimal) sizing for video files
- Customizable prefixes and suffixes for output filenames
- Supported image export formats: **JPG**, **JPEG**, **JP2**, **GIF**, **PNG**, **TIFF**, **HEIC**, **WebP**
- Supported image color spaces (dependent on format): **RGB**, **sRGB**, **P3**, **Adobe RGB**, **CMYK**, **Greyscale**
- Supported video export formats: **MP4**, **MOV**, **MKV**, **AVI**, **WebM**, **TS**, **WMV**
- Automated FFmpeg detection with the ability to download or manually select a binary
- Extended logging for detailed tracking and debugging

## Compatibility

This application is compatible with macOS 15.0 and above. Legacy versions (below 3.0) support macOS 14.0 and above.

## Installation

Download the DMG installer from the [releases](https://github.com/mirham/ImageGenerator/releases), mount it, and drag and drop the application to the Applications folder. That's it! However, you will need to allow launching applications from unidentified developers to start the application, as I don't have an Apple developer license.

### FFmpeg

This application uses [FFmpeg](https://ffmpeg.org/) for video generation—an outstanding, high-performance multimedia library. You can install it via [Homebrew](https://brew.sh/) by running:

```bash
brew install ffmpeg-full
```
If you do not use Homebrew, you can let the application handle the setup automatically. It is capable of downloading and configuring the required version directly from the official repository's latest releases. Alternatively, you can download a binary yourself and manually select its path within the application settings later.

The application will attempt to automatically de-quarantine the downloaded binary. If macOS Gatekeeper still blocks it from running, you can manually remove the quarantine flag by executing the following command in your Terminal:
```bash
xattr -rd com.apple.quarantine '/Application Support/com.MirHam.ImageGenerator/ffmpeg'
```
If you do not plan to generate videos, you can safely skip the FFmpeg installation entirely.

## Screenshots

### Main window
<p align="left">
  <img src="https://github.com/mirham/ImageGenerator/blob/main/Images/Screen1.png" width="500">
</p>
<p align="left">
  <img src="https://github.com/mirham/ImageGenerator/blob/main/Images/Screen2.png" width="500">
</p>
<p align="left">
  <img src="https://github.com/mirham/ImageGenerator/blob/main/Images/Screen3.png" width="500">
</p>
<p align="left">
  <img src="https://github.com/mirham/ImageGenerator/blob/main/Images/Screen4.png" width="500">
</p>

### Output
<p align="left">
  <img src="https://github.com/mirham/ImageGenerator/blob/main/Images/Output1.png" width="800">
</p>
<p align="left">
  <img src="https://github.com/mirham/ImageGenerator/blob/main/Images/Output2.png" width="800">
</p>
<p align="left">
  <img src="https://github.com/mirham/ImageGenerator/blob/main/Images/Output3.png" width="800">
</p>


## Improvement
> [!TIP]
> If you have any ideas, thoughts, or concerns, don't hesitate to contact me. I'm happy to help and improve the application.

## Disclaimer
> [!WARNING]
> I'm not a professional Swift developer (though I am a professional .NET developer). All my macOS apps are made for personal use by myself and my family simply because I have the skills to create them (and for fun, of course 😊). If my application has caused any harm, I apologize for that, but please be aware that you use it at your own risk.
