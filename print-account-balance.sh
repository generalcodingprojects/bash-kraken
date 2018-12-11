# Set api-key, api secret
api_key="insert_api_key_here"
api_secret="insert_api_secret_here"
api_version="0"

request() {

path="/$api_version/$1/$2"
data="$3"

if [ "$1" == "public" ]; then
  response="$(curl -s -X POST -d "$data" "https://api.kraken.com$path")"
else
  nonce="$(TZ=UTC date +%s%2N)"
  api_sign="$(
  python3 -c \
  "
import urllib.parse
import time
import hashlib
import hmac
import base64
data = {}
if '$data': data = dict(u.split('=') for u in '$data'.split('&'))
data['nonce'] = '$nonce'
postdata = urllib.parse.urlencode(data)
urlpath = '$path'
encoded = (str(data['nonce']) + postdata).encode()
message = urlpath.encode() + hashlib.sha256(encoded).digest()
signature = hmac.new(base64.b64decode('$api_secret'), message, hashlib.sha512)
sigdigest = base64.b64encode(signature.digest())
print(sigdigest.decode())
  "
  )"
  response="$(curl -s -X POST -d "$data&nonce=$nonce" "https://api.kraken.com$path" -H "API-Key:$api_key" -H "API-Sign:$api_sign")"
fi

}
