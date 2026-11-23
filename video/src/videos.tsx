import React from 'react';
import {AbsoluteFill, interpolate, Sequence, spring, useCurrentFrame, useVideoConfig} from 'remotion';
import {Confetti, EndCard, Frame, Headline, Phone, Sfx, Sticker, Tile, TileWord, Voice, Zone, Zoom} from './components';
import {C, FONT, Tone, toneColors} from './theme';

const END = 105; // end card length

/** Fades/slides a caption out at the end of its sequence. */
const Caption: React.FC<{children: React.ReactNode; dur: number}> = ({children, dur}) => {
  const frame = useCurrentFrame();
  const out = interpolate(frame, [dur - 8, dur], [1, 0], {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'});
  return <div style={{opacity: out, transform: `translateY(${(1 - out) * -30}px)`}}>{children}</div>;
};

/** Phone placed below a caption area. */
const PhoneSlot: React.FC<{top?: number; children: React.ReactNode}> = ({top = 600, children}) => (
  <div style={{position: 'absolute', top, left: 0, right: 0, display: 'flex', justifyContent: 'center'}}>{children}</div>
);

// =====================================================================
// Quiz template (J2 sept, J8 compter, J13 vingt)
// =====================================================================

type QuizProps = {
  hook: string;
  hookHi: string[];
  hookSticker: string;
  question: string;
  questionHi: string[];
  word: string;
  clip: string;
  revealSec: number; // reveal moment in the clip
  answer: string;
  wrong: string;
  explain: string;
  explainHi: string[];
  cta: string;
};

const QUIZ_HOOK = 75;
const QUIZ_THINK = 150; // 5 s of options before the reveal
const QUIZ_REVEAL = 70;
const QUIZ_EXPLAIN = 95;
const QUIZ_CTA = 70;
export const quizDuration = QUIZ_HOOK + QUIZ_THINK + QUIZ_REVEAL + QUIZ_EXPLAIN + QUIZ_CTA + END;

const Countdown: React.FC = () => {
  const frame = useCurrentFrame();
  const n = 3 - Math.floor(frame / 30);
  if (n < 1) return null;
  const local = frame % 30;
  const p = spring({frame: local, fps: 30, config: {damping: 10, stiffness: 220}});
  return (
    <div style={{position: 'absolute', right: 70, top: 640, transform: `scale(${p})`}}>
      <Sfx src="tap" at={0} volume={0.6} />
      <Tile tone={(['pink', 'blue', 'orange'] as Tone[])[n - 1]} size={150} rotate={8}>
        {n}
      </Tile>
    </div>
  );
};

export const Quiz: React.FC<QuizProps> = (p) => {
  const phoneStart = p.revealSec - QUIZ_THINK / 30;
  const zooms: Zoom[] = [
    {at: QUIZ_THINK - 2, scale: 1},
    {at: QUIZ_THINK + 12, scale: 1.3, x: 0.5, y: 0.62},
  ];
  const live = QUIZ_THINK + 36; // then freeze on the reveal
  const t1 = QUIZ_HOOK;
  const t2 = t1 + QUIZ_THINK;
  const t3 = t2 + QUIZ_REVEAL;
  const t4 = t3 + QUIZ_EXPLAIN;
  const t5 = t4 + QUIZ_CTA;
  return (
    <Frame>
      {/* Hook */}
      <Sequence durationInFrames={QUIZ_HOOK}>
        <Zone top={560}>
          <Caption dur={QUIZ_HOOK}>
            <Headline text={p.hook} hi={p.hookHi} hiTone="pink" size={104} />
            <div style={{height: 50}} />
            <div style={{display: 'flex', justifyContent: 'center'}}>
              <Sticker tone="ink" delay={22} size={70} rotate={-5}>
                {p.hookSticker}
              </Sticker>
            </div>
          </Caption>
        </Zone>
        <Sfx src="tap" at={2} volume={0.5} />
      </Sequence>

      {/* Phone from think to the end of explain */}
      <Sequence from={t1} durationInFrames={live}>
        <PhoneSlot top={640}>
          <Phone clip={p.clip} startSec={phoneStart} width={540} zooms={zooms} />
        </PhoneSlot>
      </Sequence>
      <Sequence from={t1 + live} durationInFrames={t4 - t1 - live}>
        <PhoneSlot top={640}>
          <Phone clip={p.clip} startSec={p.revealSec + 1.2} rate={0.02} width={540} delay={-30} zooms={[{at: 1, scale: 1.3, x: 0.5, y: 0.62}]} />
        </PhoneSlot>
      </Sequence>
      <Sequence from={t1} durationInFrames={t4 - t1}>
        <Voice word={p.word} at={14} />
        <Voice word={p.word} at={80} />
      </Sequence>

      {/* Question */}
      <Sequence from={t1} durationInFrames={QUIZ_THINK}>
        <Zone top={230}>
          <Caption dur={QUIZ_THINK}>
            <Headline text={p.question} hi={p.questionHi} hiTone="blue" size={84} />
          </Caption>
        </Zone>
        <Sequence from={QUIZ_THINK - 90}>
          <Countdown />
        </Sequence>
      </Sequence>

      {/* Reveal */}
      <Sequence from={t2} durationInFrames={QUIZ_REVEAL}>
        <Sfx src="success" at={0} volume={0.8} />
        <Confetti at={2} y={1100} />
        <Zone top={250}>
          <div style={{display: 'flex', gap: 40, alignItems: 'center'}}>
            <Tile tone="green" size={130} delay={0} rotate={-4}>
              {p.answer} ✓
            </Tile>
            <Tile tone="red" size={100} delay={8} rotate={5} style={{textDecoration: 'line-through'}}>
              {p.wrong}
            </Tile>
          </div>
        </Zone>
      </Sequence>

      {/* Explain */}
      <Sequence from={t3} durationInFrames={QUIZ_EXPLAIN}>
        <Zone top={220}>
          <Caption dur={QUIZ_EXPLAIN}>
            <Headline text={p.explain} hi={p.explainHi} hiTone="orange" size={70} stagger={2} />
          </Caption>
        </Zone>
      </Sequence>

      {/* CTA */}
      <Sequence from={t4} durationInFrames={QUIZ_CTA}>
        <Zone top={640}>
          <Headline text={p.cta} size={96} hi={['commentaire', 'parent']} hiTone="magenta" />
          <div style={{height: 40}} />
          <div style={{fontSize: 140}}>👇</div>
        </Zone>
        <Sfx src="star" at={4} volume={0.6} />
      </Sequence>

      <Sequence from={t5}>
        <EndCard />
      </Sequence>
    </Frame>
  );
};

export const quizSept: QuizProps = {
  hook: 'Ton enfant va tomber dans le piège.',
  hookHi: ['piège'],
  hookSticker: 'Et toi ? 🤔',
  question: 'On entend « sèt ». Le nombre, c’est lequel ?',
  questionHi: ['nombre'],
  word: 'sept',
  clip: 'bonmot',
  revealSec: 19.3,
  answer: 'sept',
  wrong: 'set',
  explain: 'Le jeu propose exprès les mots qui sonnent pareil. C’est là que se font les fautes en dictée.',
  explainHi: ['exprès', 'fautes'],
  cta: 'Dis en commentaire si t’as eu juste',
};

export const quizCompter: QuizProps = {
  hook: 'Compter ou conter ? Beaucoup d’enfants se trompent.',
  hookHi: ['compter', 'conter'],
  hookSticker: 'Teste-toi 👀',
  question: '« Je sais … jusqu’à 100. » Quelle orthographe ?',
  questionHi: ['orthographe'],
  word: 'compter',
  clip: 'q_compter',
  revealSec: 10.6,
  answer: 'compter',
  wrong: 'conter',
  explain: 'On compte les moutons… mais on conte une histoire. MesMots met ces pièges exprès dans ses jeux.',
  explainHi: ['compte', 'conte'],
  cta: 'Dis en commentaire si t’as eu juste',
};

export const quizVingt: QuizProps = {
  hook: 'Vingt : un son, plein de lettres muettes.',
  hookHi: ['muettes'],
  hookSticker: 'Ton enfant sait ? 🤔',
  question: 'Quelle est la bonne orthographe de « vingt » ?',
  questionHi: ['vingt'],
  word: 'vingt',
  clip: 'q_vingt',
  revealSec: 10.8,
  answer: 'vingt',
  wrong: 'ving',
  explain: 'Le G et le T ne s’entendent pas. Ce sont exactement les pièges que MesMots fait réviser.',
  explainHi: ['G', 'T'],
  cta: 'Envoie à un parent qui galère avec la dictée',
};

// =====================================================================
// J7 — the 7 games
// =====================================================================

type Seg = {name: string; tone: Tone; clip: string; start: number; rate: number};
const SEG = 72;
const games: Seg[] = [
  {name: 'Le bon mot', tone: 'orange', clip: 'bonmot', start: 17.0, rate: 1.4},
  {name: 'Lettres mélangées', tone: 'blue', clip: 'melange', start: 8.5, rate: 3.4},
  {name: 'Écoute et épelle', tone: 'purple', clip: 'spell', start: 3.0, rate: 3.2},
  {name: 'Mots à trous', tone: 'pink', clip: 'melange', start: 29.5, rate: 3.0},
  {name: 'Écriture', tone: 'magenta', clip: 'melange', start: 53.0, rate: 3.6},
  {name: 'Mots mêlés', tone: 'coral', clip: 'melange', start: 69.0, rate: 2.4},
  {name: 'Mots croisés', tone: 'green', clip: 'cross', start: 9.0, rate: 7.5},
];
const J7_HOOK = 66;
const J7_OUTRO = 75;
export const sevenDuration = J7_HOOK + games.length * SEG + J7_OUTRO + END;

export const SevenGames: React.FC = () => (
  <Frame>
    <Sequence durationInFrames={J7_HOOK}>
      <Zone top={480}>
        <Caption dur={J7_HOOK}>
          <div style={{display: 'flex', justifyContent: 'center'}}>
            <Tile tone="orange" size={300} rotate={-6} sfx>
              7
            </Tile>
          </div>
          <div style={{height: 60}} />
          <Headline text="jeux pour apprendre ses mots de dictée" hi={['dictée']} hiTone="pink" size={96} delay={8} />
        </Caption>
      </Zone>
    </Sequence>
    {games.map((g, i) => (
      <Sequence key={g.name} from={J7_HOOK + i * SEG} durationInFrames={SEG}>
        <Sfx src="tap" at={0} volume={0.6} />
        <Zone top={250}>
          <div style={{display: 'flex', alignItems: 'center', gap: 24}}>
            <Tile tone="ink" size={96} rotate={-6}>
              {i + 1}
            </Tile>
            <Tile tone={g.tone} size={104} delay={2} rotate={2}>
              {g.name}
            </Tile>
          </div>
        </Zone>
        <PhoneSlot top={470}>
          <Phone clip={g.clip} startSec={g.start} rate={g.rate} width={580} delay={i === 0 ? 0 : -30} />
        </PhoneSlot>
      </Sequence>
    ))}
    <Sequence from={J7_HOOK + games.length * SEG} durationInFrames={J7_OUTRO}>
      <Confetti at={0} y={700} />
      <Sfx src="success" at={0} />
      <Zone top={600}>
        <Headline text="Tous avec la liste de la semaine." hi={['semaine.']} hiTone="blue" size={100} />
      </Zone>
    </Sequence>
    <Sequence from={J7_HOOK + games.length * SEG + J7_OUTRO}>
      <EndCard />
    </Sequence>
  </Frame>
);

// =====================================================================
// J3 — crossword
// =====================================================================

const J3 = {hook: 75, a: 120, b: 84, c: 165, outro: 80};
export const crossDuration = J3.hook + J3.a + J3.b + J3.c + J3.outro + END;

export const Crossword: React.FC = () => {
  const tA = J3.hook;
  const tB = tA + J3.a;
  const tC = tB + J3.b;
  const tO = tC + J3.c;
  return (
    <Frame>
      <Sequence durationInFrames={J3.hook}>
        <Zone top={520}>
          <Caption dur={J3.hook}>
            <Headline text="La dictée de la semaine…" size={96} />
            <div style={{height: 50}} />
            <TileWord word="EN MOTS" size={120} delay={18} sfx />
            <div style={{height: 20}} />
            <TileWord word="CROISÉS" size={120} delay={34} tones={['green', 'blue', 'orange', 'pink', 'magenta', 'coral', 'purple']} sfx />
          </Caption>
        </Zone>
      </Sequence>

      <Sequence from={tA} durationInFrames={J3.a}>
        <PhoneSlot top={520}>
          <Phone clip="cross" startSec={1.2} rate={2.6} width={600} />
        </PhoneSlot>
        <Zone top={230}>
          <Caption dur={J3.a}>
            <Headline text="Il écoute le mot 🔊 et le place dans la grille" hi={['écoute']} hiTone="blue" size={76} />
          </Caption>
        </Zone>
      </Sequence>

      <Sequence from={tB} durationInFrames={J3.b}>
        <PhoneSlot top={520}>
          <Phone clip="cross" startSec={1.2 + (J3.a / 30) * 2.6} rate={2.9} width={600} delay={-30} />
        </PhoneSlot>
        <Sfx src="word_complete" at={4} />
        <Zone top={230}>
          <Caption dur={J3.b}>
            <Headline text="Mot après mot…" size={90} hi={['mot…']} hiTone="green" />
          </Caption>
        </Zone>
      </Sequence>

      <Sequence from={tC} durationInFrames={J3.c}>
        <PhoneSlot top={520}>
          <Phone
            clip="cross"
            startSec={19.3}
            rate={1.6}
            width={600}
            delay={-30}
            zooms={[
              {at: 10, scale: 1.55, x: 0.15, y: 0.35},
              {at: 120, scale: 1.55, x: 0.15, y: 0.35},
              {at: 140, scale: 1, x: 0.5, y: 0.5},
            ]}
          />
        </PhoneSlot>
        <Sfx src="word_complete" at={128} />
        <Confetti at={150} y={1000} />
        <Zone top={210}>
          <Caption dur={J3.c}>
            <Headline text="Les lettres déjà posées ? Il tape le mot d’un trait ✍️" hi={['d’un', 'trait']} hiTone="orange" size={72} stagger={2} />
          </Caption>
        </Zone>
      </Sequence>

      <Sequence from={tO} durationInFrames={J3.outro}>
        <Zone top={560}>
          <Headline text="Les mots de SA liste. Pas des mots au hasard." hi={['SA']} hiTone="pink" size={98} />
        </Zone>
        <Sfx src="star" at={2} />
      </Sequence>
      <Sequence from={tO + J3.outro}>
        <EndCard />
      </Sequence>
    </Frame>
  );
};

// =====================================================================
// J5 — Écoute et épelle
// =====================================================================

const J5 = {hook: 75, spell: 190, type: 120, outro: 75};
export const spellDuration = J5.hook + J5.spell + J5.type + J5.outro + END;

export const Spell: React.FC = () => {
  const tS = J5.hook;
  const tT = tS + J5.spell;
  const tO = tT + J5.type;
  return (
    <Frame>
      <Sequence durationInFrames={J5.hook}>
        <Zone top={540}>
          <Caption dur={J5.hook}>
            <Headline text="Ce jeu épelle les mots" size={104} hi={['épelle']} hiTone="purple" />
            <div style={{height: 40}} />
            <Sticker tone="orange" delay={20} size={70}>
              comme à l’école 🏫
            </Sticker>
          </Caption>
        </Zone>
      </Sequence>

      <Sequence from={tS} durationInFrames={J5.spell}>
        <PhoneSlot top={560}>
          <Phone clip="spell" startSec={2.6} rate={1.5} width={590} zooms={[{at: 30, scale: 1.15, x: 0.5, y: 0.45}]} />
        </PhoneSlot>
        <Voice word="printemps" at={8} />
        <Zone top={230}>
          <Caption dur={J5.spell}>
            <Headline text="Il entend le mot épelé, lettre par lettre" size={68} hi={['lettre']} hiTone="purple" />
            <div style={{height: 30}} />
            <TileWord word="PRINTEMPS" size={62} delay={30} stagger={14} sfx tones={['purple']} tilt={false} />
          </Caption>
        </Zone>
      </Sequence>

      <Sequence from={tT} durationInFrames={J5.type}>
        <PhoneSlot top={560}>
          <Phone clip="spell" startSec={24.2} rate={2.1} width={590} delay={-30} zooms={[{at: 1, scale: 1.15, x: 0.5, y: 0.45}]} />
        </PhoneSlot>
        <Sfx src="success" at={96} />
        <Confetti at={98} y={1000} />
        <Zone top={250}>
          <Caption dur={J5.type}>
            <Headline text="…puis il le reconstitue" size={84} hi={['reconstitue']} hiTone="green" />
          </Caption>
        </Zone>
      </Sequence>

      <Sequence from={tO} durationInFrames={J5.outro}>
        <Zone top={560}>
          <Headline text="Accents et cédille compris." size={100} />
          <div style={{height: 40}} />
          <div style={{display: 'flex', gap: 24}}>
            {['é', 'è', 'ê', 'à', 'ç'].map((l, i) => (
              <Tile key={l} tone={(['orange', 'pink', 'blue', 'magenta', 'coral'] as Tone[])[i]} size={130} delay={12 + i * 4} rotate={(i % 2 ? 1 : -1) * 6} sfx>
                {l}
              </Tile>
            ))}
          </div>
        </Zone>
      </Sequence>
      <Sequence from={tO + J5.outro}>
        <EndCard />
      </Sequence>
    </Frame>
  );
};

// =====================================================================
// J9 — stars
// =====================================================================

const J9 = {hook: 80, list: 200, retry: 120, outro: 0};
export const starsDuration = J9.hook + J9.list + J9.retry + END;

export const Stars: React.FC = () => {
  const tL = J9.hook;
  const tR = tL + J9.list;
  return (
    <Frame>
      <Sequence durationInFrames={J9.hook}>
        <Zone top={520}>
          <Caption dur={J9.hook}>
            <Headline text="Comment je sais quels mots il ne connaît pas encore" size={96} hi={['pas', 'encore']} hiTone="pink" />
          </Caption>
        </Zone>
      </Sequence>

      <Sequence from={tL} durationInFrames={J9.list}>
        <PhoneSlot top={600}>
          <Phone
            clip="home"
            startSec={2.4}
            rate={1}
            width={560}
            zooms={[
              {at: 100, scale: 1},
              {at: 125, scale: 1.6, x: 0.5, y: 0.2},
            ]}
          />
        </PhoneSlot>
        <Zone top={210}>
          <Caption dur={J9.list}>
            <Headline text="Chaque mot réussi gagne une étoile ⭐" size={70} hi={['étoile']} hiTone="orange" />
            <div style={{height: 26}} />
            <Sequence from={110} layout="none">
              <div style={{display: 'flex', gap: 22}}>
                <Sticker tone="green" size={44} rotate={-3}>
                  ★★★ maîtrisé
                </Sticker>
                <Sticker tone="ink" size={44} rotate={3} delay={10}>
                  ☆☆☆ à revoir
                </Sticker>
              </div>
              <Sfx src="star" at={0} />
            </Sequence>
          </Caption>
        </Zone>
      </Sequence>

      <Sequence from={tR} durationInFrames={J9.retry}>
        <PhoneSlot top={600}>
          <Phone clip="q_compter" startSec={9.6} width={560} zooms={[{at: 1, scale: 1.4, x: 0.5, y: 0.62}]} />
        </PhoneSlot>
        <Zone top={220}>
          <Caption dur={J9.retry}>
            <Headline text="Un mot raté n’est pas puni : il revient un peu plus tard" size={70} hi={['pas', 'puni']} hiTone="blue" stagger={2} />
          </Caption>
        </Zone>
      </Sequence>
      <Sequence from={tR + J9.retry}>
        <EndCard />
      </Sequence>
    </Frame>
  );
};

// =====================================================================
// J11 — landscape
// =====================================================================

const J11 = {hook: 70, play: 210, bravo: 80};
export const landDuration = J11.hook + J11.play + J11.bravo + END;

const RotatingPhone: React.FC<{children: React.ReactNode}> = ({children}) => {
  const frame = useCurrentFrame();
  const {fps} = useVideoConfig();
  const p = spring({frame: frame - 4, fps, config: {damping: 13, stiffness: 90}});
  return <div style={{flexShrink: 0, transform: `rotate(${(1 - p) * -90}deg) scale(${0.6 + 0.4 * p})`}}>{children}</div>;
};

export const Landscape: React.FC = () => {
  const tP = J11.hook;
  const tB = tP + J11.play;
  return (
    <Frame>
      <Sequence durationInFrames={J11.hook}>
        <Zone top={560}>
          <Caption dur={J11.hook}>
            <div style={{fontSize: 200, textAlign: 'center'}}>📱</div>
            <Headline text="Même à l’horizontale" size={110} hi={['l’horizontale']} hiTone="coral" />
          </Caption>
        </Zone>
      </Sequence>
      <Sequence from={tP} durationInFrames={J11.play + J11.bravo}>
        <Sfx src="tap" at={2} />
        <PhoneSlot top={780}>
          <RotatingPhone>
            <Phone clip="landscape" startSec={13.4} rate={1.05} width={900} landscape delay={-30} />
          </RotatingPhone>
        </PhoneSlot>
        <Sfx src="word_complete" at={34} volume={0.5} />
        <Sfx src="word_complete" at={92} volume={0.5} />
        <Sfx src="word_complete" at={150} volume={0.5} />
      </Sequence>
      <Sequence from={tP} durationInFrames={J11.play}>
        <Zone top={300}>
          <Caption dur={J11.play}>
            <Headline text="Mots mêlés avec les mots de la semaine" size={84} hi={['semaine']} hiTone="orange" />
          </Caption>
        </Zone>
      </Sequence>
      <Sequence from={tB} durationInFrames={J11.bravo}>
        <Confetti at={0} y={1000} />
        <Sfx src="success" at={0} />
        <Zone top={300}>
          <Headline text="Sur téléphone ou tablette." size={92} hi={['tablette.']} hiTone="blue" />
        </Zone>
      </Sequence>
      <Sequence from={tB + J11.bravo}>
        <EndCard />
      </Sequence>
    </Frame>
  );
};

// =====================================================================
// J12 — what the app doesn't have
// =====================================================================

const J12 = {hook: 60, list: 150, app: 120};
export const noAdsDuration = J12.hook + J12.list + J12.app + END;

const Crossed: React.FC<{label: string; delay: number; tone: Tone}> = ({label, delay, tone}) => {
  const frame = useCurrentFrame();
  const {fps} = useVideoConfig();
  const strike = spring({frame: frame - delay - 14, fps, config: {damping: 12, stiffness: 160}});
  const stamp = spring({frame: frame - delay - 14, fps, config: {damping: 8, stiffness: 220}});
  return (
    <div style={{position: 'relative', display: 'flex', alignItems: 'center', gap: 30}}>
      <Sfx src="error" at={delay + 14} volume={0.5} />
      <Tile tone={tone} size={120} delay={delay} rotate={-2}>
        <span style={{position: 'relative'}}>
          {label}
          <span
            style={{
              position: 'absolute',
              left: -10,
              right: -10,
              top: '52%',
              height: 12,
              borderRadius: 6,
              background: C.ink,
              transform: `scaleX(${strike})`,
              transformOrigin: 'left',
            }}
          />
        </span>
      </Tile>
      <div style={{fontSize: 110, transform: `scale(${stamp}) rotate(${(1 - stamp) * 40}deg)`}}>❌</div>
    </div>
  );
};

export const NoAds: React.FC = () => {
  const tL = J12.hook;
  const tA = tL + J12.list;
  const items: [string, Tone][] = [
    ['Pub', 'orange'],
    ['Achat intégré', 'pink'],
    ['Compte à créer', 'blue'],
    ['Données envoyées', 'magenta'],
  ];
  return (
    <Frame>
      <Sequence durationInFrames={J12.hook}>
        <Zone top={620}>
          <Caption dur={J12.hook}>
            <Headline text="Une app pour enfant SANS ça" hi={['SANS']} hiTone="red" size={112} />
            <div style={{fontSize: 130, textAlign: 'center', marginTop: 30}}>👇</div>
          </Caption>
        </Zone>
      </Sequence>
      <Sequence from={tL} durationInFrames={J12.list}>
        <Zone top={330}>
          <Caption dur={J12.list}>
            <div style={{display: 'flex', flexDirection: 'column', gap: 48, alignItems: 'flex-start'}}>
              {items.map(([label, tone], i) => (
                <Crossed key={label} label={label} delay={6 + i * 26} tone={tone} />
              ))}
            </div>
          </Caption>
        </Zone>
      </Sequence>
      <Sequence from={tA} durationInFrames={J12.app}>
        <PhoneSlot top={620}>
          <Phone clip="home" startSec={0.2} rate={1.2} width={540} />
        </PhoneSlot>
        <Zone top={230}>
          <Headline text="Juste les mots de la semaine ✏️" size={92} hi={['mots']} hiTone="green" />
          <div style={{height: 24}} />
          <Sticker tone="ink" size={46} delay={20} rotate={2}>
            Tout reste sur le téléphone
          </Sticker>
        </Zone>
        <Sfx src="success" at={4} />
      </Sequence>
      <Sequence from={tA + J12.app}>
        <EndCard />
      </Sequence>
    </Frame>
  );
};

// keep TS happy about unused imports in some builds
export const _unused = {AbsoluteFill, FONT, toneColors};
