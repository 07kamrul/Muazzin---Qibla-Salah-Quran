import { useState, useEffect, useRef } from "react";

/* ══════════════════════════════════════════════════════════════════════════════
   MUAZZIN — القرآن · الصلاة · القبلة
   Sacred Haramain atmosphere — Makkah & Madinah night prayer experience
══════════════════════════════════════════════════════════════════════════════ */

// Inject Google Fonts
(() => {
  const l = document.createElement("link");
  l.rel = "stylesheet";
  l.href = "https://fonts.googleapis.com/css2?family=Amiri:ital,wght@0,400;0,700;1,400&family=Cinzel+Decorative:wght@400;700&family=Cinzel:wght@400;600;700&family=Noto+Serif+Bengali:wght@400;500;600;700&family=Noto+Sans+Bengali:wght@300;400;500;600&display=swap";
  document.head.appendChild(l);
})();

/* ── PALETTE: Haramain Night ─────────────────────────────────────────────── */
// Inspired by: Masjid al-Haram at Fajr — cool marble, warm lantern brass,
// Madinah's Green Dome, the indigo sky above the open sahn courtyard.
const P = {
  // Sky & depth
  sky0:     "#07050C",   // pre-dawn indigo-void
  sky1:     "#0D0A12",   // deep Madinah night
  sky2:     "#140F18",   // dark courtyard stone
  sky3:     "#1C1520",   // shadowed marble
  sky4:     "#251C2A",   // lantern-lit recess

  // Sacred Green — Prophet's Mosque (ﷺ) Green Dome
  dome:     "#1F5C3A",
  domeLight:"#2D8A56",
  domePale: "#3AAD6B",
  domeGlow: "rgba(45,138,86,0.22)",
  domeBd:   "rgba(45,138,86,0.38)",

  // Madinah Brass & Gold — lantern metal, inscription gilt
  brass:    "#B8882A",
  gold:     "#D4A840",
  goldWarm: "#E8C060",
  goldPale: "#F4DFA0",
  goldGlow: "rgba(232,192,96,0.18)",
  goldBd:   "rgba(212,168,64,0.35)",

  // Marble whites — Haram floor, maqam stone
  marble:   "#F0EDE8",
  sand:     "#C8B898",
  sandMid:  "#907860",
  sandDeep: "#4A3C2C",

  // Minarets silhouette tint
  minaret:  "rgba(240,237,232,0.06)",

  // Accent
  ruby:     "#7A1E2A",
  rubyGlow: "rgba(122,30,42,0.25)",
};

/* ── GLOBAL CSS ──────────────────────────────────────────────────────────── */
const CSS = `
  *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

  @keyframes fadeUp    { from{opacity:0;transform:translateY(16px)}to{opacity:1;transform:translateY(0)} }
  @keyframes fadeIn    { from{opacity:0}to{opacity:1} }
  @keyframes scaleIn   { from{opacity:0;transform:scale(.92)}to{opacity:1;transform:scale(1)} }

  @keyframes starBlink { 0%,100%{opacity:.1} 50%{opacity:.45} }
  @keyframes shootStar {
    0%   { opacity:0; transform:translateX(0) translateY(0) scaleX(0); }
    10%  { opacity:.7; }
    80%  { opacity:.4; transform:translateX(-120px) translateY(50px) scaleX(1); }
    100% { opacity:0; transform:translateX(-160px) translateY(70px) scaleX(1.2); }
  }

  @keyframes lanternSway  { 0%,100%{transform:rotate(-1.5deg)}50%{transform:rotate(1.5deg)} }
  @keyframes lanternGlow  { 0%,100%{opacity:.55;filter:blur(6px)}50%{opacity:.9;filter:blur(10px)} }
  @keyframes tawafRing    { from{transform:rotate(0deg)}to{transform:rotate(360deg)} }
  @keyframes tawafRingRev { from{transform:rotate(0deg)}to{transform:rotate(-360deg)} }
  @keyframes goldPulse    { 0%,100%{box-shadow:0 0 14px ${P.goldGlow}}50%{box-shadow:0 0 32px rgba(232,192,96,.32)} }
  @keyframes domePulse    { 0%,100%{box-shadow:0 0 14px ${P.domeGlow}}50%{box-shadow:0 0 36px rgba(45,138,86,.38)} }
  @keyframes countBlink   { 0%,100%{opacity:1}50%{opacity:.55} }
  @keyframes slideUp      { from{transform:translateY(100%);opacity:0}to{transform:translateY(0);opacity:1} }
  @keyframes marbleShimmer{
    0%   { background-position: -200% 50%; }
    100% { background-position: 300% 50%; }
  }
  @keyframes needleLand {
    0%   { transform: rotate(calc(var(--qa) - 40deg)); }
    65%  { transform: rotate(calc(var(--qa) + 5deg)); }
    80%  { transform: rotate(calc(var(--qa) - 2deg)); }
    100% { transform: rotate(var(--qa)); }
  }
  @keyframes floatUp { 0%,100%{transform:translateY(0)}50%{transform:translateY(-5px)} }
  @keyframes writeIn {
    from { clip-path: inset(0 100% 0 0); }
    to   { clip-path: inset(0 0% 0 0); }
  }

  ::-webkit-scrollbar { width: 3px; }
  ::-webkit-scrollbar-track { background: transparent; }
  ::-webkit-scrollbar-thumb { background: ${P.goldBd}; border-radius: 3px; }

  .tap-card:hover { border-color: ${P.goldWarm} !important; }
`;

/* ── DATA ────────────────────────────────────────────────────────────────── */
const PRAYERS = [
  { key:"fajr",    bn:"ফজর",    ar:"الفجر",   en:"Fajr",    time:"05:12", jamat:"05:25", done:true,  next:false },
  { key:"dhuhr",   bn:"যোহর",   ar:"الظهر",   en:"Dhuhr",   time:"12:04", jamat:"12:30", done:true,  next:false },
  { key:"asr",     bn:"আসর",    ar:"العصر",   en:"Asr",     time:"15:48", jamat:"16:00", done:false, next:true  },
  { key:"maghrib", bn:"মাগরিব", ar:"المغرب",  en:"Maghrib", time:"18:12", jamat:"18:20", done:false, next:false },
  { key:"isha",    bn:"এশা",    ar:"العشاء",  en:"Isha",    time:"19:38", jamat:"20:00", done:false, next:false },
];
const MOSQUES = [
  { id:1, name:"বায়তুল মুকাররম জাতীয় মসজিদ", dist:"০.৮ কি.মি", badge:"official", jamat:"৪:০০", tags:["AC","ওযু","মহিলা"] },
  { id:2, name:"গুলশান আজাদ মসজিদ",            dist:"১.২ কি.মি", badge:"community",jamat:"৩:৫৫", tags:["ওযু","পার্কিং"] },
  { id:3, name:"মহাখালী জামে মসজিদ",           dist:"১.৮ কি.মি", badge:"admin",    jamat:"৪:০৫", tags:["ওযু"] },
  { id:4, name:"বনানী সেন্ট্রাল মসজিদ",         dist:"২.১ কি.মি", badge:"community",jamat:"৩:৫০", tags:["AC","ওযু"] },
];
const SURAHS = [
  { n:1,   ar:"الفاتحة",  bn:"আল-ফাতিহা",  ay:7,   t:"মাক্কী" },
  { n:2,   ar:"البقرة",   bn:"আল-বাকারা",   ay:286, t:"মাদানী" },
  { n:3,   ar:"آل عمران", bn:"আলে-ইমরান",   ay:200, t:"মাদানী" },
  { n:18,  ar:"الكهف",    bn:"আল-কাহফ",     ay:110, t:"মাক্কী" },
  { n:36,  ar:"يس",       bn:"ইয়াসিন",      ay:83,  t:"মাক্কী" },
  { n:55,  ar:"الرحمن",   bn:"আর-রাহমান",   ay:78,  t:"মাদানী" },
  { n:67,  ar:"الملك",    bn:"আল-মুলক",     ay:30,  t:"মাক্কী" },
  { n:112, ar:"الإخلاص",  bn:"আল-ইখলাস",   ay:4,   t:"মাক্কী" },
  { n:113, ar:"الفلق",    bn:"আল-ফালাক",    ay:5,   t:"মাক্কী" },
  { n:114, ar:"الناس",    bn:"আন-নাস",      ay:6,   t:"মাক্কী" },
];
const HADITH = {
  ar:"إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ، وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى",
  bn:"নিশ্চয়ই প্রতিটি কাজ নিয়তের উপর নির্ভরশীল এবং প্রতিটি মানুষ তাই পাবে যা সে নিয়ত করেছে।",
  en:"Actions are judged by intentions; every person will have what they intended.",
  src:"সহীহ বুখারী • হাদিস ১",
};
const RAMADAN = [
  { day:1,  date:"১ রমজান",  sehri:"০৪:৫২", iftar:"১৮:১০" },
  { day:2,  date:"২ রমজান",  sehri:"০৪:৫১", iftar:"১৮:১১" },
  { day:3,  date:"৩ রমজান",  sehri:"০৪:৫০", iftar:"১৮:১২" },
  { day:5,  date:"৫ রমজান",  sehri:"০৪:৪৮", iftar:"১৮:১৪" },
  { day:6,  date:"৬ রমজান",  sehri:"০৪:৪৭", iftar:"১৮:১৫", today:true },
  { day:7,  date:"৭ রমজান",  sehri:"০৪:৪৬", iftar:"১৮:১৬" },
  { day:27, date:"২৭ রমজান", sehri:"০৪:৩০", iftar:"১৮:২৮", lailat:true },
];

/* ══════════════════════════════════════════════════════════════════════════
   SVG ATOMS — Pure geometry, no emojis for structural elements
══════════════════════════════════════════════════════════════════════════ */

