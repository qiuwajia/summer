/* ============================================================
   Summer — Seed data layer
   All content here is demo data. Persisted state lives in localStorage.
   ============================================================ */

const ASSET = 'assets/';

// My dogs
const MY_DOGS = [
  { id:'d1', name:'豆包', breed:'金毛', age:'3岁', avatar: ASSET+'dog-golden.png', emoji:'🦴', tags:['社牛','大型犬'] },
  { id:'d2', name:'麻糬', breed:'柴犬', age:'2岁', avatar: ASSET+'dog-shiba.png', emoji:'🍡', tags:['温顺','中型犬'] },
];

// People / dog friends (emoji-based avatars for variety)
const FRIENDS = [
  { id:'f1', name:'小满 & 可乐', dog:'可乐', breed:'柯基', dist:'0.3km', emoji:'🐶', color:'linear-gradient(135deg,#FFD08A,#FF9A5B)' },
  { id:'f2', name:'阿哲 & 团子', dog:'团子', breed:'萨摩耶', dist:'0.6km', emoji:'🐕', color:'linear-gradient(135deg,#BFE9FF,#7CC4F5)' },
  { id:'f3', name:'Yuki & Lucky', dog:'Lucky', breed:'边牧', dist:'0.9km', emoji:'🦮', color:'linear-gradient(135deg,#D9C6FF,#A98BF0)' },
  { id:'f4', name:'大熊 & 布丁', dog:'布丁', breed:'泰迪', dist:'1.2km', emoji:'🐩', color:'linear-gradient(135deg,#FFC9C9,#FF9A9A)' },
  { id:'f5', name:'琳达 & 阿福', dog:'阿福', breed:'拉布拉多', dist:'1.5km', emoji:'🐕‍🦺', color:'linear-gradient(135deg,#C8F0D8,#7FD6A0)' },
];

// Dog-friendly places
const PLACES = [
  { id:'p1', name:'徐汇滨江狗狗乐园', addr:'徐汇区龙腾大道 · 1.1km', emoji:'🌳', rating:'4.9', badge:'免门票', feats:['围栏','小型犬区','饮水点'] },
  { id:'p2', name:'世纪公园宠物草坪', addr:'浦东新区 · 2.4km', emoji:'🌿', rating:'4.8', badge:'超大面积', feats:['可牵绳','饮水点','停车'] },
  { id:'p3', name:'愚园路宠物友好咖啡', addr:'长宁区愚园路 · 3.0km', emoji:'☕', rating:'4.7', badge:'宠物友好', feats:['露台','宠物菜单'] },
  { id:'p4', name:'共青森林公园', addr:'杨浦区 · 4.6km', emoji:'🌲', rating:'4.9', badge:'遛狗圣地', feats:['大草坪','湖边','停车'] },
];

// Walks / meetups
const WALKS = [
  {
    id:'w1', title:'傍晚滨江撒欢局 🐕', dog:'豆包', dogAvatar: ASSET+'dog-golden.png',
    host:'豆包的家长', hostAvatar: ASSET+'dog-golden.png', hostInfo:'金毛 · 社牛 · 3岁',
    status:'live', statusText:'正在进行', place:'徐汇滨江狗狗乐园', time:'今天 17:30', dist:'0.3km',
    people:4, max:8, joined:['f1','f2','f3','f4'],
    tags:['大型犬友好','可带飞盘','新手欢迎'],
    desc:'趁着天气好，带毛孩子去滨江跑一跑！我们几个已经到了，带飞盘和玩具的可以一起玩。小狗大人都可以来，注意牵绳就好～',
    placeEmoji:'🌳',
  },
  {
    id:'w2', title:'周末草坪放电大会', dog:'可乐', dogAvatar:'🐶',
    host:'小满', hostAvatar: FRIENDS[0].color, hostInfo:'柯基 · 短腿 · 2岁',
    status:'soon', statusText:'即将开始', place:'世纪公园宠物草坪', time:'明天 09:00', dist:'2.4km',
    people:6, max:10, joined:['f2','f3','f5'],
    tags:['带水','防晒','狗狗社交'],
    desc:'周末早上凉快，约上小伙伴一起去世纪公园的大草坪放放电。记得带足饮用水和拾便袋，一起维护好环境～',
    placeEmoji:'🌿',
  },
  {
    id:'w3', title:'愚园路咖啡遛弯小聚', dog:'麻糬', dogAvatar: ASSET+'dog-shiba.png',
    host:'Yuki', hostAvatar: FRIENDS[2].color, hostInfo:'边牧 · 聪明 · 4岁',
    status:'soon', statusText:'招募中', place:'愚园路宠物友好咖啡', time:'周六 14:00', dist:'3.0km',
    people:3, max:6, joined:['f1','f4'],
    tags:['咖啡','小型犬','安静'],
    desc:'遛完弯一起坐坐，这家咖啡店的露台可以带狗。性格温顺的狗狗优先哦，大家有个安静的下午茶。',
    placeEmoji:'☕',
  },
];

