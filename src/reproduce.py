"""Reproduce published displays from aggregate summaries."""
from pathlib import Path
import argparse,json,csv,subprocess,sys,shutil,os
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);p.add_argument('--rscript',default='Rscript');a=p.parse_args()
root=Path(__file__).resolve().parents[1];out=a.out.resolve();out.mkdir(parents=True,exist_ok=True)
os.environ.setdefault('XDG_CACHE_HOME',str(out/'cache'))
(out/'cache').mkdir(exist_ok=True)
tables=json.loads((root/'data/tables.json').read_text())
for t in tables:
 path=out/'tables'/(t['id']+'.csv');path.parent.mkdir(exist_ok=True)
 with path.open('w',newline='') as f:
  w=csv.writer(f);w.writerow(t['columns']);w.writerows(t['rows'])
for num in [4,5]:
 subprocess.run([sys.executable,str(root/f'src/figure{num}.py'),'--data',str(root/'data'),'--out',str(out/f'figure{num}')],check=True)
for num in ['6','7','B1']:
 subprocess.run([a.rscript,str(root/f'src/figure{num}.R'),str(root/'data'),str(out/f'figure{num}')],check=True)
print('Reproduced 11 analytical table datasets and Figures 4, 5, 6, 7 and B.1.')
