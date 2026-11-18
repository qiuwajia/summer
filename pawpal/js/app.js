/* ============================================================
   Summer — App logic
   ============================================================ */

const STORE_KEY = 'summer_state_v1';
const LEGACY_KEY = 'pawpal_state_v1'; // 兼容旧版本数据，改名不丢历史

// 每日日期键（本地时区）
function dayKey(d=new Date()){
  const p=n=>String(n).padStart(2,'0');
  return `${d.getFullYear()}-${p(d.getMonth()+1)}-${p(d.getDate())}`;
}

// 默认任务状态
function freshQuestState(){
  return {
    xp: 0,
    onboard: {},          // { questId: 完成进度 }
    onboardClaimed: {},   // { questId: true } 已领取奖励
    dailyDate: dayKey(),  // 当前每日任务所属日期
    dailyIds: [],         // 今日随机抽取的每日任务 id
    daily: {},            // { questId: 完成进度 }
    dailyClaimed: {},
    badges: [],           // 已解锁徽章 id
    stats: {},            // 累计行为计数（徽章判定用）
    streak: 0,            // 连续完成每日任务天数
    lastFullDaily: '',    // 上次全部完成每日任务的日期
    justLeveled: null,    // 本次会话刚升级到的等级（用于弹窗）
  };
}

// Load or init state (migrate from legacy key if present)
function loadState(){
  const fresh = {
    walks: JSON.parse(JSON.stringify(WALKS)),
    chats: JSON.parse(JSON.stringify(CHATS)),
    joinedMine: [],
    quest: freshQuestState(),
  };
  try{
    let raw = localStorage.getItem(STORE_KEY);
    if(!raw){
      const legacy = localStorage.getItem(LEGACY_KEY);
      if(legacy){ raw = legacy; localStorage.setItem(STORE_KEY, legacy); localStorage.removeItem(LEGACY_KEY); }
    }
    if(raw){
      const saved = JSON.parse(raw);
      const merged = { ...fresh, ...saved };
      // quest 字段做深度合并，兼容旧存档新增字段
      merged.quest = { ...fresh.quest, ...(saved.quest||{}) };
      return merged;
    }
  }catch(e){}
  return fresh;
}
let state = loadState();
function saveState(){ try{ localStorage.setItem(STORE_KEY, JSON.stringify(state)); }catch(e){} }

const $ = (s,root=document)=>root.querySelector(s);
const $$ = (s,root=document)=>Array.from(root.querySelectorAll(s));

// ---- helpers ----
function avatarHTML(av, cls=''){
  if(av && (av.startsWith('assets/') || av.startsWith('http')))
    return `<img class="${cls}" src="${av}" alt="">`;
  return `<span class="${cls}">${av||'🐕'}</span>`;
}
function avatarsStack(ids){
  const limit = 3;
  const show = ids.slice(0,limit);
  let html = show.map(id=>{
    const f = FRIENDS.find(x=>x.id===id);
    if(f) return `<div class="av" style="background:${f.color}">${f.emoji}</div>`;
    return `<div class="av">🐕</div>`;
  }).join('');
  if(ids.length>limit) html += `<span class="more-n">+${ids.length-limit}</span>`;
  return html;
}

// ============================================================
// QUEST ENGINE — 游戏化任务系统
// ============================================================

// 按日期种子确定性伪随机（同一天刷新任务不变，跨天自动换）
function seededPick(seed, arr, count){
  let s = 0;
  for(let i=0;i<seed.length;i++) s = (s*31 + seed.charCodeAt(i)) >>> 0;
  const rnd = ()=>{ s = (s*1664525 + 1013904223) >>> 0; return s/4294967296; };
  const pool = arr.slice();
  for(let i=pool.length-1;i>0;i--){ const j=Math.floor(rnd()*(i+1)); [pool[i],pool[j]]=[pool[j],pool[i]]; }
  return pool.slice(0,count).map(q=>q.id);
}

// 确保今日每日任务已生成；跨天则重置每日进度并刷新任务（保留连续天数逻辑在 track 中处理）
function ensureDaily(){
  const q = state.quest;
  if(q.dailyDate !== dayKey()){
    q.dailyDate = dayKey();
    q.daily = {};
    q.dailyClaimed = {};
    q.dailyIds = seededPick(q.dailyDate, DAILY_QUEST_POOL, 3);
    q._greeted = {}; // 每日重置打招呼记录，保证"向2位狗友打招呼"每天可完成
    saveState();
  } else if(!q.dailyIds || q.dailyIds.length===0){
    q.dailyIds = seededPick(q.dailyDate, DAILY_QUEST_POOL, 3);
    saveState();
  }
}

function getLevel(xp){
  let cur = LEVELS[0];
  for(const l of LEVELS){ if(xp>=l.min) cur=l; }
  const next = LEVELS.find(l=>l.min>xp) || null;
  return { cur, next };
}