// Chat conversations
const CHATS = [
  {
    id:'c1', friend:'小满 & 可乐', emoji:'🐶', color:FRIENDS[0].color, time:'17:22', unread:2,
    msgs:[
      { from:'them', text:'我们到滨江啦！凤鸣路那个入口～', t:'17:18' },
      { from:'me', text:'好好好，我们停车中，5分钟到！', t:'17:20' },
      { from:'them', text:'带飞盘了没？可乐一直盯着别人的玩 😂', t:'17:22' },
      { from:'them', text:'草地那边位置很空，直接过来就行', t:'17:22' },
    ]
  },
  { id:'c2', friend:'阿哲 & 团子', emoji:'🐕', color:FRIENDS[1].color, time:'昨天', unread:0,
    msgs:[
      { from:'them', text:'明天世纪公园那个局还去吗？', t:'昨天 20:10' },
      { from:'me', text:'去的！团子可以和小狗们熟悉熟悉', t:'昨天 20:15' },
      { from:'them', text:'好嘞，9点草坪见 👌', t:'昨天 20:16' },
    ]
  },
  { id:'c3', friend:'Yuki & Lucky', emoji:'🦮', color:FRIENDS[2].color, time:'周二', unread:0,
    msgs:[
      { from:'them', text:'周六咖啡那家我查了下，露台确实能带狗', t:'周二 11:30' },
      { from:'me', text:'太好了，到时候早点去占个位置', t:'周二 11:33' },
    ]
  },
];

// Map pin positions (percent of map canvas) — walks
const WALK_PINS = [
  { walkId:'w1', x:38, y:42 },
  { walkId:'w2', x:64, y:28 },
  { walkId:'w3', x:26, y:66 },
];
// Map pins — places
const PLACE_PINS = [
  { placeId:'p1', x:44, y:48 },
  { placeId:'p2', x:70, y:33 },
  { placeId:'p3', x:22, y:60 },
  { placeId:'p4', x:80, y:68 },
];

