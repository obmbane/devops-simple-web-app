import { useEffect, useState } from "react";
import { motion } from "motion/react";
import { terminalSession } from "../data";

const TYPE_MS = 45;
const PAUSE_MS = 700;

function Prompt() {
  return <span className="text-sky-400">➜ </span>;
}

export default function Terminal() {
  const [line, setLine] = useState(0);
  const [chars, setChars] = useState(0);

  // Skip the typing animation for people who prefer reduced motion.
  useEffect(() => {
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
      setLine(terminalSession.length);
    }
  }, []);

  // Type the current command one character at a time, then move on.
  useEffect(() => {
    if (line >= terminalSession.length) return;
    const cmd = terminalSession[line].cmd;
    const timer =
      chars < cmd.length
        ? setTimeout(() => setChars((c) => c + 1), TYPE_MS)
        : setTimeout(() => {
            setLine((l) => l + 1);
            setChars(0);
          }, PAUSE_MS);
    return () => clearTimeout(timer);
  }, [line, chars]);

  const done = line >= terminalSession.length;
  const cursor = <span className="ml-0.5 inline-block h-4 w-2 translate-y-0.5 animate-blink bg-emerald-400" />;

  return (
    <motion.div
      initial={{ opacity: 0, y: 30, rotate: 2 }}
      animate={{ opacity: 1, y: 0, rotate: 1 }}
      transition={{ duration: 0.7, delay: 0.3 }}
      className="w-full overflow-hidden rounded-xl border border-white/10 bg-black/60 shadow-2xl shadow-sky-500/10 backdrop-blur"
    >
      <div className="flex items-center gap-2 border-b border-white/10 px-4 py-3">
        <span className="h-3 w-3 rounded-full bg-red-400" />
        <span className="h-3 w-3 rounded-full bg-yellow-400" />
        <span className="h-3 w-3 rounded-full bg-green-400" />
        <span className="ml-3 font-mono text-xs text-slate-400">bash: ~/devops-simple-web-app</span>
      </div>
      <div className="min-h-64 space-y-1 p-5 font-mono text-sm leading-relaxed text-slate-200">
        {terminalSession.slice(0, line).map((entry) => (
          <div key={entry.cmd}>
            <p>
              <Prompt />
              {entry.cmd}
            </p>
            <p className="text-emerald-300">{entry.out}</p>
          </div>
        ))}
        <p>
          <Prompt />
          {!done && terminalSession[line].cmd.slice(0, chars)}
          {cursor}
        </p>
      </div>
    </motion.div>
  );
}