/** Haramain mosque silhouette with twin minarets */
function MosqueSilhouette({ width=320, opacity=0.07, color=P.goldPale }) {
  return (
    <svg width={width} height={width*0.45} viewBox="0 0 320 144"
         style={{ display:"block", pointerEvents:"none" }}>
      <g fill={color} opacity={opacity}>
        {/* Left minaret */}
        <rect x="18" y="20" width="12" height="110" rx="2"/>
        <polygon points="18,20 24,4 30,20"/>
        <rect x="15" y="55" width="18" height="6" rx="1"/>
        <rect x="15" y="88" width="18" height="4" rx="1"/>
        {/* Right minaret */}
        <rect x="290" y="20" width="12" height="110" rx="2"/>
        <polygon points="290,20 296,4 302,20"/>
        <rect x="287" y="55" width="18" height="6" rx="1"/>
        <rect x="287" y="88" width="18" height="4" rx="1"/>
        {/* Main building */}
        <rect x="55" y="68" width="210" height="76" rx="3"/>
        {/* Central dome */}
        <ellipse cx="160" cy="62" rx="52" ry="52"/>
        <rect x="108" y="62" width="104" height="18"/>
        {/* Side domes */}
        <ellipse cx="100" cy="82" rx="28" ry="28"/>
        <rect x="72" y="82" width="56" height="14"/>
        <ellipse cx="220" cy="82" rx="28" ry="28"/>
        <rect x="192" y="82" width="56" height="14"/>
        {/* Arched windows */}
        {[80,108,136,164,192,220].map(x => (
          <path key={x} d={`M${x},112 L${x},130 Q${x+8},105 ${x+16},130 L${x+16},112 Z`} opacity="0.5"/>
        ))}
        {/* Ground line */}
        <rect x="0" y="140" width="320" height="4" rx="2"/>
      </g>
    </svg>
  );
}

/** Kaaba cube — SVG vector, no emoji */
function KaabaIcon({ size=40, glow=false }) {
  return (
    <svg width={size} height={size} viewBox="0 0 40 40"
         style={{ filter: glow ? `drop-shadow(0 0 8px ${P.goldGlow})` : "none", display:"block" }}>
      {/* Main cube face */}
      <rect x="6" y="14" width="22" height="22" rx="1" fill="#1A1208" stroke={P.brass} strokeWidth="0.8"/>
      {/* Top face */}
      <polygon points="6,14 14,8 36,8 28,14" fill="#2A1E0C" stroke={P.brass} strokeWidth="0.8"/>
      {/* Right face */}
      <polygon points="28,14 36,8 36,30 28,36" fill="#120E08" stroke={P.brass} strokeWidth="0.8"/>
      {/* Kiswah gold band */}
      <rect x="6" y="23" width="22" height="4" fill="none" stroke={P.goldWarm} strokeWidth="1.2"/>
      {/* Gold calligraphy hint */}
      <rect x="9" y="24.5" width="16" height="1" fill={P.goldWarm} opacity="0.6"/>
      {/* Door */}
      <rect x="13" y="28" width="8" height="8" rx="1" fill="#2D2010" stroke={P.gold} strokeWidth="0.6"/>
      <path d="M13,30 Q17,27 21,30" fill="none" stroke={P.gold} strokeWidth="0.5"/>
    </svg>
  );
}

/** Star & crescent — SVG */
function StarCrescent({ size=22, color=P.goldWarm }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" style={{ display:"block" }}>
      <path d="M12,2 A10,10 0 1,0 20,18 A7,7 0 1,1 12,2 Z" fill={color} opacity="0.9"/>
      <polygon points="19,4 20.5,8 24,8 21.5,10.5 22.5,14 19,12 15.5,14 16.5,10.5 14,8 17.5,8"
               fill={color} opacity="0.9"/>
    </svg>
  );
}

/** Arabesque border strip — repeating diamond lattice */
function ArabesqueBorder({ flip=false }) {
  return (
    <svg width="100%" height="14" style={{ display:"block", opacity:.28, transform: flip?"scaleY(-1)":"none" }}>
      <defs>
        <pattern id={flip?"ab2":"ab1"} x="0" y="0" width="28" height="14" patternUnits="userSpaceOnUse">
          <path d="M0,7 L7,0 L14,7 L7,14 Z" fill="none" stroke={P.gold} strokeWidth="0.7"/>
          <path d="M14,7 L21,0 L28,7 L21,14 Z" fill="none" stroke={P.gold} strokeWidth="0.7"/>
          <circle cx="14" cy="7" r="1.2" fill={P.gold} opacity="0.5"/>
        </pattern>
      </defs>
      <rect width="100%" height="14" fill={`url(#${flip?"ab2":"ab1"})`}/>
    </svg>
  );
}

/** Eight-pointed star ornament */
function OctaStar({ size=32, color=P.goldBd, fill="none" }) {
  const pts = Array.from({length:8},(_,i)=>{
    const a=(i*45-90)*Math.PI/180, r=i%2===0?14:8;
    return `${16+r*Math.cos(a)},${16+r*Math.sin(a)}`;
  }).join(" ");
  return (
    <svg width={size} height={size} viewBox="0 0 32 32" style={{ display:"block", flexShrink:0 }}>
      <polygon points={pts} fill={fill} stroke={color} strokeWidth="0.8"/>
      <circle cx="16" cy="16" r="3" fill={color} opacity="0.6"/>
    </svg>
  );
}

/** Section divider */
function HolyDivider() {
  return (
    <div style={{ display:"flex", alignItems:"center", gap:9, padding:"3px 0", opacity:.35 }}>
      <div style={{ flex:1, height:"1px", background:`linear-gradient(to right,transparent,${P.gold})` }}/>
      <OctaStar size={18} color={P.gold}/>
      <div style={{ flex:1, height:"1px", background:`linear-gradient(to left,transparent,${P.gold})` }}/>
    </div>
  );
}

/** Twinkling star field */
function Starfield({ count=28 }) {
  const stars = useRef(Array.from({length:count},(_,i)=>({
    x:(i*137.5)%100, y:(i*73.1)%70,
    r:0.35+(i%4)*0.35, d:(i*0.31)%5, dur:1.8+(i%4)*0.7,
  })));
  return (
    <svg style={{ position:"absolute",inset:0,width:"100%",height:"100%",pointerEvents:"none" }}
         preserveAspectRatio="xMidYMid slice">
      {stars.current.map((s,i)=>(
        <circle key={i} cx={`${s.x}%`} cy={`${s.y}%`} r={s.r}
          fill={P.goldPale} opacity={0.15}
          style={{ animation:`starBlink ${s.dur}s ${s.d}s ease-in-out infinite` }}/>
      ))}
      {/* One slow shooting star */}
      <line x1="85%" y1="8%" x2="85%" y2="8%" stroke={P.goldPale} strokeWidth="0.8" opacity="0.5"
            style={{ transformOrigin:"85% 8%", animation:"shootStar 8s 3s ease-out infinite" }}/>
    </svg>
  );
}

/** Hanging lantern */
function Lantern({ x="10%", delay=0, size=1 }) {
  return (
    <div style={{ position:"absolute", top:0, left:x, pointerEvents:"none",
                  animation:`lanternSway ${3+delay}s ${delay}s ease-in-out infinite`, transformOrigin:"top center" }}>
      {/* Cord */}
      <div style={{ width:1, height:28*size, background:`linear-gradient(to bottom,${P.goldBd},transparent)`, margin:"0 auto" }}/>
      {/* Body */}
      <div style={{ width:14*size, height:22*size, borderRadius:`${4*size}px`, marginLeft:-6*size,
                    background:`linear-gradient(160deg,#3D2C10,#1C1208)`,
                    border:`1px solid ${P.brass}`,
                    position:"relative", overflow:"hidden" }}>
        {/* Inner glow */}
        <div style={{ position:"absolute", inset:0, borderRadius:`${4*size}px`,
                      background:`radial-gradient(circle at 50% 60%,rgba(255,200,80,.35),transparent 70%)`,
                      animation:`lanternGlow ${2+delay}s ${delay}s ease-in-out infinite` }}/>
        <div style={{ position:"absolute", top:"30%", left:"20%", right:"20%", height:1, background:P.brass, opacity:.5 }}/>
        <div style={{ position:"absolute", top:"60%", left:"20%", right:"20%", height:1, background:P.brass, opacity:.5 }}/>
      </div>
      {/* Bottom drip */}
      <div style={{ width:0, height:0, borderLeft:`${3*size}px solid transparent`, borderRight:`${3*size}px solid transparent`, borderTop:`${5*size}px solid ${P.brass}`, margin:`0 auto`, marginLeft:-0*size }}/>
    </div>
  );
}

/** Screen header with Arabic */
function Header({ title, ar, right }) {
  return (
    <div style={{ padding:"14px 20px 8px" }}>
      <div style={{ display:"flex", justifyContent:"space-between", alignItems:"flex-start" }}>
        <div>
          <div style={{ fontFamily:"'Cinzel',serif", fontSize:18, fontWeight:600, color:P.marble, letterSpacing:.8 }}>{title}</div>
          {ar && <div style={{ fontFamily:"'Amiri',serif", fontSize:13, color:P.goldWarm, marginTop:1 }}>{ar}</div>}
        </div>
        {right}
      </div>
      <div style={{ marginTop:7 }}><HolyDivider/></div>
    </div>
  );
}

/** Verification badge */
function VBadge({ type }) {
  const v = {
    official:  { l:"সরকারি",   bg:"rgba(31,92,58,.25)",  bd:P.domeBd,  c:P.domePale },
    admin:     { l:"যাচাইকৃত", bg:"rgba(232,192,96,.14)", bd:P.goldBd,  c:P.goldWarm },
    community: { l:"কমিউনিটি", bg:"rgba(26,60,100,.25)",  bd:"rgba(80,140,220,.4)", c:"#7AB4F0" },
  }[type]||{};
  return <span style={{ fontSize:9.5, fontFamily:"'Noto Sans Bengali',sans-serif", fontWeight:600, padding:"2px 8px", borderRadius:20, background:v.bg, border:`1px solid ${v.bd}`, color:v.c }}>{v.l}</span>;
}

