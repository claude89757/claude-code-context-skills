# cc-context-skills

**[English](README.md)**

一个 Claude Code 插件，帮助你从 Claude Code 中学习上下文工程模式，并应用到自己的智能体项目中。

## 它能做什么

Claude Code 是一个生产级 AI 编程智能体，拥有精密的上下文工程机制——包括如何组织 system prompt、管理工具、控制上下文窗口、编排子智能体等。本插件通过真实 API trace 捕获这些模式，帮助你将其迁移到自己的智能体代码库。

## Skills 一览

| Skill | 用途 |
|-------|------|
| **cc-trace** | 使用 [claude-trace](https://www.npmjs.com/package/@mariozechner/claude-trace) 抓取 Claude Code 的真实 API 请求。查看 system prompt、工具定义、thinking 配置、上下文管理等。生成 Pattern Report。 |
| **cc-learn** | 从 cc-trace 报告中提取模式，整理到持久化的主题知识库（`docs/cc-patterns/`）。支持跨版本增量更新。 |
| **cc-apply** | 扫描你的智能体项目代码，与知识库对比，生成带优先级的 Gap Report 和迁移建议。 |
| **cc-verify** | 捕获你项目的运行时 API trace，验证迁移的模式是否真正生效——而不仅仅是代码中存在。 |

## 工作流程

```
cc-trace  →  cc-learn  →  cc-apply  →  cc-verify
（抓取）      （提取）      （分析）      （验证）
                             ↑            |
                             └────────────┘
                           （迭代改进）
```

每个 skill 可独立使用，也可组合形成完整的学习闭环：

- **只是好奇？** 单独运行 `cc-trace` 看看 Claude Code 发给 API 的内容。
- **已有知识库？** 直接跳到 `cc-apply`，使用之前积累的知识库分析新项目。
- **已完成迁移？** 运行 `cc-verify` 确认运行时行为符合预期。

## 安装

### 从插件市场安装（注册后）

```
claude plugin install cc-context-skills
```

### 从 GitHub 安装

1. Clone 本仓库
2. 添加为本地 marketplace：
   ```bash
   claude plugin marketplace add /path/to/claude-code-context-skills
   claude plugin install cc-context-skills
   ```

### 前置依赖

- Node.js 16+
- jq
- [claude-trace](https://www.npmjs.com/package/@mariozechner/claude-trace)（cc-trace 会自动安装）

## 快速开始

### 1. 抓取 trace

```bash
# 运行 cc-trace skill
/cc-trace
```

抓取最新版 Claude Code 的真实 API 请求，生成 Pattern Report（`cc-trace-report-YYYY-MM-DD.md`）。

### 2. 构建知识库

```bash
/cc-learn
```

读取 Pattern Report，按主题整理到 `docs/cc-patterns/`：
- `system-prompt-design.md` — System Prompt 设计
- `tool-engineering.md` — 工具工程
- `context-management.md` — 上下文管理
- `thinking-reasoning.md` — 思维推理
- `message-patterns.md` — 消息模式
- `model-routing.md` — 模型路由
- `agent-orchestration.md` — 智能体编排

### 3. 分析你的项目

```bash
/cc-apply
```

扫描你的智能体代码库，与知识库对比，输出 `docs/cc-alignment-report.md`：
- 对齐分数
- 按优先级排列的 gap 项（HIGH / MED / LOW）
- 带文件引用的具体迁移建议

### 4. 运行时验证

```bash
/cc-verify
```

捕获你项目的 API trace，检查模式是否在运行时真正体现。

## 你能学到什么

从一次 Claude Code trace 中，你可以发现以下模式：

- **System Prompt 架构** — 3 block 结构 + 选择性缓存控制
- **稳定内容前置** — 最大化 prompt 缓存命中率
- **System-Reminder 注入** — 动态上下文放在用户消息中，而非 system prompt
- **富工具描述** — 在工具定义中嵌入行为指南
- **自适应思维** — 推理深度随任务复杂度调整
- **懒加载上下文管理** — 仅在上下文窗口接近满时才激活

## 项目结构

```
.claude-plugin/
  plugin.json              # 插件元数据
skills/
  cc-trace/                # Trace 抓取与模式提取
    SKILL.md
    scripts/               # 抓取和分析脚本
    references/            # 排障和版本分析指南
  cc-learn/                # 知识库构建
    SKILL.md
    references/            # 模式分类参考
  cc-apply/                # Gap 分析与迁移
    SKILL.md
    references/            # API 迁移策略
  cc-verify/               # 运行时验证
    SKILL.md
    references/            # 验证标准
```

## 许可证

MIT
