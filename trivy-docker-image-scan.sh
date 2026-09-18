dockerImageName=$(awk 'NR==1 {print $2}' Dockerfile)
echo $dockerImageName

docker run --rm -v $WORKSPACE/root/.cache/ aquasec/trivy:0.74.0 -q image --exit-code 0 --severity HIGH --light $dockerImageName
docker run --rm -v $WORKSPACE/root/.cache/ aquasec/trivy:0.74.0 -q image --exit-code 1 --severity HIGH --light $dockerImageName

exit_code=$?
echo "Exit Code: $exit_code"
 if [[ ${exit_code} == 1 ]]; then
    echo "Image scanning failed. Vulnerabilities"
    exit 1;
else
    echo "Image scanning passed successfully"
fi;



