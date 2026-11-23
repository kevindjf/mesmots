// node render.mjs stills "ID:frame,frame" ...   |   node render.mjs videos [ID ...]
import {bundle} from '@remotion/bundler';
import {renderMedia, renderStill, selectComposition, getCompositions} from '@remotion/renderer';
import path from 'node:path';
import fs from 'node:fs';

const [mode, ...args] = process.argv.slice(2);
const serveUrl = await bundle({entryPoint: path.resolve('src/index.ts')});
if (mode === 'stills') {
  fs.mkdirSync('stills', {recursive: true});
  for (const arg of args) {
    const [id, frames] = arg.split(':');
    const composition = await selectComposition({serveUrl, id});
    for (const f of frames.split(',')) {
      await renderStill({serveUrl, composition, frame: Number(f), output: path.resolve(`stills/${id}-${f}.png`), scale: 0.35});
      console.log('still', id, f);
    }
  }
} else {
  fs.mkdirSync('out', {recursive: true});
  const all = await getCompositions(serveUrl);
  const ids = args.length ? args : all.map((c) => c.id);
  for (const id of ids) {
    const composition = await selectComposition({serveUrl, id});
    await renderMedia({serveUrl, composition, codec: 'h264', crf: 18, outputLocation: path.resolve(`out/${id}.mp4`), audioBitrate: '192k'});
    console.log('video', id, (composition.durationInFrames / 30).toFixed(1) + 's');
  }
}
