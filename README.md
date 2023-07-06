# VPS scripts

## Setting up a new VPS server


As root user:

```bash
curl https://raw.githubusercontent.com/larryhudson/vps-scripts/main/setup-vps.sh -o setup-vps.sh
chmod +x setup-vps.sh
./setup-vps.sh

```

## Setting up a new Node app

As root user:

```bash
curl https://raw.githubusercontent.com/larryhudson/vps-scripts/main/setup-node-app.sh -o setup-node-app.sh 
chmod +x setup-node-app.sh
./setup-node-app.sh
```

## Notes
- Should probably run the 'setup node app' script as deploy user instead of root
- Having some trouble with nginx - looks like it uses the app name as the server name - should be the whole domain
- Having some trouble with selecting the port - looks like it is choosing the redis port instead of 3000