// 追踪行为：所有任务进度、统计、徽章、升级都在这里统一处理
function track(event){
  const q = state.quest;
  const incStat = (k,n=1)=>{ q.stats[k]=(q.stats[k]||0)+n; };

  // 累计统计（徽章判定）
  const statMap = { viewWalk:'viewWalk', greet:'greet', viewPlace:'viewPlace', joinWalk:'join', sendChat:'chat', publish:'publish', viewMap:'viewMap' };
  if(statMap[event]) incStat(statMap[event]);

  const checkList = (definition, progressObj, claimedObj, isDaily)=>{
    definition.forEach(def=>{
      if(def.event!==event) return;
      // 每日任务只追踪今日抽中的
      if(isDaily && !q.dailyIds.includes(def.id)) return;
      const key = def.id;
      progressObj[key] = Math.min((progressObj[key]||0)+1, def.target);
      // 完成且未领取 → 发经验
      if(progressObj[key]>=def.target && !claimedObj[key]){
        claimedObj[key] = true;
        q.xp += def.point;
        showQuestToast(def.icon, def.title, def.point);
      }
    });
  };

  checkList(ONBOARD_QUESTS, q.onboard, q.onboardClaimed, false);
  ensureDaily();
  checkList(DAILY_QUEST_POOL, q.daily, q.dailyClaimed, true);

  checkDailyComplete(); // 先结算连续天数，徽章判定依赖 streak
  checkBadges();
  checkLevelUp();
  saveState();
  renderQuestBadges();
}

// 徽章判定
function checkBadges(){
  const q = state.quest;
  const s = q.stats;
  const unlock = (id)=>{
    if(!q.badges.includes(id)){
      q.badges.push(id);
      const b = BADGES.find(x=>x.id===id);
      setTimeout(()=>showQuestToast(b.icon, `解锁徽章：${b.name}`, 0, true), 700);
    }
  };
  if(ONBOARD_QUESTS.every(d=>q.onboardClaimed[d.id])) unlock('b_ice');
  if((s.greet||0)>=10) unlock('b_social');
  if((s.publish||0)>=1) unlock('b_host');
  if((s.join||0)>=5) unlock('b_active');
  if((s.viewPlace||0)>=PLACES.length) unlock('b_scout');
  if(q.streak>=3) unlock('b_streak');
}

// 升级判定（用已展示等级对比，避免重复弹窗）
function checkLevelUp(){
  const q = state.quest;
  if(!q._levelShown) q._levelShown = 1;
  const target = getLevel(q.xp).cur;
  if(target.lv > q._levelShown){
    q._levelShown = target.lv;
    q.justLeveled = target;
    setTimeout(()=>showLevelUp(target), 300);
  }
}

// 每日任务全部完成 → 连续天数 +1（同一天只计一次）
function checkDailyComplete(){
  const q = state.quest;
  ensureDaily();
  const allDone = q.dailyIds.length>0 && q.dailyIds.every(id=>q.dailyClaimed[id]);
  if(allDone && q.lastFullDaily!==q.dailyDate){
    const last = new Date(q.lastFullDaily);
    const today = new Date(q.dailyDate);
    const diff = q.lastFullDaily ? Math.round((today-last)/86400000) : 999;
    q.streak = (diff===1) ? (q.streak||0)+1 : 1;
    q.lastFullDaily = q.dailyDate;
    setTimeout(()=>showQuestToast('📅','每日任务全清！连续 '+q.streak+' 天', 0, true), 1000);
  }
}

function questProgress(pct){
  return `<div class="quest-progress"><div class="quest-progress-fill" style="width:${Math.min(pct,100)}%"></div></div>`;
}

// 任务完成/解锁提示（顶部飞入）
let questToastTimer;
function showQuestToast(icon, title, point, isBadge){
  let el = $('#quest-toast');
  if(!el){
    el = document.createElement('div');
    el.id = 'quest-toast';
    el.className = 'quest-toast';
    $('.app').appendChild(el);
  }
  el.innerHTML = `<div class="qt-badge">${isBadge?'🏅':icon}</div><div class="qt-copy"><b>${title}</b>${point?`<span>+${point} 经验值</span>`:''}</div>`;
  el.classList.remove('show'); void el.offsetWidth; el.classList.add('show');
  clearTimeout(questToastTimer);
  questToastTimer = setTimeout(()=>el.classList.remove('show'), 2200);
}

function showLevelUp(level){
  let el = $('#levelup-overlay');
  if(!el){
    el = document.createElement('div');
    el.id = 'levelup-overlay';
    el.className = 'levelup-overlay';
    $('.app').appendChild(el);
  }
  el.innerHTML = `
    <div class="levelup-card" onclick="this.parentElement.classList.remove('show')">
      <div class="lu-rays"></div>
      <div class="lu-icon">${level.icon}</div>
      <div class="lu-kicker">LEVEL UP</div>
      <div class="lu-title">升级到 Lv.${level.lv}</div>
      <div class="lu-name">${level.name}</div>
      <div class="lu-tip">点击关闭 · 继续保持 🐾</div>
    </div>`;
  el.classList.add('show');
}

// 更新底部徽章红点（新解锁未查看）
function renderQuestBadges(){
  const dot = $('#quest-new-dot');
  if(dot) dot.style.display = state.quest.justLeveled ? 'block' : 'none';
}

// 首页任务引导横幅：显示当前可做的任务，点击进任务中心
function questBannerHTML(){
  ensureDaily();
  const q = state.quest;
  const { cur, next } = getLevel(q.xp);
  // 找第一个未完成的新手任务；若新手全完成，则取第一个未完成的每日任务
  let task = ONBOARD_QUESTS.find(d=>!q.onboardClaimed[d.id]);
  let isDaily = false;
  if(!task){
    task = DAILY_QUEST_POOL.find(d=>q.dailyIds.includes(d.id) && !q.dailyClaimed[d.id]);
    isDaily = true;
  }
  if(!task) return ''; // 全部完成时不显示
  const progress = isDaily ? (q.daily[task.id]||0) : (q.onboard[task.id]||0);
  const pct = Math.round(progress/task.target*100);
  const xpToNext = next ? next.min - q.xp : 0;
  return `
    <div class="quest-banner" onclick="openQuestCenter()">
      <div class="qb-top">
        <div class="qb-level"><span class="qb-lv-icon">${cur.icon}</span> Lv.${cur.lv} ${cur.name}</div>
        <div class="qb-xp">${next?`再得 ${xpToNext} 经验升级`:'已满级'}</div>
      </div>
      ${questProgress(next ? q.xp/next.min*100 : 100)}
      <div class="qb-task">
        <div class="qb-task-icon">${task.icon}</div>
        <div class="qb-task-copy">
          <b>${isDaily?'今日任务':'新手任务'} · ${task.title}</b>
          <span>${task.desc} (${progress}/${task.target})</span>
        </div>
        <div class="qb-go">去做 ›</div>
      </div>
    </div>`;
}

