function tableMarkup(tb){
  const cols=tb.columns||['Destination prefix','Type / decision','Target / next hop','Notes'];
  return '<table><thead><tr>'+cols.map(x=>'<th>'+safe(x)+'</th>').join('')+'</tr></thead><tbody>'+
    tb.rows.map((r,i)=>{
      const cells=[r.prefix,r.decision||r.type||'',r.target,r.note||r.reason||''].slice(0,cols.length);
      while(cells.length<cols.length)cells.push('');
      return '<tr data-row="'+i+'" class="'+(r.winner?'winner':'')+'">'+cells.map(x=>'<td>'+safe(x)+'</td>').join('')+'</tr>';
    }).join('')+'</tbody></table>';
}
function kindLabel(k){return ({
  route:'VPC subnet route lookup', service:'Service VIP / kube-proxy DNAT', lb:'Load balancer selection',
  iam:'IAM / access entry', rbac:'Kubernetes RBAC', cni:'VPC CNI / ipamd', nat:'CNI SNAT + NAT gateway',
  filter:'Security group / NetworkPolicy / NACL', dns:'CoreDNS / VPC DNS', identity:'Workload identity',
  control:'Control-plane convergence', storage:'CSI attach / mount', scale:'HPA / capacity',
  health:'Target health', return:'Return path', session:'Transport / delivery (not Service DNAT)', transport:'Transport / delivery (not Service DNAT)', config:'Configuration',
  deny:'Deny / stop', command:'Command sequence'
})[k]||k}
const MODULES=['route','service','lb','iam','cni','filter','control'];
const ROLE_STROKE={forward:'#0b5cad',service:'#7954b3',service_return:'#9b6fd1',post:'#18794e',return:'#b65b0a',stop:'#bd3047',bypass:'#bd3047'};
const ROLE_ARROW={forward:'url(#arrow)',service:'url(#arrow-svc)',service_return:'url(#arrow-svc)',post:'url(#arrow-post)',return:'url(#arrow-ret)',stop:'url(#arrow-stop)',bypass:'url(#arrow-stop)'};
function popupContent(){
  const e=current(),p=$('popover');
  p.className='popover context-band'+(e.encap?' outer':'')+(e.stop?' stop':'');
  p.hidden=false; p.style.left='';p.style.top='';p.style.width='';
  const mod=({route:'route',service:'service',lb:'lb',iam:'iam',rbac:'iam',cni:'cni',nat:'cni',filter:'filter',dns:'',identity:'iam',deny:'filter',health:'lb',session:'',return:'route',control:'control',storage:'cni',scale:'lb',command:'',transport:''})[e.kind]; // control≠IAM; session/transport/command: no DNAT/IAM chip unless kind is iam
  const chips=MODULES.map(m=>'<span class="module-chip'+(mod&&m===mod?' on':'')+'" data-module="'+m+'">'+({route:'VPC RT',service:'Service DNAT',lb:'ALB / NLB',iam:'IAM / RBAC',cni:'CNI / NAT',filter:'SG / NP / NACL',control:'Control plane'})[m]+'</span>').join('');
  const col1=e.table
    ? ('<h3>Owning table / lookup</h3><div class="owner">'+safe(e.table.owner)+'</div><div class="lookup">Lookup address: <b>'+safe(e.table.destination)+'</b></div><div id="routecard">'+tableMarkup(e.table)+'</div>')
    : ('<h3>Decision</h3><h2>'+safe(e.title)+'</h2><p>'+safe(e.body||'')+'</p>');
  const col2='<h3>Packet / hop context</h3><div class="headers">'+(e.headers||[]).map(r=>'<div class="header-row"><b>'+safe(r[0])+'</b><span>'+safe(r[1])+'</span></div>').join('')+'</div>';
  const col3='<h3>Plane</h3><div class="eyebrow">'+safe(kindLabel(e.kind))+(e.az?' · AZ-'+e.az:'')+'</div><div class="module-strip">'+chips+'</div><p>'+safe(e.body||e.statement||'')+'</p>';
  p.innerHTML='<div class="band-col">'+col1+'</div><div class="band-col">'+col2+'</div><div class="band-col">'+col3+'</div>';
  p.setAttribute('aria-label',e.title);
}
function svgEl(tag,attrs={}){let x=document.createElementNS(NS,tag);for(const[k,v]of Object.entries(attrs))x.setAttribute(k,v);return x}
function flowFor(e){
  if(typeof FLOWS!=='undefined' && FLOWS[e.path]) return FLOWS[e.path];
  const pts=PATHS[e.path]; if(!pts) return null;
  return {segments:[{fromDevice:e.owner,fromPort:'b',toDevice:e.owner,toPort:'b',points:pts,role:e.stop?'stop':'forward'}],visits:[e.owner]};
}
function hopRangeBounds(e, flow){
  const n=(flow&&flow.segments&&flow.segments.length)||0;
  if(!n) return {lo:0,hi:-1};
  let lo=0, hi=n-1;
  if(Array.isArray(e.hopRange)&&e.hopRange.length>=2){
    lo=Math.max(0, Math.min(n-1, e.hopRange[0]|0));
    hi=e.hopRange[1];
    if(hi<0) hi=n-1;
    hi=Math.max(lo, Math.min(n-1, hi|0));
  }
  return {lo,hi};
}