// Map SVG background (stylized neighborhood)
const MAP_SVG = `
<svg viewBox="0 0 393 700" preserveAspectRatio="xMidYMid slice" xmlns="http://www.w3.org/2000/svg">
  <rect width="393" height="700" fill="#EDE8DE"/>
  <!-- park areas -->
  <path d="M0 0 H150 V140 H0 Z" fill="#CFE7C4"/>
  <path d="M250 120 H393 V300 H250 Z" fill="#CFE7C4"/>
  <path d="M40 380 H200 V560 H40 Z" fill="#D6EBCA"/>
  <path d="M280 470 H393 V700 H280 Z" fill="#CFE7C4"/>
  <!-- water -->
  <path d="M0 600 Q120 560 230 610 T393 590 V700 H0 Z" fill="#Bcd9ee"/>
  <!-- roads -->
  <g stroke="#FBF9F4" stroke-width="18" fill="none">
    <path d="M0 170 H393"/><path d="M0 340 H393"/><path d="M0 520 H393"/>
    <path d="M160 0 V700"/><path d="M320 0 V700"/>
  </g>
  <g stroke="#F4F0E8" stroke-width="9" fill="none">
    <path d="M70 0 V700"/><path d="M240 0 V700"/>
    <path d="M0 90 H393"/><path d="M0 430 H393"/><path d="M0 650 H393"/>
  </g>
  <!-- faint blocks -->
  <g fill="#E4DFD4" opacity="0.6">
    <rect x="180" y="190" width="45" height="45" rx="6"/>
    <rect x="335" y="190" width="45" height="45" rx="6"/>
    <rect x="90" y="360" width="50" height="55" rx="6"/>
    <rect x="345" y="360" width="40" height="50" rx="6"/>
    <rect x="185" y="550" width="45" height="55" rx="6"/>
  </g>
  <!-- park tree dots -->
  <g fill="#A9D08E" opacity="0.7">
    <circle cx="40" cy="40" r="9"/><circle cx="90" cy="80" r="7"/><circle cx="120" cy="40" r="8"/>
    <circle cx="290" cy="160" r="9"/><circle cx="340" cy="200" r="7"/><circle cx="360" cy="150" r="8"/>
    <circle cx="70" cy="430" r="8"/><circle cx="130" cy="480" r="9"/><circle cx="90" cy="520" r="7"/>
  </g>
</svg>`;

/* ============================================================
   QUEST SYSTEM — Summer 游戏化任务
   ============================================================ */

// 新手引导链：固定顺序，帮助新人完成融入圈子的关键动作
const ONBOARD_QUESTS = [
  { id:'ob1', icon:'🔍', title:'逛逛附近',   desc:'点开一个遛狗局看看大家在玩什么', point:10, event:'viewWalk',  target:1, goto:'discover' },
  { id:'ob2', icon:'👋', title:'认识邻居',   desc:'向一位附近的狗友打个招呼',       point:10, event:'greet',     target:1, goto:'discover' },
  { id:'ob3', icon:'🌿', title:'踩点场地',   desc:'查看一个宠物友好的遛狗场所',     point:10, event:'viewPlace', target:1, goto:'discover' },
  { id:'ob4', icon:'🐾', title:'首次约遛',   desc:'报名一场附近的遛狗局',           point:20, event:'joinWalk',  target:1, goto:'discover' },
  { id:'ob5', icon:'💬', title:'打开话匣',   desc:'给狗友发送一条消息',             point:20, event:'sendChat',  target:1, goto:'messages' },
];

// 每日随机任务池：每天按日期种子抽取 3 个，做完后次日刷新
const DAILY_QUEST_POOL = [
  { id:'dq_explore', icon:'🔎', title:'探索达人',   desc:'浏览 3 个遛狗局',       point:15, event:'viewWalk',  target:3, goto:'discover' },
  { id:'dq_social',  icon:'🦋', title:'社交蝴蝶',   desc:'向 2 位狗友打招呼',     point:15, event:'greet',     target:2, goto:'discover' },
  { id:'dq_join',    icon:'🎾', title:'活力玩家',   desc:'报名 1 场遛狗局',       point:20, event:'joinWalk',  target:1, goto:'discover' },
  { id:'dq_chat',    icon:'💬', title:'闲聊高手',   desc:'发送 2 条消息',         point:15, event:'sendChat',  target:2, goto:'messages' },
  { id:'dq_place',   icon:'🗺️', title:'场地勘探',   desc:'查看 2 个遛狗场所',     point:15, event:'viewPlace', target:2, goto:'discover' },
  { id:'dq_host',    icon:'📣', title:'组织者',     desc:'发起 1 场遛狗局',       point:25, event:'publish',   target:1, goto:'post' },
  { id:'dq_map',     icon:'🧭', title:'地图达人',   desc:'打开地图 3 次',         point:10, event:'viewMap',   target:3, goto:'map' },
];