// 任务中心：抽象出单个任务项
function questItem(def, progress, claimed, isDaily){
  const done = progress>=def.target;
  const pct = Math.round(Math.min(progress/def.target,1)*100);
  return `
    <div class="quest-item ${done?'done':''}" onclick="${done?`toast('已完成，经验已到账 ✓')`:`gotoQuest('${def.goto}')`}">
      <div class="qi-icon">${def.icon}</div>
      <div class="qi-main">
        <div class="qi-row"><b>${def.title}</b><span class="qi-point">+${def.point} XP</span></div>
        <div class="qi-desc">${def.desc}</div>
        <div class="qi-progress-row">
          ${questProgress(pct)}
          <span class="qi-count">${done?'✓ 已完成':`${progress}/${def.target}`}</span>
        </div>
      </div>
    </div>`;
}

// 完整任务中心（覆盖层）
function renderQuestCenter(){
  ensureDaily();
  const q = state.quest;
  const { cur, next } = getLevel(q.xp);
  const onboardHTML = ONBOARD_QUESTS.map(d=>questItem(d, q.onboard[d.id]||0, q.onboardClaimed[d.id], false)).join('');
  const dailyHTML = DAILY_QUEST_POOL.filter(d=>q.dailyIds.includes(d.id)).map(d=>questItem(d, q.daily[d.id]||0, q.dailyClaimed[d.id], true)).join('');
  const badgesHTML = BADGES.map(b=>{
    const owned = q.badges.includes(b.id);
    return `<div class="badge-item ${owned?'owned':'locked'}" onclick="toast('${b.name}：${b.desc}')">
      <div class="bi-icon">${owned?b.icon:'🔒'}</div>
      <div class="bi-name">${b.name}</div>
      <div class="bi-desc">${b.desc}</div>
    </div>`;
  }).join('');

  let el = $('#quest-center');
  if(!el){
    el = document.createElement('div');
    el.id = 'quest-center';
    el.className = 'screen-overlay';
    $('.app').appendChild(el);
  }
  const dailyDone = q.dailyIds.filter(id=>q.dailyClaimed[id]).length;
  el.innerHTML = `
    <div class="qc-inner">
      <div class="qc-header">
        <div class="qc-back" onclick="closeQuestCenter()">${ICON.back}</div>
        <div class="qc-header-title">任务中心</div>
        <div style="width:28px"></div>
      </div>
      <div class="qc-scroll">
        <div class="qc-level-card">
          <div class="qc-level-icon">${cur.icon}</div>
          <div class="qc-level-info">
            <div class="qc-level-badge">Lv.${cur.lv} · ${cur.name}</div>
            <div class="qc-level-xp">累计 ${q.xp} 经验值${q.streak?` · 连续 ${q.streak} 天`:''}</div>
            ${questProgress(next ? q.xp/next.min*100 : 100)}
            <div class="qc-level-next">${next?`距下一级还差 ${next.min-q.xp} 经验`:'已达最高等级 👑'}</div>
          </div>
        </div>
        <div class="qc-section-title">🌱 新手任务 <small>带你快速融入圈子</small></div>
        <div class="qc-quests">${onboardHTML}</div>
        <div class="qc-section-title">📅 今日任务 <small>${dailyDone}/${q.dailyIds.length} · 每天 0 点刷新</small></div>
        <div class="qc-quests">${dailyHTML}</div>
        <div class="qc-section-title">🏅 徽章墙 <small>${q.badges.length}/${BADGES.length} 已解锁</small></div>
        <div class="qc-badges">${badgesHTML}</div>
        <div class="qc-tip">完成任务赚取经验值，升级解锁更多标识。每日任务次日刷新，连续全清有惊喜 🐾</div>
      </div>
    </div>`;
}

function openQuestCenter(){
  renderQuestCenter();
  $('#quest-center').classList.add('open');
  state.quest.justLeveled = null;
  saveState();
  renderQuestBadges();
}
function closeQuestCenter(){ $('#quest-center').classList.remove('open'); }

// 任务点击 → 跳转到对应功能并关闭任务中心
function gotoQuest(tab){
  closeQuestCenter();
  switchTab(tab);
}

