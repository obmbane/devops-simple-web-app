import {
  SiDocker,
  SiGit,
  SiGithubactions,
  SiGnubash,
  SiKubernetes,
  SiLinux,
  SiNginx,
  SiReact,
  SiTailwindcss,
  SiTerraform,
  SiVite,
} from "react-icons/si";

// Each chapter becomes a polaroid on the scrapbook board.
// Edit the text to tell the journey in your own words.
export const chapters = [
  {
    id: "01",
    title: "Linux & WSL",
    tagline: "Where it all runs",
    icon: SiLinux,
    color: "#E8A317",
    story: "Set up Ubuntu on WSL2 and got comfortable living in the terminal.",
    cmd: "uname -a",
  },
  {
    id: "02",
    title: "Git & GitHub",
    tagline: "Branch → PR → merge",
    icon: SiGit,
    color: "#F05032",
    story:
      "Stopped pushing straight to main. Every change gets a feature branch and a pull request.",
    cmd: "git switch -c feature/initial-page",
  },
  {
    id: "03",
    title: "GitHub Actions",
    tagline: "Robots check my work",
    icon: SiGithubactions,
    color: "#2088FF",
    story: "Added a CI pipeline that checks every pull request before it can merge.",
    cmd: "gh pr checks --watch",
  },
  {
    id: "04",
    title: "Docker",
    tagline: "Works on every machine",
    icon: SiDocker,
    color: "#2496ED",
    story:
      "Packaged this site with a multi-stage build: Node compiles it, nginx serves it.",
    cmd: "docker build -t simple-web-app:v1 .",
  },
  {
    id: "05",
    title: "nginx",
    tagline: "Small, fast, reliable",
    icon: SiNginx,
    color: "#009639",
    story: "nginx serves the compiled site from inside the container.",
    cmd: "nginx -t",
  },
  {
    id: "06",
    title: "Kubernetes + Kind",
    tagline: "A cluster inside Docker",
    icon: SiKubernetes,
    color: "#326CE5",
    story:
      "Ran a real Kubernetes cluster locally with Kind: Deployments, Services and pods.",
    cmd: "kubectl get pods",
  },
  {
    id: "07",
    title: "Terraform",
    tagline: "Infrastructure as code",
    icon: SiTerraform,
    color: "#844FBA",
    story:
      "Described the cluster and every Kubernetes object in code, so one command builds it all.",
    cmd: "terraform apply",
  },
  {
    id: "08",
    title: "Bash",
    tagline: "Pre-flight checks",
    icon: SiGnubash,
    color: "#4EAA25",
    story:
      "Wrote a script that checks the tools, Docker, the API server and node health before deploying.",
    cmd: "./check-env.sh",
  },
];

// Sticky notes slotted between the polaroids.
export const notes = [
  "Never push to main. Open a PR!",
  "EXPOSE doesn't publish a port. It's documentation.",
  "Pin your image tags. latest isn't a version.",
  "Running ≠ Ready. Read the probes.",
];

// Typed out line by line in the hero terminal.
export const terminalSession = [
  { cmd: "./check-env.sh", out: "✔ all checks passed" },
  { cmd: "docker build -t simple-web-app:v1 .", out: "✔ image built" },
  { cmd: "terraform apply -auto-approve", out: "Apply complete! Resources: 4 added." },
  { cmd: "kubectl get pods", out: "simple-web-app-7d9f8   1/1   Running" },
];

// How a change travels from my editor to the browser.
export const pipeline = [
  { label: "Code", sub: "Git feature branch", icon: SiGit },
  { label: "Pull request", sub: "GitHub Actions CI", icon: SiGithubactions },
  { label: "Image", sub: "Docker multi-stage", icon: SiDocker },
  { label: "Provision", sub: "Terraform", icon: SiTerraform },
  { label: "Cluster", sub: "Kubernetes on Kind", icon: SiKubernetes },
  { label: "Serve", sub: "nginx pod", icon: SiNginx },
];

// Scrolling logo strip.
export const stack = [
  { name: "Linux", icon: SiLinux },
  { name: "Git", icon: SiGit },
  { name: "GitHub Actions", icon: SiGithubactions },
  { name: "Docker", icon: SiDocker },
  { name: "nginx", icon: SiNginx },
  { name: "Kubernetes", icon: SiKubernetes },
  { name: "Terraform", icon: SiTerraform },
  { name: "Bash", icon: SiGnubash },
  { name: "React", icon: SiReact },
  { name: "Vite", icon: SiVite },
  { name: "Tailwind CSS", icon: SiTailwindcss },
];

export const repoUrl = "https://github.com/obmbane/devops-simple-web-app";
