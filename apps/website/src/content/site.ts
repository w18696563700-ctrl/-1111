export const siteConfig = {
  name: '展览装修之家',
  alternateName: '展览定制之家',
  url: 'https://zhanlan.ddup-ddup.com',
  title: '展览装修之家 | 展览项目展示与资料协作平台',
  description:
    '面向展览装修与展览定制场景的项目展示、企业展示、项目沟通与资料协作平台，首发围绕展览、消息、我的三楼展开。',
  ogTitle: '展览装修之家',
  ogDescription:
    '用清晰的项目展示、企业展示、项目沟通和资料协作，承接展览装修与展览定制场景的首发体验。',
  keywords: [
    '展览装修',
    '展览定制',
    '展台搭建',
    '展览项目管理',
    '展览企业展示',
    '展会装修平台',
    '展览项目沟通',
    '展览资料协作',
  ],
  contactEmail: '182401625@qq.com',
  brandMark: '展',
  labels: {
    homeAria: '首页',
    navigationAria: '官网导航',
    footerAria: '页脚导航',
    proofListAria: '首发重点',
    previewAria: 'App 首页视觉样机',
    trustStripAria: '首发能力条',
    sourcePrefix: '正式源',
  },
  headerActions: [
    { label: '联系平台', href: '/contact', variant: 'primary' },
    { label: '查看用户协议', href: '/terms', variant: 'secondary' },
  ],
};

export const navigation = [
  { label: '首页', href: '/' },
  { label: '平台定位', href: '#positioning' },
  { label: '核心场景', href: '#scenarios' },
  { label: '能力边界', href: '#boundaries' },
  { label: '适用对象', href: '#audience' },
  { label: '联系平台', href: '/contact' },
];

export const hero = {
  eyebrow: '展览装修之家 / 展览定制之家',
  title: '展览装修与展览定制的项目协作入口',
  summary:
    '聚焦展览项目展示、企业展示、项目沟通和资料协作，帮助展览项目从公开展示走向有序沟通。',
  primaryCta: { label: '联系平台', href: '/contact' },
  secondaryCta: { label: '查看能力边界', href: '#boundaries' },
  proofPoints: ['首发三楼：展览、消息、我的', '项目展示与企业展示', '资料协作与沟通入口'],
  appPreview: {
    statusTime: '02:08',
    title: '展览',
    subtitle: '发现优质项目，把握商机',
    location: '重庆南岸',
    weather: '多云 19°',
    weatherNote: '天气总体平稳，可按计划推进沟通。',
    syncLabel: '天气已同步',
    actions: ['重新定位并刷新', '手动选择地区'],
    channelTitle: '推荐频道',
    tabs: ['项目', '论坛', '公司', '工厂'],
    quickActions: ['进入项目列表', '去发布项目', '刷新'],
    projectTitle: '项目名称需申请查看',
    projectMeta: ['资料待确认', '项目沟通入口', '公开展示信息'],
    projectCta: '进入项目详情',
    bottomNav: ['展览', '消息', '我的'],
  },
};

export const trustStrip = {
  items: [
    {
      icon: 'shield',
      title: '真实项目展示',
      summary: '项目展示强调真实、清晰和边界明确。',
    },
    {
      icon: 'ticket',
      title: '资料协作共票',
      summary: '资料确认不等于成交，协作过程保持留痕。',
    },
    {
      icon: 'team',
      title: '多角色协同',
      summary: '项目发布方、承接方和展示企业各有入口。',
    },
    {
      icon: 'lock',
      title: '隐私与安全',
      summary: '资料与账号信息按平台边界受控处理。',
    },
  ],
};

