import { stack } from "../data";

export default function Marquee() {
  // The list is rendered twice so the strip can loop seamlessly.
  const items = [...stack, ...stack];

  return (
    <div className="overflow-hidden border-y border-white/10 bg-ink py-5 text-slate-300">
      <ul className="flex w-max animate-marquee gap-12 motion-reduce:animate-none">
        {items.map(({ name, icon: Icon }, i) => (
          <li
            key={i}
            aria-hidden={i >= stack.length ? "true" : undefined}
            className="flex items-center gap-3 whitespace-nowrap text-lg font-medium"
          >
            <Icon className="h-6 w-6" />
            {name}
          </li>
        ))}
      </ul>
    </div>
  );
}
