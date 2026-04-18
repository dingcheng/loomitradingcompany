# Loomi Company — Website

Static marketing site for **Loomi Company** (Loomi Trading Company, LLC).
Covers the company, its product categories (Golf / Snow / Lifestyle), and its
three iOS apps: **Golfiasta**, **DollyCam**, and **MakeLive**.

- Pure static: HTML + CSS + one small JS file
- No build step, no framework, no tracking
- Deploy anywhere that serves static files

---

## Local preview

Any static server works. Pick one:

```sh
# Python 3
python3 -m http.server 8000

# Node (if you have npx)
npx serve -l 8000 .

# Caddy (one-liner)
caddy file-server --listen :8000
```

Then open <http://localhost:8000>.

---

## Deploy — GitHub Pages (recommended)

The site deploys to **<https://loomicompany.com>** via the repo
[`dingcheng/loomitradingcompany`](https://github.com/dingcheng/loomitradingcompany).

### One-command deploy

```sh
./deploy.sh                      # interactive (confirms before the first force-push)
./deploy.sh --yes                # skip confirmation
./deploy.sh -m "Tweak hero copy" # custom commit message
```

The script (first run):

1. Initializes a git repo here and points `origin` at
   `git@github.com:dingcheng/loomitradingcompany.git`.
2. **Backs up** the existing remote `main` to `main-mkdocs-backup` — nothing
   is lost; you can recover the old mkdocs source at any time.
3. Force-pushes this directory as the new `main`.
4. Switches GitHub Pages source to **GitHub Actions** so the workflow at
   `.github/workflows/deploy.yml` publishes the site.
5. Re-applies the custom domain `loomicompany.com` and enforces HTTPS via the
   Pages API (so the CNAME and cert survive the source switch).

Subsequent runs just commit and push; the Actions workflow redeploys
automatically.

### Requirements

- `git`
- `gh` ([GitHub CLI](https://cli.github.com)), authenticated as the repo owner
  (`gh auth login`)
- SSH push access to the repo

### Manual workflow (alternative)

If you'd rather do it by hand:

```sh
git init -b main
git remote add origin git@github.com:dingcheng/loomitradingcompany.git
git fetch origin
# Back up the old mkdocs source
git push origin refs/remotes/origin/main:refs/heads/main-mkdocs-backup
git add -A && git commit -m "Deploy new site"
git push --force origin main
gh api --method PUT repos/dingcheng/loomitradingcompany/pages -F build_type=workflow
gh api --method PUT repos/dingcheng/loomitradingcompany/pages -F cname=loomicompany.com
```

---

## Deploy — Self-hosted

The `deploy/` folder contains ready-to-use configs:

### Caddy (easiest, auto-HTTPS)

```sh
sudo cp deploy/Caddyfile /etc/caddy/Caddyfile
sudo rsync -a --delete ./ /var/www/loomicompany/ \
    --exclude .git --exclude .github --exclude deploy --exclude README.md
sudo systemctl reload caddy
```

Caddy will automatically obtain a Let's Encrypt certificate for
`loomicompany.com`.

### nginx

```sh
sudo cp deploy/nginx.conf /etc/nginx/sites-available/loomicompany.conf
sudo ln -s /etc/nginx/sites-available/loomicompany.conf \
    /etc/nginx/sites-enabled/loomicompany.conf
sudo rsync -a --delete ./ /var/www/loomicompany/ \
    --exclude .git --exclude .github --exclude deploy --exclude README.md
sudo certbot --nginx -d loomicompany.com -d www.loomicompany.com
sudo nginx -t && sudo systemctl reload nginx
```

### Any other static host

Netlify, Cloudflare Pages, Vercel, S3+CloudFront, Fly static, Render — all
work out of the box. Point them at the repo root; no build command needed.

---

## Structure

```
.
├── index.html              Home
├── golfiasta.html          Golf GPS app page
├── dollycam.html           Cinematic video app page
├── makelive.html           Video → Live Photo app page
├── privacy.html            Privacy policy (covers all apps)
├── 404.html                Not-found page
├── CNAME                   Custom domain for GitHub Pages
├── robots.txt
├── sitemap.xml
├── .nojekyll               Tells Pages not to run Jekyll
├── deploy.sh               One-command deploy to GitHub Pages
├── .github/workflows/
│   └── deploy.yml          GitHub Pages deploy workflow
├── deploy/
│   ├── Caddyfile           Self-hosting (Caddy)
│   └── nginx.conf          Self-hosting (nginx)
└── assets/
    ├── css/main.css        Design system & components
    ├── js/main.js          Nav, scroll reveals
    └── images/
        ├── favicon.svg
        └── golfiasta/      App screenshots
```

---

## Editing

- **Copy lives directly in the HTML files.** Edit the relevant `.html`.
- **Global styles** are in `assets/css/main.css`. Design tokens
  (colors, spacing, radii) are CSS variables at the top of that file.
- **JS** is minimal and in `assets/js/main.js` — mobile menu, scrolled
  header, and reveal-on-scroll animations.
- Images are in `assets/images/`. Replace or add new ones and reference
  them from the HTML.

---

## Contact

**Loomi Company** — <contact@loomicompany.com>