export const buildings = {
  eyebrow: '首发三楼',
  title: '第一版只公开展览、消息、我的',
  summary: '装修楼、全屋定制楼和建材市场保留为后续扩展位，不在官网 V2 写成已开放。',
  items: [
    {
      title: '展览',
      summary: '承接展览项目展示、企业展示和公开入口。',
      focus: '项目与企业的公开展示层',
      icon: '展',
      tags: ['项目展示', '企业展示'],
    },
    {
      title: '消息',
      summary: '承接项目沟通、资料协作和互动入口。',
      focus: '不是泛聊天或群聊系统',
      icon: '消',
      tags: ['项目沟通', '资料协作'],
    },
    {
      title: '我的',
      summary: '聚合个人、组织、认证、项目等当前用户入口。',
      focus: '当前用户身份与资产中心',
      icon: '我',
      tags: ['身份入口', '组织入口'],
    },
  ],
};

export const features = {
  eyebrow: '核心场景',
  title: '围绕展览项目的四个核心能力',
  summary: '不做假案例、假数据或交易闭环承诺，只展示当前官网可以公开表达的协作能力。',
  items: [
    {
      icon: 'project',
      title: '项目展示',
      summary: '用清晰的项目信息承接展览装修和展览定制需求发现。',
      visualTitle: '项目卡片',
      visualLines: ['公开展示信息', '资料待确认', '进入详情'],
    },
    {
      icon: 'company',
      title: '企业展示',
      summary: '以公司、工厂、供应商等展示面呈现企业能力，公开详情与资料工作台保持分离。',
      visualTitle: '企业资料',
      visualLines: ['公司展示', '工厂展示', '供应商展示'],
    },
    {
      icon: 'message',
      title: '项目沟通',
      summary: '围绕项目推进沟通入口，不扩展成泛聊天、私聊或群聊系统。',
      visualTitle: '沟通入口',
      visualLines: ['项目提醒', '资料消息', '待办状态'],
    },
    {
      icon: 'files',
      title: '资料协作',
      summary: '把效果图、施工图、材料样板、报价资料等协作对象放在受控资料确认边界内。',
      visualTitle: '资料确认',
      visualLines: ['上传资料', '确认记录', '边界清晰'],
    },
  ],
};

export const workflow = {
  eyebrow: '工作路径',
  title: '从展示到协作的轻量路径',
  steps: [
    {
      title: '发现项目与企业',
      summary: '浏览项目展示和企业展示，找到合适的合作方向。',
    },
    {
      title: '进入项目沟通',
      summary: '围绕具体项目进入沟通入口，明确需求与资料。',
    },
    {
      title: '推进资料协作',
      summary: '在受控资料边界内完成确认与反馈。',
    },
    {
      title: '回到我的楼',
      summary: '在我的楼管理身份、组织、认证与项目入口。',
    },
  ],
};

export const capabilityBand = {
  eyebrow: '平台能力',
  items: [
    { title: '展示清晰', summary: '项目与企业展示边界明确' },
    { title: '沟通有序', summary: '围绕项目进入沟通入口' },
    { title: '资料留痕', summary: '资料协作过程保持记录' },
    { title: '边界明确', summary: '保留能力不写成已开放' },
    { title: '隐私安全', summary: '资料与账号信息受控处理' },
  ],
};

export const audience = {
  eyebrow: '适用对象',
  title: '为展览项目里的不同角色提供清晰入口',
  items: [
    {
      icon: 'owner',
      title: '项目发布方',
      summary: '需要展示项目、查看企业展示、推进资料沟通。',
    },
    {
      icon: 'builder',
      title: '承接方 / 竞标方',
      summary: '需要发现项目、整理资料、围绕项目有序沟通。',
    },
    {
      icon: 'enterprise',
      title: '展示企业',
      summary: '需要呈现公司、工厂或供应商能力，并维护展示资料。',
    },
    {
      icon: 'partner',
      title: '平台合作方',
      summary: '需要快速理解首发范围、当前边界和下一步联系路径。',
    },
  ],
};

export const boundaries = {
  eyebrow: '能力边界',
  title: '第一版官网不做无根据承诺',
  intro:
    '当前官网只表达已冻结的首发定位和有界能力。以下能力保留为后续扩展位或单独门禁事项，不写成已开放功能。',
  items: [
    '不承诺完整交易闭环。',
    '不承诺支付收款、扣费、结算、退款、钱包、保证金或发票。',
    '不承诺智能派单、AI 推荐、地图找厂或直播。',
    '不把装修楼、全屋定制楼、建材市场写成已开放。',
    '不展示虚构案例、虚构评价、虚构资质或虚构数据看板。',
  ],
};

