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
export ELKINSTALLDIR="/home/server/elastic";

# ---------------------------------------------------------------------
# clean up
# ---------------------------------------------------------------------
rm 		$ELKINSTALLDIR/ssl/*.*
rm		$ELKINSTALLDIR/ssl/temp/*.*
rm		$ELKINSTALLDIR/ssl/ca/root-ca/db/*.*
rm		$ELKINSTALLDIR/ssl/ca/signing-ca/db/*.*

echo 01 > 	$ELKINSTALLDIR/ssl/ca/root-ca/db/root-ca.crt.srl
echo 01 > 	$ELKINSTALLDIR/ssl/ca/root-ca/db/root-ca.crl.srl
echo 01 > 	$ELKINSTALLDIR/ssl/ca/signing-ca/db/signing-ca.crt.srl
echo 01 > 	$ELKINSTALLDIR/ssl/ca/signing-ca/db/signing-ca.crl.srl

touch	 	$ELKINSTALLDIR/ssl/ca/root-ca/db/root-ca.db
touch		$ELKINSTALLDIR/ssl/ca/root-ca/db/root-ca.db.attr
touch		$ELKINSTALLDIR/ssl/ca/signing-ca/db/signing-ca.db
touch		$ELKINSTALLDIR/ssl/ca/signing-ca/db/signing-ca.db.attr


# ---------------------------------------------------------------------
# start certification creation
# ---------------------------------------------------------------------

cd $ELKINSTALLDIR/ssl

# generate a self signed CA certificate

openssl req -new \
    -config ca/conf/root-ca.conf \
    -out ca/temp/root-ca.csr \
    -keyout ca/root-ca/private/root-ca.key \
    -batch \
    -passout pass:codecentric
	
# self-sign the certificate
openssl ca -selfsign \
    -config ca/conf/root-ca.conf \
    -in ca/temp/root-ca.csr \
    -out ca/temp/root-ca.crt \
    -extensions root_ca_ext \
    -batch \
    -passin pass:codecentric

# generate a signing certificate
openssl req -new \
    -config ca/conf/signing-ca.conf \
    -out ca/temp/signing-ca.csr \
    -keyout ca/signing-ca/private/signing-ca.key \
    -batch \
    -passout pass:codecentric
	
# sign the signing certificate with the Root CA
openssl ca \
    -config ca/conf/root-ca.conf \
    -in ca/temp/signing-ca.csr \
    -out ca/temp/signing-ca.crt \
    -extensions signing_ca_ext \
    -batch \
    -passin pass:codecentric
	

# create a truststore and add the root CA
keytool  \
    -import  \
    -file ca/temp/root-ca.crt  \
    -keystore truststore.jks   \
    -storepass codecentric  \
    -noprompt -alias root-ca

# add the signing certificate to the truststore
keytool  \
    -import \
    -file ca/temp/signing-ca.crt  \
    -keystore truststore.jks   \
    -storepass codecentric  \
    -noprompt -alias sig-ca

# ---------------------------------------------------------------------
# iterate over all nodes to be installed
# ---------------------------------------------------------------------

for nodeFile in "$ELKINSTALLDIR"/hiera/nodes/*.yaml ; do

	# extract the node name
	node=$(basename "$nodeFile" | cut -f 1 -d '.')

	# extract the ip adress defined in the hiera yaml file for this host
	ipaddr=$(less $ELKINSTALLDIR/hiera/nodes/"$node".yaml | grep 'network.publish_host' | cut -f 2 -d ':' | tr -d ' ')
	
	# create a keystore for the node
	keytool -genkey \
		-alias $node \
		-keystore $node-keystore.jks \
	        -keyalg    RSA \
	        -keysize   2048 \
	        -validity  712 \
		-keypass codecentric \
		-storepass codecentric \
                -dname "CN=$node, OU=Karlsruhe, O=codecentric AG, L=Karlsruhe, S=BW, C=DE" \
		-validity 10000
		# -ext san=dns:"$node",ip:"$ipaddr"

	# create a certification request for the node
	keytool -certreq \
	        -alias      $node \
	        -keystore   $node-keystore.jks \
	        -file       ca/temp/$node.csr \
	        -keyalg     rsa \
	        -keypass codecentric \
	        -storepass codecentric \
                -dname "CN=$node, OU=Karlsruhe, O=codecentric AG, L=Karlsruhe, S=BW, C=DE" \
		# -ext san=dns:"$node",ip:"$ipaddr"


	# sign the certification request
	openssl ca \
		-in ca/temp/$node.csr \
		-notext \
		-out ca/temp/$node-signed.crt \
		-config ca/conf/signing-ca.conf \
		-extensions v3_req \
		-batch \
		-passin pass:codecentric \
		-extensions server_ext

	# import the root CA into the keystore
	keytool \
		-import \
		-file ca/temp/root-ca.crt \
		-keystore $node-keystore.jks \
		-storepass codecentric \
		-noprompt \
		-alias root-ca

	# import the signing certificate into the keystore
	keytool \
		-import \
		-file ca/temp/signing-ca.crt \
		-keystore $node-keystore.jks \
		-storepass codecentric \
		-noprompt \
		-alias sig-ca

	# import the certificate for the node into the keystore
	keytool \
		-import \
		-file ca/temp/$node-signed.crt \
		-keystore $node-keystore.jks \
		-storepass codecentric \
		-noprompt \
		-alias $node

done 		


