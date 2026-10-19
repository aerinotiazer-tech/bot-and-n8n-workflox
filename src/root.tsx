import React from 'react';
import {Composition} from 'remotion';
import {BlindSpotEpisode} from './scenes/BlindSpotEpisode';

export const Root: React.FC = () => (
  <Composition
    id="BlindSpotEpisode"
    component={BlindSpotEpisode}
    durationInFrames={300}
    fps={30}
    width={1920}
    height={1080}
  />
);