// ============================================================
// RENDER: Discover
// ============================================================
function renderDiscover(){
  const liveWalks = state.walks;
  const walksHTML = liveWalks.map(w=>{
    const isJoined = state.joinedMine.includes(w.id);
    const joinedCount = w.people + (isJoined?1:0);
    return `
    <article class="walk-card" onclick="openWalk('${w.id}')">
      <div class="wc-top">
        <div class="wc-dog">${avatarHTML(w.dogAvatar,'')}</div>
        <div class="wc-main">
          <div class="wc-title-row">
            <div class="wc-title">${w.title}</div>
            <span class="${w.status==='live'?'tag-live':'tag-soon'}">${w.statusText}</span>
          </div>
          <div class="wc-host">by ${w.host} · ${w.hostInfo}</div>
        </div>
      </div>
      <div class="wc-meta">
        <span>${ICON.pin}${w.place}</span>
        <span>${ICON.clock}${w.time}</span>
        <span>${ICON.pin}${w.dist}</span>
      </div>
      <div class="wc-tags">${w.tags.map(t=>`<span class="chip">${t}</span>`).join('')}</div>
      <div class="wc-bottom">
        <div class="avatars">${avatarsStack(w.joined)}${isJoined?`<div class="av" style="background:var(--orange)">🐾</div>`:''}<span class="more-n">${joinedCount}/${w.max} 只狗狗</span></div>
        <button class="join-btn ${isJoined?'joined':''}" onclick="event.stopPropagation();toggleJoin('${w.id}')">${isJoined?'✓ 已报名':'我也去'}</button>
      </div>
    </article>`;
  }).join('');

  const placesHTML = PLACES.map(p=>`
    <div class="place-card" onclick="openPlace('${p.id}')">
      <div class="place-img">
        <div class="emoji-scene">${p.emoji}</div>
        <span class="place-badge">${p.badge}</span>
        <span class="place-rating">⭐ ${p.rating}</span>
      </div>
      <div class="place-body">
        <h4>${p.name}</h4>
        <div class="addr">📍 ${p.addr}</div>
        <div class="place-feats">${p.feats.map(f=>`<span>${f}</span>`).join('')}</div>
      </div>
    </div>`).join('');

  const friendsHTML = FRIENDS.map(f=>`
    <div class="friend" onclick="greetFriend('${f.id}')">
      <div class="fav"><div class="fav-in" style="background:${f.color}">${f.emoji}</div></div>
      <div class="fn">${f.dog}</div>
      <div class="fd">${f.dist}</div>
    </div>`).join('');

  $('#discover-scroll').innerHTML = `
    <div class="app-header">
      <div class="brand">
        <div class="brand-mark">🐾</div>
        <div class="brand-txt"><div class="cn">Summer</div><div class="en">WALK WITH DOGS</div></div>
      </div>
      <div class="header-actions">
        <div class="icon-btn" onclick="openQuestCenter()" title="任务中心">
          <span style="font-size:19px">🎯</span><span class="dot" id="quest-new-dot" style="display:none"></span>
        </div>
        <div class="icon-btn" onclick="toast('暂无新通知')">${ICON.bell}<span class="dot"></span></div>
        <img class="avatar-me" src="${ASSET}dog-golden.png" onclick="switchTab('profile')" alt="">
      </div>
    </div>
    <div class="search-row">
      <div class="search-box" onclick="toast('搜索功能：可搜索遛狗点、狗友、活动')">${ICON.search}<span>搜索遛狗点 / 狗友 / 活动</span></div>
      <div class="filter-btn" onclick="toast('筛选：距离 / 犬型 / 时间')">${ICON.filter}筛选</div>
    </div>
    <div class="loc-strip"><span class="pin">${ICON.pin}</span><span>当前位置 · 徐汇滨江</span><span class="change">切换 ›</span></div>
    <div class="hero" onclick="openWalk('w1')">
      <img src="${ASSET}hero.png" alt="">
      <div class="hero-copy">
        <span class="kicker">今日热门</span>
        <h2>找个狗友<br>一起撒欢吧</h2>
        <p>附近 12 场遛狗局正在等你加入</p>
      </div>
      <div class="hero-cta">去看看 ›</div>
    </div>
    ${questBannerHTML()}
    <div class="section-head"><h3>🐾 附近的遛狗局</h3><span class="more" onclick="switchTab('map')">查看地图 ›</span></div>
    <div class="walk-list">${walksHTML}</div>
    <div class="section-head" style="padding-top:22px"><h3>🌿 推荐遛狗点</h3><span class="more" onclick="toast('显示全部场所')">全部 ›</span></div>
    <div class="places-scroll">${placesHTML}</div>
    <div class="section-head" style="padding-top:22px"><h3>👋 附近狗友</h3><span class="more" onclick="toast('发现更多狗友')">更多 ›</span></div>
    <div class="friends-row">${friendsHTML}</div>
    <div style="height:10px"></div>
  `;
}

