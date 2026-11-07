#!/usr/bin/env python3
"""Render static source SVGs; no browser, external upload or cloud access."""
import pathlib,cairosvg
from PIL import Image,ImageOps,ImageDraw
R=pathlib.Path(__file__).resolve().parents[1];out=R/'diagrams/previews';out.mkdir(exist_ok=True)
files=sorted((R/'diagrams').glob('*.svg'))
for p in files:cairosvg.svg2png(url=str(p),write_to=str(out/(p.stem+'.png')),output_width=1920,output_height=930)
thumbs=[]
for p in files:
 im=Image.open(out/(p.stem+'.png')).convert('RGB');im.thumbnail((480,233));canvas=Image.new('RGB',(480,261),'#091725');canvas.paste(im,(0,28));ImageDraw.Draw(canvas).text((10,7),p.stem,fill='white');thumbs.append(canvas)
for batch in range((len(thumbs)+7)//8):
 sheet=Image.new('RGB',(960,1044),'#091725')
 for j,im in enumerate(thumbs[batch*8:(batch+1)*8]):sheet.paste(im,((j%2)*480,(j//2)*261))
 sheet.save(out/f'contact-{batch+1}.png')
print('Rendered',len(files),'static source diagrams and contact sheets; not browser visual sign-off')
