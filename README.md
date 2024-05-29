# EverKey

This iOS application leverages ARKit and RealityKit to provide two different keying effects: depth/human-based keying and chroma keying. The app includes a user interface to switch between these keying modes and to toggle the effects on and off.

## Features

- Depth/Human-Based Keying: Uses ARKit's people occlusion capabilities to key out humans from the camera feed.
- Chroma Keying: Provides a basic chroma key effect.
- User Interface: Includes a segmented control to switch between keying modes and a switch to toggle the selected effect on and off.

## Getting Started

### Prerequisites

- Xcode 12 or later
- iOS device with A12 Bionic chip or later (supports ARKit's people occlusion)
- iOS 13.0 or later

## Usage

1. Launch the app on your iOS device.
2. Use the segmented control at the top right to switch between "Depth/Human" mode and "Chroma Key" mode.
3. Use the switch below the segmented control to toggle the selected keying effect on and off.

### Depth/Human Mode

- Enables ARKit's people occlusion capabilities to key out humans from the camera feed.
- Displays messages indicating whether people occlusion is on or off.

### Chroma Key Mode

- Provides a basic chroma key effect.
- Displays messages indicating whether chroma keying is on or off.

## Code Overview

### ViewController.swift

- UI Elements: Sets up a segmented control and a switch for toggling the keying effects.
- Depth/Human-Based Keying: Implements methods to enable and disable people occlusion using ARKit's frame semantics.
- Chroma Keying: Implements methods for enabling and disabling chroma key effects.
- Gesture Recognizers: Adds a tap gesture recognizer to ensure the ARView recognizes taps.
- ARSessionDelegate: Ensures a virtual plane is created and added to the scene when the AR session is properly established acting as a backdrop
