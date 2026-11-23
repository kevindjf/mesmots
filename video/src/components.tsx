import React from 'react';
import {
  AbsoluteFill,
  Audio,
  Easing,
  interpolate,
  OffthreadVideo,
  Sequence,
  spring,
  staticFile,
  useCurrentFrame,
  useVideoConfig,
} from 'remotion';
import {C, FONT, rainbow, Tone, toneColors} from './theme';

// ---------- helpers ----------

export const usePop = (delay = 0, damping = 11, stiffness = 170) => {
  const frame = useCurrentFrame();
  const {fps} = useVideoConfig();
  return spring({frame: frame - delay, fps, config: {damping, stiffness, mass: 0.6}});
};

export const Sfx: React.FC<{src: string; at: number; volume?: number}> = ({src, at, volume = 0.7}) => (
  <Sequence from={at} layout="none">
    <Audio src={staticFile(`sfx/${src}.mp3`)} volume={volume} />
  </Sequence>
);

export const Voice: React.FC<{word: string; at: number; volume?: number}> = ({word, at, volume = 1}) => (
  <Sequence from={at} layout="none">
    <Audio src={staticFile(`voice/${word}.mp3`)} volume={volume} />
  </Sequence>
);

// ---------- background ----------

const shapes = Array.from({length: 14}, (_, i) => {
  const r = (n: number) => {
    const x = Math.sin(i * 9301 + n * 49297) * 233280;
    return x - Math.floor(x);
  };
  return {
    x: r(1) * 1080,
    y: r(2) * 1920,
    size: 90 + r(3) * 220,
    rot: r(4) * 60 - 30,
    speed: 0.15 + r(5) * 0.35,
    tone: rainbow[i % rainbow.length],
  };
});

export const Background: React.FC<{dark?: boolean}> = ({dark}) => {
  const frame = useCurrentFrame();
  return (
    <AbsoluteFill style={{background: dark ? C.ink : `linear-gradient(180deg, #FFFDF8 0%, #FFF4E6 100%)`, overflow: 'hidden'}}>
      {shapes.map((s, i) => (
        <div
          key={i}
          style={{
            position: 'absolute',
            left: s.x - s.size / 2,
            top: ((s.y - frame * s.speed * 3 + 2200) % 2200) - 140,
            width: s.size,
            height: s.size,
            borderRadius: s.size * 0.22,
            background: toneColors[s.tone][0],
            opacity: dark ? 0.16 : 0.13,
            transform: `rotate(${s.rot + frame * s.speed * 0.6}deg)`,
          }}
        />
      ))}
    </AbsoluteFill>
  );
};

// ---------- 3D tile & text ----------

export const Tile: React.FC<{
  children: React.ReactNode;
  tone?: Tone;
  size?: number;
  delay?: number;
  rotate?: number;
  pressed?: boolean;
  style?: React.CSSProperties;
  sfx?: boolean;
}> = ({children, tone = 'orange', size = 120, delay = 0, rotate = 0, pressed, style, sfx}) => {
  const p = usePop(delay);
  const [face, shadow, text] = toneColors[tone];
  const depth = Math.round(size * (pressed ? 0.03 : 0.07));
  return (
    <div
      style={{
        display: 'inline-flex',
        alignItems: 'center',
        justifyContent: 'center',
        minWidth: size,
        height: size,
        padding: `0 ${size * 0.22}px`,
        borderRadius: size * 0.24,
        background: face,
        color: text,
        fontFamily: FONT,
        fontWeight: 700,
        fontSize: size * 0.58,
        boxShadow: `0 ${depth}px 0 ${shadow}`,
        transform: `translateY(${pressed ? depth : 0}px) scale(${p}) rotate(${rotate * p}deg)`,
        opacity: Math.min(1, p * 1.5),
        lineHeight: 1,
        ...style,
      }}
    >
      {sfx ? <Sfx src="tap" at={delay} volume={0.5} /> : null}
      {children}
    </div>
  );
};

/** A word spelled as colourful letter tiles that pop one by one. */
export const TileWord: React.FC<{
  word: string;
  size?: number;
  delay?: number;
  stagger?: number;
  tones?: Tone[];
  tilt?: boolean;
  gap?: number;
  sfx?: boolean;
}> = ({word, size = 120, delay = 0, stagger = 3, tones = rainbow, tilt = true, gap, sfx}) => (
  <div style={{display: 'flex', gap: gap ?? size * 0.1, justifyContent: 'center', flexWrap: 'wrap'}}>
    {word.split('').map((ch, i) =>
      ch === ' ' ? (
        <div key={i} style={{width: size * 0.35}} />
      ) : (
        <Tile
          key={i}
          tone={tones[i % tones.length]}
          size={size}
          delay={delay + i * stagger}
          rotate={tilt ? ((i * 37) % 11) - 5 : 0}
          style={{padding: 0}}
          sfx={sfx && i % 2 === 0}
        >
          {ch.toUpperCase()}
        </Tile>
      ),
    )}
  </div>
);

