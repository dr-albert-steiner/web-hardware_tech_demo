from rest_framework.response import Response
from rest_framework.request import Request
from rest_framework.views import APIView

import numpy as np

# Create your views here.
data = 0.0


class SensorView(APIView):

    def get(self, request):
        return Response({"temperature": round(data, 2)})

    def put(self, request: Request):
        global data
        data = float(request.data['temperature'])
        return Response()

