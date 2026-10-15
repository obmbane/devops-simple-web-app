import { motion } from "motion/react";
import { FiCheck } from "react-icons/fi";
import { projects } from "../data";

const tones = {
  amber: { badge: "bg-amber-100 text-amber-800", dot: "bg-amber-500" },
  sky: { badge: "bg-sky-100 text-sky-800", dot: "bg-sky-500" },
};

function ProjectCard({ project, index }) {
  const tone = tones[project.tone] ?? tones.sky;
  const logoClass =
    project.logoFit === "cover"
      ? "h-full w-full object-cover"
      : "h-2/5 w-auto max-w-[70%] object-contain";

  return (
    <motion.article
      initial={{ opacity: 0, y: 40 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true, margin: "-80px" }}
      transition={{ duration: 0.5, delay: index * 0.12 }}
      whileHover={{ y: -6 }}
      className="group flex flex-col overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm transition-shadow hover:shadow-xl"
    >
      <div className={`flex aspect-[16/9] items-center justify-center overflow-hidden ${project.panel}`}>
        <img
          src={project.logo}
          alt={`${project.name} logo`}
          loading="lazy"
          className={`${logoClass} transition-transform duration-500 group-hover:scale-105`}
        />
      </div>

      <div className="flex flex-1 flex-col p-6 sm:p-8">
        <span
          className={`inline-flex w-fit items-center gap-2 rounded-full px-3 py-1 text-xs font-semibold ${tone.badge}`}
        >
          <span className={`h-1.5 w-1.5 rounded-full ${tone.dot}`} />
          {project.status}
        </span>

        <h3 className="mt-4 text-2xl font-bold tracking-tight text-ink">{project.name}</h3>
        <p className="text-sm text-slate-500">{project.category}</p>
        <p className="mt-3 text-slate-700">{project.summary}</p>

        <ul className="mt-5 space-y-2">
          {project.features.map((feature) => (
            <li key={feature} className="flex gap-3 text-sm text-slate-700">
              <FiCheck className="mt-0.5 h-4 w-4 shrink-0 text-emerald-500" />
              {feature}
            </li>
          ))}
        </ul>

        <ul className="mt-auto flex flex-wrap gap-2 pt-6">
          {project.stack.map((tech) => (
            <li key={tech} className="rounded-md bg-slate-100 px-2.5 py-1 font-mono text-xs text-slate-600">
              {tech}
            </li>
          ))}
        </ul>
      </div>
    </motion.article>
  );
}

export default function Projects() {
  return (
    <section id="projects" className="bg-slate-50 px-6 py-24">
      <div className="mx-auto max-w-6xl">
        <p className="font-mono text-sm text-slate-500">// things I've built</p>
        <h2 className="mt-2 text-4xl font-bold tracking-tight text-ink sm:text-5xl">Projects</h2>
        <p className="mt-4 max-w-2xl text-lg text-slate-600">
          Apps I've designed and built alongside learning DevOps.
        </p>

        <div className="mt-14 grid gap-8 lg:grid-cols-2">
          {projects.map((project, i) => (
            <ProjectCard key={project.name} project={project} index={i} />
          ))}
        </div>
      </div>
    </section>
  );
}
