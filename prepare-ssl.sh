#!/bin/bash

echo "THIS SCRIPT WILL PREPARE THE SSL CERTIFICATES REQUIRED"
echo "FOR THE ELASTICSEARCH INSTALLATION. IT WILL CREATE"
echo "CERTIFICATES AND KEYSTORES FOR EVERY NODE LISTED IN THE"
echo "/hiera/nodes DIRECTORY AND USE A GIVEN CA AUTHORITY (ssl/ca/...)."
echo "TO SIGN THEM."
echo ""
echo "USE THIS SCRIPT ONLY FOR TEST PURPOSES, IF YOU DO NOT WANT"
echo "TO SERVE YOUR OWN CERTIFICATES, BECAUSE THE CERTS CREATED"
echo "HERE WILL NOT BE SECURE."
echo ""
echo "THE CREATED CERTS WILL BE STORED IN THE SSL DIRECTORY."
echo "IF YOU WANT TO PROVIDE YOUR OWN CERTIFICATES, PLACE THEM"
echo "IN THIS ssl DIRECTORY."
echo ""
echo "PRESS ANY KEY TO CONTINUE"

read

# set the home of the installer directory
export ELKINSTALLDIR="/home/tobias/viega/elastic";

# clean up
rm $ELKINSTALLDIR/ssl/*.jks
rm $ELKINSTALLDIR/ssl/*.csr
rm $ELKINSTALLDIR/ssl/*.crt

cd $ELKINSTALLDIR/ssl

cd ca

# generate a self signed CA certificate
openssl req -batch -new -x509 \
	-extensions v3_ca -keyout private/cakey.pem \
	-out certs/cacert.pem \
	-days 1460 -config conf/caconfig.cnf \
	-passin pass:codecentric \
	-passout pass:codecentric



cd ..

for nodeFile in "$ELKINSTALLDIR"/hiera/nodes/*.yaml ; do
	node=$(basename "$nodeFile" | cut -f 1 -d '.')
	echo "$node"
	
	# keystore anlegen, dass dem cacert vertraut
	keytool -noprompt -importcert -keystore "$node".jks -storepass codecentric -file ca/certs/cacert.pem

	# extract the ip adress defined in the hiera yaml file for this host
	ipaddr=$(less $ELKINSTALLDIR/hiera/nodes/"$node".yaml | grep 'network.publish_host' | cut -f 2 -d ':' | tr -d ' ')
	
	# private key für das node dem keystore des nodes hinzufügen
	keytool -genkey -alias "$node" -keystore "$node".jks \
		-storepass codecentric \
		-keypass codecentric \
		-dname "CN=$node, OU=Karlsruhe, O=codecentric AG, L=Karlsruhe, S=BW, C=DE" \
		-keyalg RSA -keysize 2048 \
		-validity 10000 -ext san=dns:"$node",ip:"$ipaddr"

	# das signing request erstellen
	keytool -certreq -alias "$node" -keystore "$node".jks \
		-file "$node".csr \
		-storepass codecentric \
                -dname "CN=$node, OU=Karlsruhe, O=codecentric AG, L=Karlsruhe, S=BW, C=DE" \
		-keyalg RSA -ext san=dns:"$node",ip:"$ipaddr"


# dieser signier prozess scheint nicht zu laufen..
openssl ca -in "$node".csr -notext -out "$node"-signed.crt -config ca/conf/caconfig.cnf -extensions v3_req -passin pass:codecentric -batch -verbose
#-extensions server_ext

	# das signing request signieren
	#openssl x509 -req -days 10000 \
	#-in "$node".csr -CA ca/certs/cacert.pem \
	#-CAkey ca/private/cakey.pem \
	#-set_serial 01 \
	#-out "$node"-signed.crt \
	#-passin pass:codecentric


   # -> DAS ÜBERSCHREIBT DEN VORHERIGEN KEY. IST DAS EIN PROBLEM?
   # -> ich habs mal in -signed umbenannt..scheint auch net zu helfen.

	# das signierte zertifikat in den jks importieren
	keytool -importcert -keystore "$node".jks -file "$node"-signed.crt -alias "$node"-signed -storepass codecentric

done 		

# clean up unused files
rm $ELKINSTALLDIR/ssl/*.csr





