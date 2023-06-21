Get-Content ../.config/credentials.txt | docker login container-registry-zurich.oracle.com -u d.roth@esri.ch --password-stdin
docker build -t oracle-ee-for-sde:19.3.0.0 . 
docker logout container-registry-zurich.oracle.com