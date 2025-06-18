module.exports = {
    dependencies: {
      'expo-mlkit-ocr': {
        platforms: {
          ios: {
            sourceDir: './ios'
          },
          android: {
            sourceDir: './android',
            packageImportPath: 'import com.expo.mlkitocr.ExpoMlkitOcrPackage;',
            packageInstance: 'new ExpoMlkitOcrPackage()'
          }
        }
      }
    }
  }
  