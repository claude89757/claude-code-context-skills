# cc-context-skills

**[English](README.md)**

一个 Claude Code 插件，帮助你从 Claude Code 中学习上下文工程模式，并应用到自己的智能体项目中。

## 它能做什么

Claude Code 是一个生产级 AI 编程智能体，拥有精密的上下文工程机制——包括如何组织 system prompt、管理工具、控制上下文窗口、编排子智能体等。本插件通过真实 API trace 捕获这些模式，帮助你将其迁移到自己的智能体代码库。

## Skills 一览

| Skill | 用途 |
|-------|------|
| **cc-trace** | 使用 [claude-trace](https://www.npmjs.com/package/@mariozechner/claude-trace) 抓取 Claude Code 的真实 API 请求，保存原始 trace 数据供分析。 |
| **cc-learn** | 从原始 trace 中提取模式和原始参考素材，通过协作式对话对比你的项目代码，生成详细的改造方案（`docs/cc-context/plans/YYYY-MM-DD-migration-plan.md`）。 |
| **cc-apply** | 按改造方案逐项执行代码修改，每步完成后向用户确认。 |
| **cc-verify** | 捕获你项目的运行时 API trace，验证迁移的模式是否真正生效——而不仅仅是代码中存在。 |

## 工作流程

```
cc-trace  →  cc-learn  →  cc-apply  →  cc-verify
（抓取）      （分析        （执行）      （验证）
              + 制定方案）     ↑            |
                             └────────────┘
                           （迭代改进）
```

每个 skill 可独立使用，也可组合形成完整的学习闭环：

- **只是好奇？** 单独运行 `cc-trace` 看看 Claude Code 发给 API 的内容。
- **已有知识库？** 直接跳到 `cc-learn`，使用之前积累的知识库对比分析并制定改造方案。
- **已完成迁移？** 运行 `cc-verify` 确认运行时行为符合预期。

## 安装

### 从 GitHub 安装（推荐）

```bash
# 添加 marketplace
/plugin marketplace add claude89757/claude-code-context-skills

# 安装插件
/plugin install cc-context-skills@cc-context-skills
```

### 从本地目录安装

```bash
# 将本地 clone 的仓库添加为 marketplace
/plugin marketplace add /path/to/cc-context-skills

# 安装插件
/plugin install cc-context-skills@cc-context-skills
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

抓取最新版 Claude Code 的真实 API 请求，保存原始 trace 数据到 `docs/cc-context/traces/`。

### 2. 分析并制定改造方案

```bash
/cc-learn
```

从 trace 中提取模式和原始参考素材，通过协作式对话对比你的项目代码，生成改造方案（`docs/cc-context/plans/YYYY-MM-DD-migration-plan.md`）：
- 对齐分数
- 按优先级排列的 gap 项（HIGH / MED / LOW）
- 带文件引用的具体改造步骤

### 3. 执行改造

```bash
/cc-apply
```

读取改造方案，逐项执行代码修改，每步完成后向用户确认。

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
  cc-trace/                # Trace 抓取与原始数据存储
    SKILL.md
    scripts/               # 抓取和分析脚本
    references/            # 排障和版本分析指南
  cc-learn/                # 模式提取 + 素材整理 + 改造方案制定
    SKILL.md
    references/            # 模式分类参考
  cc-apply/                # 改造方案执行
    SKILL.md
    references/            # API 迁移策略
  cc-verify/               # 运行时验证
    SKILL.md
    references/            # 验证标准
  shared/                  # 跨 skill 共享资源
    data-contracts.md      # skill 间数据路径与格式约定
    trace-inspection.md    # 共享 jq 检查命令
```

## 许可证

MIT
