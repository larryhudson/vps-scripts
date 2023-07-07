# VPS scripts

## Setting up a new VPS server


As root user:

```bash
curl https://raw.githubusercontent.com/larryhudson/vps-scripts/main/setup-vps-1-run-as-root.sh -o setup-vps-1-run-as-root.sh
chmod +x setup-vps-1-run-as-root.sh
./setup-vps-1-run-as-root.sh
```

Then as deploy user:

```bash
curl https://raw.githubusercontent.com/larryhudson/vps-scripts/main/setup-vps-2-run-as-deploy.sh -o setup-vps-2-run-as-deploy.sh
chmod +x setup-vps-2-run-as-deploy.sh
./setup-vps-2-run-as-deploy.sh
```

## Setting up a new Node app

As root user:

```bash
curl https://raw.githubusercontent.com/larryhudson/vps-scripts/main/setup-node-app-run-as-deploy.sh -o setup-node-app-run-as-deploy.sh 
chmod +x setup-node-app-run-as-deploy.sh
./setup-node-app-run-as-deploy.sh
```

## Notes
- Having some trouble with selecting the port - looks like it is choosing the redis port instead of 3000