/* ══════════════════════════════════════════════════════════════════════════
   SALAH SCREEN
══════════════════════════════════════════════════════════════════════════ */
function SalahScreen() {
  const [tick, setTick] = useState(0);
  useEffect(()=>{ const t=setInterval(()=>setTick(x=>x+1),1000); return()=>clearInterval(t); },[]);
  const total=47*60+12, rem=total-(tick%total);
  const hh=String(Math.floor(rem/3600)).padStart(2,"0");
  const mm=String(Math.floor((rem%3600)/60)).padStart(2,"0");
  const ss=String(rem%60).padStart(2,"0");

  return (
    <div style={{ fontFamily:"'Noto Sans Bengali',sans-serif" }}>

      {/* ── Hero: Haram courtyard at night ── */}
      <div style={{
        position:"relative", overflow:"hidden",
        background:`linear-gradient(175deg, #0F0B18 0%, #0A0810 45%, ${P.sky2} 100%)`,
        paddingBottom:28,
      }}>
        <Starfield count={38}/>

        {/* Mosque silhouette watermark */}
        <div style={{ position:"absolute", bottom:-2, left:"50%", transform:"translateX(-50%)" }}>
          <MosqueSilhouette width={380} opacity={0.08} color={P.goldPale}/>
        </div>

        {/* Hanging lanterns */}
        <Lantern x="8%"  delay={0}   size={0.9}/>
        <Lantern x="88%" delay={1.2} size={0.8}/>
        <Lantern x="48%" delay={0.6} size={1.1}/>

        <div style={{ position:"relative", zIndex:2, padding:"28px 22px 0" }}>

          {/* Date & moon row */}
          <div style={{ display:"flex", justifyContent:"space-between", alignItems:"center", marginBottom:20 }}>
            <div>
              <div style={{ fontFamily:"'Cinzel',serif", fontSize:11, color:P.goldWarm, letterSpacing:2.5, textTransform:"uppercase" }}>ঢাকা, বাংলাদেশ</div>
              <div style={{ fontFamily:"'Amiri',serif", fontSize:13, color:P.sandMid, marginTop:3 }}>٦ رمضان ١٤٤٦ هـ • ৬ মার্চ ২০২৫</div>
            </div>
            <div style={{ position:"relative" }}>
              <div style={{
                width:44, height:44, borderRadius:"50%",
                background:`radial-gradient(circle at 38% 36%, #E8D8A0, ${P.gold} 55%, #5C3D08)`,
                animation:"goldPulse 4s ease-in-out infinite",
                display:"flex", alignItems:"center", justifyContent:"center",
              }}>
                <StarCrescent size={22} color={P.sky0}/>
              </div>
            </div>
          </div>

          {/* ── Tawaf countdown card ── */}
          <div style={{
            background:`linear-gradient(140deg, rgba(31,92,58,.24) 0%, rgba(18,14,22,.9) 100%)`,
            border:`1px solid ${P.domeBd}`,
            borderRadius:24, padding:"22px 20px 20px",
            position:"relative", overflow:"hidden",
          }}>
            {/* Rotating tawaf rings */}
            <div style={{ position:"absolute", right:-30, top:"50%", transform:"translateY(-50%)", pointerEvents:"none" }}>
              {[80,64,48].map((r,i)=>(
                <div key={r} style={{
                  position:"absolute", top:"50%", left:"50%",
                  width:r, height:r, marginLeft:-r/2, marginTop:-r/2,
                  borderRadius:"50%",
                  border:`1px solid rgba(45,138,86,${0.15+i*.07})`,
                  animation:`${i%2===0?"tawafRing":"tawafRingRev"} ${18+i*6}s linear infinite`,
                }}/>
              ))}
              <div style={{ position:"absolute", top:"50%", left:"50%", transform:"translate(-50%,-50%)" }}>
                <KaabaIcon size={28} glow/>
              </div>
            </div>

            {/* Corner ornaments */}
            <OctaStar size={18} color={`rgba(45,138,86,.35)`} style={{ position:"absolute", top:9, left:9 }}/>
            <OctaStar size={18} color={`rgba(45,138,86,.35)`} style={{ position:"absolute", top:9, right:9 }}/>

            <div style={{ textAlign:"center", position:"relative", zIndex:1 }}>
              <div style={{ fontFamily:"'Amiri',serif", fontSize:13, color:P.domePale, letterSpacing:1.5, marginBottom:5 }}>পরবর্তী নামাজ • العصر</div>
              <div style={{
                fontFamily:"'Cinzel',serif", fontSize:46, fontWeight:700,
                color:P.marble, letterSpacing:7, lineHeight:1,
                animation:"countBlink 1s ease-in-out infinite",
                textShadow:`0 0 30px rgba(232,192,96,.2)`,
              }}>
                {hh}:{mm}:{ss}
              </div>
              <div style={{ fontFamily:"'Noto Serif Bengali',serif", fontSize:17, color:P.goldWarm, marginTop:8, fontWeight:600 }}>আসর • ১৫:৪৮</div>
              <div style={{ fontFamily:"'Noto Sans Bengali',sans-serif", fontSize:12, color:P.sandMid, marginTop:3 }}>জামাত: ১৬:০০ • বায়তুল মুকাররম জাতীয় মসজিদ</div>
            </div>
          </div>

        </div>
      </div>

      <ArabesqueBorder/>

      {/* ── Prayer list ── */}
      <div style={{ background:P.sky1, padding:"12px 16px 4px" }}>
        {/* Bismillah */}
        <div style={{ textAlign:"center", fontFamily:"'Amiri',serif", fontSize:20, color:P.goldBd, letterSpacing:3, marginBottom:12 }}>﷽</div>

        {PRAYERS.map((p,i)=>(
          <div key={p.key} style={{
            display:"flex", alignItems:"center", gap:14,
            padding:"13px 16px", marginBottom:7, borderRadius:16,
            background: p.next
              ? `linear-gradient(120deg, rgba(31,92,58,.22), rgba(18,14,22,.95))`
              : p.done ? "rgba(255,255,255,.015)" : `rgba(255,255,255,.025)`,
            border:`1px solid ${p.next ? P.domeBd : p.done ? "rgba(255,255,255,.04)" : "rgba(255,255,255,.06)"}`,
            opacity: p.done ? .5 : 1,
            position:"relative", overflow:"hidden",
            animation:`fadeUp .4s ${i*.08}s both ease`,
            transition:"border-color .2s",
          }}>
            {/* Next prayer accent bar */}
            {p.next && (
              <div style={{ position:"absolute", left:0, top:0, bottom:0, width:3,
                background:`linear-gradient(to bottom, ${P.domePale}, ${P.goldWarm})`,
                borderRadius:"3px 0 0 3px" }}/>
            )}
            {/* Marble shimmer on next */}
            {p.next && (
              <div style={{ position:"absolute", inset:0, opacity:.03,
                background:`linear-gradient(105deg, transparent 40%, rgba(255,255,255,.8) 50%, transparent 60%)`,
                backgroundSize:"200% 100%", animation:"marbleShimmer 4s ease-in-out infinite" }}/>
            )}

            {/* Arabic name */}
            <div style={{ width:40, textAlign:"center", flexShrink:0 }}>
              <div style={{ fontFamily:"'Amiri',serif", fontSize:22, color:p.next?P.goldWarm:P.sandMid, lineHeight:1 }}>{p.ar}</div>
            </div>

            <div style={{ flex:1 }}>
              <div style={{ display:"flex", alignItems:"center", gap:7, flexWrap:"wrap" }}>
                <span style={{ fontFamily:"'Noto Serif Bengali',serif", fontSize:15, fontWeight:600, color:p.next?P.marble:P.sand }}>{p.bn}</span>
                {p.next && (
                  <span style={{ fontSize:9, background:P.domeGlow, border:`1px solid ${P.domeBd}`,
                    color:P.domePale, padding:"1px 7px", borderRadius:8,
                    fontFamily:"'Cinzel',serif", letterSpacing:1 }}>NEXT</span>
                )}
                {p.done && <span style={{ color:P.sandDeep, fontSize:13 }}>✓</span>}
              </div>
              <div style={{ fontFamily:"'Noto Sans Bengali',sans-serif", fontSize:11, color:P.sandDeep, marginTop:2 }}>জামাত {p.jamat}</div>
            </div>

            <div style={{ textAlign:"right" }}>
              <div style={{ fontFamily:"'Cinzel',serif", fontSize:17, fontWeight:600,
                color:p.next?P.goldWarm:P.sandMid, letterSpacing:1.5 }}>{p.time}</div>
            </div>
          </div>
        ))}
      </div>

      {/* IFB footer note */}
      <div style={{ margin:"4px 16px 16px", padding:"11px 15px", borderRadius:13,
        background:`rgba(31,92,58,.08)`, border:`1px solid ${P.domeBd}`,
        display:"flex", gap:11, alignItems:"center" }}>
        <div style={{ flexShrink:0 }}><KaabaIcon size={24}/></div>
        <div style={{ fontFamily:"'Noto Sans Bengali',sans-serif", fontSize:11, color:P.sandMid, lineHeight:1.55 }}>
          ইসলামিক ফাউন্ডেশন বাংলাদেশ (IFB) ও বায়তুল মুকাররম মসজিদ অনুযায়ী সময় গণনা। ফজর ১৯.৫°, ইশা ১৭.৫°
        </div>
      </div>
    </div>
  );
}

