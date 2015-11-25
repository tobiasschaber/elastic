
:: copy all files into c:\logstash-forwarder


echo "installing logstash-forwarder as a service"



nssm install logstash-forwarder "c:\logstash-forwarder"
nssm set logstash-forwarder Application "c:\logstash-forwarder\logstash-forwarder.exe"
nssm set logstash-forwarder AppDirectory "c:\logstash-forwarder"
nssm set logstash-forwarder AppParameters "-config c:\logstash-forwarder\forwarder.conf"
nssm set logstash-forwarder AppStdout "c:\logstash-forwarder\log.txt"
nssm set logstash-forwarder AppStderr "c:\logstash-forwarder\log.txt"
sc start logstash-forwarder