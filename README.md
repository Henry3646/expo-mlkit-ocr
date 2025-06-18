# Expo ML Kit OCR

A React Native module that provides text recognition functionality using Google's ML Kit Vision API on Android and Apple's Vision framework on iOS.

> **Platform Support:** ✅ Android (ML Kit) | ✅ iOS (Vision Framework)

## Installation

```bash
npm install expo-mlkit-ocr
# or
yarn add expo-mlkit-ocr
```

### Android Setup

This package automatically links with React Native projects that have auto-linking enabled (React Native 0.60 and above).

If you need to manually link:

1. Add the following to your `android/settings.gradle`:
   ```gradle
   include ':expo-mlkit-ocr'
   project(':expo-mlkit-ocr').projectDir = new File(rootProject.projectDir, '../node_modules/expo-mlkit-ocr/android')
   ```

2. In your app's `android/app/build.gradle` file, add:
   ```gradle
   dependencies {
     // ... other dependencies
     implementation project(':expo-mlkit-ocr')
   }
   ```

3. Open your `android/app/src/main/java/[...]/MainApplication.java` and add:
   ```java
   import com.expo.mlkitocr.ExpoMlkitOcrPackage; // Add this import

   @Override
   protected List<ReactPackage> getPackages() {
     List<ReactPackage> packages = new PackageList(this).getPackages();
     // Add this line
     packages.add(new ExpoMlkitOcrPackage());
     return packages;
   }
   ```

### iOS Setup

For iOS, the module uses Apple's Vision framework and will automatically link when using auto-linking.

#### Requirements:
- iOS 13.0 or higher (required for Vision text recognition)
- Xcode 11 or higher

The module will automatically be included via CocoaPods when you run:

```bash
cd ios && pod install
```

#### Manual Linking (if needed):
If auto-linking doesn't work, add the following to your `ios/Podfile`:

```ruby
pod 'expo-mlkit-ocr', :path => '../node_modules/expo-mlkit-ocr'
   ```

## Usage

```javascript
import React, { useState } from 'react';
import { View, Button, Text, Image } from 'react-native';
import ExpoMlkitOcr from 'expo-mlkit-ocr';
import * as ImagePicker from 'expo-image-picker';

export default function App() {
  const [recognizedText, setRecognizedText] = useState('');
  const [imageUri, setImageUri] = useState(null);

  const pickImage = async () => {
    // Request permission to access the image library
    const permissionResult = await ImagePicker.requestMediaLibraryPermissionsAsync();
    
    if (permissionResult.granted === false) {
      alert('Permission to access the camera roll is required!');
      return;
    }

    const result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ImagePicker.MediaTypeOptions.Images,
      allowsEditing: true,
      quality: 1,
    });

    if (!result.canceled) {
      // Get the local URI of the selected image
      const uri = result.assets[0].uri;
      setImageUri(uri);
      
      try {
        // Recognize text in the image
        const textResult = await ExpoMlkitOcr.recognizeText(uri);
        setRecognizedText(textResult.text);
      } catch (error) {
        console.error('Error recognizing text:', error);
        alert('Failed to recognize text: ' + error.message);
      }
    }
  };

  return (
    <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center', padding: 20 }}>
      <Button title="Pick an image to recognize text" onPress={pickImage} />
      
      {imageUri && (
        <Image 
          source={{ uri: imageUri }} 
          style={{ width: 300, height: 300, resizeMode: 'contain', marginTop: 20 }} 
        />
      )}
      
      {recognizedText ? (
        <View style={{ marginTop: 20, padding: 10, backgroundColor: '#f0f0f0', borderRadius: 5 }}>
          <Text style={{ fontSize: 16 }}>Recognized Text:</Text>
          <Text style={{ marginTop: 10 }}>{recognizedText}</Text>
        </View>
      ) : null}
    </View>
  );
}
```

## API Reference

### `recognizeText(imageUri: string): Promise<TextRecognitionResult>`

Performs text recognition on the specified image.

#### Parameters:
- `imageUri` (string): The URI of the image to analyze. Should be a local file URI (e.g., file:///path/to/image.jpg).

#### Returns:
A Promise that resolves to a `TextRecognitionResult` object:

```typescript
interface TextRecognitionResult {
  text: string;  // The complete recognized text
  blocks: Array<{
    text: string;  // Text content of the block
    lines: Array<{
      text: string;  // Text content of the line
      elements: Array<{
        text: string;  // Text content of the element (word)
        cornerPoints: Array<{x: number, y: number}>;  // Corner points of the element
      }>;
      cornerPoints: Array<{x: number, y: number}>;  // Corner points of the line
    }>;
    cornerPoints: Array<{x: number, y: number}>;  // Corner points of the block
  }>;
}
```

## Troubleshooting

### Image URI Format
- Make sure the image URI starts with `file://` for local files.
- For content:// URIs, you may need to convert them to file:// URIs using a library like `react-native-fs`.

### Android Permissions
Ensure you have the required permissions in your AndroidManifest.xml:

```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

## License

MIT

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. 