/* ══════════════════════════════════════════════════════════════════════════
   QIBLA SCREEN
══════════════════════════════════════════════════════════════════════════ */
function QiblaScreen() {
  const [angle, setAngle] = useState(60);
  const [aligned, setAligned] = useState(false);
  const QIBLA = 281;
  useEffect(()=>{
    let cur=60;
    const t=setInterval(()=>{
      cur += (QIBLA-cur)*0.032;
      setAngle(cur);
      setAligned(Math.abs(cur-QIBLA)<3);
    },16);
    return ()=>clearInterval(t);
  },[]);

  return (
    <div style={{ fontFamily:"'Noto Sans Bengali',sans-serif", minHeight:"100%" }}>
      <Header title="কিবলা দিকনির্দেশনা" ar="اتجاه القبلة"/>

      <div style={{ position:"relative", display:"flex", flexDirection:"column", alignItems:"center", padding:"12px 0 22px", overflow:"hidden" }}>
        <Starfield count={18}/>

        {/* ── Compass ── */}
        <div style={{ position:"relative", width:280, height:280 }}>

          {/* Outer decorative rings */}
          {[0,14,26].map((pad,i)=>(
            <div key={pad} style={{
              position:"absolute", inset:pad, borderRadius:"50%",
              border:`1px solid rgba(212,168,64,${0.22-i*.06})`,
            }}/>
          ))}

          {/* Cardinal labels */}
          {[
            {l:"N", deg:-90}, {l:"S", deg:90}, {l:"E", deg:0}, {l:"W", deg:180},
          ].map(({l,deg})=>{
            const r=(deg*Math.PI/180), radius=134;
            return (
              <div key={l} style={{
                position:"absolute",
                top:`calc(50% + ${Math.sin(r)*radius}px)`,
                left:`calc(50% + ${Math.cos(r)*radius}px)`,
                transform:"translate(-50%,-50%)",
                fontFamily:"'Cinzel',serif", fontSize:11, fontWeight:600,
                color: l==="N" ? P.goldWarm : P.sandDeep,
                letterSpacing:1,
              }}>{l}</div>
            );
          })}

          {/* Tick marks */}
          <svg style={{ position:"absolute", inset:0, width:"100%", height:"100%", pointerEvents:"none" }}>
            {Array.from({length:72},(_,i)=>{
              const a=(i*5-90)*Math.PI/180, r1=126, r2=i%18===0?112:i%6===0?117:120;
              return (
                <line key={i}
                  x1={140+r1*Math.cos(a)} y1={140+r1*Math.sin(a)}
                  x2={140+r2*Math.cos(a)} y2={140+r2*Math.sin(a)}
                  stroke={P.gold} strokeWidth={i%18===0?"1.2":i%6===0?"0.8":"0.4"}
                  opacity={i%18===0?0.5:0.2}/>
              );
            })}
          </svg>

          {/* Main compass disc — marble-like */}
          <div style={{
            position:"absolute", inset:28, borderRadius:"50%",
            background:`radial-gradient(circle at 35% 30%, #2A2218 0%, #16110C 50%, #0C0906 100%)`,
            border:`1px solid ${aligned?P.domeBd:P.goldBd}`,
            boxShadow:`
              inset 0 0 40px rgba(0,0,0,.7),
              0 0 ${aligned?"40px":"16px"} ${aligned?"rgba(45,138,86,.4)":P.goldGlow}
            `,
            transition:"box-shadow .5s, border-color .5s",
            overflow:"hidden",
          }}>
            <Starfield count={6}/>

            {/* Kaaba center */}
            <div style={{ position:"absolute", inset:0, display:"flex", alignItems:"center", justifyContent:"center", flexDirection:"column", gap:3 }}>
              <div style={{ animation:"floatUp 3s ease-in-out infinite" }}>
                <KaabaIcon size={36} glow={aligned}/>
              </div>
              <div style={{ fontFamily:"'Amiri',serif", fontSize:10, color:P.goldWarm }}>الكعبة المشرفة</div>
            </div>
          </div>

          {/* Needle */}
          <div style={{ position:"absolute", inset:0, display:"flex", alignItems:"center", justifyContent:"center", pointerEvents:"none" }}>
            <div style={{
              width:5, height:124,
              position:"absolute", transformOrigin:"50% 100%", bottom:"50%",
              transform:`rotate(${angle}deg)`,
              transition:"transform .06s linear",
            }}>
              {/* Tip */}
              <svg width="10" height="34" style={{ position:"absolute", top:0, left:-2.5 }}>
                <polygon points="5,0 10,34 5,28 0,34"
                  fill={aligned?P.domePale:P.goldWarm}
                  style={{ filter:`drop-shadow(0 0 5px ${aligned?"rgba(61,173,107,.9)":P.goldGlow})`, transition:"fill .3s" }}/>
              </svg>
              {/* Shaft */}
              <div style={{ position:"absolute", top:34, left:"50%", transform:"translateX(-50%)", width:2,
                background:`linear-gradient(to bottom, ${aligned?P.domePale:P.goldWarm}, transparent)`,
                height:"calc(100% - 34px)" }}/>
            </div>
          </div>
        </div>

        {/* Status card */}
        <div style={{
          marginTop:18, padding:"12px 26px", borderRadius:16,
          background: aligned ? "rgba(31,92,58,.22)" : "rgba(212,168,64,.09)",
          border:`1px solid ${aligned?P.domeBd:P.goldBd}`,
          textAlign:"center", transition:"all .4s",
        }}>
          <div style={{ fontFamily:"'Amiri',serif", fontSize:18, color:aligned?P.domePale:P.goldWarm }}>
            {aligned ? "قبلة صحيحة ✦ কিবলা সঠিক দিকে" : "اتجاه مكة المكرمة — مكة"}
          </div>
          <div style={{ fontFamily:"'Cinzel',serif", fontSize:11.5, color:P.sandMid, marginTop:3, letterSpacing:1 }}>
            {aligned ? "QIBLA ALIGNED • FACE THE KAABA" : `${Math.round(angle)}° current  •  Qibla: ${QIBLA}° NW`}
          </div>
        </div>

        {/* Info row */}
        <div style={{ display:"flex", gap:10, marginTop:16, padding:"0 18px", width:"100%" }}>
          {[
            ["📍","আপনার অবস্থান","23.7279°N 90.417°E"],
            ["🕋","কাবা শরীফ","21.4225°N 39.826°E"],
            ["🧲","চুম্বকীয় পার্থক্য","~0.5° পশ্চিম"],
          ].map(([ic,t,v])=>(
            <div key={t} style={{ flex:1, background:P.sky3, border:`1px solid ${P.goldBd}`, borderRadius:12, padding:"9px 7px", textAlign:"center" }}>
              <div style={{ fontSize:14, marginBottom:3 }}>{ic}</div>
              <div style={{ fontFamily:"'Noto Sans Bengali',sans-serif", fontSize:9, color:P.sandMid, marginBottom:1.5 }}>{t}</div>
              <div style={{ fontFamily:"'Cinzel',serif", fontSize:8.5, color:P.sand, letterSpacing:.3 }}>{v}</div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

/* ══════════════════════════════════════════════════════════════════════════
   MOSQUE SCREEN
══════════════════════════════════════════════════════════════════════════ */
function MosqueScreen() {
  const [sel, setSel] = useState(null);
  return (
    <div style={{ fontFamily:"'Noto Sans Bengali',sans-serif", minHeight:"100%" }}>
      <Header title="নিকটতম মসজিদ" ar="المساجد القريبة"/>

      {/* Map placeholder */}
      <div style={{ margin:"0 16px 14px", height:158, borderRadius:18,
        background:`linear-gradient(135deg, ${P.sky3}, #1A140A)`,
        border:`1px solid ${P.goldBd}`, position:"relative", overflow:"hidden" }}>
        <Starfield count={10}/>
        {/* Grid */}
        {[20,40,60,80].map(x=><div key={x} style={{ position:"absolute",left:`${x}%`,top:0,bottom:0,width:1,background:"rgba(212,168,64,.05)" }}/>)}
        {[30,60].map(y=><div key={y} style={{ position:"absolute",top:`${y}%`,left:0,right:0,height:1,background:"rgba(212,168,64,.05)" }}/>)}
        {/* Mosque pins */}
        {[[48,45],[63,60],[34,67],[71,36]].map(([x,y],i)=>(
          <div key={i} onClick={()=>setSel(i===sel?null:i)} style={{
            position:"absolute", left:`${x}%`, top:`${y}%`,
            transform:"translate(-50%,-100%)", cursor:"pointer",
            filter:sel===i?`drop-shadow(0 0 7px ${P.goldWarm})`:"none",
            transition:"filter .2s",
          }}>
            <div style={{
              width:22, height:22, borderRadius:"50% 50% 50% 0", transform:"rotate(-45deg)",
              background:i===0?P.dome:P.sky4,
              border:`1.5px solid ${i===0?P.domePale:P.goldBd}`,
              display:"flex", alignItems:"center", justifyContent:"center",
            }}>
              <div style={{ transform:"rotate(45deg)", width:10, height:10 }}>
                <svg viewBox="0 0 10 10" width="10" height="10">
                  <ellipse cx="5" cy="3.5" rx="3.5" ry="3.5" fill={i===0?P.domePale:P.goldWarm} opacity="0.8"/>
                  <rect x="1.5" y="3.5" width="7" height="4" rx="0.5" fill={i===0?P.domePale:P.goldWarm} opacity="0.8"/>
                </svg>
              </div>
            </div>
          </div>
        ))}
        {/* User dot */}
        <div style={{ position:"absolute", left:"50%", top:"50%", transform:"translate(-50%,-50%)" }}>
          <div style={{ width:12, height:12, borderRadius:"50%", background:P.goldWarm,
            boxShadow:`0 0 14px ${P.goldGlow}`, border:`2px solid ${P.marble}` }}/>
        </div>
        {/* Radius ring */}
        <div style={{ position:"absolute", left:"50%", top:"50%", transform:"translate(-50%,-50%)",
          width:82, height:82, borderRadius:"50%", border:`1px dashed ${P.goldBd}`, opacity:.35 }}/>
        <div style={{ position:"absolute", bottom:8, right:12, fontFamily:"'Cinzel',serif", fontSize:8.5, color:P.sandDeep, letterSpacing:1 }}>OpenStreetMap • ১ কিমি</div>
      </div>

      {/* List */}
      <div style={{ padding:"0 16px 8px" }}>
        {MOSQUES.map((m,i)=>(
          <div key={m.id} className="tap-card" onClick={()=>setSel(i===sel?null:i)} style={{
            padding:"12px 14px", marginBottom:7, borderRadius:14, cursor:"pointer",
            background:sel===i?`linear-gradient(120deg,rgba(31,92,58,.16),rgba(14,10,20,.98))`:P.sky3,
            border:`1px solid ${sel===i?P.domeBd:P.goldBd}`,
            animation:`fadeUp .35s ${i*.08}s both ease`, transition:"all .2s",
          }}>
            <div style={{ display:"flex", justifyContent:"space-between", alignItems:"flex-start", marginBottom:5 }}>
              <div style={{ flex:1, marginRight:8 }}>
                <div style={{ fontFamily:"'Noto Serif Bengali',serif", fontSize:14, fontWeight:600, color:P.marble, marginBottom:4 }}>{m.name}</div>
                <div style={{ display:"flex", gap:5, flexWrap:"wrap", alignItems:"center" }}>
                  <VBadge type={m.badge}/>
                  {m.tags.map(tg=><span key={tg} style={{ fontSize:9, color:P.sandMid, border:`1px solid ${P.sandDeep}`, borderRadius:7, padding:"1px 5px", fontFamily:"'Noto Sans Bengali',sans-serif" }}>{tg}</span>)}
                </div>
              </div>
              <div style={{ textAlign:"right", flexShrink:0 }}>
                <div style={{ fontFamily:"'Cinzel',serif", fontSize:13, color:P.goldWarm, fontWeight:600 }}>{m.dist}</div>
                <div style={{ fontFamily:"'Noto Sans Bengali',sans-serif", fontSize:10, color:P.sandDeep, marginTop:2 }}>জামাত {m.jamat}</div>
              </div>
            </div>
            {sel===i && (
              <div style={{ animation:"slideUp .22s ease", paddingTop:8, borderTop:`1px solid ${P.goldBd}`, display:"flex", gap:7, marginTop:3 }}>
                {[["🗺️","দিকনির্দেশ"],["📍","পিন করুন"],["✏️","আপডেট"]].map(([ic,lb])=>(
                  <button key={lb} style={{ flex:1, padding:"7px 0", borderRadius:9, cursor:"pointer",
                    background:"rgba(255,255,255,.04)", border:`1px solid ${P.goldBd}`,
                    fontFamily:"'Noto Sans Bengali',sans-serif", fontSize:10.5, color:P.sand,
                    display:"flex", alignItems:"center", justifyContent:"center", gap:4 }}>
                    <span>{ic}</span><span>{lb}</span>
                  </button>
                ))}
              </div>
            )}
          </div>
        ))}
      </div>

      <div style={{ padding:"2px 16px 16px" }}>
        <button style={{ width:"100%", padding:"13px", borderRadius:14, cursor:"pointer",
          background:`linear-gradient(135deg, rgba(31,92,58,.15), rgba(14,10,20,.9))`,
          border:`1px dashed ${P.domeBd}`,
          fontFamily:"'Noto Serif Bengali',serif", fontSize:14, color:P.domePale,
          display:"flex", alignItems:"center", justifyContent:"center", gap:9 }}>
          <span style={{ fontSize:18 }}>+</span>
          <span>নতুন মসজিদ যোগ করুন</span>
        </button>
      </div>
    </div>
  );
}

/* ══════════════════════════════════════════════════════════════════════════
   QURAN SCREEN
══════════════════════════════════════════════════════════════════════════ */
function QuranScreen() {
  const [reading, setReading] = useState(null);

  if (reading !== null) {
    const s = SURAHS[reading];
    const ayahs = [
      { n:1, ar:"الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ",       bn:"সমস্ত প্রশংসা আল্লাহর জন্য, যিনি সমগ্র বিশ্বের পালনকর্তা" },
      { n:2, ar:"الرَّحْمَٰنِ الرَّحِيمِ",                      bn:"যিনি পরম করুণাময়, অসীম দয়ালু" },
      { n:3, ar:"مَالِكِ يَوْمِ الدِّينِ",                       bn:"যিনি বিচার দিনের মালিক" },
      { n:4, ar:"إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ",     bn:"আমরা শুধু তোমারই ইবাদত করি এবং তোমারই সাহায্য চাই" },
      { n:5, ar:"اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ",           bn:"আমাদের সরল পথ দেখাও" },
      { n:6, ar:"صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ",      bn:"তাদের পথ যাদের উপর তুমি নিয়ামত দিয়েছ" },
      { n:7, ar:"غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ", bn:"তাদের পথ নয় যাদের উপর ক্রোধ হয়েছে বা যারা পথভ্রষ্ট" },
    ];
    return (
      <div style={{ fontFamily:"'Noto Sans Bengali',sans-serif", animation:"fadeIn .3s ease" }}>
        <div style={{ padding:"12px 16px 8px", display:"flex", alignItems:"center", gap:10 }}>
          <button onClick={()=>setReading(null)} style={{ background:"rgba(212,168,64,.1)", border:`1px solid ${P.goldBd}`, borderRadius:10, padding:"6px 12px", color:P.goldWarm, cursor:"pointer", fontFamily:"'Cinzel',serif", fontSize:11 }}>← ফিরুন</button>
          <div>
            <div style={{ fontFamily:"'Amiri',serif", fontSize:22, color:P.goldWarm }}>{s.ar}</div>
            <div style={{ fontFamily:"'Noto Serif Bengali',serif", fontSize:11, color:P.sandMid }}>{s.bn} • {s.ay} আয়াত • {s.t}</div>
          </div>
        </div>
        <HolyDivider/>
        {/* Bismillah */}
        <div style={{ textAlign:"center", padding:"16px 16px 10px", position:"relative" }}>
          <div style={{ fontFamily:"'Amiri',serif", fontSize:24, color:P.goldWarm, lineHeight:2.1,
            textShadow:`0 0 20px rgba(232,192,96,.2)` }}>
            بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ
          </div>
          <div style={{ fontFamily:"'Noto Serif Bengali',serif", fontSize:12, color:P.sandMid, marginTop:3 }}>পরম করুণাময় ও অসীম দয়ালু আল্লাহর নামে শুরু করছি</div>
        </div>
        <ArabesqueBorder/>
        {ayahs.map(a=>(
          <div key={a.n} style={{ padding:"13px 18px", borderBottom:`1px solid rgba(255,255,255,.04)` }}>
            <div style={{ fontFamily:"'Amiri',serif", fontSize:22, color:P.marble, direction:"rtl", textAlign:"right", lineHeight:2.2, marginBottom:7 }}>{a.ar}</div>
            <div style={{ display:"flex", alignItems:"flex-start", gap:10 }}>
              <div style={{ width:22, height:22, borderRadius:"50%", background:P.goldGlow, border:`1px solid ${P.goldBd}`, display:"flex", alignItems:"center", justifyContent:"center", fontSize:9.5, color:P.goldWarm, fontFamily:"'Cinzel',serif", flexShrink:0 }}>{a.n}</div>
              <div style={{ fontFamily:"'Noto Serif Bengali',serif", fontSize:13, color:P.sand, lineHeight:1.75 }}>{a.bn}</div>
            </div>
          </div>
        ))}
        <div style={{ height:20 }}/>
      </div>
    );
  }

  return (
    <div style={{ fontFamily:"'Noto Sans Bengali',sans-serif", minHeight:"100%" }}>
      <Header title="আল-কুরআন" ar="القرآن الكريم"/>
      <div style={{ padding:"0 16px 16px" }}>
        {SURAHS.map((s,i)=>(
          <div key={s.n} onClick={()=>setReading(i)} style={{
            display:"flex", alignItems:"center", gap:13,
            padding:"11px 14px", marginBottom:6, borderRadius:14,
            cursor:"pointer", background:P.sky3, border:`1px solid ${P.goldBd}`,
            animation:`fadeUp .3s ${i*.05}s both ease`, transition:"background .2s",
          }}>
            <div style={{ width:36, height:36, flexShrink:0,
              background:`linear-gradient(135deg, rgba(31,92,58,.3), rgba(212,168,64,.14))`,
              border:`1px solid ${P.goldBd}`, borderRadius:10,
              display:"flex", alignItems:"center", justifyContent:"center",
              fontFamily:"'Cinzel',serif", fontSize:11, color:P.goldWarm, fontWeight:600 }}>{s.n}</div>
            <div style={{ flex:1 }}>
              <div style={{ fontFamily:"'Noto Serif Bengali',serif", fontSize:14, fontWeight:600, color:P.marble }}>{s.bn}</div>
              <div style={{ fontFamily:"'Noto Sans Bengali',sans-serif", fontSize:11, color:P.sandMid, marginTop:1 }}>{s.ay} আয়াত • {s.t}</div>
            </div>
            <div style={{ fontFamily:"'Amiri',serif", fontSize:20, color:P.goldWarm }}>{s.ar}</div>
          </div>
        ))}
      </div>
    </div>
  );
}

/* ══════════════════════════════════════════════════════════════════════════
   HADITH SCREEN
══════════════════════════════════════════════════════════════════════════ */
function HadithScreen() {
  return (
    <div style={{ fontFamily:"'Noto Sans Bengali',sans-serif", minHeight:"100%" }}>
      <Header title="দৈনিক হাদিস" ar="الحديث الشريف"/>

      <div style={{ margin:"0 16px 14px", animation:"scaleIn .4s ease" }}>
        <div style={{ borderRadius:20, overflow:"hidden", border:`1px solid ${P.goldBd}`,
          background:`linear-gradient(160deg, #1C1508, ${P.sky2})`, position:"relative" }}>
          <Starfield count={14}/>

          {/* Header stripe — Green Dome green */}
          <div style={{ background:`linear-gradient(90deg, ${P.dome}, #112A1C)`, padding:"12px 18px",
            display:"flex", justifyContent:"space-between", alignItems:"center", position:"relative" }}>
            <ArabesqueBorder/>
            <div style={{ position:"relative", zIndex:1 }}>
              <div style={{ fontFamily:"'Cinzel',serif", fontSize:10, color:"rgba(255,255,255,.5)", letterSpacing:2.5 }}>HADITH OF THE DAY</div>
              <div style={{ fontFamily:"'Noto Serif Bengali',serif", fontSize:13, color:P.marble, fontWeight:600 }}>আজকের হাদিস</div>
            </div>
            <div style={{ fontFamily:"'Amiri',serif", fontSize:32, color:P.goldWarm, opacity:.55, position:"relative", zIndex:1 }}>١</div>
          </div>

          {/* Arabic text */}
          <div style={{ padding:"22px 18px 14px", borderBottom:`1px solid ${P.goldBd}`, position:"relative", zIndex:1 }}>
            <div style={{ fontFamily:"'Amiri',serif", fontSize:22, color:P.marble, direction:"rtl", textAlign:"right", lineHeight:2.2,
              textShadow:`0 0 20px rgba(232,192,96,.1)` }}>{HADITH.ar}</div>
          </div>

          {/* Bangla */}
          <div style={{ padding:"14px 18px", borderBottom:`1px solid rgba(255,255,255,.05)`, position:"relative", zIndex:1 }}>
            <div style={{ fontFamily:"'Noto Serif Bengali',serif", fontSize:14, color:P.sand, lineHeight:1.85 }}>{HADITH.bn}</div>
          </div>

          {/* English */}
          <div style={{ padding:"11px 18px", borderBottom:`1px solid rgba(255,255,255,.05)`, position:"relative", zIndex:1 }}>
            <div style={{ fontFamily:"'Cinzel',serif", fontSize:11.5, color:P.sandMid, fontStyle:"italic", lineHeight:1.7 }}>{HADITH.en}</div>
          </div>

          {/* Source & actions */}
          <div style={{ padding:"12px 18px", display:"flex", justifyContent:"space-between", alignItems:"center", position:"relative", zIndex:1 }}>
            <div style={{ fontFamily:"'Amiri',serif", fontSize:13, color:P.goldWarm }}>{HADITH.src}</div>
            <div style={{ display:"flex", gap:7 }}>
              {["🔖","🔗","📤"].map(ic=>(
                <button key={ic} style={{ width:32, height:32, borderRadius:10, background:"rgba(255,255,255,.05)", border:`1px solid ${P.goldBd}`, cursor:"pointer", fontSize:14 }}>{ic}</button>
              ))}
            </div>
          </div>
        </div>
      </div>

      <HolyDivider/>

      <div style={{ padding:"12px 16px 16px" }}>
        <div style={{ fontFamily:"'Cinzel',serif", fontSize:10.5, color:P.sandDeep, letterSpacing:2, marginBottom:10 }}>RECENT HADITHS</div>
        {[
          { ar:"الصَّلَاةُ عِمَادُ الدِّينِ",                      bn:"নামাজ হলো দ্বীনের স্তম্ভ",                     src:"তিরমিযী ২"      },
          { ar:"طَلَبُ الْعِلْمِ فَرِيضَةٌ عَلَى كُلِّ مُسْلِمٍ", bn:"জ্ঞান অর্জন প্রতিটি মুসলিমের উপর ফরজ",       src:"ইবনে মাজাহ ২২৪" },
          { ar:"خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ", bn:"তোমাদের মধ্যে সেই উত্তম যে কুরআন শেখে ও শেখায়", src:"বুখারী ৫০২৭"     },
        ].map((h,i)=>(
          <div key={i} style={{ padding:"12px 14px", marginBottom:7, borderRadius:13, background:P.sky3, border:`1px solid ${P.goldBd}` }}>
            <div style={{ fontFamily:"'Amiri',serif", fontSize:16, color:P.goldWarm, marginBottom:5, direction:"rtl", textAlign:"right", lineHeight:1.9 }}>{h.ar}</div>
            <div style={{ fontFamily:"'Noto Serif Bengali',serif", fontSize:12.5, color:P.sand, marginBottom:4 }}>{h.bn}</div>
            <div style={{ fontFamily:"'Cinzel',serif", fontSize:9.5, color:P.sandDeep, letterSpacing:.8 }}>{h.src}</div>
          </div>
        ))}
      </div>
    </div>
  );
}

/* ══════════════════════════════════════════════════════════════════════════
   RAMADAN SCREEN
══════════════════════════════════════════════════════════════════════════ */
function RamadanScreen() {
  const [tick, setTick] = useState(0);
  useEffect(()=>{ const t=setInterval(()=>setTick(x=>x+1),1000); return()=>clearInterval(t); },[]);
  const rem=5*3600+58*60-(tick%(6*3600));
  const ih=String(Math.floor(rem/3600)).padStart(2,"0");
  const im=String(Math.floor((rem%3600)/60)).padStart(2,"0");
  const is=String(rem%60).padStart(2,"0");

  return (
    <div style={{ fontFamily:"'Noto Sans Bengali',sans-serif", minHeight:"100%" }}>

      {/* Night hero */}
      <div style={{ position:"relative", overflow:"hidden", background:`linear-gradient(160deg, #120A0D, ${P.sky1})`, paddingBottom:24 }}>
        <Starfield count={30}/>
        <Lantern x="12%" delay={0}   size={0.85}/>
        <Lantern x="80%" delay={1.5} size={0.9}/>
        <div style={{ position:"absolute", bottom:-8, left:"50%", transform:"translateX(-50%)" }}>
          <MosqueSilhouette width={340} opacity={0.06}/>
        </div>

        <div style={{ position:"relative", zIndex:2, padding:"22px 20px 0" }}>
          <div style={{ textAlign:"center", marginBottom:16 }}>
            <div style={{ fontFamily:"'Amiri',serif", fontSize:30, color:P.goldWarm, lineHeight:1.4,
              textShadow:`0 0 30px rgba(232,192,96,.2)` }}>رمضان المبارك</div>
            <div style={{ fontFamily:"'Cinzel',serif", fontSize:11, color:P.sandMid, letterSpacing:4, marginTop:2 }}>RAMADAN MUBARAK ✦ রমজান মুবারক</div>
          </div>

          {/* Iftar countdown */}
          <div style={{ background:`linear-gradient(135deg, rgba(122,30,42,.28), rgba(212,168,64,.12))`,
            border:`1px solid rgba(122,30,42,.5)`, borderRadius:20, padding:"17px 20px",
            textAlign:"center", position:"relative", overflow:"hidden" }}>
            <OctaStar size={19} color="rgba(122,30,42,.5)" style={{ position:"absolute", top:8, left:8 }}/>
            <OctaStar size={19} color="rgba(122,30,42,.5)" style={{ position:"absolute", top:8, right:8 }}/>
            <div style={{ fontFamily:"'Noto Serif Bengali',serif", fontSize:12, color:"#E08888", marginBottom:6 }}>ইফতার পর্যন্ত বাকি সময়</div>
            <div style={{ fontFamily:"'Cinzel',serif", fontSize:42, fontWeight:700, color:P.marble,
              letterSpacing:6, animation:"countBlink 1s ease-in-out infinite",
              textShadow:`0 0 24px rgba(232,192,96,.18)` }}>{ih}:{im}:{is}</div>
            <div style={{ fontFamily:"'Noto Serif Bengali',serif", fontSize:13, color:P.goldWarm, marginTop:5 }}>ইফতার: ১৮:১৫ • সেহরি: ০৪:৪৭</div>
          </div>
        </div>
      </div>

      <ArabesqueBorder/>

      {/* Calendar */}
      <div style={{ padding:"12px 16px 16px", background:P.sky1 }}>
        <div style={{ fontFamily:"'Cinzel',serif", fontSize:10.5, color:P.sandDeep, letterSpacing:2, marginBottom:10 }}>WEEKLY SCHEDULE</div>
        {RAMADAN.map((r,i)=>(
          <div key={r.day} style={{
            display:"flex", alignItems:"center", gap:12,
            padding:"10px 13px", marginBottom:6, borderRadius:12,
            background:r.today?`linear-gradient(120deg,rgba(122,30,42,.2),rgba(14,10,20,.98))`:P.sky3,
            border:`1px solid ${r.today?"rgba(122,30,42,.45)":r.lailat?P.goldBd:"rgba(255,255,255,.06)"}`,
            animation:`fadeUp .3s ${i*.06}s both ease`,
          }}>
            <div style={{ width:32, height:32, borderRadius:9, flexShrink:0,
              background:r.lailat?`linear-gradient(135deg, ${P.gold}, #6A4010)`:r.today?"rgba(122,30,42,.3)":"rgba(255,255,255,.04)",
              border:`1px solid ${r.lailat?P.gold:r.today?"rgba(122,30,42,.5)":P.sandDeep}`,
              display:"flex", alignItems:"center", justifyContent:"center",
              fontFamily:"'Cinzel',serif", fontSize:12, color:r.lailat?P.sky0:P.sand, fontWeight:700 }}>{r.day}</div>
            <div style={{ flex:1 }}>
              <div style={{ display:"flex", alignItems:"center", gap:6, flexWrap:"wrap" }}>
                <span style={{ fontFamily:"'Noto Serif Bengali',serif", fontSize:13, fontWeight:600, color:r.today?P.marble:P.sand }}>{r.date}</span>
                {r.today && <span style={{ fontSize:8.5, background:"rgba(122,30,42,.25)", border:"1px solid rgba(122,30,42,.5)", color:"#E09898", padding:"1px 6px", borderRadius:7, fontFamily:"'Cinzel',serif" }}>TODAY</span>}
                {r.lailat && <span style={{ fontSize:8.5, background:P.goldGlow, border:`1px solid ${P.goldBd}`, color:P.goldWarm, padding:"1px 6px", borderRadius:7, fontFamily:"'Cinzel',serif", letterSpacing:.5 }}>লাইলাতুল কদর ✦</span>}
              </div>
              <div style={{ fontFamily:"'Noto Sans Bengali',sans-serif", fontSize:11, color:P.sandDeep, marginTop:1.5 }}>সেহরি {r.sehri}</div>
            </div>
            <div style={{ textAlign:"right" }}>
              <div style={{ fontFamily:"'Cinzel',serif", fontSize:13, color:P.goldWarm, fontWeight:600 }}>{r.iftar}</div>
              <div style={{ fontFamily:"'Noto Sans Bengali',sans-serif", fontSize:9.5, color:P.sandDeep, marginTop:1 }}>ইফতার</div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

/* ══════════════════════════════════════════════════════════════════════════
   CONTRIBUTE SCREEN
══════════════════════════════════════════════════════════════════════════ */
function ContributeScreen() {
  const [loggedIn, setLoggedIn] = useState(false);
  return (
    <div style={{ fontFamily:"'Noto Sans Bengali',sans-serif", minHeight:"100%" }}>
      <Header title="কমিউনিটি অবদান" ar="إسهام المجتمع"/>

      {!loggedIn && (
        <div style={{ margin:"0 16px 14px", padding:"16px", borderRadius:16,
          background:`linear-gradient(135deg, rgba(31,92,58,.13), rgba(14,10,20,.9))`,
          border:`1px solid ${P.domeBd}`, textAlign:"center", animation:"fadeUp .4s ease" }}>
          <div style={{ marginBottom:8, display:"flex", justifyContent:"center" }}><OctaStar size={36} color={P.domeBd} fill={`rgba(31,92,58,.15)`}/></div>
          <div style={{ fontFamily:"'Noto Serif Bengali',serif", fontSize:14, fontWeight:600, color:P.marble, marginBottom:4 }}>অবদান রাখতে লগইন করুন</div>
          <div style={{ fontFamily:"'Noto Sans Bengali',sans-serif", fontSize:12, color:P.sandMid, marginBottom:14, lineHeight:1.6 }}>মসজিদ যোগ করুন, অবস্থান সংশোধন করুন বা জামাত সময় আপডেট করুন</div>
          <div style={{ display:"flex", gap:9 }}>
            <button onClick={()=>setLoggedIn(true)} style={{ flex:1, padding:"11px", borderRadius:11, cursor:"pointer",
              background:`linear-gradient(135deg, ${P.dome}, #0E2A1A)`, border:"none",
              fontFamily:"'Noto Serif Bengali',serif", fontSize:13, color:P.marble, fontWeight:600 }}>লগইন করুন</button>
            <button style={{ flex:1, padding:"11px", borderRadius:11, cursor:"pointer",
              background:"transparent", border:`1px solid ${P.goldBd}`,
              fontFamily:"'Noto Serif Bengali',serif", fontSize:13, color:P.goldWarm }}>নিবন্ধন করুন</button>
          </div>
        </div>
      )}

      {[
        { ic:"🕌", t:"নতুন মসজিদ যোগ করুন",     s:"মানচিত্রে পিন দিন, সময় যোগ করুন",   c:P.dome },
        { ic:"📍", t:"মসজিদের অবস্থান সংশোধন",  s:"ভুল লোকেশন ঠিক করুন",              c:P.gold },
        { ic:"🕐", t:"জামাত সময় আপডেট করুন",    s:"পরিবর্তিত সময় সাবমিট করুন",       c:"#3A7AAF" },
      ].map((opt,i)=>(
        <div key={opt.t} style={{ margin:`0 16px ${i<2?"10px":"14px"}`, padding:"13px 15px", borderRadius:15,
          background:P.sky3, border:`1px solid ${P.goldBd}`, display:"flex", alignItems:"center", gap:13, cursor:"pointer",
          animation:`fadeUp .35s ${i*.1}s both ease`, transition:"border-color .2s" }}>
          <div style={{ width:44, height:44, borderRadius:13, flexShrink:0,
            background:`rgba(${opt.c===P.dome?"31,92,58":opt.c===P.gold?"212,168,64":"58,122,175"},.14)`,
            border:`1px solid ${opt.c===P.dome?P.domeBd:opt.c===P.gold?P.goldBd:"rgba(58,122,175,.38)"}`,
            display:"flex", alignItems:"center", justifyContent:"center", fontSize:22 }}>{opt.ic}</div>
          <div style={{ flex:1 }}>
            <div style={{ fontFamily:"'Noto Serif Bengali',serif", fontSize:14, fontWeight:600, color:P.marble, marginBottom:2 }}>{opt.t}</div>
            <div style={{ fontFamily:"'Noto Sans Bengali',sans-serif", fontSize:11, color:P.sandMid }}>{opt.s}</div>
          </div>
          <span style={{ color:P.sandDeep, fontSize:16 }}>›</span>
        </div>
      ))}

      <div style={{ padding:"6px 16px 16px" }}>
        <div style={{ fontFamily:"'Cinzel',serif", fontSize:10.5, color:P.sandDeep, letterSpacing:2, marginBottom:9 }}>MY SUBMISSIONS</div>
        {[
          { m:"বায়তুল মুকাররম", ty:"জামাত সময়",   st:"pending",  sbn:"পর্যালোচনাধীন" },
          { m:"গুলশান আজাদ",    ty:"নতুন মসজিদ", st:"approved", sbn:"✓ অনুমোদিত"   },
        ].map((s,i)=>(
          <div key={i} style={{ padding:"10px 13px", marginBottom:7, borderRadius:12, background:P.sky3,
            border:`1px solid ${s.st==="approved"?P.domeBd:P.goldBd}`,
            display:"flex", justifyContent:"space-between", alignItems:"center" }}>
            <div>
              <div style={{ fontFamily:"'Noto Serif Bengali',serif", fontSize:13, fontWeight:600, color:P.marble }}>{s.m}</div>
              <div style={{ fontFamily:"'Noto Sans Bengali',sans-serif", fontSize:10.5, color:P.sandMid, marginTop:2 }}>{s.ty}</div>
            </div>
            <span style={{ fontSize:10, fontFamily:"'Noto Sans Bengali',sans-serif", fontWeight:700,
              padding:"3px 10px", borderRadius:10,
              background:s.st==="approved"?"rgba(31,92,58,.2)":P.goldGlow,
              border:`1px solid ${s.st==="approved"?P.domeBd:P.goldBd}`,
              color:s.st==="approved"?P.domePale:P.goldWarm }}>{s.sbn}</span>
          </div>
        ))}
      </div>
    </div>
  );
}

/* ══════════════════════════════════════════════════════════════════════════
   MORE SCREEN
══════════════════════════════════════════════════════════════════════════ */
function MoreScreen({ onNav }) {
  const items = [
    { ic:"🌙", t:"রমজান ক্যালেন্ডার",  s:"সেহরি ও ইফতারের সময়সূচি",  a:()=>onNav("ramadan")    },
    { ic:"📿", t:"দৈনিক হাদিস",         s:"আরবি, বাংলা ও ইংরেজি",     a:()=>onNav("hadith")     },
    { ic:"🔔", t:"আযান নোটিফিকেশন",    s:"প্রতি ওয়াক্তের অ্যালার্ট", a:null                    },
    { ic:"➕", t:"কমিউনিটি অবদান",     s:"মসজিদ যোগ বা আপডেট করুন",  a:()=>onNav("contribute") },
    { ic:"⚙️", t:"সেটিংস",             s:"ভাষা, গণনা পদ্ধতি, থিম",    a:null                    },
    { ic:"ℹ️", t:"অ্যাপ সম্পর্কে",     s:"Muazzin v1.0 • IFB Standard",a:null                    },
  ];
  return (
    <div style={{ fontFamily:"'Noto Sans Bengali',sans-serif", minHeight:"100%" }}>
      <Header title="আরো" ar="المزيد"/>

      {/* Identity card */}
      <div style={{ textAlign:"center", padding:"14px 20px 20px", position:"relative" }}>
        <div style={{ position:"relative", display:"inline-block", marginBottom:12 }}>
          {/* Outer glow ring */}
          <div style={{ width:80, height:80, borderRadius:24, position:"relative",
            background:`linear-gradient(135deg, ${P.dome}, #0C2218)`,
            border:`2px solid ${P.domeBd}`,
            boxShadow:`0 0 36px ${P.domeGlow}, 0 0 60px rgba(31,92,58,.12)`,
            display:"flex", alignItems:"center", justifyContent:"center",
            animation:"domePulse 4s ease-in-out infinite",
            margin:"0 auto",
          }}>
            <div style={{ width:56, height:56, display:"flex", alignItems:"center", justifyContent:"center" }}>
              <MosqueSilhouette width={56} opacity={0.7} color={P.goldPale}/>
            </div>
          </div>
        </div>

        <div style={{ fontFamily:"'Cinzel Decorative',serif", fontSize:19, fontWeight:700, color:P.goldWarm, letterSpacing:3, marginBottom:3 }}>MUAZZIN</div>
        <div style={{ fontFamily:"'Amiri',serif", fontSize:15, color:P.sandMid, marginBottom:2 }}>المؤذن • কিবলা · সালাহ · কুরআন</div>
        <div style={{ fontFamily:"'Cinzel',serif", fontSize:9, color:P.sandDeep, letterSpacing:2.5, textTransform:"uppercase" }}>Bangladesh Islamic Foundation Standard</div>
      </div>

      <ArabesqueBorder/>

      <div style={{ padding:"12px 16px 20px" }}>
        {items.map((item,i)=>(
          <div key={item.t} onClick={item.a||undefined} style={{
            display:"flex", alignItems:"center", gap:13, padding:"12px 14px", marginBottom:7,
            borderRadius:13, cursor:item.a?"pointer":"default",
            background:P.sky3, border:`1px solid ${P.goldBd}`,
            animation:`fadeUp .3s ${i*.07}s both ease`, transition:"border-color .2s",
          }}>
            <div style={{ width:40, height:40, borderRadius:12, background:"rgba(212,168,64,.07)", border:`1px solid ${P.goldBd}`, display:"flex", alignItems:"center", justifyContent:"center", fontSize:19 }}>{item.ic}</div>
            <div style={{ flex:1 }}>
              <div style={{ fontFamily:"'Noto Serif Bengali',serif", fontSize:14, fontWeight:600, color:P.marble }}>{item.t}</div>
              <div style={{ fontFamily:"'Noto Sans Bengali',sans-serif", fontSize:11, color:P.sandMid, marginTop:1 }}>{item.s}</div>
            </div>
            {item.a && <span style={{ color:P.sandDeep, fontSize:16 }}>›</span>}
          </div>
        ))}
      </div>

      {/* Footer ayah */}
      <div style={{ padding:"0 20px 20px", textAlign:"center", opacity:.45 }}>
        <HolyDivider/>
        <div style={{ fontFamily:"'Amiri',serif", fontSize:14, color:P.sandMid, marginTop:10, lineHeight:1.9 }}>وَأَقِيمُوا الصَّلَاةَ وَآتُوا الزَّكَاةَ</div>
        <div style={{ fontFamily:"'Noto Serif Bengali',serif", fontSize:11, color:P.sandDeep, marginTop:3 }}>নামাজ কায়েম কর এবং যাকাত আদায় কর — সূরা বাকারাহ ২:৪৩</div>
      </div>
    </div>
  );
}

/* ══════════════════════════════════════════════════════════════════════════
   BOTTOM NAV
══════════════════════════════════════════════════════════════════════════ */
function BottomNav({ active, onNav }) {
  const tabs = [
    { id:"salah",  ar:"الصلاة", bn:"নামাজ", ic:"🕐" },
    { id:"qibla",  ar:"القبلة", bn:"কিবলা", ic:"🧭" },
    { id:"mosque", ar:"المسجد", bn:"মসজিদ", ic:"🕌" },
    { id:"quran",  ar:"القرآن", bn:"কুরআন", ic:"📖" },
    { id:"more",   ar:"المزيد", bn:"আরো",   ic:"⋯"  },
  ];
  return (
    <div style={{
      position:"sticky", bottom:0, zIndex:30,
      background:`linear-gradient(to top, ${P.sky0} 65%, transparent)`,
      backdropFilter:"blur(20px) saturate(1.4)",
      paddingBottom:18, paddingTop:6, paddingLeft:4, paddingRight:4,
      borderTop:`1px solid rgba(212,168,64,.1)`,
      display:"flex", justifyContent:"space-around",
    }}>
      {tabs.map(tab=>{
        const a = active===tab.id;
        return (
          <button key={tab.id} onClick={()=>onNav(tab.id)} style={{
            display:"flex", flexDirection:"column", alignItems:"center", gap:1,
            background:a?`rgba(31,92,58,.2)`:"none", border:"none", cursor:"pointer",
            padding:"6px 10px", borderRadius:13,
            borderBottom:`2px solid ${a?P.domePale:"transparent"}`,
            transition:"all .2s",
          }}>
            <span style={{ fontSize:18, lineHeight:1,
              filter:a?`drop-shadow(0 0 5px ${P.domeGlow})`:"none", transition:"filter .2s" }}>{tab.ic}</span>
            <span style={{ fontFamily:"'Noto Sans Bengali',sans-serif", fontSize:9,
              fontWeight:a?700:400, color:a?P.domePale:P.sandDeep, marginTop:2 }}>{tab.bn}</span>
          </button>
        );
      })}
    </div>
  );
}

/* ══════════════════════════════════════════════════════════════════════════
   PHONE SHELL
══════════════════════════════════════════════════════════════════════════ */
function PhoneShell({ children, screen }) {
  return (
    <div style={{
      width:388, height:834,
      background:P.sky1,
      borderRadius:50,
      overflow:"hidden",
      position:"relative",
      border:`1px solid rgba(212,168,64,.14)`,
      boxShadow:`
        0 90px 130px rgba(0,0,0,.92),
        0 0 0 1px rgba(255,255,255,.025),
        inset 0 1px 0 rgba(255,255,255,.04),
        0 0 80px rgba(31,92,58,.06)
      `,
      display:"flex", flexDirection:"column",
      animation:"scaleIn .55s cubic-bezier(0.34,1.56,0.64,1)",
    }}>
      {/* Notch */}
      <div style={{ position:"absolute", top:0, left:"50%", transform:"translateX(-50%)", width:122, height:33, background:P.sky0, borderRadius:"0 0 21px 21px", zIndex:50, display:"flex", alignItems:"center", justifyContent:"center", gap:5 }}>
        <div style={{ width:9, height:9, borderRadius:"50%", background:"#0A0808" }}/>
        <div style={{ width:54, height:6, borderRadius:4, background:"#0A0808" }}/>
      </div>
      {/* Status bar */}
      <div style={{ display:"flex", justifyContent:"space-between", alignItems:"center", padding:"11px 24px 0", height:44, flexShrink:0, zIndex:40, fontFamily:"'Cinzel',serif", fontSize:11, color:P.sand, letterSpacing:.5 }}>
        <span>9:41</span>
        <div style={{ display:"flex", gap:4, alignItems:"center", fontSize:10 }}>
          <span>▲▲▲</span><span>◈</span><span>▮▮▮</span>
        </div>
      </div>
      {/* Screen */}
      <div key={screen} style={{ flex:1, overflowY:"auto", overflowX:"hidden", position:"relative", background:P.sky1, animation:"fadeIn .28s ease" }}>
        {children}
      </div>
    </div>
  );
}

/* ══════════════════════════════════════════════════════════════════════════
   ROOT APP — Outer showcase wrapper
══════════════════════════════════════════════════════════════════════════ */
export default function App() {
  const [screen, setScreen] = useState("salah");

  const screenMap = {
    salah:      <SalahScreen/>,
    qibla:      <QiblaScreen/>,
    mosque:     <MosqueScreen/>,
    quran:      <QuranScreen/>,
    hadith:     <HadithScreen/>,
    ramadan:    <RamadanScreen/>,
    contribute: <ContributeScreen/>,
    more:       <MoreScreen onNav={setScreen}/>,
  };

  const navSet = ["salah","qibla","mosque","quran","more"];
  const activeNav = navSet.includes(screen) ? screen : "more";

  return (
    <>
      <style>{CSS}</style>
      <div style={{
        minHeight:"100vh",
        background:`
          radial-gradient(ellipse at 25% 50%, rgba(31,92,58,.09) 0%, transparent 55%),
          radial-gradient(ellipse at 75% 20%, rgba(180,136,42,.07) 0%, transparent 50%),
          ${P.sky0}
        `,
        display:"flex", flexDirection:"column", alignItems:"center", justifyContent:"center",
        padding:"36px 20px", position:"relative", overflow:"hidden",
      }}>

        {/* Background starfield */}
        <svg style={{ position:"fixed", inset:0, width:"100%", height:"100%", pointerEvents:"none", zIndex:0 }}
             preserveAspectRatio="xMidYMid slice">
          {Array.from({length:70},(_,i)=>(
            <circle key={i} cx={`${(i*137.5)%100}%`} cy={`${(i*73.1)%100}%`}
              r={0.3+(i%4)*0.35} fill={P.goldPale} opacity={0.06}
              style={{ animation:`starBlink ${1.8+(i%4)*.7}s ${(i*.31)%5}s ease-in-out infinite` }}/>
          ))}
        </svg>

        {/* Background mosque silhouette — very faint */}
        <div style={{ position:"fixed", bottom:0, left:"50%", transform:"translateX(-50%)", opacity:.04, pointerEvents:"none", zIndex:0 }}>
          <MosqueSilhouette width={900} opacity={1} color={P.goldPale}/>
        </div>

        {/* App title header */}
        <div style={{ position:"relative", zIndex:1, textAlign:"center", marginBottom:26 }}>
          <div style={{ display:"flex", alignItems:"center", justifyContent:"center", gap:14, marginBottom:6 }}>
            <OctaStar size={28} color={P.goldBd}/>
            <div style={{ fontFamily:"'Cinzel Decorative',serif", fontSize:24, fontWeight:700, color:P.goldWarm, letterSpacing:5 }}>MUAZZIN</div>
            <OctaStar size={28} color={P.goldBd}/>
          </div>
          <div style={{ fontFamily:"'Amiri',serif", fontSize:17, color:P.sandMid, letterSpacing:2 }}>المؤذن • কিবলা · সালাহ · কুরআন</div>
          <div style={{ fontFamily:"'Cinzel',serif", fontSize:9, color:P.sandDeep, letterSpacing:3, marginTop:3, textTransform:"uppercase" }}>Bangladesh Islamic Foundation Standard</div>
        </div>

        {/* Screen switcher pills */}
        <div style={{ position:"relative", zIndex:1, display:"flex", gap:5, marginBottom:18, flexWrap:"wrap", justifyContent:"center" }}>
          {[
            ["salah","🕐","নামাজ"],
            ["qibla","🧭","কিবলা"],
            ["mosque","🕌","মসজিদ"],
            ["quran","📖","কুরআন"],
            ["hadith","📿","হাদিস"],
            ["ramadan","🌙","রমজান"],
            ["contribute","➕","অবদান"],
          ].map(([id,ic,lb])=>(
            <button key={id} onClick={()=>setScreen(id)} style={{
              padding:"7px 14px", borderRadius:11, cursor:"pointer",
              background:screen===id?`linear-gradient(135deg,${P.dome},#0C2218)`:"rgba(255,255,255,.04)",
              border:`1px solid ${screen===id?P.domeBd:"rgba(255,255,255,.07)"}`,
              fontFamily:"'Noto Sans Bengali',sans-serif", fontSize:11.5, fontWeight:600,
              color:screen===id?P.marble:P.sandMid,
              transition:"all .2s", display:"flex", alignItems:"center", gap:5,
            }}>
              <span>{ic}</span><span>{lb}</span>
            </button>
          ))}
        </div>

        {/* Phone */}
        <div style={{ position:"relative", zIndex:1 }}>
          {/* Ambient glow beneath phone */}
          <div style={{ position:"absolute", inset:-30, borderRadius:80,
            background:`radial-gradient(ellipse, rgba(31,92,58,.1) 0%, transparent 68%)`,
            pointerEvents:"none", zIndex:-1 }}/>

          <PhoneShell screen={screen}>
            {screenMap[screen]}
            <BottomNav active={activeNav} onNav={setScreen}/>
          </PhoneShell>
        </div>

        {/* Footer */}
        <div style={{ position:"relative", zIndex:1, marginTop:24, textAlign:"center" }}>
          <div style={{ display:"flex", alignItems:"center", gap:10, opacity:.25, marginBottom:8 }}>
            <div style={{ width:80, height:1, background:`linear-gradient(to right,transparent,${P.gold})` }}/>
            <OctaStar size={16} color={P.gold}/>
            <div style={{ width:80, height:1, background:`linear-gradient(to left,transparent,${P.gold})` }}/>
          </div>
          <div style={{ fontFamily:"'Amiri',serif", fontSize:13, color:P.sandDeep }}>
            حَافِظُوا عَلَى الصَّلَوَاتِ وَالصَّلَاةِ الْوُسْطَىٰ — সূরা বাকারাহ ২:২৩৮
          </div>
        </div>
      </div>
    </>
  );
}
