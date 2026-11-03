"""Render saved support geometry and length summaries."""
from pathlib import Path
import argparse,json,os
p=argparse.ArgumentParser();p.add_argument('--data',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args();W=a.out;W.mkdir(parents=True,exist_ok=True)
os.environ.setdefault('MPLCONFIGDIR',str(W/'fontcache'))
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib import font_manager as fm
from matplotlib.patches import Rectangle,PathPatch
from matplotlib.path import Path as MPath
from matplotlib.lines import Line2D
font_family='Arial' if any(f.name=='Arial' for f in fm.fontManager.ttflist) else 'DejaVu Sans'
plt.rcParams.update({'font.family':font_family,'font.size':7.2,'pdf.fonttype':42,'axes.labelsize':8,'axes.linewidth':.6,'path.simplify':False})
A=W
# Fixed display width in TeX points.
texpt=472.03123; width=texpt*72/72.27
heights={'observation_support.pdf':80*72/25.4,'speed_profiles.pdf':155*72/25.4}
style={'dark':'#1F1F1F','trough':'#005AB5','peak':'#DC3220','interval':'#4BA99D','interval_alpha':.20,'profile':'#237E77','support':'#DDE3E7','separator':'#C7CFD5','outline':'#626F78','domain':'#A5ADB2','objective':'#92979B','data_width':.95,'axis_width':.6,'objective_width':.6,'marker_size':3.8,'label_size':7.2,'axis_label_size':8}
data=json.loads((a.data/'profiles.json').read_text())
rids=[d['rid'] for d in data['domains']];pr=[];transforms={}
def log(asset,role,rid,bin,coords,**kw):pr.append(dict(asset=asset,role=role,rid=rid,bin=bin,coords=coords,**kw))
def fig(name):return plt.figure(figsize=(width/72,heights[name]/72),dpi=144)
def ftext(f,x,y,s,**kw):return f.text(x/width,y/(f.get_figheight()*72),s,fontsize=kw.pop('fontsize',7.2),**kw)
def finish(f,name):
 f.savefig(A/name,format='pdf',metadata={'Title':name.replace('_',' '),'Creator':'Saved profile renderer','CreationDate':None,'ModDate':None})
 plt.close(f)
# Profiles: explicit open paths, one per saved connected component. No baseline closure.
name='speed_profiles.pdf';f=fig(name);hh=heights[name];pw=201;ph=75
transforms[name]={'width':width,'height':hh,'panel_width':pw,'panel_height':ph,'x_origins':[38,263],'y_origins':[351,257,163,69],'x_range':[-350,10],'y_range':[0,35]}
for i,d in enumerate(data['domains']):
 rid=d['rid'];col=i%2;row=i//2;px=[38,263][col];py=[351,257,163,69][row]
 ax=f.add_axes([px/width,py/hh,pw/width,ph/hh]);ax.set_xlim(-350,10);ax.set_ylim(0,35)
 for side in ['top','right']:ax.spines[side].set_visible(False)
 ax.set_xticks([-300,-200,-100,0]);ax.set_yticks([0,10,20,30]);ax.tick_params(direction='out',width=.6,length=2.5,pad=2.5,labelsize=7.2,labelbottom=row==3,labelleft=col==0)
 ftext(f,px+1,py+ph+5,rid,fontsize=7.2,fontweight="bold",color=style["dark"])
 ftext(f,px+pw,py+ph+5,f"{d['days']} days"+(" · descriptive" if rid=="r19" else ""),fontsize=7.2,ha="right",color="#666666")
 tx=lambda x:px+(x+350)/360*pw;ty=lambda y:py+y/35*ph
 bins=[b for b in data['bins'] if b['rid']==rid and b['retained']];byid={b['bin']:b for b in bins}
 for b in bins:
  if b['reportable']:
   lo,up=b['lower_display'],b['upper_display']
   # Zero-height rectangles are preserved as zero area; no widening or artificial stroke.
   ax.add_patch(Rectangle((b['start'],lo),b['end']-b['start'],up-lo,facecolor=style['interval'],alpha=style['interval_alpha'],edgecolor='none',linewidth=0,zorder=1))
   log(name,'pointwise_interval',rid,b['bin'],[b['start'],b['end'],lo,up],pdf=[tx(b['start']),ty(lo),tx(b['end']),ty(up)])
 ax.axhline(25,color=style['objective'],linewidth=.6,linestyle=(0,(3,2)),zorder=2)
 log(name,'objective',rid,None,[25],pdf=[px,ty(25),px+pw,ty(25)])
 for comp in d['components']:
  bs=[byid[k] for k in comp['bins']];vertices=[]
  for j,b in enumerate(bs):
   if j:
    prev=bs[j-1];assert prev['end']==b['start'] and prev['component']==b['component']==comp['component']
    vertices.append((b['start'],b['Q_display']))
    log(name,'step_connector',rid,b['bin'],[b['start'],prev['Q_display'],b['Q_display']],previous_bin=prev['bin'],component=comp['component'],pdf=[tx(b['start']),ty(prev['Q_display']),tx(b['start']),ty(b['Q_display'])])
   else:vertices.append((b['start'],b['Q_display']))
   vertices.append((b['end'],b['Q_display']))
   log(name,'Q_segment',rid,b['bin'],[b['start'],b['end'],b['Q_display']],pdf=[tx(b['start']),ty(b['Q_display']),tx(b['end']),ty(b['Q_display'])])
  path=MPath(vertices,[MPath.MOVETO]+[MPath.LINETO]*(len(vertices)-1))
  ax.add_patch(PathPatch(path,facecolor='none',edgecolor=style['profile'],linewidth=.95,capstyle='butt',joinstyle='miter',zorder=3))
 for m in [m for m in data['markers'] if m['rid']==rid]:
  trough=m['role']=='qualified trough'
  ax.plot([m['x']],[m['y']],marker='v' if trough else 'o',markersize=3.8,markeredgewidth=0,color=style['trough' if trough else 'peak'],linestyle='none',zorder=4)
  log(name,m['role'],rid,m['bin'],[m['x'],m['y']],pdf=[tx(m['x']),ty(m['y'])])
ftext(f,9,247,r'Uncapped $p_{85}$, $Q$ (conditional mph)',fontsize=8,rotation=90,ha='center',va='center')
ftext(f,251,40,r'Local sensor coordinate, $x$ (model m)',fontsize=8,ha='center')
handles=[Line2D([0],[0],color=style['profile'],lw=.95),Rectangle((0,0),1,1,facecolor=style['interval'],alpha=style['interval_alpha'],edgecolor='none'),Line2D([0],[0],color=style['objective'],lw=.6,linestyle=(0,(3,2))),Line2D([0],[0],color=style['trough'],marker='v',ms=3.8,mew=0,ls='none'),Line2D([0],[0],color=style['peak'],marker='o',ms=3.8,mew=0,ls='none')]
f.legend(handles,[r'$Q$','Pointwise 95% interval','Objective','Qualified trough','Post-trough peak'],loc='lower center',bbox_to_anchor=(.5,.023),frameon=False,ncol=5,fontsize=7.2,handlelength=1.7,handletextpad=.5,columnspacing=1.3,borderaxespad=0)
finish(f,name)
(W/'marks.json').write_text(json.dumps(pr,indent=2)+'\n')
