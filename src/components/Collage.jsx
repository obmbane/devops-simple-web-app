import { useEffect, useRef, useState } from "react";
import { motion } from "motion/react";
import { chapters, notes } from "../data";

const tilts = [-3, 2, -1.5, 3, -2.5, 1.5, -2, 2.5, -1, 3.5, -3.5, 1];
const offsets = ["", "lg:mt-14", "lg:-mt-2", "lg:mt-8"];
const noteColors = ["bg-yellow-200", "bg-pink-200", "bg-lime-200", "bg-sky-200"];

// Put a sticky note after every second polaroid.
const items = chapters.flatMap((chapter, i) => {
  const note = notes[(i - 1) / 2];
  return i % 2 === 1 && note
    ? [{ type: "polaroid", chapter }, { type: "note", text: note }]
    : [{ type: "polaroid", chapter }];
});

function Polaroid({ chapter }) {
  const Icon = chapter.icon;
  return (
    <div className="relative bg-white p-3 pb-5 shadow-xl shadow-black/15">
      <span aria-hidden="true" className="tape" />
      <div
        className="relative flex aspect-[4/3] items-center justify-center overflow-hidden"
        style={{ background: `linear-gradient(135deg, ${chapter.color}, #0b0f19)` }}
      >
        <Icon className="h-20 w-20 text-white drop-shadow-lg" />
        <span className="absolute left-2 top-2 font-mono text-xs font-bold text-white/80">
          CH.{chapter.id}
        </span>
      </div>
      <h3 className="mt-3 font-hand text-3xl leading-none text-ink">{chapter.title}</h3>
      <p className="mt-1 text-xs font-semibold uppercase tracking-widest text-slate-500">
        {chapter.tagline}
      </p>
      <p className="mt-2 text-sm text-slate-700">{chapter.story}</p>
      <code className="mt-3 block truncate rounded bg-ink px-2 py-1 font-mono text-xs text-emerald-300">
        $ {chapter.cmd}
      </code>
    </div>
  );
}

function StickyNote({ text, color }) {
  return (
    <div className={`relative ${color} p-6 shadow-lg shadow-black/10`}>
      <span aria-hidden="true" className="tape" />
      <p className="font-hand text-3xl leading-snug text-ink">{text}</p>
    </div>
  );
}

export default function Collage() {
  const boardRef = useRef(null);

  // Only make cards draggable with a mouse, so touch users can still scroll.
  const [canDrag, setCanDrag] = useState(false);
  useEffect(() => {
    setCanDrag(window.matchMedia("(pointer: fine)").matches);
  }, []);

  let noteCount = 0;

  return (
    <section id="journey" className="board px-6 py-24">
      <div className="mx-auto max-w-6xl">
        <p className="font-mono text-sm text-slate-500">// the scrapbook</p>
        <h2 className="mt-2 text-4xl font-bold tracking-tight text-ink sm:text-5xl">
          Every tool, one chapter at a time
        </h2>
        {canDrag && (
          <p className="mt-3 font-hand text-2xl text-slate-600">
            psst, you can drag the cards around ↓
          </p>
        )}

        <div
          ref={boardRef}
          className="mt-16 grid items-start gap-x-8 gap-y-12 sm:grid-cols-2 lg:grid-cols-4"
        >
          {items.map((item, i) => (
            <motion.div
              key={item.type === "note" ? item.text : item.chapter.id}
              className={`relative ${offsets[i % offsets.length]} ${canDrag ? "cursor-grab" : ""}`}
              initial={{ opacity: 0, y: 60, rotate: 0 }}
              whileInView={{ opacity: 1, y: 0, rotate: tilts[i % tilts.length] }}
              viewport={{ once: true, margin: "-80px" }}
              transition={{ type: "spring", stiffness: 110, damping: 14, delay: (i % 4) * 0.08 }}
              whileHover={{ rotate: 0, scale: 1.03, zIndex: 20 }}
              drag={canDrag}
              dragConstraints={boardRef}
              dragElastic={0.2}
              whileDrag={{ scale: 1.06, rotate: 0, zIndex: 30, cursor: "grabbing" }}
            >
              {item.type === "note" ? (
                <StickyNote text={item.text} color={noteColors[noteCount++ % noteColors.length]} />
              ) : (
                <Polaroid chapter={item.chapter} />
              )}
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}
