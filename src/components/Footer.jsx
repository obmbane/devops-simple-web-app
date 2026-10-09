import { SiGithub } from "react-icons/si";
import { repoUrl } from "../data";

export default function Footer() {
  return (
    <footer className="border-t border-white/10 bg-ink px-6 py-12 text-slate-400">
      <div className="mx-auto flex max-w-6xl flex-col items-center justify-between gap-6 sm:flex-row">
        <p className="font-mono text-sm">
          served by <span className="text-emerald-400">nginx</span> → in a{" "}
          <span className="text-sky-400">pod</span> → on <span className="text-sky-400">Kind</span> →
          built with <span className="text-violet-400">Terraform</span>
        </p>
        <a
          href={repoUrl}
          className="inline-flex items-center gap-2 text-sm font-medium text-white transition-colors hover:text-sky-300"
        >
          <SiGithub className="h-5 w-5" />
          View the source
        </a>
      </div>
    </footer>
  );
}
