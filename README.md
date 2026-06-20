# Codex Study Skills

面向课程 PPT、PDF 和课堂笔记的一组 Codex 学习技能：`skill-study` 负责按课件顺序教学，`skill-mindmap` 负责把完成的章节框架转换成离线思维导图。

## 功能

- 按幻灯片或页面顺序教学，不用简短摘要代替讲解。
- 默认每次处理 3-8 页，并根据内容密度调整。
- 每个学习单元结束后生成练习题并批改答案。
- 区分课件内容与课外补充资料。
- 章节结束时生成供 `$skill-mindmap` 使用的思维导图输入大纲。
- 在每轮回复末尾记录学习进度，方便继续学习。
- 将已完成章节导出为 Markdown 和自包含的离线 Markmap HTML。

## 安装

将仓库中的两个技能目录复制到 Codex 技能目录：

```powershell
Copy-Item -Recurse -Force .\skill-study "$env:USERPROFILE\.codex\skills\skill-study"
Copy-Item -Recurse -Force .\skill-mindmap "$env:USERPROFILE\.codex\skills\skill-mindmap"
```

重新启动 Codex，使技能被重新加载。

## 使用

上传课程 PPT、PDF、课堂笔记或截图，然后调用：

```text
$skill-study SSW4353
```

也可以直接提出学习请求：

```text
请按顺序从零基础讲解这份课件，每一部分结束后给我练习题。
```

后续可以说“继续”“跳过练习”“复习第 10-18 页”或“只讲考试重点”。

章节完成后生成离线思维导图：

```text
$skill-mindmap chap3
```

思维导图生成需要本地已有 `markmap-cli`。技能不会自行下载安装依赖。

## 目录

```text
skill-study/
|-- SKILL.md
|-- agents/
|   `-- openai.yaml
`-- references/
    |-- assessment-rubric.md
    `-- teaching-workflow.md

skill-mindmap/
|-- SKILL.md
|-- agents/
|   `-- openai.yaml
`-- scripts/
    `-- generate_mindmap.ps1
```

两个 ZIP 文件是早期分发包。仓库中的展开源码是后续维护和审查的基准。

## 隐私与资料范围

课件内容始终是主要依据。技能不会在未经允许的情况下上传、发布或搜索私人课件内容；使用公开资料补充时，应明确标注“课外补充”并提供来源。
