from django.shortcuts import render
import os
import numpy as np
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.conf import settings
from tensorflow.keras.models import load_model
from tensorflow.keras.preprocessing.image import load_img, img_to_array
from .models import PredictionResult
from .serializers import PredictionResultSerializer

# Only use densenet model
DENSENET_PATH = os.path.join(settings.BASE_DIR, '../Models/DenseNet-201.keras')
DENSENET_MODEL = load_model(DENSENET_PATH) if os.path.exists(DENSENET_PATH) else None

CLASS_NAMES = [
    'Anthracnose', 'Bacterial Canker', 'Cutting Weevil', 'Die Back',
    'Gall Midge', 'Healthy', 'Powdery Mildew', 'Sooty Mould'
]

class PredictionViewSet(viewsets.ModelViewSet):
    queryset = PredictionResult.objects.all()
    serializer_class = PredictionResultSerializer

    def preprocess_image(self, image_path, target_size=(224, 224)):
        img = load_img(image_path, target_size=target_size)
        img_array = img_to_array(img)
        img_array = np.expand_dims(img_array, axis=0)
        img_array = img_array / 255.0
        return img_array

    @action(detail=False, methods=['post'])
    def predict(self, request):
        image = request.FILES.get('image')
        if not image:
            return Response({'error': 'Image is required.'}, status=status.HTTP_400_BAD_REQUEST)
        if DENSENET_MODEL is None:
            return Response({'error': 'DenseNet-201 model not found.'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        # Save image temporarily
        temp_dir = os.path.join(settings.MEDIA_ROOT, 'temp')
        os.makedirs(temp_dir, exist_ok=True)
        temp_path = os.path.join(temp_dir, image.name)
        with open(temp_path, 'wb+') as f:
            for chunk in image.chunks():
                f.write(chunk)

        try:
            img_array = self.preprocess_image(temp_path)
            preds = DENSENET_MODEL.predict(img_array)
            pred_idx = int(np.argmax(preds[0]))
            confidence = float(preds[0][pred_idx]) * 100
            pred_class = CLASS_NAMES[pred_idx]

            # Save result
            result = PredictionResult.objects.create(
                image=image,
                prediction=pred_class,
                confidence=confidence,
                model_used='densenet'
            )
            os.remove(temp_path)
            return Response({
                'prediction': pred_class,
                'confidence': confidence,
                'model_used': 'densenet'
            })
        except Exception as e:
            if os.path.exists(temp_path):
                os.remove(temp_path)
            return Response({'error': str(e)}, status=500)
