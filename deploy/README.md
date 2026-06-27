# RASHA Super App — Deployment

Each deployment target has its own folder under `deploy/`.

## Structure

```txt
deploy/
├── ibent95.my.id/          # Deployment for ibent95.my.id hosting
│   ├── build.sh            # Linux/Mac build script
│   ├── build.bat           # Windows build script
│   ├── deploy.env          # Environment config
│   ├── README.md           # Deployment docs
│   └── dist/               # Build output (gitignored)
│       ├── public_html/    # Angular builds → upload to hosting public_html/
│       └── services/       # Laravel services → upload to hosting home/
├── another-domain.com/     # (Future) Deployment for another domain
└── README.md               # This file
```

## Adding a New Deployment Target

1. Create `deploy/{domain}/` folder
2. Copy build scripts from `deploy/ibent95.my.id/`
3. Update `deploy.env` with domain-specific settings
4. Update `.htaccess` with domain-specific routing
5. Update README with deployment steps

## Current Deployments

|             Domain              |        Hosting        | Status |
|---------------------------------|-----------------------|--------|
| [ibent95.my.id](ibent95.my.id/) | cPanel Shared Hosting | Active |
