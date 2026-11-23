// Brand tokens, mirrored from lib/core/constants/app_colors.dart.
export const C = {
  orange: '#FFA726',
  orangeShadow: '#E69500',
  pink: '#FF7B9C',
  pinkShadow: '#E66384',
  blue: '#42A5F5',
  blueShadow: '#2889D9',
  magenta: '#E040FB',
  magentaShadow: '#C626E0',
  coral: '#FF8A65',
  coralShadow: '#E5704D',
  purple: '#7E57C2',
  purpleShadow: '#6440A8',
  green: '#4CAF50',
  greenShadow: '#3D8B40',
  red: '#FF5252',
  redShadow: '#CC3B3B',
  turquoise: '#4ECDC4',
  ink: '#2D3142',
  inkShadow: '#1C1F2B',
  paper: '#FFFDF8',
  white: '#FFFFFF',
};

export type Tone = 'orange' | 'pink' | 'blue' | 'magenta' | 'coral' | 'purple' | 'green' | 'red' | 'ink' | 'white';

export const toneColors: Record<Tone, [string, string, string]> = {
  // [face, shadow, text]
  orange: [C.orange, C.orangeShadow, C.white],
  pink: [C.pink, C.pinkShadow, C.white],
  blue: [C.blue, C.blueShadow, C.white],
  magenta: [C.magenta, C.magentaShadow, C.white],
  coral: [C.coral, C.coralShadow, C.white],
  purple: [C.purple, C.purpleShadow, C.white],
  green: [C.green, C.greenShadow, C.white],
  red: [C.red, C.redShadow, C.white],
  ink: [C.ink, C.inkShadow, C.white],
  white: [C.white, '#D5D8E0', C.ink],
};

export const rainbow: Tone[] = ['orange', 'pink', 'blue', 'magenta', 'coral', 'purple'];

export const FONT = 'Fredoka';
export const FPS = 30;
export const W = 1080;
export const H = 1920;
