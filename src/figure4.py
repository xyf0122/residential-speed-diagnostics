"""Render saved support geometry and length summaries."""
from pathlib import Path
import argparse,json,os
p=argparse.ArgumentParser();p.add_argument('--data',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args();W=a.out;W.mkdir(parents=True,exist_ok=True)
os.environ.setdefault('MPLCONFIGDIR',str(W/'fontcache'))
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib import font_manager as fm
from matplotlib.patches import Rectangle,Circle
from matplotlib.lines import Line2D
from matplotlib.textpath import TextPath
font_family='Arial' if any(f.name=='Arial' for f in fm.fontManager.ttflist) else 'DejaVu Sans'
plt.rcParams.update({'font.family':font_family,'font.size':7.2,'pdf.fonttype':42,'axes.labelsize':8,'axes.linewidth':.6,'path.simplify':False})
fields=json.loads((a.data/'support.json').read_text());rids=list(fields)
width=472.03123*72/72.27;height=286
fig=plt.figure(figsize=(width/72,height/72));canvas=fig.add_axes([0,0,1,1]);canvas.set_xlim(0,width);canvas.set_ylim(0,height);canvas.set_axis_off()
colors=['#2B6F8A','#3D5F9B','#287D76','#AF7532','#85608F'];groups=[['r1'],['r13','r15','r16'],['r17'],['r18'],['r19','r20']];bycolor={r:c for g,c in zip(groups,colors) for r in g}
light=lambda h:tuple(.80+.20*int(h[i:i+2],16)/255 for i in [1,3,5])
marks=[]
def text(x,y,s,**kw):return canvas.text(x,y,s,fontsize=kw.pop('fontsize',7.2),va=kw.pop('va','center'),**kw)
# Visible-glyph centering avoids Arial's ascender/descender midpoint offset.
row_text_alignment=[]
row_font=fm.FontProperties(family=font_family,size=7.2)
def rowtext(x,y,s,**kw):
 bounds=TextPath((0,0),s,prop=row_font).get_extents();ink_center=(bounds.y0+bounds.y1)/2
 row_text_alignment.append({'text':s,'x':x,'row_y':y,'baseline_y':y-ink_center,'glyph_y_min':float(bounds.y0),'glyph_y_max':float(bounds.y1)})
 return text(x,y-ink_center,s,va='baseline',**kw)
def line(xs,ys,**kw):canvas.plot(xs,ys,clip_on=False,**kw)
x0=76;extent=228;top=222;stride=22;barh=7.2;fx=lambda x:x0+(x+350)/360*extent
# One canvas for the entire figure: no opaque panel and no displaced axis.
# The common table baseline at y=56 also serves as the coordinate-axis spine.
for tick in [-300,-200,-100,0]:
 xx=fx(tick);line([xx,xx],[56,53.5],color='#525A60',lw=.6)
 text(xx,46.5,str(tick).replace('-','−'),ha='center')
text(x0+extent/2,32,'Local sensor coordinate, $x$ (model m)',fontsize=8,ha='center')
# Shared table alignment: grouped header, horizontal rules, no boxed cells.
text(17,247,'Acq.',ha='center',fontweight='bold');text(49,247,'Days',ha='center',fontweight='bold')
text(190,272,'Observation support',fontsize=8,ha='center',fontweight='bold');text(390,272,'Length summaries (model m)',fontsize=8,ha='center',fontweight='bold')
text(190,247,'Selected-point domain and retained bins',ha='center')
for xc,head,sym in [(343,'Span',r'$\ell$'),(394,'Nominal grid',r'$S_{\rm grid}$'),(445,'Clipped',r'$S$')]:text(xc,251,head,ha='center');text(xc,238,sym,ha='center',fontsize=8)
line([5,465],[263,263],color='#25282B',lw=.7);line([5,465],[231,231],color='#25282B',lw=.6)
# Sparse group separators echo the reference's Nature table; grouping is identity metadata.
for y in [211,145,123,101]:line([5,465],[y,y],color='#D5DADF',lw=.35,zorder=0)
line([5,465],[56,56],color='#25282B',lw=.6)
for g,c in zip(groups,colors):
 ys=[top-rids.index(r)*stride for r in g];canvas.add_patch(Rectangle((4,min(ys)-8),2,max(ys)-min(ys)+16,facecolor=c,edgecolor='none'))
for i,rid in enumerate(rids):
 f=fields[rid];y=top-i*stride;c=bycolor[rid]
 canvas.add_patch(Circle((19,y),8.7,facecolor=c,edgecolor='none'));rowtext(19,y,rid,ha='center',color='white',fontsize=7.2)
 days=f['days'];rowtext(49,y,str(days),ha='center');marks.append({'kind':'days','rid':rid,'value':days})
 canvas.plot([fx(v) for v in f['domain']],[y,y],lw=.6,color='#9AA3AA',solid_capstyle='butt',zorder=1)
 for edge in f['domain']:canvas.plot([fx(edge),fx(edge)],[y-2.5,y+2.5],color='#9AA3AA',lw=.6,zorder=1)
 marks.append({'kind':'domain','rid':rid,'data':f['domain'],'pdf':[fx(f['domain'][0]),y,fx(f['domain'][1]),y]})
 for b in f['bins']:
  if not b['retained']:continue
  canvas.add_patch(Rectangle((fx(b['start']),y-barh/2),fx(b['end'])-fx(b['start']),barh,facecolor=light(c),edgecolor='#FFFFFF',linewidth=.22,zorder=2))
  marks.append({'kind':'retained_bin','rid':rid,'bin':b['bin'],'data':[b['start'],b['end']],'pdf':[fx(b['start']),y-barh/2,fx(b['end'])-fx(b['start']),barh]})
 for co in f['components']:
  if not co['principal']:continue
  canvas.add_patch(Rectangle((fx(co['start']),y-barh/2-.5),fx(co['end'])-fx(co['start']),barh+1,facecolor='none',edgecolor=c,linewidth=.7,zorder=3))
  marks.append({'kind':'principal_outline','rid':rid,'component':co['component'],'data':[co['start'],co['end']],'pdf':[fx(co['start']),y-barh/2-.5,fx(co['end'])-fx(co['start']),barh+1]})
 for right,key in [(360,'ell_model_m'),(411,'S_grid_retained_nominal_m'),(462,'S_retained_clipped_m')]:
  s=f"{f[key]:.2f}";rowtext(right,y,s,ha='right');marks.append({'kind':'table_value','rid':rid,'key':key,'value':f[key],'display':s,'anchor':[right,y]})
# Compact visual key: category colour is categorical group identity, never a magnitude.
handles=[Line2D([0],[0],color='#9AA3AA',lw=.6,marker='|',markersize=4,markeredgewidth=.6),Rectangle((0,0),1,1,facecolor=light(colors[0]),edgecolor='white',lw=.22),Rectangle((0,0),1,1,facecolor='none',edgecolor=colors[0],lw=.7)]
fig.legend(handles,['Selected-point domain','Retained bin','Principal component'],ncol=3,frameon=False,loc='lower center',bbox_to_anchor=(.5,.014),fontsize=7.2,handlelength=1.8,columnspacing=1.5,handletextpad=.55,borderaxespad=0)
# Group identity is already self-mapping through repeated badge and support colours.
fig.savefig(W/'Figure4.pdf',metadata={'Title':'Observation support','CreationDate':None,'ModDate':None})
plt.close(fig)
(W/'marks.json').write_text(json.dumps(marks,indent=2)+'\n')