/** Big kinetic headline: each word springs in. `hi` words get a coloured highlight. */
export const Headline: React.FC<{
  text: string;
  delay?: number;
  size?: number;
  color?: string;
  hi?: string[];
  hiTone?: Tone;
  stagger?: number;
  align?: 'center' | 'left';
  width?: number;
}> = ({text, delay = 0, size = 92, color = C.ink, hi = [], hiTone = 'orange', stagger = 3, align = 'center', width = 920}) => {
  const frame = useCurrentFrame();
  const {fps} = useVideoConfig();
  const words = text.split(' ');
  return (
    <div
      style={{
        width,
        display: 'flex',
        flexWrap: 'wrap',
        justifyContent: align === 'center' ? 'center' : 'flex-start',
        columnGap: size * 0.26,
        rowGap: size * 0.12,
        fontFamily: FONT,
        fontWeight: 700,
        fontSize: size,
        lineHeight: 1.08,
        color,
      }}
    >
      {words.map((w, i) => {
        const p = spring({frame: frame - delay - i * stagger, fps, config: {damping: 12, stiffness: 180, mass: 0.6}});
        const isHi = hi.some((h) => w.toLowerCase().replace(/[^a-zàâçéèêëîïôûùüÿœ]/g, '') === h.toLowerCase());
        const [face, shadow] = toneColors[hiTone];
        return (
          <span
            key={i}
            style={{
              display: 'inline-block',
              transform: `translateY(${(1 - p) * 40}px) scale(${0.6 + 0.4 * p})`,
              opacity: p,
              ...(isHi
                ? {
                    background: face,
                    color: '#fff',
                    padding: `0 ${size * 0.18}px`,
                    borderRadius: size * 0.2,
                    boxShadow: `0 ${size * 0.08}px 0 ${shadow}`,
                    transform: `translateY(${(1 - p) * 40}px) scale(${0.6 + 0.4 * p}) rotate(-2deg)`,
                  }
                : {}),
            }}
          >
            {w}
          </span>
        );
      })}
    </div>
  );
};

/** Rotated sticker-like pill. */
export const Sticker: React.FC<{children: React.ReactNode; tone?: Tone; delay?: number; rotate?: number; size?: number}> = ({
  children,
  tone = 'pink',
  delay = 0,
  rotate = -4,
  size = 52,
}) => {
  const p = usePop(delay, 9, 200);
  const [face, shadow, text] = toneColors[tone];
  return (
    <div
      style={{
        display: 'inline-block',
        background: face,
        color: text,
        fontFamily: FONT,
        fontWeight: 700,
        fontSize: size,
        padding: `${size * 0.28}px ${size * 0.6}px`,
        borderRadius: size * 0.9,
        boxShadow: `0 ${size * 0.14}px 0 ${shadow}`,
        transform: `scale(${p}) rotate(${rotate}deg)`,
        whiteSpace: 'nowrap',
      }}
    >
      {children}
    </div>
  );
};

// ---------- phone with screen recording ----------

export type Zoom = {at: number; scale: number; x?: number; y?: number};

/**
 * Phone frame playing a screen recording.
 * startSec: where to start in the clip. rate: playback speed.
 * zooms: keyframes (frame within the sequence) of scale and focus point (0..1 of the screen).
 */
export const Phone: React.FC<{
  clip: string;
  startSec: number;
  rate?: number;
  width?: number;
  landscape?: boolean;
  zooms?: Zoom[];
  delay?: number;
  tilt?: number;
}> = ({clip, startSec, rate = 1, width = 620, landscape, zooms = [], delay = 0, tilt = 0}) => {
  const frame = useCurrentFrame();
  const {fps} = useVideoConfig();
  const ratio = landscape ? 994 / 2160 : 2346 / 1080;
  const height = width * ratio;
  const bezel = width * 0.028;
  const radius = (landscape ? height : width) * 0.13;
  const enter = spring({frame: frame - delay, fps, config: {damping: 14, stiffness: 120}});

  let scale = 1;
  let fx = 0.5;
  let fy = 0.5;
  if (zooms.length) {
    const ats = [0, ...zooms.map((z) => z.at)];
    const ease = {easing: Easing.inOut(Easing.cubic), extrapolateLeft: 'clamp' as const, extrapolateRight: 'clamp' as const};
    scale = interpolate(frame, ats, [1, ...zooms.map((z) => z.scale)], ease);
    fx = interpolate(frame, ats, [0.5, ...zooms.map((z) => z.x ?? 0.5)], ease);
    fy = interpolate(frame, ats, [0.5, ...zooms.map((z) => z.y ?? 0.5)], ease);
  }

  return (
    <div
      style={{
        width: width + bezel * 2,
        height: height + bezel * 2,
        borderRadius: radius + bezel,
        background: '#14161F',
        padding: bezel,
        flexShrink: 0,
        boxSizing: 'content-box',
        boxShadow: '0 40px 80px rgba(45,49,66,0.35), 0 12px 0 #0B0C12',
        transform: `translateY(${(1 - enter) * 300}px) rotate(${tilt}deg)`,
        opacity: enter,
      }}
    >
      <div style={{width, height, borderRadius: radius, overflow: 'hidden', position: 'relative', background: '#fff'}}>
        <div
          style={{
            width,
            height,
            transform: `scale(${scale})`,
            transformOrigin: `${fx * 100}% ${fy * 100}%`,
          }}
        >
          <OffthreadVideo
            src={staticFile(`clips/${clip}.mp4`)}
            startFrom={Math.round(startSec * fps)}
            playbackRate={rate}
            muted
            style={{width, height, objectFit: 'cover'}}
          />
        </div>
      </div>
    </div>
  );
};

