# devops-simple-web-app

Simple Dockerised Web Page Served Using Nginx.

A React site about my DevOps learning journey. It's built into a Docker image, served by nginx, and deployed to a local Kubernetes cluster (Kind) with Terraform.

## Container image

| | |
|---|---|
| **Registry** | Docker Hub (`docker.io`) |
| **Repository** | [`olly007/simple-web-app`](https://hub.docker.com/r/olly007/simple-web-app) |
| **Current tag** | `v1` |
| **Full image name** | `docker.io/olly007/simple-web-app:v1` |
| **Digest (v1)** | `sha256:08ff4bcc7a09ec892e65a6553167a18cac5bc1460d5365b8b0005117efc6a804` |
| **Container port** | `80` |
| **Health check** | `GET /healthz` returns `200 ok` |

Pull and run it:

```bash
docker pull olly007/simple-web-app:v1
docker run -d --name simple-web-app -p 8080:80 olly007/simple-web-app:v1
```

Then open http://localhost:8080.

To pin the exact build, reference the digest instead of the tag:

```bash
docker pull olly007/simple-web-app@sha256:08ff4bcc7a09ec892e65a6553167a18cac5bc1460d5365b8b0005117efc6a804
```

## Build and push a new version

The [Dockerfile](Dockerfile) is a multi-stage build. Stage 1 (`node:22-alpine`) runs `npm ci` and `npm run build`. Stage 2 (`nginx:1.30-alpine`) serves only the built `dist/` files using [nginx.conf](nginx.conf).

```bash
docker build -t olly007/simple-web-app:<tag> .
docker push olly007/simple-web-app:<tag>
```

Use a new tag (`v2`, `v3`, ...) for every release. Don't overwrite an existing tag.

## Local development

Requires Node.js 22.

```bash
npm ci          # install dependencies
npm run dev     # dev server at http://localhost:5173
npm run build   # production build into dist/
```

All of the page's text lives in [src/data.js](src/data.js).

## Project structure

```
├── Dockerfile            # multi-stage build: Node builds, nginx serves
├── nginx.conf            # nginx site config (caching, gzip, /healthz)
├── index.html            # Vite entry point
├── src/
│   ├── main.jsx          # React entry
│   ├── App.jsx           # page layout
│   ├── data.js           # page content
│   └── components/       # Hero, Terminal, Marquee, Collage, Pipeline, Footer
└── .github/workflows/    # CI: HTML validation on pull requests
```

## Roadmap

- [x] React site (Vite, Tailwind CSS, Motion)
- [x] CI with GitHub Actions
- [x] Multi-stage Docker image on Docker Hub
- [ ] Bash script to check the local environment
- [ ] Terraform to create the Kind cluster and Kubernetes objects
- [ ] Deploy and serve the site from Kubernetes
