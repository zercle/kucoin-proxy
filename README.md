# kucoin-proxy
kucoin-proxy docker build from [mikekonan/exchange-proxy](https://github.com/mikekonan/exchange-proxy) release with latest `GO` and run with latest `Alpine Linux`

#### run
```bash
docker run -d -p 8080:8080 --restart always zercle/kucoin-proxy
```

### freqtrade config
```json
"exchange": {
        "name": "kucoin",
        "key": "",
        "secret": "",
        "ccxt_config": {
            "enableRateLimit": false,
            "timeout": 60000,
            "urls": {
                "api": {
                    "public": "http://127.0.0.1:8080/kucoin",
                    "private": "http://127.0.0.1:8080/kucoin"
                }
            }
        },
        "ccxt_async_config": {
            "enableRateLimit": false,
            "timeout": 60000
        },
}
```