function mapRender(){
  const e=current();
  const sceneKey=e.sceneKey||e.path||'F01_forward';
  const svgText=(typeof SCENES!=='undefined' && SCENES[sceneKey]) ? SCENES[sceneKey] : (SCENES[e.path]||Object.values(SCENES)[0]);
  $('map').innerHTML=svgText;
  const svg=$('map').firstElementChild,layer=svg.querySelector('#dynamic-layer');
  document.querySelectorAll('#map [data-active]').forEach(n=>n.removeAttribute('data-active'));
  if(e.owner) svg.querySelector('#'+CSS.escape(e.owner))?.setAttribute('data-active','true');
  if(e.reveal){document.querySelectorAll('#map [data-actor]').forEach(n=>{if(!e.reveal.includes(n.id))n.style.opacity='.14'})}
  const flow=flowFor(e); if(!flow){console.error('missing flow',e.path);return}
  currentFlow=flow; currentSegPaths=[];
  flow.segments.forEach((seg,i)=>{
    const stroke=ROLE_STROKE[seg.role]||'#0b5cad';
    const p=svgEl('path',{id:'seg-'+i,'data-seg':String(i),'data-role':seg.role||'forward',
      d:'M'+seg.points.map(pt=>pt.join(',')).join(' L'), fill:'none', stroke, 'stroke-width':3.5,
      'stroke-linecap':'round','stroke-linejoin':'round','marker-end':ROLE_ARROW[seg.role]||'url(#arrow)',
      opacity: seg.role==='service_return'?'0.95':'1'});
    layer.append(p); currentSegPaths.push(p);
  });
  // v5.1: DISCONTINUOUS geometry — never bridge device interiors with a continuous L path
  currentPath=svgEl('path',{id:'active-path',d:flow.segments.map(seg=>'M'+seg.points.map(pt=>pt.join(',')).join(' L')).join(' '),fill:'none',stroke:'none'});
  layer.append(currentPath);
  hopMetrics=currentSegPaths.map(sp=>sp.getTotalLength());
  hopTotal=hopMetrics.reduce((a,b)=>a+b,0)||1;
  tokenObstacles=[...svg.querySelectorAll('[data-node-highlight],[data-header-strip],[data-caption]')].map(n=>{try{const r=n.getBBox();return {x:r.x,y:r.y,width:r.width,height:r.height};}catch(err){return {x:0,y:0,width:0,height:0}}});
  const token=svgEl('g',{id:'token'});
  token.append(svgEl('rect',{id:'outer-shell',x:-28,y:-23,width:56,height:46,rx:9,fill:'#f4effa',stroke:'#7954b3','stroke-width':3,opacity:'0'}));
  token.append(svgEl('circle',{id:'inner-packet',r:16,fill:e.stop?'#bd3047':'#0b5cad',stroke:'white','stroke-width':3}));
  const label=svgEl('text',{'text-anchor':'middle',y:5,fill:'white','font-size':15,'font-weight':700});label.textContent='IP';token.append(label);layer.append(token);
  position();
}
let hopMetrics=[],hopTotal=1,tokenObstacles=[],currentHopState=null;
function hopAtDistance(distance){
  const n=hopMetrics.length;
  if(!n) return {index:0,local:0,length:1,distance:0,p:0,point:{x:0,y:0},wrapped:false,scale:1,processing:true,processDevice:null,visible:false,gap:0};
  distance=Math.max(0,Math.min(hopTotal, distance));
  let rest=distance, index=n-1;
  for(let i=0;i<n;i++){
    const L=hopMetrics[i]||0;
    // Strict < so exact end-of-segment distance advances to the next hop's start (progress 0 of hopRange).
    // Final path end settles on last segment via i===n-1.
    if(i===n-1 || rest < L - 1e-9){ index=i; break; }
    rest-=L;
  }
  const seg=currentFlow.segments[index], length=hopMetrics[index]||1;
  let local=Math.max(0,Math.min(length, rest));
  if(distance >= hopTotal - 1e-9){ index=n-1; local=hopMetrics[index]||0; }
  const wrapped=false;
  const hw=19.5,hh=19.5;
  const baseScale=Math.min(1,Math.max(.35,(length-6)/(2*(hw+2))));
  const gap=Math.min(length*.42,(hw+2)*baseScale);
  const start=local<=gap,end=local>=length-gap;
  const point=currentSegPaths[index].getPointAtLength(local);
  let scale=baseScale;
  for(const r of tokenObstacles){
    const dx=Math.max(r.x-point.x,point.x-r.x-r.width,0);
    const dy=Math.max(r.y-point.y,point.y-r.y-r.height,0);
    scale=Math.min(scale,Math.max(dx/(hw+2),dy/(hh+2))*.96);
  }
  const processing=start||end;
  const processDevice=start?seg.fromDevice:seg.toDevice;
  return {index,local,length,distance,p:hopTotal?distance/hopTotal:0,point:{x:point.x,y:point.y},wrapped,scale,
    processing,processDevice,visible:!processing&&scale>=.35,gap};
}
function hopAt(p){
  const distance=Math.max(0,Math.min(1,p))*hopTotal;
  let rest=distance, index=hopMetrics.length-1;
  for(let i=0;i<hopMetrics.length;i++){
    if(rest<hopMetrics[i]||i===hopMetrics.length-1){index=i;break;}
    rest-=hopMetrics[i];
  }
  const seg=currentFlow.segments[index], length=hopMetrics[index]||1;
  const local=Math.max(0,Math.min(length,rest));
  const wrapped=false; // native VPC — no GENEVE envelope on EKS canonical path
  const hw=19.5,hh=19.5;
  const baseScale=Math.min(1,Math.max(.35,(length-6)/(2*(hw+2))));
  const gap=Math.min(length*.42,(hw+2)*baseScale);
  const start=local<=gap,end=local>=length-gap;
  const point=currentSegPaths[index].getPointAtLength(local);
  let scale=baseScale;
  for(const r of tokenObstacles){
    const dx=Math.max(r.x-point.x,point.x-r.x-r.width,0);
    const dy=Math.max(r.y-point.y,point.y-r.y-r.height,0);
    scale=Math.min(scale,Math.max(dx/(hw+2),dy/(hh+2))*.96);
  }
  const processing=start||end;
  const processDevice=start?seg.fromDevice:seg.toDevice;
  return {index,local,length,distance,p,point:{x:point.x,y:point.y},wrapped,scale,
    processing,processDevice,visible:!processing&&scale>=.35,gap};
}
function activeSegmentIndex(p){return hopAt(p).index;}
function position(){
  const e=current();if(e.type==='lecture'){lectureBuilds(progress);return}
  if(!currentPath||!currentFlow)return;
  const bounds=hopRangeBounds(e,currentFlow);
  let p=reduce.matches?(progress<.5?0:progress<1?.5:1):progress;if(e.think>0)p=0;
  const decision=['route','service','lb','iam','rbac','cni','nat','filter','dns','identity','deny','health','session','transport','control','storage','scale'].includes(e.kind);
  // C1 v3: cumulative DISTANCE interpolation across hopRange (not equal index fractions)
  let local=decision?Math.max(0,(p-.45)/.55):p;
  local=Math.max(0,Math.min(1,local));
  const nSeg=Math.max(1,currentFlow.segments.length);
  let startDist=0, rangeLen=0;
  for(let i=0;i<nSeg;i++){
    const L=hopMetrics[i]||0;
    if(i<bounds.lo) startDist+=L;
    if(i>=bounds.lo && i<=bounds.hi) rangeLen+=L;
  }
  if(rangeLen<=0){ rangeLen=hopMetrics[bounds.lo]||1; }
  // progress 0 → start of first in-range hop; progress 1 → end of last in-range hop (settle on delivery port)
  // Never land exactly on cumulative end (which equals next hop start); settle inside last in-range hop.
  const targetDist=startDist + local*rangeLen*(1-1e-9);
  const state=currentHopState=hopAtDistance(targetDist);
  const si=state.index;
  const seg=currentFlow.segments[si]||currentFlow.segments[bounds.lo];
  const token=$('map').querySelector('#token');
  if(token){
    token.setAttribute('transform',`translate(${state.point.x} ${state.point.y}) scale(${Math.max(0,state.scale)})`);
    token.style.visibility=state.visible?'visible':'hidden';
    token.dataset.segment=String(si);token.dataset.processing=String(state.processing);
    token.dataset.processDevice=state.processDevice||'';
    token.dataset.hopLo=String(bounds.lo);token.dataset.hopHi=String(bounds.hi);
    token.dataset.distance=String(state.distance);
  }
  currentSegPaths.forEach((sp,i)=>{sp.setAttribute('stroke-opacity',i<=si?'1':'.35');sp.setAttribute('stroke-width',i===si?'5':'3.5');});
  document.querySelectorAll('#map [data-active]').forEach(n=>n.removeAttribute('data-active'));
  // C1: decision cards lock highlight to declared owner; motion still uses hop geometry
  const proc=e.owner || (state.processing?state.processDevice:(seg&&(seg.processAt||seg.toDevice)));
  if(proc) document.querySelector('#map #'+CSS.escape(proc))?.setAttribute('data-active','true');
  const rows=[...document.querySelectorAll('#routecard tbody tr')];
  const threshold=e.kind==='health'?1:.3;
  rows.forEach((r,i)=>{r.classList.toggle('pending',progress<threshold);r.classList.toggle('evaluating',e.kind!=='health'&&progress<threshold&&i===Math.min(rows.length-1,Math.floor(progress/threshold*rows.length)))});
  if(e.kind==='health'&&rows[0]&&rows[0].cells[1])rows[0].cells[1].textContent=progress>=1?'SUCCESS':progress<.5?'Request in flight':'Reply in flight';
  const shell=$('map').querySelector('#outer-shell');if(shell)shell.setAttribute('opacity','0');
  const inner=$('map').querySelector('#inner-packet');
  if(inner){
    if(e.kind==='nat')inner.setAttribute('fill',progress<.5?'#0b5cad':'#b65b0a');
    if(e.stop&&progress>.92)inner.setAttribute('fill','#bd3047');
  }
}
function placePopup(){
  if(current().type==='lecture')return;
  const pop=$('popover');
  pop.style.left='';pop.style.top='';pop.style.width='';
  pop.classList.add('context-band');
  popupPlacement={mode:'bottom-band',disjoint:true};
  $('map').querySelector('#popup-pointer')?.remove();
}
