# Plant Disease Detection ML Model Setup

## Overview
This app integrates a DenseNet-201 TensorFlow Lite model for plant disease detection. The model can classify 33 different plant diseases and healthy conditions.

## Setup Instructions

### 1. Dependencies
The following packages are required:
- `tflite_flutter: ^0.10.4` - TensorFlow Lite Flutter plugin
- `image: ^4.1.7` - Image processing library
- `image_picker: ^1.2.0` - Image selection from camera/gallery

### 2. Model Files
Ensure the following files are in the `assets/model/` directory:
- `DenseNet-201 .tflite` - The trained model file (69MB)
- `labels.txt` - Class labels for the model

### 3. Model Classes
The model can detect the following plant diseases:
- **Apple**: Apple scab, Black rot, Cedar apple rust, Healthy
- **Cherry**: Powdery mildew, Healthy
- **Corn**: Cercospora leaf spot, Common rust, Northern leaf blight, Healthy
- **Grape**: Black rot, Esca, Leaf blight, Healthy
- **Peach**: Bacterial spot, Healthy
- **Pepper**: Bacterial spot, Healthy
- **Potato**: Early blight, Late blight, Healthy
- **Strawberry**: Leaf scorch, Healthy
- **Tomato**: Bacterial spot, Early blight, Late blight, Leaf mold, Septoria leaf spot, Spider mites, Target spot, Yellow leaf curl virus, Mosaic virus, Healthy

## Usage

### 1. Home Screen
- Tap the "Diagnose Your Plant" button to start the scanning process

### 2. Scan Screen
- Choose between Camera or Gallery to select an image
- The app will automatically process the image and run the ML model
- View real-time loading indicators and error messages

### 3. Results Screen
- See the uploaded image
- View disease name and confidence percentage
- Read detailed description of the detected disease
- Get treatment recommendations
- Access tips for better results

## Technical Details

### Image Preprocessing
- Images are resized to 224x224 pixels (DenseNet-201 input size)
- RGB values are normalized using ImageNet statistics
- Mean: [0.485, 0.456, 0.406]
- Std: [0.229, 0.224, 0.225]

### Model Inference
- Uses TensorFlow Lite Flutter plugin for efficient inference
- Processes images on-device for privacy and speed
- Returns top 5 predictions with confidence scores

### Error Handling
- Graceful fallback to simulation if model fails to load
- Comprehensive error messages for debugging
- Loading states and user feedback

## Troubleshooting

### Common Issues

1. **Model Loading Error**
   - Ensure the model file is in the correct location
   - Check file permissions
   - Verify the model file is not corrupted

2. **Image Processing Error**
   - Ensure the image is in a supported format (JPEG, PNG)
   - Check image file size (should be reasonable)
   - Verify image picker permissions

3. **Memory Issues**
   - The model is 69MB, ensure sufficient device memory
   - Close other apps if experiencing crashes

### Performance Tips
- Use clear, well-lit images for better accuracy
- Focus on the affected area of the plant
- Include both healthy and diseased parts when possible
- Ensure images are not blurry or too small

## Future Enhancements
- Add support for more plant species
- Implement batch processing for multiple images
- Add disease severity assessment
- Integrate with plant care recommendations
- Add historical tracking of plant health

