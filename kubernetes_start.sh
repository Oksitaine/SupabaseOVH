#!/bin/sh

# Check if a KUBECONFIG file path was provided as a command-line argument.
if [ -n "$1" ]; then
  # If provided, use the command-line argument as the KUBECONFIG path.
  KUBECONFIG="$1"
else
  # Otherwise, default to using kubeconfig.yml in the current directory.
  KUBECONFIG="$(pwd)/kubeconfig.yml"
fi


# Create the deployment for the cluster 

kubectl --kubeconfig="$KUBECONFIG" apply -f frontend_deployment.yml
kubectl --kubeconfig="$KUBECONFIG" wait --for=condition=available --timeout=300s deployment/nextself-prod

kubectl --kubeconfig="$KUBECONFIG" apply -f frontend_svc_nodeport.yaml


# curl -i -X POST http://91.134.77.186:8000/storage/v1/upload/resumable \
# -H "Authorization: Bearer xxx" \
# -H "Tus-Resumable: 1.0.0" \
# -H "Upload-Length: 66957746" \
# -H "Upload-Metadata: bucketName dGVzdA==,objectName bGFyZ2VfZmlsZQ==,contentType YXBwbGljYXRpb24vb2N0ZXQtc3RyZWFt,cacheControl MzYwMA==" \
# -H "x-upsert: true"


# curl -i -X PATCH http://91.134.77.186:8000/storage/v1/upload/resumable/dGVzdC9sYXJnZV9maWxlLzNhZTE2NzE0LWJlOTItNDJjYS05MjlhLTE2YjE1MDg1ZDZiNg \
# -H "Authorization: Bearer xxx" \
# -H "Content-Type: application/offset+octet-stream" \
# -H "Tus-Resumable: 1.0.0" \
# -H "Upload-Offset: 0" \
# --data-binary "@/Users/wglint/Desktop/ovh/docker/4xNM.pth"