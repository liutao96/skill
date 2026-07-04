# 抖音投流运营知识库地图

## Root

Default root on this machine:

`P:\projects-test\短视频带货项目\投流和流程运营教程\抖音运营知识库`

Override root:

`DOUYIN_TOULIU_KB_ROOT`

Portable discovery order:

1. Explicit `--kb-root` passed to `scripts/search_douyin_kb.py`.
2. User environment variable `DOUYIN_TOULIU_KB_ROOT`.
3. `抖音运营知识库` near the current working directory or the skill script path.
4. Common drive-letter candidates under `P:`, `F:`, `E:`, `D:`, `G:`.

The root may be either the knowledge-base folder itself or the project folder that contains `抖音运营知识库`.

## Coverage

- 68 course videos total.
- 55 videos from `2026R728 安琪好物2026短视频带货投流课`.
- 13 videos from `流量运营和抖加投流秘笈课`.
- 68 transcripts, 68 OCR/screenshot groups, 68 course summaries.
- 25 daily operation Q&A cards.
- One topic index and one quality-check report.

## Directory Use

- `README.md`: overall purpose, source count, and usage principles.
- `00_处理清单/`: manifest, processing state, logs, temporary audio.
- `01_课程逐字稿/`: use for original wording, source verification, or ambiguous summaries.
- `02_画面OCR与截图/`: use for backend screens, button names, setting paths, or visual evidence.
- `03_课程精华总结/`: use for lesson-level summaries, checklists, scenarios, and risks.
- `04_主题索引/主题总索引.md`: use first for broad topic routing.
- `05_日常运营问答库/`: use first for practical advice and repeated operation questions.
- `06_质量检查/2026-06-28_完整性与网上一致性检查.md`: use for completeness, risk, and currentness caveats.

## Main Q&A Cards

- 账号: `账号搭建定位橱窗涨粉_初版.md`, `账号标签十步法_初版.md`, `主页优化提升转粉率_初版.md`, `投流与账号冷启动_初版.md`, `兴趣推荐算法与账号冷启动_初版.md`
- 内容: `爆款开头与前3秒_初版.md`, `短视频图文剪辑实操_初版.md`, `挂车发布与简易剪辑_初版.md`, `原创实拍与剪辑_初版.md`, `评论互动上热门_初版.md`, `铁粉培养与评论运营_初版.md`
- 选品: `选品判断与商品数据_初版.md`
- 抖加: `抖加快速涨粉三步法_初版.md`, `抖加认知低质粉与持续投放_初版.md`, `抖加三种投法与追投_初版.md`, `抖加商业流量与自然流量_初版.md`, `抖加投放设置技巧_初版.md`
- 随心推: `随心推基础投放与数据复盘_初版.md`, `随心推手动出价与测品打法_初版.md`, `随心推测不正续费追投与素材剔除_初版.md`, `随心推老素材浇水与自动追投_初版.md`
- 千川: `千川基础建计划充值上传审核_初版.md`, `千川计划调控_初版.md`, `千川账号素材与保障_初版.md`, `千川放量授权炸素材与提佣_初版.md`

## Quality And Risk Notes

The local quality check says the knowledge base is structurally complete: 68/68 videos have transcripts, frames, OCR, and summaries, with no missing output or obvious transcript truncation.

Do not treat course material as current official policy. Backend UI,投放产品,ROI口径,成本保障,审核规则, and platform governance may change.

Treat `搬运`, `防搬运`, `炸素材`, `隐藏榜单`, and bulk low-effort remix tactics as high-risk historical course content. Reframe toward authorized material, original shooting, compliant template testing, and real data review.

## Cross-computer Use

Use the GitHub repository for the lightweight skill only. Keep the real knowledge base in the project folder or removable drive. On a new computer:

1. Clone or copy the skill repository.
2. Copy or mount the project folder that contains `抖音运营知识库`.
3. Install the skill into `%USERPROFILE%\.codex\skills\douyin-touliu-ops-kb`.
4. Set `DOUYIN_TOULIU_KB_ROOT` if the drive letter or folder layout differs.
5. Run the search script with a known query, such as `随心推 测品 ROI`.
