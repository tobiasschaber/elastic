#!/bin/bash


# set the home of the installer directory
export ELKINSTALLDIR="/home/tobias/work/elastic";

echo -e "--------------------------------------------------------"
echo -e "SSL CERTIFICATE GENERATION SCRIPT"
echo -e "--------------------------------------------------------"
echo -e "This script will create all SSL artifacts which are required"
echo -e "for a working elasticsearch installation."
echo -e " "
echo -e "It will create ca Root CA and a Signing CA, and will then"
echo -e "iterate over all nodes defined under \"hiera/nodes\" and"
echo -e "create a keystore for every node and a common truststore".
echo -e " "
echo -e "All finally required artifacts will be created into the \"ssl\""
echo -e "directory. The following artifacts well be created:"
echo -e " "
echo -e " - *node*-keystore.jks \t| one keystore for every node"
echo -e " - truststore.jks\t| the truststore for every node"
echo -e " - root-ca.crt  \t| the Root CA certificate"
echo -e " - signing-ca.crt \t| the Signin certificate"
echo -e " - kibana.crt 	\t| the ssl certificate for kibanas https"
echo -e " - kibana.key 	\t| the private key for kibanas https"
echo -e " - kibana.pub 	\t| the public key for kibanas https"
echo -e " "
echo -e "--------------------------------------------------------"
echo -e "If you want to provide your own certificates instead of"
echo -e "using the generated ones, start with executing this script"
echo -e "and replace the generated files with your own ones, so you"
echo -e "will know which files are required and how to name them."
echo -e ""
echo -e "PRESS ANY KEY TO CONTINUE"

read

# ---------------------------------------------------------------------
# clean up
# ---------------------------------------------------------------------
rm 		$ELKINSTALLDIR/ssl/*.*
rm		$ELKINSTALLDIR/ssl/temp/*.*
rm		$ELKINSTALLDIR/ssl/ca/root-ca/db/*.*
rm		$ELKINSTALLDIR/ssl/ca/signing-ca/db/*.*

mkdir -p	$ELKINSTALLDIR/ssl/ca/temp
mkdir -p	$ELKINSTALLDIR/ssl/ca/root-ca/db
mkdir -p	$ELKINSTALLDIR/ssl/ca/signing-ca/db
mkdir -p	$ELKINSTALLDIR/ssl/ca/root-ca/private
mkdir -p	$ELKINSTALLDIR/ssl/ca/signing-ca/private

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
    -out root-ca.crt \
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
    -out signing-ca.crt \
    -extensions signing_ca_ext \
    -batch \
    -passin pass:codecentric
	

# create a truststore and add the root CA
keytool  \
    -import  \
    -file root-ca.crt  \
    -keystore truststore.jks   \
    -storepass codecentric  \
    -noprompt -alias root-ca

# add the signing certificate to the truststore
keytool  \
    -import \
    -file signing-ca.crt  \
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
		-file root-ca.crt \
		-keystore $node-keystore.jks \
		-storepass codecentric \
		-noprompt \
		-alias root-ca

	# import the signing certificate into the keystore
	keytool \
		-import \
		-file signing-ca.crt \
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



# ---------------------------------------------------------------------
# create kibana https artifacts
# ---------------------------------------------------------------------

	# create a pem encoded ssl certificate and a private key
	openssl req \
		-config ca/conf/kibana.conf \
		-nodes \
		-new \
		-x509 \
		-sha256 \
		-keyout kibana.key \
		-out kibana.crt \
		-batch
	
	# reduce permissions which is needed for ssh-keygen
	chmod 600 kibana.key

	# extract the public key out of the private key
	ssh-keygen -f kibana.key -y -e -m pem > kibana.pub

