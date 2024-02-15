#!/bin/bash
function build_client_key {
  CLIENT_NAME=$1
  pushd easy-rsa
  export KEY_NAME=$CLIENT_NAME
  echo -ne '\n' | ./easyrsa gen-req $CLIENT_NAME nopass
  echo -ne 'yes' | ./easyrsa sign-req client $CLIENT_NAME
  
  popd
  mkdir -p clients/$CLIENT_NAME/tun_$CLIENT_NAME
  mv easy-rsa/pki/issued/$CLIENT_NAME.crt clients/$CLIENT_NAME/tun_$CLIENT_NAME/
  mv easy-rsa/pki/private/$CLIENT_NAME.key clients/$CLIENT_NAME/tun_$CLIENT_NAME/
  cp keys/ca.crt clients/$CLIENT_NAME/tun_$CLIENT_NAME/
  cp keys/ta.key clients/$CLIENT_NAME/tun_$CLIENT_NAME/
  GREP_BEGIN_END='(?P<dashes>-+)\s?BEGIN\s(?P<name>.+)(?P=dashes)\s(.+\s)+?(?P=dashes)\s?END\s(?P=name)(?P=dashes)'
  cat << EOF > clients/$CLIENT_NAME/tun_$CLIENT_NAME.ovpn
dev                 tun_$CLIENT_NAME
proto               udp
client
remote              office.devforth.io 888
cipher              BF-CBC
auth                SHA256
resolv-retry        infinite
persist-key
persist-tun
#ns-cert-type       server
comp-lzo
keepalive           9 30
verb                3
nobind
tun-mtu             1500
mssfix              1300
mute                20
redirect-gateway autolocal
key-direction 1
#status             /var/log/tun_$CLIENT_NAME.status
<ca>
`cat clients/$CLIENT_NAME/tun_$CLIENT_NAME/ca.crt`
</ca>
<cert>
`cat clients/$CLIENT_NAME/tun_$CLIENT_NAME/$CLIENT_NAME.crt`
</cert>
<key>
`cat clients/$CLIENT_NAME/tun_$CLIENT_NAME/$CLIENT_NAME.key`
</key>
<tls-crypt>
`cat clients/$CLIENT_NAME/tun_$CLIENT_NAME/ta.key`
</tls-crypt>
EOF
  pushd clients
  # tar zcvf tun_$CLIENT_NAME.tar.gz $CLIENT_NAME
  popd
}
export -f build_client_key
bash -c "build_client_key $@"