/** Finger tap marker (circle that pulses) placed over the phone. */
export const TapDot: React.FC<{x: number; y: number; at: number}> = ({x, y, at}) => {
  const frame = useCurrentFrame();
  const t = frame - at;
  if (t < 0 || t > 18) return null;
  const s = interpolate(t, [0, 18], [0.6, 1.6]);
  const o = interpolate(t, [0, 4, 18], [0, 0.9, 0]);
  return (
    <div
      style={{
        position: 'absolute',
        left: x - 50,
        top: y - 50,
        width: 100,
        height: 100,
        borderRadius: 50,
        border: '8px solid rgba(255,255,255,0.95)',
        background: 'rgba(45,49,66,0.25)',
        transform: `scale(${s})`,
        opacity: o,
      }}
    />
  );
};

// ---------- confetti ----------

export const Confetti: React.FC<{at: number; x?: number; y?: number; count?: number}> = ({at, x = 540, y = 900, count = 36}) => {
  const frame = useCurrentFrame();
  const t = frame - at;
  if (t < 0 || t > 50) return null;
  return (
    <AbsoluteFill style={{pointerEvents: 'none'}}>
      {Array.from({length: count}, (_, i) => {
        const a = (i / count) * Math.PI * 2 + i;
        const v = 18 + ((i * 7) % 13);
        const px = x + Math.cos(a) * v * t;
        const py = y + Math.sin(a) * v * t + 0.9 * t * t;
        const tone = rainbow[i % rainbow.length];
        return (
          <div
            key={i}
            style={{
              position: 'absolute',
              left: px,
              top: py,
              width: 22,
              height: 22,
              borderRadius: 6,
              background: toneColors[tone][0],
              transform: `rotate(${t * 12 + i * 30}deg)`,
              opacity: interpolate(t, [0, 35, 50], [1, 1, 0]),
            }}
          />
        );
      })}
    </AbsoluteFill>
  );
};

// ---------- retention progress bar ----------

export const ProgressBar: React.FC = () => {
  const frame = useCurrentFrame();
  const {durationInFrames} = useVideoConfig();
  return (
    <div style={{position: 'absolute', left: 0, top: 0, height: 12, width: `${(frame / durationInFrames) * 100}%`, background: C.orange}} />
  );
};

// ---------- end card ----------

export const EndCard: React.FC<{line?: string; cta?: string}> = ({line = 'Gratuit · Sans pub · Sans compte', cta = 'Lien en bio'}) => {
  const frame = useCurrentFrame();
  const bounce = Math.sin(frame / 5) * 10;
  return (
    <AbsoluteFill style={{alignItems: 'center', justifyContent: 'center'}}>
      <Background />
      <Sfx src="level_complete" at={2} volume={0.5} />
      <div style={{display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 22, marginTop: -180}}>
        <TileWord word="MES" size={170} stagger={4} tones={['orange', 'pink', 'blue']} />
        <TileWord word="MOTS" size={170} delay={10} stagger={4} tones={['magenta', 'coral', 'orange', 'pink']} />
        <div style={{height: 40}} />
        <Headline text="Les mots de dictée, révisés en jouant" size={64} delay={26} stagger={2} />
        <div style={{height: 10}} />
        <Sticker tone="ink" delay={40} rotate={0} size={44}>
          {line}
        </Sticker>
        <div style={{height: 30}} />
        <div style={{transform: `translateY(${bounce}px)`}}>
          <Sticker tone="orange" delay={50} rotate={-3} size={64}>
            {cta} 👆
          </Sticker>
        </div>
        <div style={{fontFamily: FONT, fontWeight: 600, fontSize: 40, color: C.ink, opacity: interpolate(frame, [58, 70], [0, 0.7], {extrapolateRight: 'clamp'})}}>
          iPhone · Android
        </div>
      </div>
    </AbsoluteFill>
  );
};

/** Wrapper for every TikTok: background + safe area + progress bar. */
export const Frame: React.FC<{children: React.ReactNode; dark?: boolean}> = ({children, dark}) => (
  <AbsoluteFill>
    <Background dark={dark} />
    {children}
    <ProgressBar />
  </AbsoluteFill>
);

/** Positions content inside TikTok's safe zone (top ~200, bottom ~420 kept for UI). */
export const Zone: React.FC<{top: number; children: React.ReactNode; height?: number}> = ({top, children, height}) => (
  <div style={{position: 'absolute', left: 60, right: 60, top, height, display: 'flex', flexDirection: 'column', alignItems: 'center'}}>{children}</div>
);
