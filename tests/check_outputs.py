"""Check reported table cells and the scientific marks drawn from clean summaries."""
from pathlib import Path
import argparse,json,csv,math,hashlib
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);a=p.parse_args();root=Path(__file__).resolve().parents[1];out=a.out
read=lambda p:json.loads(p.read_text())
for line in (root/'checksums.sha256').read_text().splitlines():
 h,n=line.split('  ',1);assert hashlib.sha256((root/n).read_bytes()).hexdigest()==h,n
tables=read(root/'data/tables.json');assert len(tables)==12
for t in tables:
 rows=list(csv.reader((out/'tables'/(t['id']+'.csv')).open()));assert rows==[t['columns']]+t['rows'],t['id']
support=read(root/'data/support.json');marks=read(out/'figure4/marks.json')
for rid,f in support.items():
 assert next(m['value'] for m in marks if m['rid']==rid and m['kind']=='days')==f['days']
 assert next(m['data'] for m in marks if m['rid']==rid and m['kind']=='domain')==f['domain']
 for b in f['bins']:
  m=[m for m in marks if m['rid']==rid and m['kind']=='retained_bin' and m['bin']==b['bin']]
  assert bool(m)==b['retained']
  if m:assert m[0]['data']==[b['start'],b['end']]
 for k in ['ell_model_m','S_grid_retained_nominal_m','S_retained_clipped_m']:
  assert next(m['value'] for m in marks if m['rid']==rid and m['kind']=='table_value' and m['key']==k)==f[k]
 for c in f['components']:
  ms=[m for m in marks if m['rid']==rid and m['kind']=='principal_outline' and m['component']==c['component']]
  assert bool(ms)==c['principal']
  if ms:assert ms[0]['data']==[c['start'],c['end']]
d=read(root/'data/profiles.json');marks=read(out/'figure6/marks.json');by={(b['rid'],b['bin']):b for b in d['bins']}
for b in d['bins']:
 ms=[m for m in marks if m['rid']==b['rid'] and m['bin']==b['bin']]
 seg=[m for m in ms if m['role']=='Q_segment'];assert bool(seg)==b['retained']
 if seg:assert seg[0]['coords']==[b['start'],b['end'],b['Q_display']]
 ci=[m for m in ms if m['role']=='pointwise_interval'];assert bool(ci)==bool(b['retained'] and b['reportable'])
 if ci:assert ci[0]['coords']==[b['start'],b['end'],b['lower_display'],b['upper_display']]
 if b.get('Q_display') is not None:assert math.isclose(b['Q_raw']/0.44704,b['Q_display'],rel_tol=1e-14)
for m in marks:
 if m['role']=='step_connector':
  b=by[m['rid'],m['bin']];prev=by[m['rid'],m['previous_bin']];assert b['component']==prev['component'] and b['start']==prev['end']
assert not any(m['rid']=='r19' and m['role']=='pointwise_interval' for m in marks)
for m in d['markers']:assert any(x['rid']==m['rid'] and x['bin']==m['bin'] and x['role']==m['role'] and x['coords']==[m['x'],m['y']] for x in marks)
for n in ['4','5','6','7','8','B1']:assert len(list((out/f'figure{n}').glob('*.pdf')))==1
params=read(root/'data/parameters.json');assert params['mph_to_model_m_s']==.44704 and params['joint_scale_multiplier']==1.609344 and params['bin_width']==7.62 and params['fit_min_span']==30.48
print('PASS: 12 table datasets; all support edges/lengths; all Q segments, gaps, pointwise intervals and recovery markers; exact conversions; six PDFs.')

# Published objective sensitivity: compare rounding with the reported checks.
with (out / 'tables/objective_sensitivity.csv').open() as stream:
    sensitivity = list(csv.DictReader(stream))
assert len(sensitivity) == 8 * 3
twenty = [r for r in sensitivity if r['objective_mph'] == '20']
for column, limits in [('p', (0.7017, 0.8687)), ('A_mph', (2.0255, 5.0446))]:
    values = [float(r[column]) for r in twenty]
    assert (round(min(values), 4), round(max(values), 4)) == limits

primary = {r[0]: r for r in next(t for t in tables if t['id'] == 'self_enforcement_index')['rows']}
for row in sensitivity:
    if row['objective_mph'] == '25':
        expected = primary[row['acquisition']]
        for column, index, digits in [('p', 1, 4), ('A_mph', 3, 2), ('E', 4, 4)]:
            assert round(float(row[column]), digits) == float(expected[index])
    if row['objective_mph'] == '30':
        assert float(row['p']) == float(row['A_mph']) == 0
        assert row['m_mph'] == row['E'] == '' and row['index_defined'] == '0'

populations = next(t for t in tables if t['id'] == 'analytical_population')['rows']
assert sum(int(r[2]) for r in populations) == 45364
assert sum(int(r[6]) for r in populations) == 6758
for row in populations:
    assert int(row[4]) - int(row[5]) == int(row[6])
    assert row[7] == f'{100 * int(row[6]) / int(row[2]):.2f}'
pairs = next(t for t in tables if t['id'] == 'selection_fields')['rows']
for rid, target in [('r15', ('0.1034', '0.3103')), ('r16', ('0.0000', '0.2510'))]:
    full, fits = [r for r in pairs if r[0] == rid]
    assert full[2:5] == fits[2:5] and (full[5], fits[5]) == target
print('PASS: fixed-field objectives, normalization domain and within-acquisition selection checks.')