// ============================================================
// RENDER: Map
// ============================================================
function renderMap(){
  const pinHTML = WALK_PINS.map(p=>{
    const w = state.walks.find(x=>x.id===p.walkId);
    if(!w) return '';
    return `<div class="map-pin" style="left:${p.x}%;top:${p.y}%" onclick="openWalk('${w.id}')">
      <div class="pin-dog"><div class="pd-av">${avatarHTML(w.dogAvatar,'')}</div><div class="pd-lbl">${w.dog}</div></div>
    </div>`;
  }).join('');
  const placePinHTML = PLACE_PINS.map(p=>{
    const pl = PLACES.find(x=>x.id===p.placeId);
    if(!pl) return '';
    return `<div class="map-pin" style="left:${p.x}%;top:${p.y}%" onclick="openPlace('${pl.id}')">
      <div class="pin-place"><span>${pl.emoji}</span></div>
    </div>`;
  }).join('');
  const sheetHTML = state.walks.slice(0,3).map(w=>`
    <div class="mini-walk" onclick="openWalk('${w.id}')">
      <div class="mav">${avatarHTML(w.dogAvatar,'')}</div>
      <div class="mt"><h5>${w.title}</h5><p>${w.place} · ${w.time} · ${w.dist}</p></div>
      <div class="mjoin" onclick="event.stopPropagation();toggleJoin('${w.id}')">${state.joinedMine.includes(w.id)?'已加入':'加入'}</div>
    </div>`).join('');

  $('#map-screen').innerHTML = `
    <div class="map-wrap">
      <div class="map-canvas">${MAP_SVG}</div>
      ${placePinHTML}
      ${pinHTML}
      <div class="map-search" onclick="toast('在地图上搜索')">${ICON.search}<span>搜索这一带...</span></div>
      <div class="map-controls">
        <button class="map-ctrl" onclick="toast('已定位到：徐汇滨江')">${ICON.locate}</button>
        <button class="map-ctrl" onclick="toast('切换地图图层')">${ICON.layers}</button>
      </div>
      <div class="map-fab" onclick="switchTab('post')">${ICON.plus}发起遛狗局</div>
      <div class="map-sheet">
        <div class="sheet-handle"></div>
        <div class="sheet-title">附近正在发生 <small>实时更新 · ${state.walks.length} 场</small></div>
        ${sheetHTML}
      </div>
    </div>`;
}

// ============================================================
// RENDER: Post
// ============================================================
let postDraft = { dog:'d1', type:'normal', place:PLACES[0].id, time:'', vis:'public' };
function renderPost(){
  const dogsHTML = MY_DOGS.map(d=>`
    <div class="dog-opt ${postDraft.dog===d.id?'sel':''}" onclick="pickDog('${d.id}')">
      <div class="dim"><div class="dim-in"><img src="${d.avatar}" alt=""></div></div>
      <div class="dn">${d.name}</div>
    </div>`).join('');
  const types = [
    {k:'normal',i:'🦮',t:'一起遛弯',s:'轻松散步'},
    {k:'run',i:'🎾',t:'撒欢放电',s:'奔跑玩耍'},
    {k:'cafe',i:'☕',t:'咖啡小聚',s:'狗狗下午茶'},
    {k:'train',i:'🎯',t:'训练课堂',s:'社交学习'},
  ];
  const typeHTML = types.map(t=>`
    <div class="type-opt ${postDraft.type===t.k?'sel':''}" onclick="pickType('${t.k}')">
      <div class="ti">${t.i}</div><div><div class="tt">${t.t}</div><div class="ts">${t.s}</div></div>
    </div>`).join('');
  const visHTML = [['public','公开'],['friends','仅好友'],['private','私密']].map(([k,l])=>
    `<div class="vis-opt ${postDraft.vis===k?'sel':''}" onclick="pickVis('${k}')">${l}</div>`).join('');

  $('#post-scroll').innerHTML = `
    <div class="post-header"><div class="cancel" onclick="switchTab('discover')">取消</div><h2>发起遛狗局</h2><div style="width:30px"></div></div>
    <div class="post-form">
      <div class="field"><label>① 带哪只狗狗参加 <span class="req">*</span></label><div class="choose-dogs">${dogsHTML}</div></div>
      <div class="field"><label>② 活动类型</label><div class="type-grid">${typeHTML}</div></div>
      <div class="field"><label>③ 活动标题 <span class="req">*</span></label><input class="input" id="f-title" placeholder="例如：傍晚滨江撒欢局 🐕" value="傍晚一起去遛狗吧 🐕"></div>
      <div class="field"><label>④ 地点 <span class="req">*</span></label>
        <div class="select-like" onclick="cyclePlace()"><span id="f-place-label">📍 ${PLACES.find(p=>p.id===postDraft.place).name}</span>${ICON.chevron}</div>
      </div>
      <div class="row-2">
        <div class="field"><label>⑤ 日期时间</label><input class="input" id="f-time" type="datetime-local" value="${postDraft.time}"></div>
        <div class="field"><label>⑥ 人数上限</label><input class="input" type="number" id="f-max" min="2" max="20" value="8"></div>
      </div>
      <div class="field"><label>⑦ 活动说明</label><textarea class="input" id="f-desc" placeholder="告诉大家集合点、要带什么...">天气不错，带毛孩子一起出去玩！记得带水和拾便袋～</textarea></div>
      <div class="field"><label>⑧ 谁可以看到</label><div class="visibility">${visHTML}</div></div>
      <button class="publish-btn" onclick="publishWalk()">${ICON.plus} 发布遛狗局</button>
      <div style="text-align:center;font-size:11px;color:var(--muted);margin-top:-6px">发布后附近狗友就能看到并报名啦 🐾</div>
    </div>`;
  const dt = $('#f-time');
  if(dt && !dt.value){
    const now = new Date(); now.setHours(now.getHours()+2); now.setMinutes(0);
    dt.value = toLocalInput(now);
  }
}
function toLocalInput(d){
  const pad=n=>String(n).padStart(2,'0');
  return `${d.getFullYear()}-${pad(d.getMonth()+1)}-${pad(d.getDate())}T${pad(d.getHours())}:${pad(d.getMinutes())}`;
}
function pickDog(id){ postDraft.dog=id; renderPost(); }
function pickType(k){ postDraft.type=k; renderPost(); }
function pickVis(k){ postDraft.vis=k; renderPost(); }
function cyclePlace(){
  const i = PLACES.findIndex(p=>p.id===postDraft.place);
  postDraft.place = PLACES[(i+1)%PLACES.length].id;
  $('#f-place-label').textContent = '📍 '+PLACES.find(p=>p.id===postDraft.place).name;
}
function publishWalk(){
  const title = $('#f-title').value.trim();
  if(!title){ toast('给活动起个标题吧'); return; }
  const dog = MY_DOGS.find(d=>d.id===postDraft.dog);
  const place = PLACES.find(p=>p.id===postDraft.place);
  const timeVal = $('#f-time').value;
  const timeStr = timeVal ? formatTime(timeVal) : '时间待定';
  const max = parseInt($('#f-max').value)||8;
  const desc = $('#f-desc').value.trim();
  const typeLabels = {normal:'一起遛弯',run:'撒欢放电',cafe:'咖啡小聚',train:'训练课堂'};
  const newWalk = {
    id:'w'+Date.now(), title, dog:dog.name, dogAvatar:dog.avatar,
    host:dog.name+'的家长', hostAvatar:dog.avatar, hostInfo:`${dog.breed} · ${dog.tags[0]}`,
    status:'soon', statusText:'刚刚发布', place:place.name, time:timeStr, dist:'0.0km',
    people:0, max, joined:[], tags:[typeLabels[postDraft.type],'新活动'],
    desc:desc||'欢迎大家一起来！', placeEmoji:place.emoji,
  };
  state.walks.unshift(newWalk);
  state.joinedMine.push(newWalk.id);
  track('publish');
  saveState();
  renderAll();
  switchTab('discover');
  toast('🎉 遛狗局发布成功！');
}
function formatTime(v){
  const d = new Date(v);
  const wd = ['周日','周一','周二','周三','周四','周五','周六'][d.getDay()];
  const pad=n=>String(n).padStart(2,'0');
  const today = new Date();
  const isToday = d.toDateString()===today.toDateString();
  return `${isToday?'今天':(d.getMonth()+1)+'月'+d.getDate()+'日 '+wd} ${pad(d.getHours())}:${pad(d.getMinutes())}`;
}

