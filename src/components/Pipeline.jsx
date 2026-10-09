import { Fragment } from "react";
import { motion } from "motion/react";
import { pipeline } from "../data";

function Connector() {
  return (
    <>
      {/* Horizontal line with a travelling dot on wide screens */}
      <div aria-hidden="true" className="relative hidden h-0.5 flex-1 bg-white/15 lg:block">
        <span className="absolute top-1/2 h-2 w-2 -translate-x-1/2 -translate-y-1/2 animate-flow rounded-full bg-sky-400 shadow-[0_0_12px_var(--color-sky-400)] motion-reduce:hidden" />
      </div>
      {/* Plain vertical line on narrow screens */}
      <div aria-hidden="true" className="mx-auto h-8 w-0.5 bg-white/15 lg:hidden" />
    </>
  );
}

export default function Pipeline() {
  return (
    <section className="bg-ink px-6 py-24 text-white">
      <div className="mx-auto max-w-6xl">
        <p className="font-mono text-sm text-sky-300">// how this page got here</p>
        <h2 className="mt-2 text-4xl font-bold tracking-tight sm:text-5xl">
          From my editor to your browser
        </h2>

        <ol className="mt-16 flex flex-col lg:flex-row lg:items-center">
          {pipeline.map((stage, i) => {
            const Icon = stage.icon;
            return (
              <Fragment key={stage.label}>
                {i > 0 && <Connector />}
                <motion.li
                  initial={{ opacity: 0, y: 20 }}
                  whileInView={{ opacity: 1, y: 0 }}
                  viewport={{ once: true }}
                  transition={{ delay: i * 0.12 }}
                  className="flex flex-col items-center text-center"
                >
                  <span className="flex h-16 w-16 items-center justify-center rounded-2xl border border-white/15 bg-white/5 transition-colors hover:border-sky-400 hover:bg-sky-400/10">
                    <Icon className="h-8 w-8" />
                  </span>
                  <span className="mt-3 font-semibold">{stage.label}</span>
                  <span className="text-xs text-slate-400">{stage.sub}</span>
                </motion.li>
              </Fragment>
            );
          })}
        </ol>
      </div>
    </section>
  );
}
