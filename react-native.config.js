module.exports = {
    dependencies: {
      'expo-mlkit-ocr': {
        platforms: {
          ios: null, // Currently not implemented for iOS
          android: {
            sourceDir: './android',
            packageImportPath: 'import com.expo.mlkitocr.ExpoMlkitOcrPackage;',
            packageInstance: 'new ExpoMlkitOcrPackage()'
          }
        }
      }
    }
  }
  