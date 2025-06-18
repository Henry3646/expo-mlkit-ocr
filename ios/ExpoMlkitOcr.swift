import Foundation
import UIKit
import Vision
import React

@objc(ExpoMlkitOcr)
class ExpoMlkitOcr: NSObject {
    
    @objc
    static func requiresMainQueueSetup() -> Bool {
        return false
    }
    
    @objc
    func recognizeText(_ imageUriString: String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        
        guard let imageUrl = URL(string: imageUriString) else {
            reject("INVALID_URI", "Invalid image URI received: \(imageUriString)", nil)
            return
        }
        
        guard let image = loadImage(from: imageUrl) else {
            reject("ERROR_LOADING_IMAGE", "Failed to load image from URI: \(imageUriString)", nil)
            return
        }
        
        guard let cgImage = image.cgImage else {
            reject("ERROR_LOADING_IMAGE", "Failed to get CGImage from UIImage", nil)
            return
        }
        
        let request = VNRecognizeTextRequest { [weak self] (request, error) in
            if let error = error {
                reject("ERROR_PROCESSING_IMAGE", "Failed to process image: \(error.localizedDescription)", error)
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                reject("ERROR_PROCESSING_IMAGE", "No text recognition results found", nil)
                return
            }
            
            let result = self?.convertVisionResultToMap(observations: observations, imageSize: image.size) ?? [:]
            resolve(result)
        }
        
        request.recognitionLevel = .accurate
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([request])
        } catch {
            reject("ERROR_PROCESSING_IMAGE", "Failed to perform text recognition: \(error.localizedDescription)", error)
        }
    }
    
    private func loadImage(from url: URL) -> UIImage? {
        if url.isFileURL {
            return UIImage(contentsOfFile: url.path)
        } else {
            guard let data = try? Data(contentsOf: url) else { return nil }
            return UIImage(data: data)
        }
    }
    
    private func convertVisionResultToMap(observations: [VNRecognizedTextObservation], imageSize: CGSize) -> [String: Any] {
        let allText = observations.compactMap { observation in
            return observation.topCandidates(1).first?.string
        }.joined(separator: "\n")
        
        let blocks = convertObservationsToBlocks(observations: observations, imageSize: imageSize)
        
        return [
            "text": allText,
            "blocks": blocks
        ]
    }
    
    private func convertObservationsToBlocks(observations: [VNRecognizedTextObservation], imageSize: CGSize) -> [[String: Any]] {
        return observations.compactMap { observation in
            guard let candidate = observation.topCandidates(1).first else { return nil }
            
            let cornerPoints = convertBoundingBoxToCornerPoints(
                boundingBox: observation.boundingBox,
                imageSize: imageSize
            )
            
            let lineMap: [String: Any] = [
                "text": candidate.string,
                "elements": convertStringToElements(text: candidate.string, observation: observation, imageSize: imageSize),
                "cornerPoints": cornerPoints
            ]
            
            return [
                "text": candidate.string,
                "lines": [lineMap],
                "cornerPoints": cornerPoints
            ]
        }
    }
    
    private func convertStringToElements(text: String, observation: VNRecognizedTextObservation, imageSize: CGSize) -> [[String: Any]] {
        let words = text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        
        return words.map { word in
            let cornerPoints = convertBoundingBoxToCornerPoints(
                boundingBox: observation.boundingBox,
                imageSize: imageSize
            )
            
            return [
                "text": word,
                "cornerPoints": cornerPoints
            ]
        }
    }
    
    private func convertBoundingBoxToCornerPoints(boundingBox: CGRect, imageSize: CGSize) -> [[String: Int]] {
        let x = boundingBox.origin.x * imageSize.width
        let y = (1 - boundingBox.origin.y - boundingBox.height) * imageSize.height
        let width = boundingBox.width * imageSize.width
        let height = boundingBox.height * imageSize.height
        
        return [
            ["x": Int(x), "y": Int(y)],
            ["x": Int(x + width), "y": Int(y)],
            ["x": Int(x + width), "y": Int(y + height)],
            ["x": Int(x), "y": Int(y + height)]
        ]
    }
}
