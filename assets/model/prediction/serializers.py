from rest_framework import serializers
from .models import PredictionResult

class PredictionResultSerializer(serializers.ModelSerializer):
    class Meta:
        model = PredictionResult
        fields = ['id', 'image', 'prediction', 'confidence', 'model_used', 'created_at']
