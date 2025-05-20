package com.expo.mlkitocr;

import android.graphics.Rect;
import android.graphics.Point;
import android.net.Uri;
import androidx.annotation.NonNull;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableArray;

import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.mlkit.vision.common.InputImage;
import com.google.mlkit.vision.text.Text;
import com.google.mlkit.vision.text.TextRecognition;
import com.google.mlkit.vision.text.TextRecognizer;
import com.google.mlkit.vision.text.latin.TextRecognizerOptions;

import java.io.IOException;
import java.util.List;


public class ExpoMlkitOcr extends ReactContextBaseJavaModule {

    private InputImage image;

    ExpoMlkitOcr(ReactApplicationContext context) {
        super(context);
    }

    @NonNull
    @Override
    public String getName() {
        return "ExpoMlkitOcr";
    }

    @ReactMethod
    public void recognizeText(String imageUriString, Promise promise) {
        Uri imageUri;
        try {
            imageUri = Uri.parse(imageUriString);
            if (imageUri == null || imageUri.getPath() == null) {
                promise.reject("INVALID_URI", "Invalid image URI received: " + imageUriString);
                return;
            }
        } catch (Exception e) {
            promise.reject("URI_PARSE_ERROR", "Failed to parse image URI: " + imageUriString, e);
            return;
        }

        try {
            this.image = InputImage.fromFilePath(getReactApplicationContext(), imageUri);
        } catch (IOException e) {
            promise.reject("ERROR_LOADING_IMAGE", "Failed to load image: " + e.getMessage(), e);
            return;
        } catch (IllegalArgumentException e) {
             promise.reject("INVALID_FILE_PATH", "Invalid file path from URI: " + e.getMessage(), e);
             return;
        }

        TextRecognizer recognizer = TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS);

        recognizer.process(this.image)
            .addOnSuccessListener(new OnSuccessListener<Text>() {
                @Override
                public void onSuccess(Text visionText) {
                    WritableMap result = convertMlKitTextToWritableMap(visionText);
                    promise.resolve(result);
                }
            })
            .addOnFailureListener(new OnFailureListener() {
                @Override
                public void onFailure(@NonNull Exception e) {
                    promise.reject("ERROR_PROCESSING_IMAGE", "Failed to process image: " + e.getMessage(), e);
                }
            });

    }

    private WritableMap convertMlKitTextToWritableMap(Text visionText) {
        WritableMap map = Arguments.createMap();
        if (visionText == null) return map;

        map.putString("text", visionText.getText());
        map.putArray("blocks", convertMlKitBlocksToWritableArray(visionText.getTextBlocks()));
        return map;
    }

    private WritableArray convertMlKitBlocksToWritableArray(List<Text.TextBlock> blocks) {
        WritableArray array = Arguments.createArray();
        if (blocks == null) return array;

        for (Text.TextBlock block : blocks) {
            if (block != null) {
                array.pushMap(convertMlKitBlockToWritableMap(block));
            }
        }
        return array;
    }

    private WritableMap convertMlKitBlockToWritableMap(Text.TextBlock block) {
        WritableMap map = Arguments.createMap();
        if (block == null) return map;

        map.putString("text", block.getText());
        map.putArray("lines", convertMlKitLinesToWritableArray(block.getLines()));
        map.putArray("cornerPoints", convertPointsToWritableArray(block.getCornerPoints()));
        return map;
    }

    private WritableArray convertMlKitLinesToWritableArray(List<Text.Line> lines) {
        WritableArray array = Arguments.createArray();
         if (lines == null) return array;

        for (Text.Line line : lines) {
             if (line != null) {
                array.pushMap(convertMlKitLineToWritableMap(line));
             }
        }
        return array;
    }

    private WritableMap convertMlKitLineToWritableMap(Text.Line line) {
        WritableMap map = Arguments.createMap();
         if (line == null) return map;

        map.putString("text", line.getText());
        map.putArray("elements", convertMlKitElementsToWritableArray(line.getElements()));
        map.putArray("cornerPoints", convertPointsToWritableArray(line.getCornerPoints()));
        return map;
    }

    private WritableArray convertMlKitElementsToWritableArray(List<Text.Element> elements) {
        WritableArray array = Arguments.createArray();
        if (elements == null) return array;

        for (Text.Element element : elements) {
             if (element != null) {
                array.pushMap(convertMlKitElementToWritableMap(element));
             }
        }
        return array;
    }

    private WritableMap convertMlKitElementToWritableMap(Text.Element element) {
        WritableMap map = Arguments.createMap();
         if (element == null) return map;

        map.putString("text", element.getText());
        map.putArray("cornerPoints", convertPointsToWritableArray(element.getCornerPoints()));
        return map;
    }

    private WritableArray convertPointsToWritableArray(Point[] points) {
        WritableArray array = Arguments.createArray();
        if (points == null) return array;

        for (Point point : points) {
            if (point != null) {
                WritableMap pointMap = Arguments.createMap();
                pointMap.putInt("x", point.x);
                pointMap.putInt("y", point.y);
                array.pushMap(pointMap);
            }
        }
        return array;
    }

}