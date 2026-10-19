import React from 'react';
import {AbsoluteFill, Easing, interpolate, spring, useCurrentFrame, useVideoConfig} from 'remotion';

const BG = '#080808';
const WHITE = '#F4F4F4';
const RED = '#FF0000';

export const BlindSpotEpisode: React.FC = () => {
  const frame = useCurrentFrame();
  const {fps} = useVideoConfig();
  const reveal = spring({frame: frame - 18, fps, config: {damping: 22, stiffness: 90, mass: 0.9}});
  const drift = interpolate(frame, [0, 300], [0, -26], {easing: Easing.inOut(Easing.quad), extrapolateRight: 'clamp'});
  const accent = interpolate(frame, [66, 74, 88, 96], [0, 1, 1, 0], {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'});
  const scale = interpolate(reveal, [0, 1], [1.08, 1]);
  const opacity = interpolate(reveal, [0, 1], [0, 1]);

  return (
    <AbsoluteFill style={{backgroundColor: BG, color: WHITE, fontFamily: 'Inter, Arial, sans-serif', overflow: 'hidden'}}>
      <AbsoluteFill style={{transform: `translateY(${drift}px) scale(${scale})`, opacity}}>
        <div style={{position: 'absolute', inset: 0, backgroundImage: 'linear-gradient(rgba(255,255,255,.035) 1px, transparent 1px), linear-gradient(90deg, rgba(255,255,255,.035) 1px, transparent 1px)', backgroundSize: '80px 80px', maskImage: 'linear-gradient(to bottom, transparent, black 25%, black 75%, transparent)'}} />
        <div style={{position: 'absolute', left: 160, top: 170, color: '#aaa', fontSize: 23, letterSpacing: 8, textTransform: 'uppercase'}}>Blind Spot / Essai vidéo</div>
        <div style={{position: 'absolute', left: 158, top: 410, width: 8, height: 250, backgroundColor: RED, opacity: accent}} />
        <div style={{position: 'absolute', left: 205, top: 390, maxWidth: 1360, fontSize: 102, fontWeight: 750, lineHeight: 1.02, letterSpacing: -4}}>
          Le système que<br/>personne ne regarde.
        </div>
        <div style={{position: 'absolute', left: 210, top: 675, color: '#bdbdbd', fontSize: 28, letterSpacing: 3}}>ANALYSE • TECHNOLOGIE • POUVOIR</div>
        <div style={{position: 'absolute', right: 158, bottom: 112, width: 170, height: 2, backgroundColor: RED, transform: `scaleX(${accent})`, transformOrigin: 'right'}} />
      </AbsoluteFill>
      <div style={{position: 'absolute', left: 80, right: 80, bottom: 62, height: 1, backgroundColor: '#333'}} />
      <div style={{position: 'absolute', left: 82, bottom: 28, color: '#777', fontSize: 17, letterSpacing: 4}}>DOCUMENTAIRES & ESSAIS VIDÉO</div>
    </AbsoluteFill>
  );
};
