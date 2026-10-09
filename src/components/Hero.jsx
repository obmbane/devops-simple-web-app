import { motion } from "motion/react";
import Terminal from "./Terminal";

export default function Hero() {
  return (
    <header className="relative overflow-hidden bg-ink text-white">
      {/* Drifting colour blobs and a faint grid */}
      <div aria-hidden="true" className="pointer-events-none absolute inset-0">
        <motion.div
          className="absolute -left-32 -top-32 h-96 w-96 rounded-full bg-sky-500/30 blur-3xl"
          animate={{ x: [0, 80, 0], y: [0, 50, 0] }}
          transition={{ duration: 14, repeat: Infinity, ease: "easeInOut" }}
        />
        <motion.div
          className="absolute -right-24 top-1/3 h-[28rem] w-[28rem] rounded-full bg-fuchsia-500/20 blur-3xl"
          animate={{ x: [0, -60, 0], y: [0, -40, 0] }}
          transition={{ duration: 18, repeat: Infinity, ease: "easeInOut" }}
        />
        <div className="hero-grid absolute inset-0" />
      </div>

      <div className="relative mx-auto grid min-h-screen max-w-6xl items-center gap-12 px-6 py-20 lg:grid-cols-2">
        <div>
          <motion.p
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            className="font-mono text-sm text-sky-300"
          >
            ~/devops-journey $ cat README.md
          </motion.p>
          <motion.h1
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 }}
            className="mt-4 text-5xl font-bold leading-tight tracking-tight sm:text-6xl"
          >
            From <span className="font-mono text-sky-400">git init</span> to{" "}
            <span className="font-mono text-emerald-400">Running</span>.
          </motion.h1>
          <motion.p
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2 }}
            className="mt-6 max-w-lg text-lg text-slate-300"
          >
            A scrapbook of my DevOps learning journey: the tools, the commands and the lessons
            learned along the way. This page is the project itself. It's containerised, served by
            nginx, and running on Kubernetes.
          </motion.p>
          <motion.a
            href="#journey"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.3 }}
            className="mt-8 inline-flex items-center gap-2 rounded-full bg-white px-6 py-3 font-semibold text-ink transition-colors hover:bg-sky-300"
          >
            Open the scrapbook ↓
          </motion.a>
        </div>
        <Terminal />
      </div>
    </header>
  );
}