// ============================================================
// RENDER: Messages
// ============================================================
function renderMessages(){
  const listHTML = state.chats.map(c=>`
    <div class="msg-item" onclick="openChat('${c.id}')">
      <div class="msg-av" style="background:${c.color}">${c.emoji}${c.unread?'<span class="unread"></span>':''}</div>
      <div class="msg-body">
        <div class="r1"><span class="nm">${c.friend}</span><span class="tm">${c.time}</span></div>
        <div class="pv"><b>${c.msgs[c.msgs.length-1].from==='me'?'我：':''}</b>${c.msgs[c.msgs.length-1].text}</div>
      </div>
    </div>`).join('');
  $('#messages-scroll').innerHTML = `
    <div class="msg-header"><h2>消息</h2></div>
    <div class="msg-list">${listHTML}</div>
    <div style="height:10px"></div>`;
}

// ============================================================
// RENDER: Profile
// ============================================================
function renderProfile(){
  const dogsHTML = MY_DOGS.map(d=>`
    <div class="my-dog-card" onclick="toast('查看 ${d.name} 的档案')">
      <img src="${d.avatar}" alt="">
      <div><h5>${d.name}</h5><p>${d.breed} · ${d.age}</p></div>
    </div>`).join('');
  const myCount = state.walks.filter(w=>state.joinedMine.includes(w.id)).length;
  const { cur, next } = getLevel(state.quest.xp);
  $('#profile-scroll').innerHTML = `
    <div class="profile-hero">
      <img class="ph-av" src="${ASSET}dog-golden.png" alt="">
      <div class="ph-info">
        <h2>豆包的家长</h2>
        <p>📍 上海 · 徐汇滨江</p>
        <div class="ph-stats">
          <div><b>${MY_DOGS.length}</b><span>我的狗狗</span></div>
          <div><b>${myCount}</b><span>参与活动</span></div>
          <div><b>${FRIENDS.length}</b><span>狗友</span></div>
        </div>
      </div>
    </div>
    <div class="level-strip" onclick="openQuestCenter()">
      <div class="ls-icon">${cur.icon}</div>
      <div class="ls-main">
        <div class="ls-title"><b>Lv.${cur.lv} ${cur.name}</b><span>任务中心 ›</span></div>
        ${questProgress(next ? state.quest.xp/next.min*100 : 100)}
        <div class="ls-xp">${state.quest.xp} 经验${next?` · 距升级还差 ${next.min-state.quest.xp}`:' · 已满级'}</div>
      </div>
    </div>
    <div class="section-head"><h3>🐕 我的毛孩子</h3><span class="more" onclick="toast('添加狗狗')">+ 添加</span></div>
    <div class="my-dogs">${dogsHTML}</div>
    <div class="menu-group">
      <div class="menu-item" onclick="openQuestCenter()"><div class="mi">🎯</div><div class="mt">任务与徽章</div><div class="mv">${state.quest.badges.length} 枚徽章</div><div class="marrow">›</div></div>
      <div class="menu-item" onclick="toast('我发起的遛狗局')"><div class="mi">📢</div><div class="mt">我发起的活动</div><div class="mv">${state.walks.filter(w=>w.host.includes('家长')).length} 场</div><div class="marrow">›</div></div>
      <div class="menu-item" onclick="toast('我报名的活动')"><div class="mi">🐾</div><div class="mt">我报名的活动</div><div class="mv">${myCount} 场</div><div class="marrow">›</div></div>
      <div class="menu-item" onclick="toast('遛狗足迹')"><div class="mi">🗺️</div><div class="mt">遛狗足迹</div><div class="mv">12.6 km</div><div class="marrow">›</div></div>
      <div class="menu-item" onclick="openQuestCenter()"><div class="mi">🏅</div><div class="mt">成就徽章</div><div class="mv">${state.quest.badges.length}/${BADGES.length}</div><div class="marrow">›</div></div>
    </div>
    <div class="menu-group">
      <div class="menu-item" onclick="toast('隐私设置：模糊距离、家庭隐私圈')"><div class="mi">🔒</div><div class="mt">隐私与安全</div><div class="marrow">›</div></div>
      <div class="menu-item" onclick="toast('消息通知设置')"><div class="mi">🔔</div><div class="mt">消息通知</div><div class="marrow">›</div></div>
      <div class="menu-item" onclick="toast('Summer · 演示版本 v1.0')"><div class="mi">⚙️</div><div class="mt">设置</div><div class="marrow">›</div></div>
    </div>
    <div style="height:10px"></div>`;
}

