from django.db import models

class PredictionResult(models.Model):
    image = models.ImageField(upload_to='uploads/')
    prediction = models.CharField(max_length=100)
    confidence = models.FloatField()
    model_used = models.CharField(max_length=50)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.model_used} - {self.prediction} ({self.confidence:.2f}%)"