export const finalCta = {
  eyebrow: '下一步',
  title: '先从一个展览项目场景开始沟通',
  summary:
    '如果你关注展览装修、展览定制、项目展示或企业展示，可以先联系平台确认当前适用范围。',
  primaryCta: { label: '联系平台', href: '/contact' },
  secondaryCta: { label: '查看用户协议', href: '/terms' },
};

export const footer = {
  title: '展览装修之家',
  summary: '第一版官网仅表达首发范围和能力边界，具体开放能力以 App 内实际页面和正式公告为准。',
  legal: [
    { label: '隐私政策', href: '/privacy' },
    { label: '用户协议', href: '/terms' },
    { label: '联系平台', href: '/contact' },
  ],
};

export const contactPage = {
  eyebrow: 'Contact',
  metadataTitle: '联系平台',
  metadataDescription:
    '联系展览装修之家，了解展览项目展示、企业展示、项目沟通和资料协作的当前首发范围。',
  title: '联系平台',
  summary:
    '官网 V2 阶段提供轻量联系入口，用于项目场景沟通、企业展示咨询和试用预约。',
  mailCta: '发送邮件',
  emailLabel: '客服邮箱',
  cardsAria: '联系场景',
  responseNote: '客服电话当前暂未公示，请优先通过邮箱联系。',
  cards: [
    {
      title: '项目场景沟通',
      summary: '适合希望了解项目展示、企业展示和资料协作边界的团队。',
    },
    {
      title: '企业展示咨询',
      summary: '适合关注公司、工厂、供应商展示资料维护的企业。',
    },
    {
      title: '平台合作咨询',
      summary: '适合需要确认首发三楼和后续扩展位的合作方。',
    },
  ],
};

export const legalPages = {
  privacy: {
    eyebrow: 'Privacy',
    metadataTitle: '隐私政策',
    metadataDescription:
      '展览装修之家官网隐私政策摘要，正式文本以 App 内发布版本和 docs/legal/privacy_policy.md 为准。',
    title: '隐私政策',
    summary:
      '本页为官网轻量摘要。正式隐私政策以仓库 `docs/legal/privacy_policy.md` 和 App 内发布版本为准。',
    source: 'docs/legal/privacy_policy.md',
    itemsAria: '隐私政策摘要',
    items: [
      '平台在合法、正当、必要范围内处理账号、组织、企业展示、项目协作、消息互动、文件上传和安全审计相关信息。',
      '文件上传遵循受控确认流程，业务绑定以平台正式记录和业务实体关联为准。',
      '定位与地区上下文用于地区天气、地区选择和本地化展示，不代表持续后台跟踪精确位置。',
      '未开放或需单独门禁的能力，不作为官网第一版服务承诺。',
    ],
  },
  terms: {
    eyebrow: 'Terms',
    metadataTitle: '用户协议',
    metadataDescription:
      '展览装修之家官网用户协议摘要，正式文本以 App 内发布版本和 docs/legal/user_agreement.md 为准。',
    title: '用户协议',
    summary:
      '本页为官网轻量摘要。正式用户协议以仓库 `docs/legal/user_agreement.md` 和 App 内发布版本为准。',
    source: 'docs/legal/user_agreement.md',
    itemsAria: '用户协议摘要',
    items: [
      '产品当前围绕手机号验证码登录、展览信息浏览、组织与企业展示、项目协作、消息互动和个人资料能力展开。',
      '企业入驻申请提交成功不当然意味着立即对外展示，通常仍需后台审核并完成发布上架。',
      '消息能力主要是互动提醒、实例待办和项目沟通承接，不代表自由即时通讯或站外消息送达能力。',
      '用户发布项目、资料、案例、论坛内容和附件时，应保证内容真实、合法并具备相应权利基础。',
    ],
  },
};