// ============================================================
// Interactions
// ============================================================
function switchTab(tab){
  $$('.tab').forEach(t=>t.classList.toggle('active', t.dataset.tab===tab));
  $$('.screen').forEach(s=>s.classList.remove('active'));
  const map = {discover:'screen-discover', post:'screen-post', messages:'screen-messages', profile:'screen-profile'};
  if(tab==='map'){
    $('#map-screen').classList.add('active');
    renderMap();
    track('viewMap');
  } else {
    $('#'+map[tab]).classList.add('active');
  }
  // reset scroll
  const active = $('.screen.active .scroll'); if(active) active.scrollTop=0;
  // update badge
  const badge = $('.tab[data-tab="messages"] .badge');
  const unread = state.chats.reduce((a,c)=>a+c.unread,0);
  if(badge){ badge.textContent=unread; badge.style.display=unread?'flex':'none'; }
}

function toggleJoin(id){
  const w = state.walks.find(x=>x.id===id);
  if(!w) return;
  if(state.joinedMine.includes(id)){
    state.joinedMine = state.joinedMine.filter(x=>x!==id);
    toast('已取消报名');
  } else {
    state.joinedMine.push(id);
    toast(`🐾 报名成功！去和 ${w.dog} 一起玩吧`);
    track('joinWalk');
  }
  saveState();
  renderAll();
  // refresh open detail if any
  if($('#overlay').classList.contains('open') && $('#overlay').dataset.walkId===id){
    openWalk(id);
  }
}

function openWalk(id){
  const w = state.walks.find(x=>x.id===id);
  if(!w) return;
  track('viewWalk');
  const isJoined = state.joinedMine.includes(id);
  const joinedCount = w.people + (isJoined?1:0);
  const participants = w.joined.map(fid=>{
    const f = FRIENDS.find(x=>x.id===fid);
    return f?`<div class="av" style="width:34px;height:34px;margin:0;font-size:18px;background:${f.color}">${f.emoji}</div>`:'';
  }).join('') + (isJoined?`<div class="av" style="width:34px;height:34px;margin:0;background:var(--orange)">🐾</div>`:'');

  const overlay = $('#overlay');
  overlay.dataset.walkId = id;
  overlay.innerHTML = `
    <div class="detail-sheet" onclick="event.stopPropagation()">
      <div class="detail-handle"></div>
      <div class="detail-hero-img">
        <div class="dhi-emoji">${w.placeEmoji||'🌳'}</div>
        <span class="detail-badge" style="background:${w.status==='live'?'var(--green)':'var(--orange)'}">${w.statusText}</span>
      </div>
      <div class="detail-title">${w.title}</div>
      <div class="detail-host">
        ${avatarHTML(w.hostAvatar,'dhav')}
        <div class="dhn"><b>${w.host}</b><span>${w.hostInfo}</span></div>
      </div>
      <div class="detail-info-grid">
        <div class="di-cell"><div class="ici">${ICON.pin}</div><div class="ict"><span>地点</span><b>${w.place}</b></div></div>
        <div class="di-cell"><div class="ici">${ICON.clock}</div><div class="ict"><span>时间</span><b>${w.time}</b></div></div>
        <div class="di-cell"><div class="ici">📏</div><div class="ict"><span>距离</span><b>${w.dist}</b></div></div>
        <div class="di-cell"><div class="ici">${ICON.users}</div><div class="ict"><span>已报名</span><b>${joinedCount} / ${w.max}</b></div></div>
      </div>
      <div class="detail-desc">${w.desc}</div>
      <div class="wc-tags" style="margin-bottom:16px">${w.tags.map(t=>`<span class="chip">${t}</span>`).join('')}</div>
      <div class="detail-participants">
        <h4>🐾 已经报名的狗狗</h4>
        <div class="avatars" style="gap:6px">${participants||'<span style="font-size:12px;color:var(--muted)">还没有狗友报名，来做第一个吧</span>'}</div>
      </div>
      <div class="detail-actions">
        <button class="chat-act" onclick="openChatByWalk('${w.id}')">${ICON.chat}</button>
        <button class="big-join ${isJoined?'joined':''}" onclick="toggleJoin('${w.id}')">${isJoined?'✓ 已报名，点击取消':'我也去 · 立即报名'}</button>
      </div>
    </div>`;
  overlay.classList.add('open');
}
function openPlace(id){
  const p = PLACES.find(x=>x.id===id);
  if(!p) return;
  track('viewPlace');
  const overlay = $('#overlay');
  overlay.removeAttribute('data-walk-id');
  overlay.innerHTML = `
    <div class="detail-sheet" onclick="event.stopPropagation()">
      <div class="detail-handle"></div>
      <div class="detail-hero-img">
        <div class="dhi-emoji">${p.emoji}</div>
        <span class="detail-badge" style="background:var(--green)">${p.badge}</span>
      </div>
      <div class="detail-title">${p.name}</div>
      <div class="wc-meta" style="margin-top:10px"><span>${ICON.pin}${p.addr}</span><span>⭐ ${p.rating}</span></div>
      <div class="detail-desc" style="margin-top:14px">由狗友们实地标注的宠物友好去处。带毛孩子来之前记得确认现场规定，一起维护好环境～</div>
      <div class="wc-tags" style="margin-bottom:18px">${p.feats.map(f=>`<span class="chip">${f}</span>`).join('')}</div>
      <div class="detail-actions">
        <button class="big-join" onclick="closeOverlay();switchTab('post')">${ICON.plus} 在这里发起遛狗局</button>
      </div>
    </div>`;
  overlay.classList.add('open');
}
function closeOverlay(){ $('#overlay').classList.remove('open'); }

