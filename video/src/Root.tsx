import React from 'react';
import {Composition, continueRender, delayRender, staticFile} from 'remotion';
import {
  Crossword,
  crossDuration,
  Landscape,
  landDuration,
  NoAds,
  noAdsDuration,
  Quiz,
  quizCompter,
  quizDuration,
  quizSept,
  quizVingt,
  SevenGames,
  sevenDuration,
  Spell,
  spellDuration,
  Stars,
  starsDuration,
} from './videos';
import {FPS, H, W} from './theme';

const weights: [string, number][] = [
  ['Fredoka-Regular', 400],
  ['Fredoka-Medium', 500],
  ['Fredoka-SemiBold', 600],
  ['Fredoka-Bold', 700],
];
const handle = delayRender('fonts');
Promise.all(
  weights.map(([file, weight]) => {
    const face = new FontFace('Fredoka', `url(${staticFile(`fonts/${file}.ttf`)})`, {weight: String(weight)});
    document.fonts.add(face);
    return face.load();
  }),
).then(() => continueRender(handle));

const common = {fps: FPS, width: W, height: H};

export const Root: React.FC = () => (
  <>
    <Composition id="J02-quiz-sept" component={Quiz} defaultProps={quizSept} durationInFrames={quizDuration} {...common} />
    <Composition id="J03-mots-croises" component={Crossword} durationInFrames={crossDuration} {...common} />
    <Composition id="J05-ecoute-epelle" component={Spell} durationInFrames={spellDuration} {...common} />
    <Composition id="J07-les-7-jeux" component={SevenGames} durationInFrames={sevenDuration} {...common} />
    <Composition id="J08-quiz-compter" component={Quiz} defaultProps={quizCompter} durationInFrames={quizDuration} {...common} />
    <Composition id="J09-etoiles" component={Stars} durationInFrames={starsDuration} {...common} />
    <Composition id="J11-paysage" component={Landscape} durationInFrames={landDuration} {...common} />
    <Composition id="J12-sans-pub" component={NoAds} durationInFrames={noAdsDuration} {...common} />
    <Composition id="J13-quiz-vingt" component={Quiz} defaultProps={quizVingt} durationInFrames={quizDuration} {...common} />
  </>
);
