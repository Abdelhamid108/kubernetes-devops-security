docker volume inspect trivy-cache >/dev/null 2>&1 || \
    docker volume create trivy-cache 

dockerImageName=$(awk 'NR==1 {print $2}' Dockerfile)
echo $dockerImageName

docker run --rm -v trivy-cache:/root/.cache aquasec/trivy:0.74.0 -q image --timeout 15m --exit-code 0 --severity LOW,MEDIUM,HIGH --light $dockerImageName
docker run --rm -v trivy-cache:/root/.cache aquasec/trivy:0.74.0 -q image --timeout 15m --exit-code 1 --severity CRITICAL --light $dockerImageName

exit_code=$?
echo "Exit Code: $exit_code"
 if [[ ${exit_code} == 1 ]]; then
    echo "Image scanning failed. Vulnerabilities"
    exit 1;
else
    echo "Image scanning passed successfully"
fi;