function openChat(id){
  const c = state.chats.find(x=>x.id===id);
  if(!c) return;
  c.unread = 0; saveState();
  const cv = $('#chat-view');
  cv.innerHTML = `
    <div class="chat-top">
      <div class="chat-back" onclick="closeChat()">${ICON.back}</div>
      <div class="chat-who">
        <div class="ca" style="background:${c.color}">${c.emoji}</div>
        <div><div class="cn">${c.friend}</div><div class="cs">● 最近活跃</div></div>
      </div>
    </div>
    <div class="chat-body" id="chat-body">
      ${c.msgs.map(m=>`<div class="bubble ${m.from}">${m.text}<span class="bt">${m.t}</span></div>`).join('')}
    </div>
    <div class="chat-input">
      <input class="ci-field" id="chat-field" placeholder="发条消息..." onkeydown="if(event.key==='Enter')sendChat('${c.id}')">
      <button class="chat-send" onclick="sendChat('${c.id}')">${ICON.send}</button>
    </div>`;
  cv.classList.add('open');
  $$('.screen').forEach(s=>s.classList.remove('active'));
  $('#screen-messages').classList.add('active');
  setTimeout(()=>{ const b=$('#chat-body'); if(b) b.scrollTop=b.scrollHeight; },50);
}
function openChatByWalk(walkId){
  closeOverlay();
  switchTab('messages');
  setTimeout(()=>openChat('c1'),150);
}
function closeChat(){ $('#chat-view').classList.remove('open'); renderMessages(); }
function sendChat(id){
  const c = state.chats.find(x=>x.id===id);
  const f = $('#chat-field');
  if(!f || !f.value.trim()) return;
  const now = new Date();
  const t = `${String(now.getHours()).padStart(2,'0')}:${String(now.getMinutes()).padStart(2,'0')}`;
  c.msgs.push({from:'me', text:f.value.trim(), t});
  c.time = t;
  track('sendChat');
  saveState();
  openChat(id);
  setTimeout(()=>{ const b=$('#chat-body'); if(b) b.scrollTop=b.scrollHeight; },30);
}

function greetFriend(id){
  const f = FRIENDS.find(x=>x.id===id);
  if(!f) return;
  if(!state.quest._greeted) state.quest._greeted = {};
  if(state.quest._greeted[id]){
    toast(`你已经和 ${f.dog} 打过招呼啦 🐾`);
    return;
  }
  state.quest._greeted[id] = true;
  toast(`已向 ${f.dog} 发送打招呼 🐾`);
  track('greet');
  saveState();
}

// toast
let toastTimer;
function toast(msg){
  const t = $('#toast');
  t.textContent = msg;
  t.classList.add('show');
  clearTimeout(toastTimer);
  toastTimer = setTimeout(()=>t.classList.remove('show'), 2000);
}

// clock in status bar
function updateClock(){
  const now = new Date();
  $('#sb-time').textContent = `${now.getHours()}:${String(now.getMinutes()).padStart(2,'0')}`;
}

function renderAll(){
  renderDiscover();
  renderMessages();
  renderProfile();
  renderMap();
  renderQuestBadges();
  // post only re-render when active or first time
  if($('#screen-post').classList.contains('active') || !$('#post-scroll').innerHTML.trim()) renderPost();
}

// ============================================================
// INIT
// ============================================================
document.addEventListener('DOMContentLoaded', ()=>{
  updateClock(); setInterval(updateClock, 30000);
  ensureDaily();
  renderAll();
  // deep link support: ?tab=map|post|messages|profile, ?walk=w1, ?place=p1, ?chat=c1
  const qs = new URLSearchParams(location.search);
  const tab = qs.get('tab');
  const validTabs = ['discover','map','post','messages','profile'];
  switchTab(validTabs.includes(tab) ? tab : 'discover');
  const walk = qs.get('walk'); if(walk) setTimeout(()=>openWalk(walk),120);
  const place = qs.get('place'); if(place) setTimeout(()=>openPlace(place),120);
  const chat = qs.get('chat'); if(chat) setTimeout(()=>openChat(chat),120);
  if(qs.get('quest')==='1') setTimeout(()=>openQuestCenter(),120);
  // bind tabs
  $$('.tab').forEach(t=>t.addEventListener('click', ()=>{
    if($('#chat-view').classList.contains('open')) closeChat();
    switchTab(t.dataset.tab);
  }));
  // overlay click to close
  $('#overlay').addEventListener('click', closeOverlay);
});