// 等级体系（按累计经验值）
const LEVELS = [
  { lv:1, name:'初来乍到', min:0,   icon:'🌱' },
  { lv:2, name:'熟门熟路', min:80,  icon:'🐕' },
  { lv:3, name:'圈子红人', min:180, icon:'⭐' },
  { lv:4, name:'遛狗老炮', min:350, icon:'🏆' },
  { lv:5, name:'狗狗大使', min:600, icon:'👑' },
];

// 徽章定义（达成条件由 app.js 判定）
const BADGES = [
  { id:'b_ice',    icon:'🧊', name:'破冰者',   desc:'完成全部新手任务' },
  { id:'b_social', icon:'💞', name:'社交达人', desc:'累计打招呼 10 次' },
  { id:'b_host',   icon:'📣', name:'组织者',   desc:'发起第一场遛狗局' },
  { id:'b_active', icon:'🔥', name:'活动家',   desc:'累计报名 5 场遛狗局' },
  { id:'b_scout',  icon:'🔭', name:'探险家',   desc:'查看全部遛狗场所' },
  { id:'b_streak', icon:'📅', name:'坚持不懈', desc:'连续 3 天完成每日任务' },
];

// Icons (inline SVG strings)
const ICON = {
  search:`<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="7"/><path d="M21 21l-4-4"/></svg>`,
  filter:`<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 6h16M7 12h10M10 18h4"/></svg>`,
  pin:`<svg viewBox="0 0 24 24" fill="currentColor"><path d="M12 2a7 7 0 0 0-7 7c0 5 7 13 7 13s7-8 7-13a7 7 0 0 0-7-7zm0 9.5A2.5 2.5 0 1 1 12 6a2.5 2.5 0 0 1 0 5.5z"/></svg>`,
  clock:`<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/></svg>`,
  users:`<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="9" cy="8" r="3"/><path d="M3 20c0-3 3-5 6-5s6 2 6 5"/><path d="M16 5a3 3 0 0 1 0 6M18 15c2 .7 3 2.3 3 5"/></svg>`,
  bell:`<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 8a6 6 0 0 0-12 0c0 7-3 7-3 9h18c0-2-3-2-3-9z"/><path d="M10 21h4"/></svg>`,
  chat:`<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15a4 4 0 0 1-4 4H8l-5 3V7a4 4 0 0 1 4-4h10a4 4 0 0 1 4 4z"/></svg>`,
  send:`<svg viewBox="0 0 24 24" fill="currentColor"><path d="M2 21l21-9L2 3v7l15 2-15 2z"/></svg>`,
  plus:`<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M12 5v14M5 12h14"/></svg>`,
  layers:`<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 2L2 7l10 5 10-5z"/><path d="M2 12l10 5 10-5M2 17l10 5 10-5"/></svg>`,
  locate:`<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="8"/><circle cx="12" cy="12" r="3" fill="currentColor"/><path d="M12 2v3M12 19v3M2 12h3M19 12h3"/></svg>`,
  back:`<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M15 18l-6-6 6-6"/></svg>`,
  chevron:`<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 18l6-6-6-6"/></svg>`,
  // tab icons
  tabHome:`<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 11l9-8 9 8"/><path d="M5 10v10h14V10"/><path d="M9 20v-6h6v6"/></svg>`,
  tabMap:`<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 3L3 5v16l6-2 6 2 6-2V3l-6 2z"/><path d="M9 3v16M15 5v16"/></svg>`,
  tabChat:`<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15a4 4 0 0 1-4 4H8l-5 3V7a4 4 0 0 1 4-4h10a4 4 0 0 1 4 4z"/></svg>`,
  tabUser:`<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="8" r="4"/><path d="M4 21c0-4 4-6 8-6s8 2 8 6"/></svg>`,
};
