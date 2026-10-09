import { motion, useScroll, useSpring } from "motion/react";
import Hero from "./components/Hero";
import Marquee from "./components/Marquee";
import Collage from "./components/Collage";
import Pipeline from "./components/Pipeline";
import Footer from "./components/Footer";

export default function App() {
  // Thin bar across the top that fills as you scroll.
  const { scrollYProgress } = useScroll();
  const progress = useSpring(scrollYProgress, { stiffness: 120, damping: 25 });

  return (
    <>
      <motion.div
        className="fixed inset-x-0 top-0 z-50 h-1 origin-left bg-gradient-to-r from-sky-400 via-fuchsia-400 to-emerald-400"
        style={{ scaleX: progress }}
      />
      <Hero />
      <Marquee />
      <main>
        <Collage />
        <Pipeline />
      </main>
      <Footer />
    </>
  );
}
